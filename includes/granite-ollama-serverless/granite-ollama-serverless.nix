# man systemd-socket-proxyd
{
  # config,
  pkgs,
  ...
}: {
  networking.firewall.allowedTCPPorts = [
  8080 # port for container
  # 11434 # port for container
  8443 # port for user service  
  443 # port for system service
  ];

  # enable lingering so service starts before user logs in
  users.users.drew.linger = true;

  systemd.sockets.granite-ollama_serverless = {
    requires = [
      "network-online.target"
      "default.target"
    ]; 
    wantedBy = [
      "default.target"
      "sockets.target"
      "multi-user.target"
    ];
    listenStreams = [
      "443"
    ];
  };

  systemd.services.granite-ollama_serverless = {
    serviceConfig = { 
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=10s 127.0.0.1:8443";
    };
  };

  systemd.user.sockets.granite-ollama_serverless = {
    requires = [
      # "network-online.target"
      "default.target"
    ]; # TODO make sure this is there, if starting at boot 
    wantedBy = [
      "default.target"
      "sockets.target"
      "multi-user.target"
    ];
    listenStreams = [
      # "127.0.0.1:8443"
      "8443"
      # "192.168.2.180:9999"
      # "8080"
    ];
  };

  systemd.user.services.granite-ollama_serverless = {
    requires = [
      "granite-ollama_start_ollama.service"
      "granite-ollama_start_open-webui.service"
      "granite-ollama_serverless.socket"
    ];
    after = [
      "granite-ollama_start_ollama.service"
      "granite-ollama_start_open-webui.service"
      "granite-ollama_serverless.socket"
    ];

    serviceConfig = { 
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=180s 127.0.0.1:8080";
    };
  };

  systemd.services.granite-ollama-git-repo = {
    path = with pkgs; [
      git
    ];
    description = "granite-ollama-git-repo";
    wants = ["basic.target"];
    requires = ["network-online.target"];
    after = ["basic.target" "network-online.target"];
    wantedBy = ["multi-user.target"];
    unitConfig = {
      ConditionPathExists = "!/tmp/granite-ollama";
    };
    script = ''
      /run/wrappers/bin/su - drew -s /bin/sh -c 'cd /tmp/; git clone https://github.com/yeltnar/granite-ollama';
    '';
    serviceConfig = {
      Type = "oneshot";
      SyslogIdentifier = "granite-ollama";
      WorkingDirectory = "/tmp";
      # ExecStartPost = "systemctl start granite-ollama_start.service";
    };
  };

  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/current-system/sw/bin"
  '';

  systemd.user.services.granite-ollama_start_ollama = {
    path = with pkgs; [
      podman
      podman-compose
    ];
    requires = ["podman.service" "podman.socket"];
    # WARNING this process can not self re-start, or it will confuse the serverless aspect
    script = ''
      PATH="$PATH:${pkgs.podman}/bin";
      ${pkgs.podman-compose}/bin/podman-compose --podman-run-args="--replace --sdnotify=container --pidfile=/tmp/systemd_proxy_ollama_podman.pid --replace" up --no-recreate -d ollama
      
      podman-compose logs -f open-webui 2>&1 | while IFS= read -r line; do
        # Process the line
        if [[ "$line" == *"Uvicorn running on"* ]]; then
          echo "Found a match: $line"
          # Take action, e.g., run another command
          systemd-notify --ready --status="container up"
        else
          echo "x-$line"
        fi
      done

    '';
    # wantedBy = ["multi-user.target"];
    unitConfig = {
      StopWhenUnneeded = "yes";
      StartLimitInterval = 30;
      StartLimitBurst = 3;
      ConditionPathExists = "/tmp/granite-ollama";
      RequiresMountsFor = "/run/user/1000/containers";
    };
    serviceConfig = {
      Type = "notify";
      WorkingDirectory = "/tmp/granite-ollama"; # TODO change repo location
      Restart = "always";
      NotifyAccess = "all";
      # PIDFile = "/tmp/systemd_proxy_ollama_podman.pid"; # TODO change pid location 
    };
  };

  # TODO create exit scripts for containers 
  # pkgs.writeShellScript = "stop-granite-ollama_start_open-webui" ''
  #   PATH="$PATH:${pkgs.podman}/bin";
  #   ${pkgs.podman-compose}/bin/podman-compose --podman-run-args="--replace --sdnotify=container --pidfile=/tmp/systemd_proxy_open-webui_podman.pid --replace" down --no-recreate -d open-webui
  # '';

  systemd.user.services.granite-ollama_start_open-webui = {
    path = with pkgs; [
      podman
      podman-compose
    ];
    requires = ["podman.service" "podman.socket"];
    # WARNING this process can not self re-start, or it will confuse the serverless aspect
    script = ''
      PATH="$PATH:${pkgs.podman}/bin";
      ${pkgs.podman-compose}/bin/podman-compose --podman-run-args="--replace --sdnotify=container --pidfile=/tmp/systemd_proxy_open-webui_podman.pid --replace" up --no-recreate -d open-webui
    '';
    # wantedBy = ["multi-user.target"];
    unitConfig = {
      StopWhenUnneeded = "yes";
      StartLimitInterval = 30;
      StartLimitBurst = 3;
      ConditionPathExists = "/tmp/granite-ollama";
      RequiresMountsFor = "/run/user/1000/containers";
    };
    serviceConfig = {
      # Type = "simple";
      ExecStop = ""; # TODO 
      WorkingDirectory = "/tmp/granite-ollama"; # TODO change repo location
      Restart = "always";
      NotifyAccess = "all";
      # PIDFile = "/tmp/systemd_proxy_open-webui_podman.pid"; # TODO change pid location 
    };
  };
}
