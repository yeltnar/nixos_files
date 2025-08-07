{
  config,
    pkgs,
    lib, 
    ...
}:
let 
  desktop_environment = config.services.desktop_environment.selection;
  hyprspaceConfig =''
    plugin = ${pkgs.hyprlandPlugins.hyprspace}/lib/libhyprspace.so
  '';
  hyprexpoConfig =''
    plugin = ${pkgs.hyprlandPlugins.hyprexpo}/lib/libhyprexpo.so
  '';
  wallpaper = pkgs.fetchurl {
    url = "https://hot.andbrant.com/milkyway+C&H-nix.jpg";
    sha256 = "sha256-Xzlv420zq3SOcjDJU0mc7Cew9dNql0IvhQcSvTVbziM=";
  };
  monitor_file = "~/.config/hypr/monitors.${config.networking.hostName}.conf";
in
{

  config = lib.mkIf ( "hyprland" == desktop_environment ) {

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    # TODO move settings to nix repo
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    # screensharing from nixos site # TODO verify
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
    };

    hardware = {
      graphics.enable = true;
      nvidia.modesetting.enable = true;
    };

    # we need a keyring for some app login to work
    services.gnome.gnome-keyring.enable = true;

    environment.systemPackages = with pkgs; [
      wayland-pipewire-idle-inhibit
      hyprlandPlugins.hyprspace
      hyprlandPlugins.hyprexpo
      waybar
      wofi
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
      kdePackages.dolphin

      # move dispalys and change settings # make wraper to use specific file
      (pkgs.writeShellScriptBin "nwg-displays" ''
        ${nwg-displays}/bin/nwg-displays -m ${monitor_file}
      '')

      # select color from screen
      (pkgs.writeShellScriptBin "hyprpicker" ''
        nix-shell -p hyprpicker --command hyprpicker
      '')
    ];


    programs.hyprlock.enable = true;
    security.pam.services.hyprlock = {};

    services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # 'command' tells greetd which greeter to use and what to launch afterwards.
        # We're using agreety, and telling it to execute Hyprland directly.
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --time --time-format \"%b %-d %I:%M:%S\" --cmd \"${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop\"";
        user = "greeter";
      };
    };
  };

  security.pam.services.greetd.enableGnomeKeyring = true;

  environment.etc."greetd/environments".text = ''
    bash
    hyprland
  '';
  
  environment.etc."hypr/hyprspace".source = "${pkgs.hyprlandPlugins.hyprspace}/lib/libhyprspace.so";
  environment.etc."hypr/hyprexpo".source = "${pkgs.hyprlandPlugins.hyprexpo}/hyprexpo/lib/libhyprexpo.so";
  environment.etc."hypr/wallpaper.jpg".source = "${wallpaper}";

  # Mount the Hyprland configuration file
  environment.etc."hypr/hyprspace.conf".text = hyprspaceConfig;
  environment.etc."hypr/hyprexpo.conf".text = hyprexpoConfig;

   
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
    '';
  };

  };
}
