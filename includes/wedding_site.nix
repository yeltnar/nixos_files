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

    script = ''
      podman-compose up
    '';

    wantedBy = ["multi-user.target"];
    # If you use podman
    requires = ["wedding_site-git-repo.service" "podman.service" "podman.socket"];
    unitConfig = {
      ConditionPathExists = "/tmp/wedding_site";
    };
    serviceConfig = {
      User = "drew";
      # Type = "forking";
      WorkingDirectory = "/tmp/wedding_site";
    };
  };
}
