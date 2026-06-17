{
  config,
    pkgs,
    lib, 
    inputs,
    ...
}:
let 
  desktop_environment = config.services.desktop_environment.selection;
  # hyprspaceConfig =''
  #   plugin = ${pkgs.hyprlandPlugins.hyprspace}/lib/libhyprspace.so
  # '';
  # hyprexpoConfig =''
  #   plugin = ${pkgs.hyprlandPlugins.hyprexpo}/lib/libhyprexpo.so
  # '';
  wallpaper = pkgs.fetchurl {
    url = "https://hot.andbrant.com/milkyway+C&H-nix.jpg";
    sha256 = "sha256-Xzlv420zq3SOcjDJU0mc7Cew9dNql0IvhQcSvTVbziM=";
  };
  monitor_file = "~/.config/hypr/monitors.${config.networking.hostName}.conf";
  extra_file_start = "~/.config/hypr/${config.networking.hostName}.extra.start.conf";
  extra_file_end = "~/.config/hypr/${config.networking.hostName}.extra.end.conf";

  watch_locks = pkgs.writeShellScriptBin "watch_locks" ''
    journalctl --user -u hypridle.service -b | awk "/(Wayland session got|Started Hyprland's idle daemon)/"
    journalctl --user -n 0 -fu hypridle.service -b | awk "/(Wayland session got|Started Hyprland's idle daemon)/"
  '';
in
{

  config = lib.mkIf ( "hyprland" == desktop_environment ) {

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    programs.hyprland = {
      enable = true;
      # withUWSM = true;
      xwayland.enable = true;

      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    };

    # screensharing from nixos site # TODO verify
    xdg.portal = {
      enable = true;
      extraPortals = [ 
        # pkgs.xdg-desktop-portal-hyprland
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk 
      ];
      config = {
        common = {
          # Use hyprland as the primary portal, fallback to gtk if hyprland doesn't implement a interface
          default = [ "hyprland" "gtk" ];
        };
        hyprland = {
          default = [ "hyprland" "gtk" ];
        };
      };
    };

    environment.sessionVariables = {
      # This helps apps find the desktop portals
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
    };

    hardware = {
      graphics.enable = true;
      nvidia.modesetting.enable = true;
    };

    # we need a keyring for some app login to work
    services.gnome.gnome-keyring.enable = true;

    # Enable the thumbnailer service
    services.tumbler.enable = true;
    # Ensure Thunar and its plugins are installed
    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
    services.gvfs.enable = true; # Helps with metadata and remote files
    environment.pathsToLink = [ "/share/thumbnailers" ]; # Links the actual thumbnailer logic

    # TODO switch this back to the regular environment.systemPackages when you can
    programs.waybar = {
      enable = true;
      package = pkgs.waybar.overrideAttrs (oldAttrs: {
        version = "v0.15.0";
        src = pkgs.fetchFromGitHub {
          owner = "Alexays";
          repo = "Waybar";
          # rev = "master"; 
          rev = "05945748dccce28bf96d26d8f64a9e69a8dd49ba"; 
          hash = "sha256-51R3mIt8cLNvh/X5qe9vOqeJCj0U9KRyemVE5y+OhiU="; # Replace with your actual hash once Nix gives it to you
        };
        # Add this line to tell Meson to skip building with CAVA support
        mesonFlags = (oldAttrs.mesonFlags or []) ++ [ "-Dcava=disabled" ];
      });
    };

    environment.systemPackages = with pkgs; [
      wayland-pipewire-idle-inhibit
      # hyprlandPlugins.hyprspace
      # hyprlandPlugins.hyprexpo
      # waybar # using programs.waybar now
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
      bemenu
      swaynotificationcenter
      hyprpaper
      hypridle
      playerctl
      brightnessctl
      wl-clipboard
      uwsm
      networkmanagerapplet
      blueman # start GUI with blueman-manager
      pavucontrol # audio control
      adwaita-icon-theme
      hyprshot
      # hyprshell # TODO add this to repo
      wlr-which-key

      watch_locks
      # move dispalys and change settings # make wraper to use specific file
      (pkgs.writeShellScriptBin "nwg-displays" ''
        ${nwg-displays}/bin/nwg-displays -m ${monitor_file}
      '')

      # select color from screen
      (pkgs.writeShellScriptBin "hyprpicker" ''
        nix-shell -p hyprpicker --command hyprpicker
      '')

      # fix audio breaking up in games... need to auto do this with rtkit somehow
      (pkgs.writeShellScriptBin "fix-audio-pipewire-pulse" ''
        sudo renice -n -11 `pgrep pipewire; pgrep wireplumber`
      '')

    ];


    programs.hyprlock.enable = true;
    security.pam.services.hyprlock = {};

    services.displayManager.defaultSession = "hyprland";

    programs.regreet = {
      cageArgs = [ "-m" "last" ]; # Forces cage onto a single connected display
      enable = true;
      # 1. Force Dark Mode via GTK Settings
      settings = {
        GTK = {
          application_prefer_dark_theme = true;
        };
        skip_selection = true;
      };
      # 2. Pick a Dark-friendly GTK theme (Adwaita is built-in and works great)
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
      font = {
        name = "Cantarell";
        size = 16;
      };
    };

    # services.greetd = let 
    #   # tuigreet_command = "${pkgs.uwsm}/bin/uwsm start start-hyprland";
    #   # command = ''
    #   #   ${pkgs.tuigreet}/bin/tuigreet --remember --time --time-format "%b %-d %I:%M:%S" --cmd "${tuigreet_command}"
    #   # '';
    #   # command = "${pkgs.tuigreet}/bin/tuigreet --remember --time --time-format \"%b %-d %I:%M:%S\" --cmd \"${pkgs.mangowc}/bin/mango\"";
    #   command = "${pkgs.regreet}/bin/regreet";
    # in {
    #   enable = true;
    #   settings = {
    #     default_session = {
    #       # 'command' tells greetd which greeter to use and what to launch afterwards.
    #       # We're using agreety, and telling it to execute Hyprland directly.
    #       inherit command;
    #       user = "greeter";
    #     };
    #   };
    # };

    # this failed at least once
    # try to fix showing startup logs on tuigreet
    systemd.services.greetd = {
      serviceConfig = {
        Type = "idle";
      };
    };

  security.pam.services.greetd.enableGnomeKeyring = true;

  environment.etc."greetd/environments".text = ''
    bash
    hyprland
  '';
  
  # environment.etc."hypr/hyprspace".source = "${pkgs.hyprlandPlugins.hyprspace}/lib/libhyprspace.so";
  # environment.etc."hypr/hyprexpo".source = "${pkgs.hyprlandPlugins.hyprexpo}/hyprexpo/lib/libhyprexpo.so";
  environment.etc."hypr/wallpaper.jpg".source = "${wallpaper}";

  # Mount the Hyprland configuration file
  # environment.etc."hypr/hyprspace.conf".text = hyprspaceConfig;
  # environment.etc."hypr/hyprexpo.conf".text = hyprexpoConfig;

   
  # this should be the first hyprland activationScripts
  system.activationScripts.link_hyprland_dir = {
    text = ''
      # if it is a directory, replace with link
      link_file="/home/drew/.config/hypr"
      if [ -d "$link_file" ] && [ ! -L "$link_file" ]; then
        rm -rf "$link_file"
        /run/wrappers/bin/su - drew -s /bin/sh -c "ln -s /home/drew/playin/nixos_files/includes/desktop/hypr $link_file";
      fi
    '';
  };

  system.activationScripts.hypr_ln = {
    text = ''
      # if it exsists, and is not a link, dont do anything
      link_file="/home/drew/.config/hypr"
      if [ ! -e "$link_file" ]; then
        /run/wrappers/bin/su - drew -s /bin/sh -c "ln -s ~/playin/nixos_files/includes/desktop/hypr $link_file";
      fi
    '';
  };

  system.activationScripts.hypr_monitor_ln = {
    text = ''
      # if it exsists, and is not a link, dont do anything
      link_file="/home/drew/.config/hypr/monitors.conf"
      if [ ! -e "$link_file" ]; then
        /run/wrappers/bin/su - drew -s /bin/sh -c "ln -s ${monitor_file} $link_file";
      fi
      if [ ! -e "${monitor_file}" ]; then
        /run/wrappers/bin/su - drew -s /bin/sh -c "touch ${monitor_file}";
      fi
    '';
  };

  system.activationScripts.hypr_extra_files = {
    text = ''
      # if it exsists, and is not a link, dont do anything
      link_file_start="/home/drew/.config/hypr/extra_start.conf"
      link_file_end="/home/drew/.config/hypr/extra_end.conf"
      if [ ! -e "$link_file_start" ]; then
        /run/wrappers/bin/su - drew -s /bin/sh -c "ln -s ${extra_file_start} $link_file_start";
      fi
      if [ ! -e "$link_file_end" ]; then
        /run/wrappers/bin/su - drew -s /bin/sh -c "ln -s ${extra_file_end} $link_file_end";
      fi
      if [ ! -e "${extra_file_start}" ]; then
        /run/wrappers/bin/su - drew -s /bin/sh -c "touch ${extra_file_start}";
      fi
      if [ ! -e "${extra_file_end}" ]; then
        /run/wrappers/bin/su - drew -s /bin/sh -c "touch ${extra_file_end}";
      fi
    '';
  };

  system.activationScripts.wallpaper = {
    text = ''
      link_file="/home/drew/.config/hypr/hyprpaper/wallpaper.jpg"
      toss=$(rm -rf $link_file; true)
      /run/wrappers/bin/su - drew -s /bin/sh -c "ln -s /etc/hypr/wallpaper.jpg $link_file";
    '';
  };

  };
}
