-- main.lua
-- Mouse program: a menu of mouse mini-games.
-- Holds the shared infrastructure (sound palette and
-- the mini-game menu) plus app state and LOVE
-- callbacks. Each mini-game lives in its own file.

require("constants")

gfx = love.graphics

-- Event -> logical sound name

SND = {
  move = "step",
  hit = "knock",
  cheese = "powerup",
  click = "win"
}

-- Local files shipped with the game, by logical name.
-- Filenames stay as delivered until the names are
-- renamed in the standard lib (step, powerup).
-- knock and win already live in the standard lib.

LOCAL_SND = {
  step = "snd/footsteps-5.ogg",
  powerup = "snd/powerup-8.ogg"
}

local_cache = { }

-- Resolve a name to a playable source

function get_local(name)
  local src = local_cache[name]
  if src then
    return src
  end
  src = love.audio.newSource(LOCAL_SND[name], "static")
  local_cache[name] = src
  return src
end

function play_local(name)
  local src = get_local(name)
  src:stop()
  love.audio.play(src)
end

-- Standard-lib sound if present, else local file

function play(name)
  local fn = compy.audio[name]
  if fn then
    fn()
  elseif LOCAL_SND[name] then
    play_local(name)
  end
end

-- Rate-limited play, keyed by event. Returns the new
-- timer so callers can store it back.

function play_gated(name, timer, gap)
  if 0 < timer then
    return timer
  end
  play(name)
  return gap
end

-- Cheese sound: play now, optionally arm a second
-- play after a short gap (drained in update_pause).
-- Set CHEESE.twice = false if the echo feels laggy.

function play_cheese()
  play(SND.cheese)
  if CHEESE.twice then
    mm.cheese_echo = CHEESE.echo_gap
  end
end

-- Built mini-games, in display order. Only games that
-- exist in the build are listed; unbuilt ones are
-- simply absent (no disabled placeholders).

GAMES = {
  { key = "1", name = "Meet the mouse", mod = "meet" }
}

-- Menu lifecycle hooks. The menu is static, so these
-- are intentional no-ops; they mirror the game
-- lifecycle and give later menus a place to grow.

function menu_init()
end

function menu_update(dt)
end

-- Draw one numbered line

function draw_menu_line(i, entry)
  local y = MENU.y + (i - 1) * MENU.line_h
  gfx.setColor(COLOR_FG)
  gfx.print(entry.key .. ".  " .. entry.name, MENU.x, y)
end

function menu_draw()
  gfx.clear(COLOR_BG)
  gfx.setColor(COLOR_DIM)
  gfx.print("Mouse Games", MENU.x, MENU.title_y)
  for i, entry in ipairs(GAMES) do
    draw_menu_line(i, entry)
  end
end

-- Digit launches the matching built game

function menu_key(k)
  for _, entry in ipairs(GAMES) do
    if entry.key == k then
      open_game(entry.mod)
      return
    end
  end
end

require("meet")

-- App state. mode is "menu" or "game"; active is the
-- module name of the running mini-game.

GS = {
  init = false,
  mode = "menu",
  active = nil,
  focused = true
}

games = {
  meet = meet
}

-- Shared helpers

function clamp(value, lo, hi)
  return math.max(lo, math.min(value, hi))
end

function rand_range(lo, hi)
  return lo + love.math.random() * (hi - lo)
end

-- Game control

function open_game(name)
  GS.active = name
  GS.mode = "game"
  games[name].enter()
end

function close_game()
  games[GS.active].leave()
  GS.active = nil
  GS.mode = "menu"
end

function ensure_init()
  if GS.init then
    return
  end
  menu_init()
  GS.init = true
end

-- Shift state for the reset chord

function shift_down()
  local d = love.keyboard.isDown
  return d("lshift") or d("rshift")
end

function ctrl_down()
  local d = love.keyboard.isDown
  return d("lctrl") or d("rctrl")
end


-- Main loop

-- Focus loss freezes the game and shows a calm
-- message; regaining focus resumes where it left off.

function love.focus(f)
  GS.focused = f
end

function love.update(dt)
  ensure_init()
  if not GS.focused then
    return
  end
  if GS.mode == "game" then
    games[GS.active].update(dt)
  else
    menu_update(dt)
  end
end

-- Dim the last frame and show the reconnect message.
-- Reads the window directly so it works before a game
-- has filled APP (e.g. focus lost on the menu).

function draw_reconnect()
  local w, h = love.graphics.getDimensions()
  gfx.setColor(0, 0, 0, RECONNECT.dim)
  gfx.rectangle("fill", 0, 0, w, h)
  gfx.setColor(COLOR_BG)
  gfx.print(RECONNECT.text, RECONNECT.x, RECONNECT.y)
end

function love.draw()
  if GS.mode == "game" then
    games[GS.active].draw()
  else
    menu_draw()
  end
  if not GS.focused then
    draw_reconnect()
  end
end

-- Input is dispatched to the active game. A game
-- implements only the handlers it needs; missing
-- ones mean the event is ignored.

function active_game()
  if GS.mode == "game" then
    return games[GS.active]
  end
  return nil
end

function love.mousemoved(x, y, dx, dy)
  local g = active_game()
  if g and g.moved then
    g.moved(dx, dy)
  end
end

function love.mousepressed(x, y, button)
  local g = active_game()
  if g and g.pressed then
    g.pressed(button)
  end
end

function love.mousereleased(x, y, button)
  local g = active_game()
  if g and g.released then
    g.released(button)
  end
end

function love.wheelmoved(x, y)
  local g = active_game()
  if g and g.wheel then
    g.wheel(y)
  end
end

-- Raw Esc is right-click; Shift+Esc is the
-- back-to-menu chord. Ctrl+Esc is never bound here.

function handle_escape()
  local g = active_game()
  if ctrl_down() then
    return
  elseif shift_down() then
    close_game()
  elseif g and g.right then
    g.right()
  end
end

function love.keypressed(k)
  if k == "escape" then
    if GS.mode == "game" then
      handle_escape()
    end
    return
  end
  if GS.mode == "menu" then
    menu_key(k)
  end
end
