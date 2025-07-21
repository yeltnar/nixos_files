{
  config,
    pkgs,
    lib, 
    ...
}:
let 
  desktop_environment = config.services.desktop_environment.selection;
in {

  config = lib.mkIf ( "hyprland" == desktop_environment ) {

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    hardware = {
      opengl.enable = true;
      nvidia.modesetting.enable = true;
    };

    environment.systemPackages = [
      pkgs.waybar
    ];

    services.xserver.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
}
