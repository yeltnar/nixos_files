{
  config,
  pkgs,
  ...
}: {
  security.sudo = {
    extraRules = [
      {
        users = ["drew"];
        commands = [
          {
            command = "/run/current-system/sw/bin/tlp-stat";
            options = ["NOPASSWD"];
          }
          {
            command = "/run/current-system/sw/bin/tlp";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
  };

  # gnome power management conflicts with tlp
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
      STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
    };
  };
}
