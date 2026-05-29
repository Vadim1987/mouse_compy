-- Generated from /Users/vadym/mouse_svg/MOUSE04_4.svg
local gfx = love.graphics
local convex_fill = compy.graphics.shape2d.convex_fill
local concave_fill = compy.graphics.shape2d.concave_fill
local selfx_fill = compy.graphics.shape2d.selfx_fill
local bezier_stroke = compy.graphics.shape2d.bezier_stroke
local paths = { }

paths.p1 = { -- concave
  { "M", 127.63, 10.15 },
  { "C", 191.39, 11.61, 243.1, 64.21, 243.1, 128.31 },
  { "L", 243.1, 162.42 },
  { "C", 208.88, 181.87, 169.49, 193.16, 127.63, 193.63 },
  { "L", 127.63, 130.87 },
  { "C", 135.17, 130.34, 141.18, 124.01, 141.18, 116.33 },
  { "L", 141.18, 72.55 },
  { "C", 141.18, 64.88, 135.17, 58.54, 127.63, 58.01 },
  { "L", 127.63, 10.15 },
  { "Z" },
}
return function()
concave_fill(paths.p1)

end
