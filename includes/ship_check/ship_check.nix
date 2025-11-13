{
  config,
  pkgs,
  ...
}: let 
  script = ''
    export bashrc_folder="/home/drew/playin/custom_bashrc"
    export PATH="$PATH:/home/drew/playin/custom_bashrc/bin"

    echo "$bashrc_folder"
    echo "$PATH"

    if [ -e /tmp/ship_date.txt ]; then
      file_age=$(( $(date +%s) - $(date -r /tmp/ship_date.txt +%s) ))
      # if [ "$file_age" -gt 0 ]; then
      if [ "$file_age" -gt 86400 ]; then
        rm /tmp/ship_date.txt
      fi
    fi

    ship_date=""
    if [ -e /tmp/ship_date.txt ]; then
      ship_date=$(cat /tmp/ship_date.txt)
    fi

    new_ship_date=$(
      curl 'https://www.my-order-status.com/orderstatus/ShowOrder.do?o=XYV11NZZVY_04775064595&r=e' 2>/dev/null |
      awk -F'>' '/Estimated Ship/{print $5}' |
      awk -F'<' '{print $1}'
    )
    
    echo "ship_date: $ship_date; new_ship_date: $new_ship_date;"

    if [ "$ship_date" != "$new_ship_date" ]; then
      send_push "ship_date" "$new_ship_date; check back 11/10/25... 11/15/25"
      echo "$new_ship_date" > /tmp/ship_date.txt
    fi
  '';
  path = with pkgs; [
    curl
    gawk
  ];
in {

  imports = [ ../nm-online.service.nix ];

  systemd.user.timers."ship_check" = {
    wantedBy = ["timers.target"];
    requires = ["nm-online.service"];
    timerConfig = {
      OnUnitActiveSec = "60m";
      # start service when timer starts
      OnActiveSec = "0s";
      Unit = "ship_check.service";
    };
  };

  systemd.user.services."ship_check" = {
    requires = ["nm-online.service"];
    environment =
      config.nix.envVars
      // {
        inherit (config.environment.sessionVariables) NIX_PATH;
        HOME = "/home/drew";
      }
      // config.networking.proxy.envVars;
    path = path;
    script = script;
  };
}
