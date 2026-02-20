{
  config,
  pkgs,
  ...
}:
let 
  # TODO fix the $
  # cmd = ''${pkgs.chromium}/bin/chromium --user-data-dir="$HOME/.config/teams" --app="https://teams.microsoft.com"'';
  cmd = ''${pkgs.chromium}/bin/chromium --user-data-dir=${config.users.users.drew.home}/.config/teams --app=https://teams.microsoft.com'';
  cmd_pkg = pkgs.writeShellScriptBin "teams-webapp" cmd; 
in
{
  environment.systemPackages = [
    (pkgs.makeDesktopItem {
        name = "Teams-Webapp";
        desktopName = "Teams-Webapp";
        comment = "A feature-rich client for Matrix.org";
        genericName = "Matrix Client";
        # TODO setup for teams
        # mimeTypes=["x-scheme-handler/element" "x-scheme-handler/io.element.desktop"];
        exec = "${cmd} %u";
        # TODO 
        # icon = "${pkgs.element-desktop}/share/icons/hicolor/128x128/apps/element.png";
        terminal = false;
        categories = [ "Network" "InstantMessaging" "Chat" ];
        startupWMClass="teams-webapp";
        type="Application";
    })
    cmd_pkg
  ];
}
