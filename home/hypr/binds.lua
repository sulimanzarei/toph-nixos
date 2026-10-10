-- toph: keyboard and mouse shortcuts
--
-- SUPER is the Windows key. Shortcuts keep working while typing in Arabic,
-- because Hyprland reads them from the first layout (us).
-- Kept free on purpose: SUPER+L (lock screen) and SUPER+V (clipboard
-- history), to match Windows; both come with my shell in Phase 6.

local mod   = "SUPER"
local wsMod = "CTRL"   -- workspaces: CTRL+1..0, like Spaces on macOS. Change to "SUPER" to swap.

-- Start a program through UWSM, so it runs in its own systemd scope
-- instead of as a child of Hyprland
local function app(cmd)
    return hl.dsp.exec_cmd("uwsm app -- " .. cmd)
end

------------------------------------------------------------------------
-- Apps
------------------------------------------------------------------------
hl.bind(mod .. " + Return", app("kitty"),              { desc = "Terminal" })
hl.bind(mod .. " + Space",  hl.dsp.exec_cmd("fuzzel"), { desc = "App launcher (temporary)" })
hl.bind(mod .. " + E",      app("dolphin"),            { desc = "Files (temporary)" })
hl.bind(mod .. " + B",      app("firefox"),            { desc = "Browser" })

------------------------------------------------------------------------
-- Windows
------------------------------------------------------------------------
hl.bind(mod .. " + Q",         hl.dsp.window.close(),                            { desc = "Close window" })
hl.bind(mod .. " + F",         hl.dsp.window.fullscreen(),                       { desc = "Fullscreen" })
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }), { desc = "Maximise (keeps gaps)" })
hl.bind(mod .. " + T",         hl.dsp.window.float({ action = "toggle" }),       { desc = "Float / tile" })
hl.bind(mod .. " + J",         hl.dsp.layout("togglesplit"),                     { desc = "Flip split direction" })

-- Arrows: SUPER moves focus, SUPER+SHIFT moves the window itself
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mod .. " + " .. dir,         hl.dsp.focus({ direction = dir }))
    hl.bind(mod .. " + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }))
end

-- SUPER + left mouse drags a window, SUPER + right mouse resizes it
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize())

------------------------------------------------------------------------
-- Workspaces
------------------------------------------------------------------------
-- wsMod+1..0 goes to workspace 1..10; adding SHIFT takes the window along.
-- Hyprland catches these before apps do, so apps never see CTRL+1..0
-- (Chrome's and VS Code's own CTRL+number shortcuts stop working).
for i = 1, 10 do
    local key = i % 10   -- workspace 10 is on the 0 key
    hl.bind(wsMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(wsMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- SUPER + mouse wheel steps through workspaces that have windows
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Scratchpad: a hidden workspace that slides over whatever is open
hl.bind(mod .. " + S",       hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:scratch" }))

------------------------------------------------------------------------
-- Screenshots (saved to ~/Pictures/Screenshots and copied to the clipboard)
------------------------------------------------------------------------
local function screenshot(region)
    local cmd = 'mkdir -p "$HOME/Pictures/Screenshots"'
        .. ' && f="$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"'
    if region then
        -- if the selection is cancelled with Esc, slurp fails and nothing is saved
        cmd = cmd .. ' && r="$(slurp)" && grim -g "$r" "$f"'
    else
        cmd = cmd .. ' && grim "$f"'
    end
    return hl.dsp.exec_cmd(cmd .. ' && wl-copy < "$f"')
end

-- No Print key on the QK65, so: S for snip (as Win+Shift+S on Windows), A for all
hl.bind(mod .. " + SHIFT + S", screenshot(true),  { desc = "Screenshot a region" })
hl.bind(mod .. " + SHIFT + A", screenshot(false), { desc = "Screenshot all screens" })

------------------------------------------------------------------------
-- Wallpaper and colours (the toph-theme command, see home/scripts/toph-theme.sh)
------------------------------------------------------------------------
hl.bind(mod .. " + W",         hl.dsp.exec_cmd("toph-theme wall"),   { desc = "Random wallpaper" })
hl.bind(mod .. " + SHIFT + W", hl.dsp.exec_cmd("toph-theme toggle"), { desc = "Colours: signature / from wallpaper" })

------------------------------------------------------------------------
-- Volume keys (also work on the lock screen later)
------------------------------------------------------------------------
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })

------------------------------------------------------------------------
-- Session
------------------------------------------------------------------------
-- Log out the UWSM way, so the whole session shuts down cleanly
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("uwsm stop"), { desc = "Log out" })
