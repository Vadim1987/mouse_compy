-- find.lua
-- Mini-game 2: Find the glowing circle.
-- A glowing target sits on a dark field; the child moves
-- the visible pointer into it (no clicking). On entry the
-- target warms and a bell plays; after the notch's spawn
-- pause it cross-fades to a new target elsewhere, at least
-- the relocation distance away. Difficulty rides the
-- shared notch mechanism (notch_level / notch_report).

require("pointer")

find = {
  notched = true
}

-- Circle and run state. Reset fully on enter.

fc = {
  x = 0,
  y = 0,
  r = 0,
  phase = "live",
  age = 0,
  warm = 0,
  won_t = 0,
  swap_t = 0,
  alpha = 1,
  struggled = false,
  new_x = 0,
  new_y = 0,
  new_r = 0,
  new_alpha = 0,
  px = 0,
  py = 0
}

function find_row()
  return FIND_NOTCH[notch_level("find")]
end

-- Circle radius for a notch row, clamped to the floor

function find_radius(row)
  local d = math.max(row.size * APP.width, FIND.min_px)
  return d / 2
end

-- Edge-rule margin for a center sample: keep the circle
-- on screen, and off the edges unless the notch allows it.

function find_margin(r, edge)
  if edge then
    return r
  end
  return math.max(FIND.edge_frac * APP.width, r)
end

function find_sample(r, edge)
  local m = find_margin(r, edge)
  local x = rand_range(m, APP.width - m)
  local y = rand_range(m, APP.height - m)
  return x, y
end

-- Sample a center at least the notch relocation distance
-- from the current one.

function find_far_point(r, row)
  local need = row.reloc * APP.width
  while true do
    local x, y = find_sample(r, row.edge)
    local dx, dy = x - fc.x, y - fc.y
    if need * need <= dx * dx + dy * dy then
      return x, y
    end
  end
end

-- Make (x, y) the live target with radius r

function find_spawn(x, y, r)
  fc.x, fc.y, fc.r = x, y, r
  fc.phase = "live"
  fc.age = 0
  fc.warm = 0
  fc.won_t = 0
  fc.swap_t = 0
  fc.alpha = 1
  fc.struggled = false
end

function find.enter()
  sync_screen()
  love.mouse.setRelativeMode(false)
  love.mouse.setVisible(false)
  fc.px, fc.py = love.mouse.getPosition()
  local row = find_row()
  local r = find_radius(row)
  local x, y = find_sample(r, row.edge)
  find_spawn(x, y, r)
end

function find.leave()
  love.mouse.setVisible(true)
end

-- Pointer inside the live target?

function find_inside()
  local dx, dy = fc.px - fc.x, fc.py - fc.y
  return dx * dx + dy * dy <= fc.r * fc.r
end

-- Score the spawn on entry: clean within the window, else
-- neutral (unless a struggle already fired this spawn).

function find_resolve()
  if fc.age <= FIND.clean_t then
    notch_report("find", "clean")
  elseif not fc.struggled then
    notch_report("find", "neutral")
  end
end

-- Pointer entered: warm up, score it, play the bell

function find_enter_circle()
  fc.phase = "won"
  fc.won_t = 0
  find_resolve()
  play(SND.bell)
end

-- Live: age the target, detect entry, fire struggle once

function find_live(dt)
  fc.age = fc.age + dt
  if find_inside() then
    find_enter_circle()
  elseif not fc.struggled and FIND.struggle_t <= fc.age then
    fc.struggled = true
    notch_report("find", "struggle")
  end
end

-- Won: cool->warm transition, then start the swap once the
-- notch spawn pause (bell-to-next-circle delay) elapses.

function find_won(dt)
  fc.won_t = fc.won_t + dt
  fc.warm = math.min(1, fc.won_t / FIND.warm_t)
  local row = find_row()
  if row.pause <= fc.won_t then
    find_start_swap(row)
  end
end

function find_start_swap(row)
  local r = find_radius(row)
  fc.new_x, fc.new_y = find_far_point(r, row)
  fc.new_r = r
  fc.new_alpha = 0
  fc.phase = "swap"
  fc.swap_t = 0
end

-- Swap: old fades out as the new fades in; the new target
-- then becomes the live one.

function find_swap(dt)
  fc.swap_t = fc.swap_t + dt
  local t = math.min(1, fc.swap_t / FIND.fade_t)
  fc.alpha = 1 - t
  fc.new_alpha = t
  if FIND.fade_t <= fc.swap_t then
    find_spawn(fc.new_x, fc.new_y, fc.new_r)
  end
end

PHASE = {
  live = find_live,
  won = find_won,
  swap = find_swap
}

function find.update(dt)
  fc.px, fc.py = love.mouse.getPosition()
  PHASE[fc.phase](dt)
end

-- Drawing

function mix_rgb(a, b, t)
  return {
    a[1] + (b[1] - a[1]) * t,
    a[2] + (b[2] - a[2]) * t,
    a[3] + (b[3] - a[3]) * t
  }
end

-- Pulsing glow factor in 0..1, period FIND.pulse

function find_glow()
  local t = love.timer.getTime() / FIND.pulse
  return 0.5 + 0.5 * math.sin(t * 2 * math.pi)
end

-- A target: a soft pulsing halo plus a solid core

function find_circle(x, y, r, color, alpha)
  local g = find_glow()
  set_color(color, alpha * (0.25 + 0.3 * g))
  gfx.circle("fill", x, y, r * (1 + 0.22 * g))
  set_color(color, alpha)
  gfx.circle("fill", x, y, r)
end

function find_draw_current()
  local color = mix_rgb(FIND_COOL, FIND_WARM, fc.warm)
  find_circle(fc.x, fc.y, fc.r, color, fc.alpha)
end

function find.draw()
  gfx.clear(FIND_BG)
  find_draw_current()
  if fc.phase == "swap" then
    find_circle(fc.new_x, fc.new_y, fc.new_r,
      FIND_COOL, fc.new_alpha)
  end
  draw_pointer(fc.px, fc.py)
end
