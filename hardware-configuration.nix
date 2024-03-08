{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  fileSystems."/home/drew/disk_test/mnt" = {
    device = "/home/drew/disk_test/to_squash.sqsh";
    fsType = "squashfs";
    options = ["loop"];
  };
}
