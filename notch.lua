-- notch.lua
-- Shared difficulty-notch mechanism for skill-based
-- mini-games (find, pop). A game opts in with g.notched;
-- Meet the mouse does not, so chords are a no-op there.
--
-- The notch LEVEL persists across menu exit and reenter
-- and is the only state that survives a mini-game reset.
-- Streaks and the cooldown are run state, cleared on each
-- enter. Auto-match (notch_report) bumps the level once a
-- clean/struggle streak is reached and the cooldown has
-- elapsed; teacher chords (notch_teacher) bypass the
-- cooldown. Any level change resets both streaks.

NOTCH_LEVEL = { }
NOTCH_RUN = { }

-- Zero every notched game's level at program start

function notch_init()
  for _, entry in ipairs(GAMES) do
    if games[entry.mod].notched then
      NOTCH_LEVEL[entry.mod] = 0
    end
  end
end

-- Fresh run state on enter; the level is left untouched

function notch_enter(name)
  NOTCH_RUN[name] = {
    clean = 0,
    struggle = 0,
    cool = 0
  }
end

function notch_level(name)
  return NOTCH_LEVEL[name]
end

-- Shift the level by dir, clamped. On a real change,
-- reset streaks and restart the cooldown. Used by both
-- auto-match and teacher chords.

function notch_shift(name, dir)
  local v = clamp(NOTCH_LEVEL[name] + dir, NOTCH.min, NOTCH.max)
  if v == NOTCH_LEVEL[name] then
    return
  end
  NOTCH_LEVEL[name] = v
  local run = NOTCH_RUN[name]
  run.clean = 0
  run.struggle = 0
  run.cool = NOTCH.cooldown
end

-- Auto-shift if a streak threshold is met and the
-- cooldown since the last shift has elapsed.

function notch_try_auto(name)
  local run = NOTCH_RUN[name]
  if 0 < run.cool then
    return
  end
  if NOTCH.up_streak <= run.clean then
    notch_shift(name, 1)
  elseif NOTCH.down_streak <= run.struggle then
    notch_shift(name, -1)
  end
end

-- A mini-game reports each target outcome: "clean",
-- "struggle", or "neutral". Clean and struggle each reset
-- the opposite streak; neutral (a late but valid success)
-- only breaks the clean streak.

function notch_report(name, result)
  local run = NOTCH_RUN[name]
  if result == "clean" then
    run.clean = run.clean + 1
    run.struggle = 0
  elseif result == "struggle" then
    run.struggle = run.struggle + 1
    run.clean = 0
  else
    run.clean = 0
  end
  notch_try_auto(name)
end

-- Bleed the cooldown for the active notched game

function notch_tick_active(dt)
  local g = active_game()
  if not (g and g.notched) then
    return
  end
  local run = NOTCH_RUN[GS.active]
  run.cool = math.max(0, run.cool - dt)
end

-- Ctrl+Alt+Up / Down: one notch harder / easier on the
-- active game, bypassing the cooldown. No-op when the
-- active game does not use notches (e.g. Meet the mouse).

function notch_teacher(dir)
  local g = active_game()
  if not (g and g.notched) then
    return
  end
  notch_shift(GS.active, dir)
end
