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
      hyprlandPlugins.hyprspace
      hyprlandPlugins.hyprexpo
      waybar
      wofi
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
    ];

    # dont need if read from hypr dir
    # systemd.user.services.hyprpaper = {
    #   overrideStrategy = "asDropin";
    #   serviceConfig = { 
    #     Environment = [
    #             "XDG_CONFIG_HOME=%h/.config/hypr/hyprpaper"
    #     ]; 
    #   };
    # };

    systemd.user.services.waybar = {
      overrideStrategy = "asDropin";
      serviceConfig = { 
        Environment = [
                "XDG_CONFIG_HOME=%h/.config/hypr"
        ]; 
      };
    };

    systemd.user.services.hypridle = {
      overrideStrategy = "asDropin";
      serviceConfig = { 
        Environment = [
                "HYPRIDLE_CONFIG=%h/.config/hypr/hypridle.conf"
        ]; 
      };
    };

    programs.hyprlock.enable = true;
    security.pam.services.hyprlock = {};

    services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # 'command' tells greetd which greeter to use and what to launch afterwards.
        # We're using agreety, and telling it to execute Hyprland directly.
        # command = "${pkgs.greetd.greetd}/bin/agreety --cmd ${pkgs.hyprland}/bin/hyprland";
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --time --cmd \"${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop\"";
        user = "greeter"; # Or any user you want greetd to run the greeter as
                          # This user doesn't need to exist as a login user,
                          # greetd handles the actual user login.
      };
    };
  };

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

  };
}
