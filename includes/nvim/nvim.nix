{
  pkgs,
  ...
}:{
  environment.systemPackages = with pkgs; [
    # see about moving to nvim section 
    lua-language-server
    nixd
    stylua
    nodejs # needed for some packages
    clang # needed to compile c # used by nvim 
    ripgrep
  ];

  programs.neovim = {
    enable = true;
    # package = unstable.neovim-unwrapped;
    package = pkgs.neovim-unwrapped;
    defaultEditor = true;
    vimAlias = true; 
    viAlias = true; 
  };
}
