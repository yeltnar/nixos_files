{ pkgs, ... }:
let
  teams-webapp = pkgs.writeShellScriptBin "teams-webapp" ''
    # chromium --user-data-dir=/home/drew/.config/teams --profile-directory=Default --app-id=cifhbcnohmdccbgoicgdjpfamggdegmo
    chromium --user-data-dir=/home/drew/.config/teams --profile-directory=Default --app=https://teams.microsoft.com/v2/
  '';


  start_work = pkgs.writeShellScriptBin "start_work" ''

    hyprctl dispatch "hl.dsp.focus({ workspace = 'name:w2' })"
    bash -c 'work-chromium &' >/dev/null 2>&1
    # Loop until a window is detected in the current workspace
    while true; do
        # Check if the active workspace has any windows (clients)
        if [[ $(hyprctl activeworkspace -j | jq '.windows') -gt 0 ]]; then
            break
        fi
        sleep 1
    done
    hyprctl dispatch "hl.dsp.focus({ workspace = 'name:w1' })"
    bash -c '${teams-webapp}/bin/teams-webapp &' >/dev/null 2>&1

  '';

in
{
  environment.systemPackages =[
    teams-webapp
    start_work
  ];
}
