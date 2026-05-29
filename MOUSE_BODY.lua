-- Generated from /Users/vadym/mouse_svg/MOUSE04_2.svg
local gfx = love.graphics
local convex_fill = compy.graphics.shape2d.convex_fill
local concave_fill = compy.graphics.shape2d.concave_fill
local selfx_fill = compy.graphics.shape2d.selfx_fill
local bezier_stroke = compy.graphics.shape2d.bezier_stroke
local paths = { }

paths.p1 = { -- concave
  { "M", 127.72, 10.21 },
  { "C", 191.48, 11.67, 243.19, 64.27, 243.19, 128.37 },
  { "L", 243.19, 311.6 },
  { "C", 243.19, 376.6, 190, 429.79, 125, 429.79 },
  { "L", 125, 429.79 },
  { "C", 60, 429.79, 6.81, 376.6, 6.81, 311.6 },
  { "L", 6.81, 128.37 },
  { "C", 6.81, 64.27, 58.52, 11.67, 122.28, 10.21 },
  { "L", 122.28, 58.07 },
  { "C", 114.74, 58.6, 108.73, 64.94, 108.73, 72.61 },
  { "L", 108.73, 116.39 },
  { "C", 108.73, 124.07, 114.74, 130.4, 122.28, 130.93 },
  { "L", 122.28, 242.64 },
  { "C", 122.28, 244.13, 123.5, 245.36, 125, 245.36 },
  { "C", 126.5, 245.36, 127.72, 244.13, 127.72, 242.64 },
  { "L", 127.72, 130.93 },
  { "C", 135.26, 130.4, 141.27, 124.07, 141.27, 116.39 },
  { "L", 141.27, 72.61 },
  { "C", 141.27, 64.94, 135.26, 58.6, 127.72, 58.07 },
  { "L", 127.72, 10.21 },
  { "Z" },
}
return function()
gfx.setColor(0.902, 0.902, 0.902, 1.000)
concave_fill(paths.p1)
gfx.setColor(0.200, 0.200, 0.200, 1.000)
gfx.setLineWidth(2.36)
bezier_stroke(paths.p1)

gfx.setColor(0.702, 0.702, 0.702, 1.000)
gfx.rectangle("fill", 112.54, 61.33, 24.91, 66.34, 12.46, 14.37)
gfx.setColor(0.200, 0.200, 0.200, 1.000)
gfx.setLineWidth(2.36)
gfx.rectangle("line", 112.54, 61.33, 24.91, 66.34, 12.46, 14.37)

end
