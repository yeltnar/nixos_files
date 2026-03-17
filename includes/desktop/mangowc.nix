{
  config,
  pkgs,
  lib,
  ...
}:
let
  desktop_environment = config.services.desktop_environment.selection;
  
  # Note: Hyprland-specific plugins (hyprspace/hyprexpo) are not compatible with Mango.
  # I've removed them from the config to prevent build failures.
  
  wallpaper = pkgs.fetchurl {
    url = "https://hot.andbrant.com/milkyway+C&H-nix.jpg";
    sha256 = "sha256-Xzlv420zq3SOcjDJU0mc7Cew9dNql0IvhQcSvTVbziM=";
  };

  # Mango specific paths
  monitor_file = "~/.config/mango/monitors.${config.networking.hostName}.conf";
in
{
  # Only trigger if the selection is 'mango' (assuming you update your selection logic)
  config = lib.mkIf ( "mango" == desktop_environment ) {

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Mango doesn't have a dedicated 'programs.mango' in nixpkgs yet, 
    # so we enable generic Wayland support and install the package manually.
    services.xserver.displayManager.sessionPackages = [ pkgs.mango ];

    xdg.portal = {
      enable = true;
      # Use the generic wlr portal as it's most compatible with Mango
      extraPortals = with pkgs; [ xdg-desktop-portal-wlr ];
    };

    hardware = {
      graphics.enable = true;
      nvidia.modesetting.enable = true;
    };

    services.gnome.gnome-keyring.enable = true;
    programs.thunar.enable = true;

    environment.systemPackages = with pkgs; [
      mango # The core compositor
      wayland-pipewire-idle-inhibit
      waybar
      wofi
      fuzzel
      (pkgs.writeShellScriptBin "dfuzzel" ''
        ${fuzzel}/bin/fuzzel \
          --font 'Hack Nerd Font:size=20' \
          --width 30 \
          --lines 10 \
          --border-width 2 \
          --border-radius 8 \
          --prompt "Launch: " \
          --background 2e3440e6 \
          --text-color d8dee9ff \
          --match-color 88c0d0ff \
          --selection-color 4c566aff \
          --selection-text-color e5e9f0ff \
          --selection-match-color 8fbcbbff \
          --border-color 88c0d0ff "$@"
      '')
      swaynotificationcenter
      hyprpaper # Works fine on Mango (Wayland generic)
      hypridle
      playerctl
      brightnessctl
      wl-clipboard
      networkmanagerapplet
      blueman
      pavucontrol
      adwaita-icon-theme
      
      (pkgs.writeShellScriptBin "fix-audio-pipewire-pulse" ''
        sudo renice -n -11 `pgrep pipewire; pgrep wireplumber`
      '')
    ];

    # Greeting / Session Handling
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          # Launching Mango directly via tuigreet
          command = "${pkgs.tuigreet}/bin/tuigreet --remember --time --time-format \"%b %-d %I:%M:%S\" --cmd \"mango\"";
          user = "greeter";
        };
      };
    };

    system.activationScripts.link_mango_dir = {
      text = ''
        # if it is a directory, replace with link
        link_file="/home/drew/.config/mango"
        if [ -d "$link_file" ] && [ ! -L "$link_file" ]; then
          rm -rf "$link_file"
          /run/wrappers/bin/su - drew -s /bin/sh -c "ln -s /home/drew/playin/nixos_files/includes/desktop/mango $link_file";
        fi
      '';
    };


    system.activationScripts.mango_ln = {
      text = ''
        # if it exsists, and is not a link, dont do anything
        link_file="/home/drew/.config/mango"
        if [ ! -e "$link_file" ]; then
          /run/wrappers/bin/su - drew -s /bin/sh -c "ln -s ~/playin/nixos_files/includes/desktop/mango $link_file";
        fi
      '';
    };

    # Exporting wallpaper to a consistent location
    environment.etc."mango/wallpaper.jpg".source = "${wallpaper}";
  };
}

