# man systemd-socket-proxyd
{
  # config,
  pkgs,
  ...
}: let
  code_parent_dir="/home/drew/playin";
  code_dir="${code_parent_dir}/granite-ollama";  
in {
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

  # serverless socket setup dedicated to ollama
  systemd.user.sockets.granite-ollama_small_serverless = {
    requires = [
      # "network-online.target"
      "default.target"
    ]; 
    wantedBy = [
      "default.target"
      "sockets.target"
      "multi-user.target"
    ];
    listenStreams = [
      # "127.0.0.1:8443"
      "11435"
      # "192.168.2.180:9999"
      # "8080"
    ];
  };

  systemd.user.services.granite-ollama_small_serverless = {
    requires = [
      # "granite-ollama_start_llama-cpp.service"
      "granite-ollama_start_ollama.service"
      "granite-ollama_small_serverless.socket"
    ];
    after = [
      # "granite-ollama_start_llama-cpp.service"
      "granite-ollama_start_ollama.service"
      "granite-ollama_small_serverless.socket"
    ];

    serviceConfig = { 
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=180s 127.0.0.1:11434";
    };
  };


  systemd.user.sockets.granite-llama-cpp_small_serverless = {
    requires = [
      # "network-online.target"
      "default.target"
    ]; 
    wantedBy = [
      "default.target"
      "sockets.target"
      "multi-user.target"
    ];
    listenStreams = [
      # "127.0.0.1:8443"
      "8082"
      # "192.168.2.180:9999"
      # "8080"
    ];
  };
  systemd.user.services.granite-llama-cpp_small_serverless = {
    requires = [
      # "granite-llama-cpp_start_llama-cpp.service"
      "granite-ollama_start_llama-cpp.service"
      "granite-llama-cpp_small_serverless.socket"
    ];
    after = [
      # "granite-llama-cpp_start_llama-cpp.service"
      "granite-ollama_start_llama-cpp.service"
      "granite-llama-cpp_small_serverless.socket"
    ];
    serviceConfig = { 
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=180s 127.0.0.1:8081";
    };
  };




  # serverless socket setup for open-webui, and ollama
  systemd.user.sockets.granite-ollama_serverless = {
    requires = [
      # "network-online.target"
      "default.target"
    ]; 
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
      # "granite-ollama_start_llama-cpp.service"
      "granite-ollama_start_ollama.service"
      "granite-ollama_start_open-webui.service"
      "granite-ollama_serverless.socket"
    ];
    after = [
      # "granite-ollama_start_llama-cpp.service"
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
      ConditionPathExists = "!${code_dir}";
    };
    script = ''
      /run/wrappers/bin/su - drew -s /bin/sh -c 'cd ${code_parent_dir}/; git clone https://github.com/yeltnar/granite-ollama';
    '';
    serviceConfig = {
      Type = "oneshot";
      SyslogIdentifier = "granite-ollama";
      WorkingDirectory = "${code_parent_dir}";
      # ExecStartPost = "systemctl start granite-ollama_start.service";
    };
  };

  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/current-system/sw/bin"
  '';

  systemd.user.services.granite-ollama_start_llama-cpp = {
    path = with pkgs; [
      podman
      podman-compose
    ];
    # for some reason when I have this turned on, podman networking breaks
    # requires = ["podman.service" "podman.socket"];
    # WARNING this process can not self re-start, or it will confuse the serverless aspect
    script = ''
      PATH="$PATH:${pkgs.podman}/bin";
      ${pkgs.podman-compose}/bin/podman-compose down llama-cpp
      ${pkgs.podman-compose}/bin/podman-compose --podman-run-args="--replace --sdnotify=container --pidfile=/tmp/systemd_proxy_llama-cpp_podman.pid --gpus=all" up --no-recreate -d llama-cpp

      podman-compose logs -f llama-cpp 2>&1 | while IFS= read -r line; do
        # Process the line
        if [[ "$line" == *"listening on"* ]]; then
          echo "Found a match: $line"
          # Take action, e.g., run another command
          systemd-notify --ready --status="container up"
          break
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
      ConditionPathExists = "${code_dir}";
      RequiresMountsFor = "/run/user/1000/containers";
    };
    serviceConfig = {
      Type = "notify";
      WorkingDirectory = "${code_dir}";
      Restart = "always";
      NotifyAccess = "all";
      PIDFile = "/tmp/systemd_proxy_llama-cpp_podman.pid"; # TODO change pid location 
      ExecStop = pkgs.writeShellScript "stop-granite-llama-cpp_start_open-webui" ''
        PATH="$PATH:${pkgs.podman}/bin";
        ${pkgs.podman-compose}/bin/podman-compose down llama-cpp
      '';
    };
  };

  systemd.user.services.granite-ollama_start_ollama = {
    path = with pkgs; [
      podman
      podman-compose
    ];
    # for some reason when I have this turned on, podman networking breaks
    # requires = ["podman.service" "podman.socket"];
    # WARNING this process can not self re-start, or it will confuse the serverless aspect
    script = ''
      PATH="$PATH:${pkgs.podman}/bin";
      ${pkgs.podman-compose}/bin/podman-compose down ollama
      ${pkgs.podman-compose}/bin/podman-compose --podman-run-args="--replace --sdnotify=container --pidfile=/tmp/systemd_proxy_ollama_podman.pid --gpus=all" up --no-recreate -d ollama


      podman-compose logs -f ollama 2>&1 | while IFS= read -r line; do
        # Process the line
        if [[ "$line" == *"Listening on"* ]]; then
          echo "Found a match: $line"
          # Take action, e.g., run another command
          systemd-notify --ready --status="container up"
          break
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
      ConditionPathExists = "${code_dir}";
      RequiresMountsFor = "/run/user/1000/containers";
    };
    serviceConfig = {
      Type = "notify";
      WorkingDirectory = "${code_dir}";
      Restart = "always";
      NotifyAccess = "all";
      PIDFile = "/tmp/systemd_proxy_ollama_podman.pid"; # TODO change pid location 
      ExecStop = pkgs.writeShellScript "stop-granite-ollama_start_open-webui" ''
        PATH="$PATH:${pkgs.podman}/bin";
        ${pkgs.podman-compose}/bin/podman-compose down ollama
      '';
    };
  };

  systemd.user.services.granite-ollama_start_open-webui = {
    path = with pkgs; [
      podman
      podman-compose
    ];
    # for some reason when I have this turned on, podman networking breaks
    # requires = ["podman.service" "podman.socket"];
    # WARNING this process can not self re-start, or it will confuse the serverless aspect
    script = ''
      PATH="$PATH:${pkgs.podman}/bin";
      ${pkgs.podman-compose}/bin/podman-compose down open-webui 
      ${pkgs.podman-compose}/bin/podman-compose --podman-run-args="--replace --sdnotify=container --pidfile=/tmp/systemd_proxy_open-webui_podman.pid" up --no-recreate -d open-webui

      podman-compose logs -f open-webui 2>&1 | while IFS= read -r line; do
        # Process the line
        if [[ "$line" == *"Started server process"* ]]; then
          echo "Found a match: $line"
          # Take action, e.g., run another command
          systemd-notify --ready --status="container up"
          break
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
      ConditionPathExists = "${code_dir}";
      RequiresMountsFor = "/run/user/1000/containers";
    };
    serviceConfig = {
      Type = "notify";
      WorkingDirectory = "${code_dir}"; 
      Restart = "always";
      NotifyAccess = "all";
      PIDFile = "/tmp/systemd_proxy_open-webui_podman.pid"; # TODO change pid location  
      ExecStop = pkgs.writeShellScript "stop-granite-ollama_start_open-webui" ''
        PATH="$PATH:${pkgs.podman}/bin";
        ${pkgs.podman-compose}/bin/podman-compose down open-webui
      '';

    };
  };
}
