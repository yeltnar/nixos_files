# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{lib, pkgs, ...}:
let
  _wallpaper = "file:///home/drew/Downloads/milkyway+C&H-nix.jpg"; 
  wallpaper = pkgs.fetchurl {
    url = "https://hot.andbrant.com/milkyway+C&H-nix.jpg";
    sha256 = "sha256-Xzlv420zq3SOcjDJU0mc7Cew9dNql0IvhQcSvTVbziM=";
  };
in 
with lib.hm.gvariant; {
  dconf.settings = {
    "org/gnome/Console" = {
      font-scale = 1.7000000000000006;
      audible-bell = false;
    };

    "org/gnome/desktop/background" = {
      picture-uri = "file://${wallpaper}";
      picture-uri-dark = "file://${wallpaper}";
    }; 

    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      clock-show-seconds = true;
      color-scheme = "prefer-dark";
      show-battery-percentage = true;
      enable-hot-corners = false;
    };

    "org/gnome/desktop/notifications" = {
      application-children = ["firefox" "org-gnome-console"];
      show-in-lock-screen = false; 
    };

    "org/gnome/desktop/notifications/application/firefox" = {
      application-id = "firefox.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-console" = {
      application-id = "org.gnome.Console.desktop";
    };

    "org/gnome/desktop/screensaver" = {
      lock-delay = mkUint32 120;
      lock-enable = true;
    };

    "org/gnome/desktop/search-providers" = {
      sort-order = ["org.gnome.Settings.desktop" "org.gnome.Nautilus.desktop" "org.gnome.Contacts.desktop" "org.gnome.Documents.desktop" "org.gnome.Calculator.desktop" "org.gnome.Calendar.desktop" "org.gnome.Characters.desktop" "org.gnome.clocks.desktop"];
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 600;
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      workspaces-only-on-primary = true;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "nothing";
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-type = "nothing";
    };

    "org/gnome/shell" = {
      enabled-extensions = [ "space-bar@luchrioh" "switcher@landau.fi" "tactile@lundal.io" "system-monitor@gnome-shell-extensions.gcampax.github.com" ];
      welcome-dialog-last-shown-version = "47.2";
    };

    "org/gnome/shell/extensions/space-bar/appearance" = {
      application-styles = ".space-bar {n  -natural-hpadding: 12px;n}nn.space-bar-workspace-label.active {n  margin: 0 4px;n  background-color: rgba(255,255,255,0.3);n  color: rgba(255,255,255,1);n  border-color: rgba(0,0,0,0);n  font-weight: 700;n  border-radius: 4px;n  border-width: 0px;n  padding: 3px 8px;n}nn.space-bar-workspace-label.inactive {n  margin: 0 4px;n  background-color: rgba(0,0,0,0);n  color: rgba(255,255,255,1);n  border-color: rgba(0,0,0,0);n  font-weight: 700;n  border-radius: 4px;n  border-width: 0px;n  padding: 3px 8px;n}nn.space-bar-workspace-label.inactive.empty {n  margin: 0 4px;n  background-color: rgba(0,0,0,0);n  color: rgba(255,255,255,0.5);n  border-color: rgba(0,0,0,0);n  font-weight: 700;n  border-radius: 4px;n  border-width: 0px;n  padding: 3px 8px;n}";
    };

    "org/gnome/shell/extensions/space-bar/state" = {
      version = 32;
    };

    "org/gnome/shell/world-clocks" = {
      locations = [];
    };

    "org/gnome/shell" = {
      favorite-apps = [];
    };

    "org/gtk/settings/file-chooser" = {
      clock-format = "12h";
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Control><Alt>t";
      command = "ghostty";
      name = "open terminal";
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-applications = [];
      switch-applications-backward = [];
      switch-windows = ["<Alt>Tab"];
      switch-windows-backward = ["<Shift><Alt>Tab"];
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };
  };
}
