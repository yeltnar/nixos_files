ff_count=`hyprctl clients -j | jq --arg id "$(hyprctl activeworkspace -j | jq '.id')" 'map(select(.workspace.id == ($id | tonumber) and .initialClass == "firefox"))' | jq 'length'`

if [ $ff_count -gt 0 ]; then
  firefox $@
else
  firefox --new-window $@
fi
