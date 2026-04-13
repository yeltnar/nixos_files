{ pkgs, ... }:
pkgs.writeShellScriptBin "start_work" ''
  hyprctl dispatch workspace name:w2
  bash -c 'work-chromium &' >/dev/null 2>&1
  sleep 3;
  hyprctl dispatch workspace name:w1
  bash -c 'teams-webapp &' >/dev/null 2>&1
''
