{
  config,
  pkgs,
  lib,
  ...
}:
let
  desktop_environment = config.services.desktop_environment.selection;
  wallpaper = pkgs.fetchurl {
    url = "https://hot.andbrant.com/milkyway+C&H-nix.jpg";
    sha256 = "sha256-Xzlv420zq3SOcjDJU0mc7Cew9dNql0IvhQcSvTVbziM=";
  };
in
{

  config = lib.mkIf ( "mangowc" == desktop_environment ) {

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # screensharing from nixos site # TODO verify
    xdg.portal = {
      enable = true;
      # extraPortals = with pkgs; [ 
      #   xdg-desktop-portal-hyprland 
      # ];
    };

    hardware = {
      graphics.enable = true;
      nvidia.modesetting.enable = true;
    };

    # we need a keyring for some app login to work
    services.gnome.gnome-keyring.enable = true;

    programs.thunar.enable = true;

    environment.systemPackages = with pkgs; [
      mangowc

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
      bemenu
      swaynotificationcenter
      playerctl
      brightnessctl
      wl-clipboard
      uwsm
      networkmanagerapplet
      blueman # start GUI with blueman-manager
      pavucontrol # audio control
      adwaita-icon-theme
      # hyprshell # TODO add this to repo
      wlr-which-key

      # move dispalys and change settings # make wraper to use specific file
      (pkgs.writeShellScriptBin "nwg-displays" ''
        ${nwg-displays}/bin/nwg-displays -m ${monitor_file}
      '')

      # fix audio breaking up in games... need to auto do this with rtkit somehow
      (pkgs.writeShellScriptBin "fix-audio-pipewire-pulse" ''
        sudo renice -n -11 `pgrep pipewire; pgrep wireplumber`
      '')

    ];

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          # 'command' tells greetd which greeter to use and what to launch afterwards.
          command = "${pkgs.tuigreet}/bin/tuigreet --remember --time --time-format \"%b %-d %I:%M:%S\" --cmd \"${pkgs.mangowc}/bin/mango\"";
          _command = "${pkgs.regreet}/bin/regreet";
          user = "greeter";
        };
      };
    };

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
  
  # this should be the first mangoland activationScripts
  system.activationScripts.link_mangoland_dir = {
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

  # system.activationScripts.wallpaper = {
  #   text = ''
  #     link_file="/home/drew/.config/hypr/hyprpaper/wallpaper.jpg"
  #     toss=$(rm -rf $link_file; true)
  #     /run/wrappers/bin/su - drew -s /bin/sh -c "ln -s /etc/hypr/wallpaper.jpg $link_file";
  #   '';
  # };

  };
}
