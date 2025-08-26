{ pkgs, ... }:

{
  systemd.user.services.nm-online = {
    description = "Wait for NetworkManager to report online";
    # removed because I don't think it does anything 
    # after = [ "network-online.target" ];
    wantedBy = [ "default.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.networkmanager}/bin/nm-online --timeout=60";
      Type = "oneshot";
    };
  };
}
