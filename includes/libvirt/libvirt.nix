# man systemd-socket-proxyd
{
  # config,
  pkgs,
  ...
}: {
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.drew = {
    extraGroups = [ 
      "libvirtd" 
    ];
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    virt-manager
    qemu
  ];

}
