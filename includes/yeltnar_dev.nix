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
  ];
}
