{
  config,
  pkgs,
  ...
}: {
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    lazygit
    nodejs_20
    dig
    websocat
    ansible
    python3

    wireshark
    usbutils # has lsusb

    # libreoffice with spell check
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
  ];
}
