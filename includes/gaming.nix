{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    keybase
    keybase-gui

    slack
    element-desktop

    mullvad-vpn

    protonup
    # steam is set below
  ];

  ### gaming ###

  # config.environment.sessionVariables = {
  #   STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  # };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;

  programs.gamemode.enable = true;

  ### gaming ###
}
