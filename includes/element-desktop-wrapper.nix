{pkgs}:(pkgs.makeDesktopItem {
    name = "Element";
    desktopName = "Element";
    comment = "A feature-rich client for Matrix.org";
    genericName = "Matrix Client";
    exec = "${pkgs.element-desktop}/bin/element-desktop --password-store=\"gnome-libsecret\"";
    icon = "${pkgs.element-desktop}/share/icons/hicolor/128x128/apps/element.png";
    terminal = false;
    categories = [ "Network" "InstantMessaging" "Chat" ];
})
