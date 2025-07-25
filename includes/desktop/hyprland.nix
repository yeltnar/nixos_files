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
    # TODO add settings to nix 
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    hardware = {
      graphics.enable = true;
      nvidia.modesetting.enable = true;
    };

    environment.systemPackages = with pkgs; [
      waybar # TODO add settings to nix 
      hyprlandPlugins.hyprspace
      hyprlandPlugins.hyprexpo
      wofi # TODO add settings to nix 
      hyprpaper
      hypridle
      playerctl
      wl-clipboard
      networkmanagerapplet
      blueman # start GUI with blueman-manager
      pavucontrol # audio control
      adwaita-icon-theme
    ];

    programs.hyprlock.enable = true;
    security.pam.services.hyprlock = {};

    services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # 'command' tells greetd which greeter to use and what to launch afterwards.
        # We're using agreety, and telling it to execute Hyprland directly.
        # command = "${pkgs.greetd.greetd}/bin/agreety --cmd ${pkgs.hyprland}/bin/hyprland";
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --time --cmd ${pkgs.hyprland}/bin/hyprland";
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

  # TODO link these files to the correct directory

  };
}
