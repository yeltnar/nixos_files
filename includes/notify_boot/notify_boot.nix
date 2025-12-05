{
  config,
  pkgs,
  ...
}: let 
  script = pkgs.writeShellScript "notify_boot" ''
    export bashrc_folder="/home/drew/playin/custom_bashrc"
    export PATH="$bashrc_folder/bin:$PATH:${pkgs.curl}/bin:${pkgs.coreutils-full}/bin"
    /home/drew/playin/custom_bashrc/bin/send_push "${config.networking.hostName}" "booted"
  '';
in{
  imports = [ ../nm-online.service.nix ];

  systemd.user.services."notify_boot" = {
    description = "Notify when system boots";
    after = ["nm-online.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true; 
      ExecStart = "${script}"; 
    };
    wantedBy = [ "multi-user.target" ];
  };
}
