{
  config,
  pkgs,
  ...
}: {
  systemd.services.wedding_site-git-repo = {
    description = "wedding_site-git-repo";
    wants = ["basic.target"];
    requires = ["network-online.target"];
    after = ["basic.target" "network-online.target"];
    wantedBy = ["multi-user.target"];
    unitConfig = {
      ConditionPathExists = "!/tmp/wedding_site";
    };
    serviceConfig = {
      User = "drew";
      SyslogIdentifier = "wedding_site";
      WorkingDirectory = "/tmp";
      ExecStart = "/run/current-system/sw/bin/git clone https://github.com/yeltnar/wedding_site";
    };
  };

  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/current-system/sw/bin"
  '';

  systemd.services.wedding_site_start = {
    path = with pkgs; [
      podman
      podman-compose
    ];

    description = "Podman container-1b04c16fe8c6e6fe62d99666001e4d899057def07f1237a4fed270fd5a52bf04.service";
    wants = ["network-online.target"];
    # After = ["network-online.target"];
    # RequiresMountsFor = "/run/user/1000/containers";

    requires = ["wedding_site-git-repo.service"];
    after = ["wedding_site-git-repo.service" "podman.service" "podman.socket"];
    wantedBy = ["default.target"];
    unitConfig = {
      ConditionPathExists = "/tmp/wedding_site";
    };
    script = ''
      podman-compose up -d;
    '';
    serviceConfig = {
      TimeoutStopSec = "70";
      Restart = "on-failure";
      # ExecStart = "/run/current-system/sw/bin/podman start 1b04c16fe8c6e6fe62d99666001e4d899057def07f1237a4fed270fd5a52bf04";
      # ExecStop = "/run/current-system/sw/bin/podman stop -t 10 1b04c16fe8c6e6fe62d99666001e4d899057def07f1237a4fed270fd5a52bf04";
      # ExecStopPost = "/run/current-system/sw/bin/podman stop -t 10 1b04c16fe8c6e6fe62d99666001e4d899057def07f1237a4fed270fd5a52bf04";
      # PIDFile = "/run/user/1000/containers/overlay-containers/1b04c16fe8c6e6fe62d99666001e4d899057def07f1237a4fed270fd5a52bf04/userdata/conmon.pid";
      Type = "forking";

      Environment = "PODMAN_SYSTEMD_UNIT=%n";
      # Environment = "\"PATH=/run/current-system/sw/bin\"";
      User = "drew";
      SyslogIdentifier = "wedding_site";
      WorkingDirectory = "/tmp/wedding_site";
      # ExecStart = "podman-compose up -d";
      # ExecStart = "ls";
    };
  };
}
