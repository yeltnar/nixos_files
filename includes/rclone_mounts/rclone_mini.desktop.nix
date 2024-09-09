{
  config,
  pkgs,
  ...
}: let
  host = "mini";
  user = "drew";
  port = "22";
  remote_dir = "/";
  local_dir = "/tmp/mini";
  private_key = "/home/drew/.ssh/id_ed25519";
  pub_cert = "/home/drew/.ssh/id_ed25519-cert.pub";
in {

### Add "rclone" to your packages first

# RClone Google Drive service
systemd.services.rclone-mini-mount = {
  # Ensure the service starts after the network is up
  wantedBy = [ "multi-user.target" ];
  after = [ "network-online.target" ];
  requires = [ "network-online.target" ];

  # Service configuration
  serviceConfig = {
    Type = "simple";
    ExecStartPre = "/run/current-system/sw/bin/mkdir -p ${local_dir}"; # Creates folder if didn't exist
    ExecStart = "${pkgs.rclone}/bin/rclone mount --vfs-cache-mode full --allow-other --sftp-key-file ${private_key} --sftp-pubkey-file ${pub_cert} --sftp-host ${host} --sftp-user ${user} --sftp-port ${port} :sftp:${remote_dir} ${local_dir}";
    ExecStop = "/run/current-system/sw/bin/fusermount -u ${local_dir}"; # Dismounts
    Restart = "on-failure";
    RestartSec = "10s";
    User = "drew";
    Group = "users";
    Environment = [ "PATH=/run/wrappers/bin/:$PATH" ]; # Required environments
  };
};

}
