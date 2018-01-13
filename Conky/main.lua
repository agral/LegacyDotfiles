-- Main lua module for main conky. Loads all the other modules.

package.path = package.path .. ";/home/simba/Repos/aszczerbiak/Dotfiles/Conky/?.lua"

--Immutable = require("Immutable")
--local Cairo = require("CairoHelper")
--local Solarized = require("Solarized")
--local Clock = require("Clock")

local ch = require("CairoHelper")
require("cairo")

--[[
  Prepares Conky context - it will be used by submodules.
  exports two global variables, "cr" and "csurface".
--]]
function conky_main()
  if not conky_window or conky_window.width == 0
    or conky_window.height == 0 then
      return
  end

  if cr == nil then
    print("Initializing conky-cairo")
    csurface = cairo_xlib_surface_create(
        conky_window.display,
        conky_window.drawable,
        conky_window.visual,
        conky_window.width,
        conky_window.height
    )
    cr = cairo_create(csurface)
  end

  -- X.draw()
  ch.AnalogGauge(200, 200)
end

