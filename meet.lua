-- meet.lua
-- Mini-game 1: Meet the mouse.
-- Contains the whole mini-game: state, motion, sounds,
-- input, cheese placement, barrier, and the cheese
-- delight effect. 

require("mousedraw")

cheese = {
  x = 0,
  y = 0,
  active = false,
  searching = false,
  min_d = 0
}

-- Screen diagonal in pixels

function screen_diag()
  local w, h = APP.width, APP.height
  return math.sqrt(w * w + h * h)
end

-- Begin a fresh search; mouse loses its cheese

function cheese_take()
  cheese.active = false
end

function cheese_respawn()
  cheese.searching = true
  cheese.min_d = screen_diag() * CHEESE.min_diag_frac
end

-- A point is legal if far enough from the mouse, off
-- the margin, and clear of the barrier (if present).

function cheese_legal(x, y)
  local dx, dy = x - mm.x, y - mm.y
  if dx * dx + dy * dy < cheese.min_d * cheese.min_d then
    return false
  end
  if barrier_hit(x, y) then
    return false
  end
  return true
end

-- Sample one random point inside the screen margin

-- Sample a point the mouse center can actually reach:
-- inside the same wall-clamped rectangle, so the cheese
-- never lands in the half-sprite dead band at the edges.

function cheese_sample()
  local hx, hy = mm_half()
  local x = rand_range(hx, APP.width - hx)
  local y = rand_range(hy, APP.height - hy)
  return x, y
end

-- Run a few tries this frame; relax distance on miss

function cheese_progress()
  if not cheese.searching then
    return
  end
  for _ = 1, CHEESE.tries_per_frame do
    local x, y = cheese_sample()
    if cheese_legal(x, y) then
      cheese.x, cheese.y = x, y
      cheese.active = true
      cheese.searching = false
      return
    end
  end
  cheese.min_d = cheese.min_d * CHEESE.relax
end

-- Overlap test against the mouse center

-- Cheese is caught when the mouse's reach (a fraction
-- of its half-extent) plus the cheese radius covers the
-- gap between centers, not only when centers nearly meet.

function cheese_overlap(x, y)
  if not cheese.active then
    return false
  end
  local hx, hy = mm_half()
  local reach = math.min(hx, hy) * MOUSE_TUNE.catch_frac
  local r = reach + CHEESE.size / 2
  local dx, dy = x - cheese.x, y - cheese.y
  return dx * dx + dy * dy < r * r
end

function cheese_draw()
  if not cheese.active then
    return
  end
  gfx.push("all")
  gfx.translate(cheese.x, cheese.y)
  cheese_sprite()
  gfx.pop()
end

barrier = {
  active = false,
  angle = 0,
  len = 0,
  thick = 0,
  x = 0,
  y = 0,
  alpha = 0,
  fade_dir = 0,
  shaped = false,
  swap_x = 0,
  swap_y = 0
}

function barrier_clear()
  barrier.active = false
  barrier.shaped = false
  barrier.alpha = 0
end

-- Sample orientation and length once for the session

-- Max bar length whose rotated bbox fits a screen
-- fraction along one axis. cos/sin pick the axis.

function len_cap(limit, along, across)
  if along <= 0 then
    return limit
  end
  return (limit - barrier.thick * across) / along
end

-- Sample orientation once; length = largest value
-- that meets the width, height, and area envelope.

function barrier_shape()
  barrier.angle = rand_range(0, math.pi / 2)
  barrier.thick = APP.width * BARRIER.thick_frac
  local c, s = math.cos(barrier.angle), math.sin(barrier.angle)
  local lw = len_cap(APP.width * BARRIER.bbox_w_frac, c, s)
  local lh = len_cap(APP.height * BARRIER.bbox_h_frac, s, c)
  local la = APP.width * APP.height * BARRIER.area_frac
  barrier.len = math.min(lw, lh, la / barrier.thick)
  barrier.shaped = true
end

-- Pick a legal center: bbox inside the margin, not
-- over the mouse. Resample on overlap.

function barrier_place(px, py)
  local m = APP.width * BARRIER.margin
  for _ = 1, BARRIER.place_tries do
    local x = rand_range(m, APP.width - m)
    local y = rand_range(m, APP.height - m)
    if not barrier_point(x, y, px, py) then
      barrier.x, barrier.y = x, y
      return
    end
  end
  barrier.x, barrier.y = APP.width / 2, APP.height / 2
end

-- True if (px,py) lands within the bar at center x,y

function barrier_local(px, py, cx, cy)
  local dx, dy = px - cx, py - cy
  local a = -barrier.angle
  local c, s = math.cos(a), math.sin(a)
  local lx = dx * c - dy * s
  local ly = dx * s + dy * c
  return math.abs(lx) <= barrier.len / 2
       and math.abs(ly) <= barrier.thick / 2
end

function barrier_point(x, y, px, py)
  return barrier_local(px, py, x, y)
end

-- Hit test for the mouse against the live barrier

function barrier_hit(px, py)
  if not barrier.active then
    return false
  end
  return barrier_local(px, py, barrier.x, barrier.y)
end

-- Called on each cheese: appear or swap on schedule

-- First appearance fades in; a later swap fades the
-- old bar out, then in at its new spot (in barrier_fade).

function barrier_on_cheese(count, px, py)
  if count < BARRIER.first_cheese then
    return
  end
  local after = count - BARRIER.first_cheese
  if after % BARRIER.swap_every ~= 0 then
    return
  end
  if not barrier.active then
    barrier_appear(px, py)
  else
    barrier_start_swap(px, py)
  end
end

-- Place the first barrier and fade it in

function barrier_appear(px, py)
  if not barrier.shaped then
    barrier_shape()
  end
  barrier_place(px, py)
  barrier.active = true
  barrier.fade_dir = 1
end

-- Begin a swap: remember the spot, fade the old out

function barrier_start_swap(px, py)
  barrier.swap_x = px
  barrier.swap_y = py
  barrier.fade_dir = -1
end

-- Fade alpha during the cheese pause

-- Drive the fade. fade_dir +1 fades in; -1 fades out,
-- and at zero it repositions and flips to fade in.

function barrier_fade(dt)
  if barrier.fade_dir == 0 then
    return
  end
  local step = dt / BARRIER.fade * barrier.fade_dir
  barrier.alpha = clamp(barrier.alpha + step, 0, 1)
  if barrier.fade_dir == 1 and barrier.alpha >= 1 then
    barrier.fade_dir = 0
  elseif barrier.fade_dir == -1 and barrier.alpha <= 0 then
    barrier_place(barrier.swap_x, barrier.swap_y)
    barrier.fade_dir = 1
  end
end

function barrier_draw()
  if not barrier.active then
    return
  end
  gfx.push("all")
  gfx.translate(barrier.x, barrier.y)
  gfx.rotate(barrier.angle)
  barrier_sprite(barrier.alpha)
  gfx.pop()
end

meet = { }

-- Mutable state. Reset fully on enter.

mm = {
  x = 0,
  y = 0,
  tilt = 0,
  move_dir = 0,
  speed = 0,
  pause = 0,
  bump = 0,
  move_snd = 0,
  hit_snd = 0,
  wheel = 0,
  wheel_vel = 0,
  btn = { },
  cheese_count = 0,
  delight = 0
}

-- Sprite half-extents in screen pixels

function mm_half()
  local s = sprite_scale()
  return SP.w * s / 2, SP.h * s / 2
end

-- Lifecycle

-- Zero the per-run sound and motion timers

function reset_mm_timers()
  mm.cheese_count = 0
  mm.delight = 0
  mm.cheese_echo = 0
  mm.right_flash = 0
  mm.hit_snd = 0
  mm.move_snd = 0
  mm.speed = 0
  mm.move_dir = 0
end

-- Match APP to the real window so the playfield fills
-- the screen on any device, not a fixed 800x480.

function sync_screen()
  APP.width, APP.height = love.graphics.getDimensions()
end

function meet.enter()
  sync_screen()
  mm.x = APP.width / 2
  mm.y = APP.height / 2
  mm.tilt = 0
  mm.pause = 0
  mm.bump = 0
  mm.wheel = 0
  mm.wheel_vel = 0
  mm.btn = { }
  reset_mm_timers()
  barrier_clear()
  cheese_respawn()
  love.mouse.setVisible(false)
  love.mouse.setRelativeMode(true)
end

function meet.leave()
  love.mouse.setRelativeMode(false)
  love.mouse.setVisible(true)
end

-- Clamp the mouse center to the playfield walls.
-- Returns true if a wall was touched.

function clamp_walls()
  local hx, hy = mm_half()
  local nx = clamp(mm.x, hx, APP.width - hx)
  local ny = clamp(mm.y, hy, APP.height - hy)
  local hit = (nx ~= mm.x) or (ny ~= mm.y)
  mm.x, mm.y = nx, ny
  return hit
end

-- Apply a pointer delta with light smoothing

function apply_delta(dx, dy)
  mm.x = mm.x + dx * MOUSE_TUNE.smooth
  mm.y = mm.y + dy * MOUSE_TUNE.smooth
  mm.speed = math.sqrt(dx * dx + dy * dy) / MOUSE_TUNE.smooth
end

-- Start a bump (squash) response on contact

function start_bump()
  mm.bump = BUMP.time
end

-- React to wall or barrier contact

function on_contact()
  start_bump()
  mm.hit_snd = play_gated(SND.hit, mm.hit_snd,
       MOVE_SND.hit_gap)
end

-- Pointer input (only while not paused)

function meet_moved(dx, dy)
  if 0 < mm.pause then
    return
  end
  local ox, oy = mm.x, mm.y
  apply_delta(dx, dy)
  if MOUSE_TUNE.jitter < mm.speed then
    mm.move_dir = math.atan2(dy, dx)
  end
  local wall = clamp_walls()
  if barrier_hit(mm.x, mm.y) then
    mm.x, mm.y = ox, oy
    on_contact()
  elseif wall then
    on_contact()
  end
end

-- Update: tilt toward travel, bump decay, sounds

function update_tilt(dt)
  local target = 0
  if MOUSE_TUNE.jitter < mm.speed then
    target = math.cos(mm.move_dir) * MOUSE_TUNE.tilt_max
  end
  local k = math.min(1, MOUSE_TUNE.tilt_rate * dt)
  mm.tilt = mm.tilt + (target - mm.tilt) * k
end

-- Movement-sound cadence scales with speed

function move_gap()
  local t = math.min(1, mm.speed / MOVE_SND.fast_speed)
  return MOVE_SND.slow + (MOVE_SND.fast - MOVE_SND.slow) * t
end

function update_move_snd(dt)
  mm.move_snd = mm.move_snd - dt
  if MOUSE_TUNE.jitter < mm.speed and mm.move_snd <= 0 then
    play(SND.move)
    mm.move_snd = move_gap()
  end
end

-- Wheel scroll spins down over time

function update_wheel(dt)
  mm.wheel = (mm.wheel + mm.wheel_vel * dt) % 1
  local k = math.min(1, WHEEL.decay * dt)
  mm.wheel_vel = mm.wheel_vel - mm.wheel_vel * k
end

-- Decay per-frame timers and bleed off speed

function update_timers(dt)
  mm.bump = math.max(0, mm.bump - dt)
  mm.hit_snd = math.max(0, mm.hit_snd - dt)
  mm.right_flash = math.max(0, mm.right_flash - dt)
  mm.speed = mm.speed * MOUSE_TUNE.speed_decay
end

function meet.update(dt)
  if 0 < mm.pause then
    update_pause(dt)
    return
  end
  cheese_progress()
  if cheese_overlap(mm.x, mm.y) then
    on_cheese()
  end
  update_tilt(dt)
  update_move_snd(dt)
  update_wheel(dt)
  update_timers(dt)
end

-- Cheese delight: pause, sound, blink, wink, respawn

function on_cheese()
  mm.pause = CHEESE.pause
  mm.delight = CHEESE.pause
  play_cheese()
  mm.cheese_count = mm.cheese_count + 1
  cheese_take()
  barrier_on_cheese(mm.cheese_count, mm.x, mm.y)
end

-- During the pause, run blink/wink, then respawn once

function update_pause(dt)
  mm.pause = math.max(0, mm.pause - dt)
  mm.delight = math.max(0, mm.delight - dt)
  drain_cheese_echo(dt)
  barrier_fade(dt)
  if mm.pause <= 0 then
    cheese_respawn()
  end
end

-- Fire the deferred second cheese sound once its
-- gap elapses (armed by play_cheese).

function drain_cheese_echo(dt)
  if mm.cheese_echo <= 0 then
    return
  end
  mm.cheese_echo = mm.cheese_echo - dt
  if mm.cheese_echo <= 0 then
    play(SND.cheese)
  end
end

-- Button / wheel-click highlight via dispatch

BTN_OF = {
  [1] = "left",
  [2] = "right",
  [3] = "wheel",
  l = "left",
  r = "right",
  m = "wheel",
  left = "left",
  right = "right",
  middle = "wheel"
}

WHEEL_OF = {
  [4] = 1,
  [5] = -1,
  wu = 1,
  wd = -1,
  wheelup = 1,
  wheeldown = -1
}

function meet_pressed(button)
  local dy = WHEEL_OF[button]
  if dy then
    meet_wheel(dy)
    return
  end
  local zone = BTN_OF[button]
  if zone then
    mm.btn[zone] = true
    if zone == "right" then
      mm.right_flash = BUMP.right_flash
    end
    play(SND.click)
  end
end

function meet_released(button)
  local zone = BTN_OF[button]
  if zone then
    mm.btn[zone] = false
  end
end

-- Right-click arrives as raw Esc 

function meet_right()
  mm.right_flash = BUMP.right_flash
  play(SND.click)
end

function meet_wheel(dy)
  mm.wheel_vel = mm.wheel_vel + dy * WHEEL.scroll_rate
end

-- Input methods for the generic dispatch in main.
-- A mini-game implements only the events it uses;
-- the rest are nil and silently ignored.

meet.moved = meet_moved
meet.pressed = meet_pressed
meet.released = meet_released
meet.wheel = meet_wheel
meet.right = meet_right

function meet.draw()
  gfx.clear(MOUSE_BG)
  cheese_draw()
  barrier_draw()
  draw_mouse_sprite()
end
