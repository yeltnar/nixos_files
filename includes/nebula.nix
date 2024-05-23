{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./update_nebula/update_nebula_systemd.nix
    # TODO fix... this is preventing booting (I guess thats what activation scripts do when they fail)
    # ./update_nebula/install_update_nebula.nix
  ];

  environment.systemPackages = with pkgs; [
    nebula
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

  # */5 * * * * bash -c 'export SUDO_USER="drew"; cd /var/yeltnar-nebula; ./compare_date.sh 2>&1 > ./compare_date.log'
}
