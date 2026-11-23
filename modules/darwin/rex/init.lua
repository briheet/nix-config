-- Rex config: linked to ~/.config/rex/init.lua by modules/darwin/rex.nix.
-- These bindings sit on top of Rex's defaults; shortcuts set in the app win over them.
-- Check:  rex config check   Keys:  rex keymap   Actions:  rex actions
-- Docs:   https://superlogical.com/rex/docs/customize/config.md

-- Panes: vim keys next to the default alt+cmd+arrows
local dirs = { h = "left", j = "down", k = "up", l = "right" }

for key, dir in pairs(dirs) do
  rex.bind("alt+cmd+" .. key, "pane.focus", { direction = dir })
  rex.bind("shift+alt+cmd+" .. key, "pane.move", { direction = dir })
end

-- Splits, tmux-like: | to the right, - below
rex.bind("alt+cmd+\\", "pane.split.right")
rex.bind("alt+cmd+-", "pane.split.down")
rex.bind("alt+cmd+z", "pane.zoom")
rex.bind("alt+cmd+=", "pane.balance")

-- Tabs
rex.bind("ctrl+tab", "client.tab.next")
rex.bind("ctrl+shift+tab", "client.tab.previous")

-- Resize mode: alt+cmd+r, then hjkl/arrows (shift for bigger steps); escape or enter leaves
rex.mode("resize", { exclusive = true })
rex.bind("alt+cmd+r", "client.mode.enter", { name = "resize" })

local arrows = { left = "left", down = "down", up = "up", right = "right" }

for _, map in ipairs({ dirs, arrows }) do
  for key, dir in pairs(map) do
    rex.bind("resize/" .. key, "pane.resize", { direction = dir })
    rex.bind("resize/shift+" .. key, "pane.resize", { direction = dir, amount = 5 })
  end
end

rex.bind("resize/=", "pane.balance")
rex.bind("resize/escape", "client.mode.exit")
rex.bind("resize/enter", "client.mode.exit")

-- Config
rex.bind("alt+cmd+,", "client.config.reload")
