-- Ported from hyprland.conf using the Hyprland 0.55+ Lua configuration API.

--- Safely requires a module only if it exists, bypassing global error loggers.
-- @param module_name string: The name of the module to load.
-- @return table|nil: The loaded module, or nil if not found.
local function silent_require(module_name)
    -- package.searchpath returns the file path if found, or nil + error message
    if package.searchpath(module_name, package.path) then
        return require(module_name)
    end
    return nil
end

local terminal = "~/.config/hypr/start_ghostty.sh"
local terminal_floating = "ghostty --class=com.mitchellh.ghostty.floating"
local browser = "firefox"
local fileManager = "thunar"
local menu = "dfuzzel"
local mainMod = "SUPER"
local shiftMod = "SUPER + SHIFT"
local border_color_1 = "rgba(33ccffee)"
local border_color_2 = "rgba(00ff99ee)"
local border_color_3 = "rgba(c864faee)"
local hyprshot = "mkdir -p ~/hyprshot; hyprshot -o ~/hyprshot"

-- local hostname = 'drew-lin-desktop'
-- local hostname = os.getenv("HOSTNAME") or 'drew-lin-desktop'
local file = io.open("/proc/sys/kernel/hostname", "r")
local hostname = file:read("*l") -- Read the first line
file:close()

-- MONITORS
do
  hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
  silent_require('monitors_'..hostname)
  silent_require(hostname..'_extra_start')
  -- pcall(require, "extra_start")
end

-- WORKSPACES
do
  hl.workspace_rule({ workspace = "name:second", monitor = "DP-2", persistent = true, default = true })
  hl.workspace_rule({ workspace = "name:wstart", on_created_empty = "start_work" })
  hl.workspace_rule({ workspace = "name:term", on_created_empty = terminal })
  hl.workspace_rule({ workspace = "name:slack", on_created_empty = "slack" })
  hl.workspace_rule({ workspace = "name:element", on_created_empty = "element-desktop" })
  hl.workspace_rule({ workspace = "name:fisms", on_created_empty = browser .. " --new-window \"https://yeltnar.github.io/search/?yeltnarsearch&q=fisms\"" })
  hl.workspace_rule({ workspace = "name:yt", on_created_empty = browser .. " --new-window \"https://yeltnar.github.io/search/?yeltnarsearch&q=yt%20\"" })
  hl.workspace_rule({ workspace = "name:doom", on_created_empty = "steam steam://rungameid/782330" }) -- Doom Eternal
  hl.workspace_rule({ workspace = "name:superhot", on_created_empty = "steam steam://rungameid/322500" }) -- Superhot
  hl.workspace_rule({ workspace = "name:rear", on_created_empty = "ghostty --command='export bashrc_folder=/home/drew/playin/custom_bashrc;PATH=$PATH:$bashrc_folder/bin;/home/drew/playin/custom_bashrc/bin/rear.lan.ffplay'" })
  hl.workspace_rule({ workspace = "name:backyard", on_created_empty = "ghostty --command='export bashrc_folder=/home/drew/playin/custom_bashrc;PATH=$PATH:$bashrc_folder/bin;/home/drew/playin/custom_bashrc/bin/backyard.lan.ffplay'" })
  hl.workspace_rule({ workspace = "name:front", on_created_empty = "ghostty --command='export bashrc_folder=/home/drew/playin/custom_bashrc;PATH=$PATH:$bashrc_folder/bin;/home/drew/playin/custom_bashrc/bin/front.lan.ffplay'" })
  hl.workspace_rule({ workspace = "name:sleep", on_created_empty = "ghostty --command='/home/drew/playin/custom_bashrc/bin/sleep_hyprland && hyprctl dispatch 'hl.dsp.focus({ workspace = 'previous' })' ; sleep 20; exit'" })
  hl.workspace_rule({ workspace = "name:hibernate", on_created_empty = "ghostty --command='hyprctl dispatch hl.dsp.focus({ workspace = 'previous' }) ; systemctl hibernate &&  sleep 20; exit'" })
  hl.workspace_rule({ workspace = "name:firefox", on_created_empty = "firefox" })
  hl.workspace_rule({ workspace = "name:ff", on_created_empty = "hyprctl dispatch \"hl.dsp.focus({ workspace = 'name:firefox' })\"" 
  })
end

-- WINDOW RULES
do
  hl.window_rule({ name = "firefox-float-rule", match = { workspace = "name:firefox" }, float = true, size = { 800, 600 } })
  hl.window_rule({ name = "n-float-rule", match = { workspace = "name:n" }, float = true, size = { 800, 600 } })
  hl.window_rule({ name = "pip-float", match = { title = ".*Picture-in-Picture.*" }, float = true, pin = true, size = { "50%", "50%" } })
  hl.window_rule({ match = { class = "ffplay" }, maximize = true })
  hl.window_rule({ match = { class = "steam_app_(.*)" }, fullscreen = true })
  hl.window_rule({ match = { class = "steam_app_782330", title = "DoomEternal" }, float = true })
  hl.window_rule({ match = { class = "steam_app_782330" }, workspace = "name:doom" })
  hl.window_rule({ match = { title = "DoomEternal" }, workspace = "name:doom" })
  hl.window_rule({ match = { title = "DoomEternal" }, fullscreen = true })
  hl.window_rule({ name = "doom-float-rule", match = { title = "DOOMEternal" }, fullscreen = true })
  hl.window_rule({ name = "doom-launcher-float-rule", match = { title = "DOOM Eternal Launcher.*" }, float = true, size = { 800, 600 } })
  hl.window_rule({ match = { title = "SUPERHOT" }, workspace = "name:superhot" })
  hl.window_rule({ match = { class = "com.mitchellh.ghostty.floating" }, float = true })
  hl.window_rule({ match = { class = "com.mitchellh.ghostty.floating" }, size = { "50%", "50%" } })
  hl.window_rule({ name = "flip-fullscreen-borders", match = { fullscreen = true }, border_color = { colors = { border_color_3, border_color_1 }, angle = 45 } })
  hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })
  hl.window_rule({ match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false }, no_focus = true })
end

-- AUTOSTART
do
  hl.on("hyprland.start", function()
    for _, cmd in ipairs({
      "uwsm app -- hypridle",
      "uwsm app -- swaync",
      "uwsm app -- wayland-pipewire-idle-inhibit",
      "uwsm app -- ~/.config/hypr/waybar/start-waybar.sh",
      "uwsm app -- hyprpaper --config ~/.config/hypr/hyprpaper/hyprpaper.conf",
      "uwsm app -- gnome-keyring-daemon --start --components=secrets",
      terminal,
      "tmux setenv -g HYPRLAND_INSTANCE_SIGNATURE \"$HYPRLAND_INSTANCE_SIGNATURE\"",
      "playerctld daemon",
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland",
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland",
    }) do hl.exec_cmd(cmd) end
  end)

  hl.on("window.urgent", function(w)
    -- w = hl.get_active_window()
    -- local k = keys(w)
    -- hl.notification.create({ text = k, timeout = 5000, icon = "ok" })
    hl.notification.create({ text = "Window urgant: " .. w.title .." pid: ".. w.pid, timeout = 5000, icon = "ok" })
  end)

  hl.on("window.active", function(w)
    -- hl.notification.create({ text = "Window focused: " .. w.title .." pid: ".. w.pid, timeout = 5000, icon = "ok" })
    -- local cjson = require("cjson")

    -- w = hl.get_active_window()

    -- hl.dispatch( hl.dsp.window.center( { window=w } ) )
    -- hl.dispatch( hl.dsp.window.float( { window=w } ) )

    -- local data = keys(w)
    -- local json_string = cjson.encode(data)

    -- print(json_string)
    --
    -- local text = type(w)
    local text = w.title

    -- hl.notification.create({ text = text, timeout = 5000, icon = "ok" })
    -- print(json_string)
  end)

  -- hl.on("workspace.move_to_monitor", function(ws, m)
  --   hl.notification.create({
  --     text = "Workspace: " .. ws.name .. " moved to a monitor at x: " .. m.position.x,
  --     timeout = 4000,
  --     icon = "ok"
  --   })
  -- end) 

end

-- ENVIRONMENT VARIABLES
do
  hl.env("XCURSOR_SIZE", "24")
  hl.env("HYPRCURSOR_SIZE", "24")
  hl.env("XCURSOR_THEME", "Adwaita")
end

-- LOOK AND FEEL / INPUT / GROUPS
do
  hl.config({
    debug = {disable_logs = false},
    general = {
      gaps_in = 2,
      gaps_out = 2,
      border_size = 2,
      col = {
        active_border = { colors = { border_color_1, border_color_2 }, angle = 45 },
        inactive_border = "rgba(595959aa)",
      },
      resize_on_border = false,
      allow_tearing = false,
      layout = "dwindle",
    },
    decoration = {
      rounding = 1,
      rounding_power = 2,
      active_opacity = 1.0,
      inactive_opacity = 1.0,
      shadow = { enabled = true, range = 4, render_power = 3, color = "rgba(1a1a1aee)" },
      blur = { enabled = true, size = 3, passes = 1, vibrancy = 0.1696 },
    },
    animations = { enabled = false },
    dwindle = { preserve_split = true },
    master = { new_status = "master" },
    misc = {
      force_default_wallpaper = -1,
      disable_hyprland_logo = true,
      key_press_enables_dpms = true,
      on_focus_under_fullscreen = 2,
      allow_session_lock_restore = true,
    },
    input = {
      kb_layout = "us",
      kb_variant = "",
      kb_model = "",
      kb_options = "",
      kb_rules = "",
      follow_mouse = 1,
      sensitivity = 0,
      touchpad = { natural_scroll = true, clickfinger_behavior = 1 },
    },
    group = {
      insert_after_current = true,
      groupbar = {
        height = 18,
        font_size = 14,
        gradients = true,
        render_titles = true,
        col = { active = "rgba(000000cc)", inactive = "rgba(333333ff)" },
        scrolling = true,
      },
    },
  })
end

-- Gestures and per-device input.
do
  hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
  hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })
end

-- KEYBINDINGS
do

  hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd(terminal))
  hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
  hl.bind(mainMod .. " + U", hl.dsp.exec_cmd(terminal))
  hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("~/.config/hypr/wlr-which-key/add-tab-or-new-window.sh \"https://gemini.google.com\""))
  hl.bind("CTRL + ALT + SHIFT + T", hl.dsp.exec_cmd(terminal_floating))
  hl.bind(shiftMod .. " + T", hl.dsp.exec_cmd(terminal_floating))
  hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
  hl.bind(mainMod .. " + Q", hl.dsp.window.close())
  hl.bind(mainMod .. " + CTRL + SHIFT + M", hl.dsp.exec_cmd("uwsm stop"))
  hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
  hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
  hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(menu))
  hl.bind(mainMod .. " + P", hl.dsp.window.float({action = "toggle"}))
  hl.bind(shiftMod .. " + P", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.pin({ action = "toggle" }))
  end)
  hl.bind(mainMod .. " + escape", hl.dsp.exec_cmd("hyprlock -q"))
  hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t"))
  hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
  hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

  for key, dir in pairs({ left = "l", right = "r", up = "u", down = "d", h = "l", j = "d", k = "u", l = "r" }) do
   hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = dir }))
  end
  for i = 1, 10 do
    local key = (i == 10) and "0" or tostring(i)
   hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = tostring(i) }))
   hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i) }))
  end
  hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "previous_per_monitor" }))
  hl.bind(mainMod .. " + Return", hl.dsp.focus({ urgent_or_last = true }))
  hl.bind(mainMod .. " + equal", hl.dsp.exec_cmd("~/.config/hypr/move_workspace.sh next"))
  hl.bind(mainMod .. " + minus", hl.dsp.exec_cmd("~/.config/hypr/move_workspace.sh prev"))
  hl.bind(shiftMod .. " + equal", hl.dsp.group.next())
  hl.bind(shiftMod .. " + minus", hl.dsp.group.prev())
  hl.bind(mainMod .. " + w", hl.dsp.exec_cmd("bash ~/.config/hypr/bemenu/switch-workspace.sh"))
  hl.bind(shiftMod .. " + w", hl.dsp.exec_cmd("bash ~/.config/hypr/bemenu/switch-workspace.sh move"))
  for key, dir in pairs({ right = "r", left = "l", up = "u", down = "d", l = "r", h = "l", k = "u", j = "d" }) do
   hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.swap({ direction = dir }))
  end
  hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.workspace.move({ monitor = "+1" }))
  hl.bind(mainMod .. " + s", hl.dsp.exec_cmd("wlr-which-key /home/drew/.config/hypr/wlr-which-key/config.yaml"))
  hl.bind(shiftMod .. " + b", hl.dsp.exec_cmd("wlr-which-key /home/drew/.config/hypr/wlr-which-key/browser-config.yaml"))
  hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
  hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
  hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd(hyprshot .. " -m window"))
  hl.bind(shiftMod .. " + PRINT", hl.dsp.exec_cmd(hyprshot .. " -m output"))
  hl.bind("PRINT", hl.dsp.exec_cmd(hyprshot .. " -m region"))
  hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
  hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

  hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
  hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
  hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
  hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
  hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
  hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
  hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
  hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
  hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
  hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

end

silent_require(hostname .. '_extra_end')
