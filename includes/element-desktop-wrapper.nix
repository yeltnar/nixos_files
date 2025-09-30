{
  pkgs,
  ...
}:
let 
  cmd = "${pkgs.element-desktop}/bin/element-desktop --password-store=\"gnome-libsecret\"";
  cmd_pkg = pkgs.writeShellScriptBin "element-desktop" cmd; 
in
{
  environment.systemPackages = [
    (pkgs.makeDesktopItem {
        name = "Element";
        desktopName = "Element";
        comment = "A feature-rich client for Matrix.org";
        genericName = "Matrix Client";
        mimeTypes=["x-scheme-handler/element" "x-scheme-handler/io.element.desktop"];
        exec = "${cmd} %u";
        icon = "${pkgs.element-desktop}/share/icons/hicolor/128x128/apps/element.png";
        terminal = false;
        categories = [ "Network" "InstantMessaging" "Chat" ];
        startupWMClass="Element";
        type="Application";
    })
    cmd_pkg
  ];
}
