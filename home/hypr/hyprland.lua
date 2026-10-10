-- toph: Hyprland entry point
--
-- ~/.config/hypr is a live link to this folder (set in home/hyprland.nix).
-- Hyprland reloads by itself when any file here is saved.
-- Every hl.* function is listed in /run/current-system/sw/share/hypr/stubs/hl.meta.lua

------------------------------------------------------------------------
-- Monitors
------------------------------------------------------------------------
-- Screens are matched by the start of their description (see `hyprctl monitors all`),
-- not by port name, so swapping DisplayPort cables changes nothing.
-- Serial numbers are left out on purpose; the start of the description is enough.
-- Positions are in pixels, measured from the top-left corner of the whole layout:
--
--   x = 0            x = 1920                    x = 4480
--                    +---------------------------+   y = 0
--   +----------------+                           |   y = 180
--   |   ViewSonic    |          LG OLED          |
--   |   1920x1080    |         2560x1440         |
--   +----------------+                           |   y = 1260
--                    +---------------------------+   y = 1440
--
-- The ViewSonic sits 180 px down, which lines up the middles of both
-- screens: (1440 - 1080) / 2 = 180.

-- ViewSonic, on the left, vertically centred against the LG
hl.monitor({
    output   = "desc:ViewSonic Corporation XG2431",
    mode     = "1920x1080@239.76",
    position = "0x180",
    scale    = 1,
})

-- LG OLED, main screen, on the right
hl.monitor({
    output   = "desc:LG Electronics LG ULTRAGEAR+",
    mode     = "2560x1440@239.97",
    position = "1920x0",
    scale    = 1,
})

-- Any other screen plugged in later (the TV, a projector): highest
-- resolution, then the highest refresh rate at that resolution.
-- "preferred" would often pick 60 Hz: the ViewSonic lists 60 Hz as its
-- preferred mode even though it does 240.
hl.monitor({
    output   = "",
    mode     = "highres",
    position = "auto",
    scale    = 1,
})

------------------------------------------------------------------------
-- Input
------------------------------------------------------------------------
hl.config({
    input = {
        kb_layout     = "us,ara",               -- English and Arabic
        kb_options    = "grp:alt_shift_toggle", -- Alt+Shift switches, as on Windows
        repeat_delay  = 300,                    -- ms before a held key repeats
        repeat_rate   = 40,                     -- repeats per second
        follow_mouse  = 1,                      -- focus follows the pointer
        accel_profile = "flat",                 -- no pointer acceleration
        sensitivity   = 0,
    },
})

------------------------------------------------------------------------
-- Window rules (both from Hyprland's official example config)
------------------------------------------------------------------------
-- Apps can't maximise themselves and break the tiling
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Stops invisible XWayland helper windows from stealing focus during drag and drop
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

------------------------------------------------------------------------
-- The rest, one file per topic
------------------------------------------------------------------------
require("look")   -- gaps, borders, corners, blur, shadows, animations
require("binds")  -- keyboard and mouse shortcuts
