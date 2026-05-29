-- Generated from /Users/vadym/mouse_svg/MOUSE04_5.svg
local gfx = love.graphics
local convex_fill = compy.graphics.shape2d.convex_fill
local concave_fill = compy.graphics.shape2d.concave_fill
local selfx_fill = compy.graphics.shape2d.selfx_fill
local bezier_stroke = compy.graphics.shape2d.bezier_stroke
local paths = { }

paths.p1 = { -- concave
  { "M", 122.05, 10.15 },
  { "C", 58.29, 11.61, 6.58, 64.21, 6.58, 128.31 },
  { "L", 6.58, 162.42 },
  { "C", 40.8, 181.87, 80.19, 193.16, 122.05, 193.63 },
  { "L", 122.05, 130.87 },
  { "C", 114.5, 130.34, 108.49, 124.01, 108.49, 116.33 },
  { "L", 108.49, 72.55 },
  { "C", 108.49, 64.88, 114.5, 58.54, 122.05, 58.01 },
  { "L", 122.05, 10.15 },
  { "Z" },
}
return function()
concave_fill(paths.p1)

end
