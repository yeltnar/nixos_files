args@{
  config,
  pkgs,
  user,
  group ? "100",
  SECONDARY_HOST ? "hot.h.lan",
  DEVICE_NAME ? "${config.networking.hostName}",
  ...
}: {
  imports = [
    ./update_nebula_systemd.nix
    ( import ./install_update_nebula.nix (args // {
      user = user; 
      group = group; 
      SECONDARY_HOST = SECONDARY_HOST;
      DEVICE_NAME = DEVICE_NAME;
    }))
  ];

  environment.systemPackages = with pkgs; [
    nebula
    # openssh used for management encryption 
    openssh
  ];

  # [Unit]
  # Description=nebula
  # Wants=basic.target
  # After=basic.target network.target
  # Before=sshd.service

  # [Service]
  # SyslogIdentifier=nebula
  # ExecReload=/bin/kill -HUP $MAINPID
  # ExecStart=/usr/local/bin/nebula -config /etc/nebula/config.yml
  # Restart=always

  # [Install]
  # WantedBy=multi-user.target

  systemd.services.nebula = {
    path = with pkgs; [
      nebula
    ];
    description = "nebula daemon";
    wants = ["basic.target"];
    after = ["basic.target" "network.target"];
    before = ["sshd.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      SyslogIdentifier = "nebula";
      ExecReload = "kill -HUP $MAINPID";
      ExecStart = "${pkgs.nebula}/bin/nebula -config /etc/nebula/config.yml";
      Restart = "always";
    };
  };
}
