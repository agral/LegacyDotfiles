-- CairoHelper.lua: a set of helper functions drawing various things.

-- Requires cairo, but it is already sourced globally in "main.lua".

local CairoHelper = {}

local function AnalogGauge(x, y, val)
  cairo_set_source_rgba(cr, 127, 127, 127, 200)
  cairo_set_line_width(cr, 1)

  cairo_move_to(cr, x-20, y)
  cairo_line_to(cr, x+20, y)
  cairo_move_to(cr, x, y-20)
  cairo_line_to(cr, x, y+20)
  cairo_stroke(cr)

  cairo_set_line_width(cr, 10)
  cairo_set_source_rgba(cr, 133, 153, 0, 50)
  start_angle = -math.pi / 2
  end_angle = 0
  cairo_arc(cr, x, y, 60, start_angle, end_angle)
  cairo_stroke(cr)

end

CairoHelper.AnalogGauge = AnalogGauge
return CairoHelper
