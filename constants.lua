-- constants.lua

-- App layout. Size is read from the real window at
-- game start (sync_screen); declared empty here.

APP = { }

COMPY_SCREEN = {
  w = 1024,
  h = 600
}

-- Menu chrome

COLOR_BG = {
  0.95,
  0.95,
  0.92
}
COLOR_FG = {
  0.15,
  0.15,
  0.15
}
COLOR_DIM = {
  0.55,
  0.55,
  0.55
}

MENU = {
  x = 240,
  y = 170,
  title_y = 110,
  line_h = 44
}

-- Calm overlay shown when focus or input is lost

RECONNECT = {
  text = "Paused - move the mouse to continue",
  x = 200,
  y = 220,
  dim = 0.7
}

-- Compy LEGO palette (per-button) from COMPY_colors.

LEGO = {
  left = {
    0,
    0.129,
    0.863
  },
  right = {
    0.059,
    0.914,
    0.627
  },
  wheel = {
    0.918,
    0.337,
    0.439
  },
  cheese = {
    1,
    0.804,
    0
  }
}

-- Base logo mark: monochrome gray on the body. Turns
-- colorful (the winking brand mark) on cheese delight.

LOGO_COLOR = {
  0.45,
  0.45,
  0.45
}

-- Offset to place the 200x250 wink phases onto the
-- body-logo origin (MOUSE04_7). Same size, shift only.

WINK_OFF = {
  x = 25,
  y = 163
}

-- LEGO blink cycle for the cheese delight effect.
-- Built from LEGO so the colors live in one place.

LEGO_BLINK = {
  LEGO.left,
  LEGO.right,
  LEGO.wheel,
  LEGO.cheese
}

-- Meet playfield: quiet light-colored field.

MOUSE_BG = {
  0.94,
  0.98,
  0.96
}

-- size: fraction of screen; tilt: max body lean (rad).
-- smooth: follow lerp factor per frame.

MOUSE_TUNE = {
  size_w = 0.2,
  size_h = 0.31,
  tilt_max = 8 * math.pi / 180,
  tilt_rate = 8,
  smooth = 1,
  jitter = 1.5,
  speed_decay = 0.5,
  press_shift = 4,
  catch_frac = 0.5
}

-- Wall/barrier bump response. right_flash: how long the
-- right zone lights after a raw-Esc right-click, which
-- has no matching release event.

BUMP = {
  time = 0.12,
  recoil = 6,
  right_flash = 0.3
}

-- Button press glow: rate eases mm.glow toward the
-- pressed state; add is the additive glow strength;
-- eps is the alpha below which the zone is skipped.

GLOW = {
  rate = 12,
  add = 0.5,
  eps = 0.02
}

-- Soft shadow under the mouse. rx/ry are fractions of
-- the sprite half-width; dy drops it toward the base
-- as a fraction of the sprite half-height.

SHADOW = {
  c = {
    0,
    0,
    0
  },
  alpha = 0.04,
  rx = 0.95,
  ry = 0.28,
  dy = 0.8
}

-- Movement sound cadence (seconds between ticks)

MOVE_SND = {
  slow = 0.7,
  fast = 0.25,
  fast_speed = 600,
  hit_gap = 0.4
}

-- Wheel scroll motion (pellets wrap in the window)

WHEEL = {
  pellets = 3,
  scroll_rate = 40,
  decay = 3,
  eps = 2
}

-- Wheel window and pellet geometry (sprite space)

WHEEL_WIN = {
  pel_x = 114.36,
  pel_w = 21.275,
  pel_h = 5.331,
  pel_r = 2.5,
  band_top = 63.15,
  band_h = 62.7,
  pel_c = {
    0.2,
    0.2,
    0.2
  }
}

-- Scroll direction arrow above/below the window

WHEEL_ARR = {
  arr_up = 60,
  arr_dn = 128,
  arr_h = 10,
  arr_w = 22,
  arr_c = {
    0.059,
    0.914,
    0.627
  }
}

-- Cheese: size, pause, respawn distance rule

CHEESE = {
  size = 48,
  pause = 0.5,
  min_diag_frac = 1 / 3,
  margin_frac = 0.02,
  tries_per_frame = 8,
  twice = true,
  echo_gap = 0.12
}

-- Cheese delight effect timings.
-- wink_p1/p2: progress thresholds between the three
-- wink phases (neutral, half, closed).

DELIGHT = {
  blink_rate = 12,
  wink_time = 0.3,
  wink_p1 = 1 / 3,
  wink_p2 = 2 / 3
}

-- Barrier envelope and placement (sampled per session)

BARRIER = {
  first_cheese = 5,
  swap_every = 3,
  thick_frac = 0.05,
  bbox_w_frac = 0.55,
  bbox_h_frac = 0.3,
  area_frac = 0.03,
  margin = 0.02,
  fade = 0.15,
  place_tries = 16,
  color = {
    1,
    0,
    0
  }
}

-- Difficulty-notch convention shared by skill-based
-- mini-games (find, pop). Meet opts out. Level range is
-- min..max; auto-match bumps up after up_streak clean
-- successes, down after down_streak struggles. Cooldown
-- gates auto-shifts only; teacher chords bypass it.
-- Streaks reset on any notch change. The level is the
-- only state that survives a mini-game exit and reenter.

NOTCH = {
  min = -2,
  max = 2,
  up_streak = 3,
  down_streak = 2,
  cooldown = 15
}

-- "Plug in the mouse" screen, shown program-wide when no
-- external mouse is present. The picture carries the
-- message for non-reading children; the caption is a
-- teacher aide. icon_h: mouse height as a screen
-- fraction; plug_gap: sprite-space gap to the plug;
-- text_dy: caption offset below center.

NO_MOUSE = {
  text = "Plug in the mouse.",
  icon_h = 0.3,
  plug_gap = 40,
  text_dy = 170
}

-- Unconnected USB-A plug glyph for the no-mouse screen,
-- drawn in sprite-space units and scaled by the caller.

PLUG = {
  w = 70,
  h = 46,
  inner = 9,
  tongue_w = 0.66,
  cable = 60,
  line_w = 7,
  shell = {
    0.58,
    0.58,
    0.62
  },
  metal = {
    0.82,
    0.82,
    0.86
  },
  cable_c = {
    0.2,
    0.2,
    0.2
  }
}

-- Mini-game 2: Find the glowing circle. Dark field so
-- the target stands out.

FIND_BG = {
  0.12,
  0.12,
  0.14
}

-- Cool (idle) and warm (entered) target colors

FIND_COOL = {
  0.42,
  0.46,
  0.95
}
FIND_WARM = {
  1,
  0.7,
  0.16
}

-- Timings (s) and geometry. clean_t / struggle_t are the
-- auto-match windows; warm_t the cool->warm transition;
-- fade_t the swap cross-fade; pulse the glow period;
-- edge_frac the no-edge-spawn inset (of screen width);
-- tries caps the relocation sampling loop.

FIND = {
  min_px = 60,
  clean_t = 4,
  struggle_t = 12,
  warm_t = 0.3,
  fade_t = 0.3,
  pulse = 1,
  edge_frac = 0.1,
  tries = 24
}

-- Per-notch table. size: circle diameter as a screen-
-- width fraction; pause: bell-to-next-circle delay;
-- reloc: min center move as a width fraction; edge:
-- allow spawns near the screen edges.

FIND_NOTCH = {
  [-2] = {
    size = 0.3,
    pause = 1.5,
    reloc = 0.2,
    edge = false
  },
  [-1] = {
    size = 0.22,
    pause = 1,
    reloc = 0.25,
    edge = false
  },
  [0] = {
    size = 0.17,
    pause = 0.8,
    reloc = 0.3,
    edge = false
  },
  [1] = {
    size = 0.12,
    pause = 0.5,
    reloc = 0.4,
    edge = false
  },
  [2] = {
    size = 0.08,
    pause = 0.3,
    reloc = 0.5,
    edge = true
  }
}

-- Enlarged high-contrast pointer (shared by find / pop).
-- shape: normalized arrow points (tip at 0,0), scaled by
-- size; convex so polygon fill is correct.

POINTER = {
  size = 40,
  line = 3,
  fill = {
    1,
    1,
    1
  },
  edge = {
    0.1,
    0.1,
    0.12
  },
  shape = {
    0,
    0,
    0,
    1,
    0.7,
    0.7
  }
}

-- Mini-game 3: Pop the bubble. Light cheerful field.

POP_BG = {
  0.94,
  0.98,
  1
}

-- Bubble look: translucent fill, brighter rim, white
-- highlight. Alphas and highlight geometry in POP.

POP_FILL = {
  0.5,
  0.75,
  1
}
POP_RIM = {
  0.3,
  0.55,
  0.95
}
POP_HI = {
  1,
  1,
  1
}

-- Timings (s) and tuning. pop_t: shrink-to-zero; grow_t:
-- grow-in; struggle_t: no-pop struggle window;
-- struggle_clicks: off-target clicks that trigger a
-- struggle; forgive: off-target clicks still counted
-- clean; tries caps relocation sampling.

POP = {
  min_px = 60,
  pop_t = 0.2,
  grow_t = 0.3,
  struggle_t = 15,
  struggle_clicks = 3,
  forgive = 1,
  tries = 24,
  rim_w = 3,
  fill_a = 0.35,
  hi_a = 0.85,
  hi_off = 0.3,
  hi_r = 0.22
}

-- Per-notch table. size: bubble diameter as a screen-
-- width fraction; respawn: click-to-next-bubble delay;
-- reloc: min center move as a width fraction; motion:
-- drift speed (px/s, 0 = stationary).

POP_NOTCH = {
  [-2] = {
    size = 0.3,
    respawn = 1,
    reloc = 0.2,
    motion = 0
  },
  [-1] = {
    size = 0.22,
    respawn = 0.7,
    reloc = 0.25,
    motion = 0
  },
  [0] = {
    size = 0.17,
    respawn = 0.5,
    reloc = 0.3,
    motion = 0
  },
  [1] = {
    size = 0.12,
    respawn = 0.4,
    reloc = 0.4,
    motion = 0
  },
  [2] = {
    size = 0.08,
    respawn = 0.3,
    reloc = 0.5,
    motion = 20
  }
}

-- Pop burst: tiny circles scattering from the center.

BURST = {
  count = 8,
  speed = 180,
  life = 0.35,
  r = 5
}
