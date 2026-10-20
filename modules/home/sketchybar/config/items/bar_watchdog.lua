-- SketchyBar destroys and recreates its bar windows on every display change,
-- one per display that is active at that moment. Closing the lid makes the
-- built-in display inactive, so the bar is rebuilt with zero windows. If the
-- display is still inactive during SketchyBar's own rebuilds on wake, nothing
-- rebuilds it again and the bar stays gone (process alive) until a reload.
-- SketchyBar does report the display coming back: display_change fires with
-- INFO going from 0 to a display index. Rebuild the windows at that point.
local watchdog = sbar.add("item", { drawing = false, updates = true })

local function rebuild_bar(reason)
  io.write(os.date("%Y-%m-%d %H:%M:%S"), " [bar_watchdog] rebuild: ", reason, "\n")
  io.flush()
  -- Changing any bar property recreates all bar windows. shadow is cosmetic
  -- and left at its default (off) in bar.lua, so flip it on and back off.
  sbar.bar({ shadow = true })
  sbar.bar({ shadow = false })
end

local last_display = nil

watchdog:subscribe("display_change", function(env)
  if last_display == "0" and env.INFO ~= "0" then
    rebuild_bar("display " .. env.INFO .. " active again")
  end
  last_display = env.INFO
end)

-- Fallback in case the display_change above is missed: rebuild once the
-- display has had time to come up after a wake.
watchdog:subscribe("system_woke", function()
  sbar.delay(5, function() rebuild_bar("system woke") end)
end)
