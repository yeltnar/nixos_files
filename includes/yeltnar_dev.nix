{
  config,
  pkgs,
  ...
}: {
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    lazygit
    nodejs_24
    dig
    websocat
    ansible
    python3
    netcat-gnu

    wireshark
    usbutils # has lsusb

    # android dev tools... found from nixos android page
    androidenv.androidPkgs.platform-tools

    # libreoffice with spell check
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
  ];
}
