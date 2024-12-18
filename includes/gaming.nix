{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    protonup
    mangohud
    # steam is set below
  ];

  ### gaming ###

  # config.environment.sessionVariables = {
  #   STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  # };

  # hardware.graphics = {
  hardware.opengl = {
    # enable = true;
    # enable32Bit = true;
    # driSupport = true; # removed at request of nixos-rebuild
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;

  # TODO move this to a nvidia file? 
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.open = false; # use non-free drivers

  programs.gamemode.enable = true;

  ### gaming ###
}
