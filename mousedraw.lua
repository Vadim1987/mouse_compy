-- mousedraw.lua
-- Draws the on-screen mouse from SVG2LOVE layers.
-- Each require returns a draw function authored in a
-- 250x440 sprite box. The runtime centers, tilts,
-- scales, then stacks layers back -> front. Tintable
-- layers (buttons, wheel, logo, cheese) carry no
-- setColor; the runtime sets the color before each
-- call. The wink phases keep their own brand colors.

mouse_body = require("MOUSE_BODY")
mouse_btn_l = require("MOUSE_BTN_L")
mouse_btn_r = require("MOUSE_BTN_R")
mouse_wheel_hl = require("MOUSE_WHEEL")
mouse_logo = require("MOUSE_LOGO")
mouse_cheese = require("CHEESE")
logo_wink_0 = require("LOGO_WINK_0")
logo_wink_1 = require("LOGO_WINK_1")
logo_wink_2 = require("LOGO_WINK_2")

-- Sprite-space box the layers are authored in

SP = {
  w = 250,
  h = 440
}

-- Cheese is authored in a 254x217 box near the top

CH_BOX = {
  w = 254,
  h = 217,
  cx = 125,
  cy = 125
}

-- Set draw color from an {r, g, b} table, alpha 1

function set_color(c, a)
  gfx.setColor(c[1], c[2], c[3], a or 1)
end

-- Scale so the sprite fills MOUSE_TUNE.size_w/h of the screen

function sprite_scale()
  local sx = APP.width * MOUSE_TUNE.size_w / SP.w
  local sy = APP.height * MOUSE_TUNE.size_h / SP.h
  return math.min(sx, sy)
end

-- Highlight color for a pressed zone, else nil

-- Highlight color for a pressed zone, else nil. The
-- right zone also lights briefly on a raw-Esc click.

function btn_color(zone)
  if mm.btn[zone] then
    return LEGO[zone]
  end
  if zone == "right" and 0 < mm.right_flash then
    return LEGO.right
  end
  return nil
end

-- Blink color while the cheese delight is active

function delight_color()
  if mm.delight <= 0 then
    return nil
  end
  local t = love.timer.getTime() * DELIGHT.blink_rate
  local i = math.floor(t) % #LEGO_BLINK + 1
  return LEGO_BLINK[i]
end

-- A button's effective tint: delight overrides press

function zone_tint(zone)
  return delight_color() or btn_color(zone)
end

-- Draw one tintable zone. A pressed zone also shifts
-- down slightly; the delight blink only recolors.

function draw_zone(layer, zone)
  local tint = zone_tint(zone)
  if not tint then
    return
  end
  set_color(tint)
  if mm.btn[zone] then
    gfx.push("all")
    gfx.translate(0, MOUSE_TUNE.press_shift)
    layer()
    gfx.pop()
  else
    layer()
  end
end

-- Pick the wink phase layer from delight progress.
-- Called only while delight is active (see draw_logo_layer).

function wink_phase()
  local p = 1 - mm.delight / DELIGHT.wink_time
  if p < DELIGHT.wink_p1 then
    return logo_wink_0
  end
  if p < DELIGHT.wink_p2 then
    return logo_wink_1
  end
  return logo_wink_2
end

-- Logo: plain tinted mark, or winking during delight.
-- Wink phases are authored in a 200x250 box; shift
-- them onto the body-logo origin so the wink lands in
-- place. Phases keep their own colors (no tint).

function draw_logo_layer()
  if mm.delight <= 0 then
    set_color(LOGO_COLOR)
    mouse_logo()
  else
    gfx.push("all")
    gfx.translate(WINK_OFF.x, WINK_OFF.y)
    wink_phase()()
    gfx.pop()
  end
end

-- The MOUSE04_4/_5 layers are authored mirrored vs
-- screen sides: _4 (mouse_btn_l) covers the right half,
-- _5 (mouse_btn_r) the left. Bind by screen side, not
-- by file name, so button 1 lights the left zone.

function draw_mouse_layers()
  gfx.setColor(1, 1, 1, 1)
  mouse_body()
  draw_zone(mouse_btn_r, "left")
  draw_zone(mouse_btn_l, "right")
  draw_zone(mouse_wheel_hl, "wheel")
  draw_scroll()
  draw_logo_layer()
end

function draw_mouse_sprite()
  local s = sprite_scale()
  local push = (0 < mm.bump) and bump_push() or 0
  gfx.push("all")
  gfx.translate(mm.x, mm.y - push)
  gfx.rotate(mm.tilt)
  gfx.scale(s, s)
  gfx.translate(-SP.w / 2, -SP.h / 2)
  draw_mouse_layers()
  gfx.pop()
end

-- Small recoil offset during a wall/barrier bump

function bump_push()
  local p = mm.bump / BUMP.time
  return math.sin(p * math.pi) * BUMP.recoil
end

-- Wheel scroll: 3 pellets wrapping in the window,
-- plus a direction arrow above or below. Drawn in
-- sprite space (window from the MOUSE04 layout).

function pellet_y(i)
  local off = mm.wheel * WHEEL_WIN.gap
  local y = off + i * WHEEL_WIN.gap
  return WHEEL_WIN.win_y + (y % WHEEL_WIN.win_h)
end

function draw_pellets()
  set_color(WHEEL_WIN.pel_c)
  for i = 0, WHEEL.pellets - 1 do
    local y = pellet_y(i)
    gfx.rectangle("fill", WHEEL_WIN.win_x, y,
      WHEEL_WIN.pel_w, WHEEL_WIN.pel_h,
      WHEEL_WIN.pel_r, WHEEL_WIN.pel_r)
  end
end

-- Arrow triangle above (dir<0) or below (dir>0)

function scroll_arrow(dir)
  local cx = WHEEL_WIN.win_x + WHEEL_WIN.pel_w / 2
  local ay = (dir < 0) and WHEEL_ARR.arr_up
    or WHEEL_ARR.arr_dn
  local h = WHEEL_ARR.arr_h * dir
  set_color(WHEEL_ARR.arr_c)
  gfx.polygon("fill", cx, ay + h,
    cx - WHEEL_ARR.arr_w / 2, ay,
    cx + WHEEL_ARR.arr_w / 2, ay)
end

function draw_scroll()
  draw_pellets()
  if WHEEL.eps < math.abs(mm.wheel_vel) then
    scroll_arrow(mm.wheel_vel < 0 and -1 or 1)
  end
end

-- Cheese prop: tinted yellow, centered and scaled to
-- CHEESE.size. Called by meet.lua in world space.

function cheese_sprite()
  local s = CHEESE.size / CH_BOX.w
  gfx.push("all")
  gfx.scale(s, s)
  gfx.translate(-CH_BOX.cx, -CH_BOX.cy)
  set_color(LEGO.cheese)
  mouse_cheese()
  gfx.pop()
end

-- Barrier stays procedural: a rounded bar in the
-- barrier's local frame (meet.lua sets the transform).

function barrier_sprite(alpha)
  local l, t = barrier.len, barrier.thick
  set_color(BARRIER.color, alpha)
  gfx.rectangle("fill", -l / 2, -t / 2, l, t, t / 3)
end
