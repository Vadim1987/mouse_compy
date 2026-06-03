-- pointer.lua
-- Enlarged high-contrast pointer for the goal-based mouse
-- mini-games (find, pop), where the visible pointer must
-- be at least 2x default size and stand out against the
-- background. The system cursor is hidden and this is
-- drawn at the mouse position instead.

-- Build the arrow polygon at (x, y), scaled by s

function pointer_points(x, y, s)
  local p = { }
  local sh = POINTER.shape
  for i = 1, #sh, 2 do
    p[#p + 1] = x + sh[i] * s
    p[#p + 1] = y + sh[i + 1] * s
  end
  return p
end

function draw_pointer(x, y)
  local p = pointer_points(x, y, POINTER.size)
  set_color(POINTER.fill)
  gfx.polygon("fill", p)
  set_color(POINTER.edge)
  gfx.setLineWidth(POINTER.line)
  gfx.polygon("line", p)
end
