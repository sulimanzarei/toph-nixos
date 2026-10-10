-- toph: how everything looks. This is the ricing file.
--
-- The colours are placeholders. The colour pipeline (next step) will
-- generate them, either from my signature blue or from the wallpaper.

local blue      = "rgba(3d7bffee)"
local blueLight = "rgba(7fb2ffee)"
local idle      = "rgba(1c2230aa)"   -- unfocused windows: almost black

------------------------------------------------------------------------
-- Layout, borders, corners, blur, shadows
------------------------------------------------------------------------
hl.config({
    general = {
        gaps_in     = 6,    -- between windows
        gaps_out    = 14,   -- between windows and the screen edge
        border_size = 2,
        col = {
            active_border   = { colors = { blue, blueLight }, angle = 45 },
            inactive_border = idle,
        },
        layout           = "dwindle",
        resize_on_border = true,   -- drag a border or gap to resize
    },

    decoration = {
        rounding       = 4,
        rounding_power = 3,   -- 2 is a plain circle arc; higher gives softer "squircle" corners

        shadow = {
            enabled      = true,
            range        = 18,
            render_power = 3,
            color        = 0x66000000,   -- 0xAARRGGBB: black at 40% opacity
        },

        blur = {
            enabled  = true,
            size     = 6,
            passes   = 3,       -- more passes = smoother, slightly more GPU
            vibrancy = 0.17,
            noise    = 0.02,    -- a little grain stops colour banding in dark gradients
        },
    },

    dwindle = {
        preserve_split = true,   -- a split keeps its direction when windows close
    },

    animations = {
        enabled = true,
    },
})

------------------------------------------------------------------------
-- Animation curves
------------------------------------------------------------------------
-- Bezier: a fixed shape over a fixed time ("speed" is in tenths of a second).
-- Spring: real physics. Stiffness pulls toward the target, dampening slows
-- it down, so less dampening means more bounce. The physics decides how
-- long it takes; "speed" is still required but doesn't matter for springs.
hl.curve("smooth", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })      -- fast start, gentle stop
hl.curve("linear", { type = "bezier", points = { {0, 0},    {1, 1}    } })
hl.curve("bouncy", { type = "spring", mass = 1, stiffness = 130, dampening = 16 })  -- one small overshoot
hl.curve("firm",   { type = "spring", mass = 1, stiffness = 150, dampening = 21 })  -- almost no overshoot

------------------------------------------------------------------------
-- Animations
------------------------------------------------------------------------
-- Opening windows pop in with a small bounce; closing is quick and plain
-- (a custom close animation is planned for Phase 12).
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 5, spring = "bouncy", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2, bezier = "linear", style = "popin 85%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, spring = "firm" })

hl.animation({ leaf = "fade",        enabled = true, speed = 3, bezier = "smooth" })
hl.animation({ leaf = "border",      enabled = true, speed = 5, bezier = "smooth" })

-- Layers are bars, launchers and notifications
hl.animation({ leaf = "layersIn",    enabled = true, speed = 4, spring = "bouncy", style = "popin 90%" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 2, bezier = "linear", style = "fade" })

-- Workspaces slide sideways; the scratchpad slides in from above
hl.animation({ leaf = "workspaces",       enabled = true, speed = 4, bezier = "smooth", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "smooth", style = "slidevert" })
