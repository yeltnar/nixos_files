{
  config,
  pkgs,
  ...
}: let 
  script = pkgs.writeShellScript "notify_boot" ''
    export bashrc_folder="/home/drew/playin/custom_bashrc"
    export PATH="$bashrc_folder/bin:$PATH:${pkgs.curl}/bin:${pkgs.coreutils-full}/bin"
    /home/drew/playin/custom_bashrc/bin/send_push "${config.networking.hostName}" "booted $(date)"
  '';
in{
  # imports = [ ../nm-online.service.nix ];

  imports = [
    # these scripts depend on some custom scripts, so need this setup
    ../../includes/custom_bashrc.nix
  ];

  systemd.services."notify_boot" = {
    description = "Notify when system boots";
    after = ["network-online.target"];
    requires = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true; 
      ExecStart = "${script}"; 
      ExecStartPre = pkgs.writeScript "check-dir-exists" ''
        #!${pkgs.bash}/bin/bash
        dir="/home/drew/playin/custom_bashrc/"
        while [ ! -d "$dir" ]; do
          echo "Waiting for $dir"
          sleep 10
        done
      '';
    };
    wantedBy = [ 
      "default.target" 
      "multi-user.target" 
    ];
  };
}
