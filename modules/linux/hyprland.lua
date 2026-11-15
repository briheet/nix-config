-- Hyprland config for the M4 Pro, managed by home manager
-- (modules/linux/hyprland.nix). Started from github:briheet/nixos-m4pro's
-- nixos/hyprland.lua. Hyprland 0.57 reads Lua; the wiki is at
-- https://wiki.hypr.land/configuring/
--
-- Rendering is on the GPU and the panel runs at 120 Hz through the display
-- coprocessor (since 2026-11-15; before, llvmpipe on the CPU into the boot
-- framebuffer), so animations are on. Blur and shadows still start off.

---- Monitor: the whole 3024x1964 panel (notch strip included) at scale 4/3 ----
-- (looks like 2268x1473; the panel divides into whole pixels only at
-- scales 2, 4/3, ...)
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1.333333,
})

---- Programs ----
local terminal = "ghostty"
local menu     = "fuzzel"
local browser  = "firefox"

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("QT_QPA_PLATFORM", "wayland")

---- Look ----
hl.config({
    general = {
        gaps_in     = 4,
        gaps_out    = 8,
        border_size = 2,
        col = {
            active_border   = "rgba(7ebae4ff)",
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = true,
        layout = "dwindle",
    },

    decoration = {
        rounding = 6,
        shadow = { enabled = false },
        blur   = { enabled = false },
    },

    animations = { enabled = true },

    dwindle = { preserve_split = true },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})

---- Input: the MacBook keyboard and trackpad ----
hl.config({
    input = {
        kb_layout    = "us",
        kb_options   = "caps:escape",
        follow_mouse = 1,
        touchpad = {
            natural_scroll       = false,
            tap_to_click         = true,
            clickfinger_behavior = true,
            scroll_factor        = 0.5,
        },
    },
})

-- Three fingers left/right: next/previous workspace.
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

---- Keys: Super is the Command key ----
local mod = "SUPER"

-- Ghostty's single instance, started without a window, so that a new
-- terminal opens in it at once (modules/linux/ghostty.nix).
hl.on("hyprland.start", function()
    hl.exec_cmd(terminal .. " --initial-window=false")
end)

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("hyprctl dispatch 'hl.dsp.exit()'"))

hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screen brightness (the panel's backlight, through logind).
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

---- Windows ----
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

---- Animations: Hyprland's default curves, about twice as fast ----
-- (speed is the duration in tenths of a second: smaller is faster)
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1},  {0.32, 1} } })
hl.curve("linear",       { type = "bezier", points = { {0, 0},     {1, 1}    } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5}, {0.75, 1} } })
hl.curve("quick",        { type = "bezier", points = { {0.15, 0},  {0.1, 1}  } })
hl.curve("easy",         { type = "spring", mass = 1, stiffness = 238.1191, damping = 24.21279333 })

hl.animation({ leaf = "global",       enabled = true, speed = 5,   bezier = "default" })
hl.animation({ leaf = "border",       enabled = true, speed = 3,   bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",      enabled = true, speed = 2.5, spring = "easy" })
hl.animation({ leaf = "windowsIn",    enabled = true, speed = 2,   spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",   enabled = true, speed = 1,   bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",       enabled = true, speed = 1,   bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",      enabled = true, speed = 0.8, bezier = "almostLinear" })
hl.animation({ leaf = "fade",         enabled = true, speed = 1.5, bezier = "quick" })
hl.animation({ leaf = "layers",       enabled = true, speed = 2,   bezier = "easeOutQuint" })
hl.animation({ leaf = "workspaces",   enabled = true, speed = 1,   bezier = "almostLinear", style = "fade" })

---- Performance: as fast as possible ----
hl.config({
    render = {
        -- Fullscreen apps hand their frames straight to the display.
        direct_scanout = 1,
    },
})
