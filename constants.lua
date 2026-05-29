-- constants.lua

-- App layout. Size is read from the real window at
-- game start (sync_screen); declared empty here.

APP = { }

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

-- Logo mark color on the body (Compy blue)

LOGO_COLOR = {
  0,
  0.396,
  0.996
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

-- Meet-the-mouse playfield and sprite

MOUSE_BG = {
  0.88,
  0.93,
  0.91
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
  win_x = 116,
  win_y = 64,
  win_h = 60,
  gap = 20,
  pel_w = 18,
  pel_h = 7,
  pel_r = 2,
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
  tries_per_frame = 8,
  relax = 0.9,
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
    0.8,
    0.45,
    0.45
  }
}
