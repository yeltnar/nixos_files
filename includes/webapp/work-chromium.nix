{
  config,
  pkgs,
  ...
}:
let 
  # TODO fix the $
  cmd = ''${pkgs.chromium}/bin/chromium --user-data-dir=${config.users.users.drew.home}/.config/teams'';
  cmd_pkg = pkgs.writeShellScriptBin "work-chromium" cmd; 
in
{
  environment.systemPackages = [
    (pkgs.makeDesktopItem {
        name = "Work Chromium";
        desktopName = "Work Chromium";
        comment = "A feature-rich client for Matrix.org";
        genericName = "Matrix Client";
        # TODO
        # mimeTypes=["x-scheme-handler/element" "x-scheme-handler/io.element.desktop"];
        exec = "${cmd} %u";
        # TODO 
        # icon = "${pkgs.element-desktop}/share/icons/hicolor/128x128/apps/element.png";
        terminal = false;
        categories = [ "Network" "InstantMessaging" "Chat" ];
        startupWMClass="work-chromium";
        type="Application";
    })
    cmd_pkg
  ];
}
