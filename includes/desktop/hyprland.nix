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
  };
}
