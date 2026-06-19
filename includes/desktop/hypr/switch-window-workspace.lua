local mainMod = "SUPER"

local callback_functions = {}

function CallbackWrapper(key, index)
  callback_functions[key](index)
end

local function merge_arrays(t1, t2)
    -- Loop through the second array
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i] -- Appends to the end of t1
    end
    return t1
end

hl.bind(mainMod .. " + U", function()

  local k = tostring(math.random() * 100000)

  local windows = hl.get_windows()
  local workspaces = hl.get_workspaces()

  -- local merged_arr = merge_arrays(windows, workspaces)
  local merged_arr = merge_arrays(workspaces, windows)

  local arr = {}
  -- get the list of window titles
  for i, v in ipairs(merged_arr) do
    if v.workspace ~= nil then
      table.insert( arr, "wn: "..v.class..": "..v.title )
    else
      table.insert( arr, "ws: "..v.name )
    end
  end

  -- create callback which will be called after dfuzzel selection
  local subcommand = "echo -e \'" .. table.concat(arr,"\\n") .. "\' | dfuzzel --width 60 --dmenu --index | xargs -I {} hyprctl eval 'CallbackWrapper(\""..k.."\", {})'"

  callback_functions[k] = function( index )

    local selected = merged_arr[index+1]
    local workspace_or_window = 'workspace'
    local focus_table = {}

    if selected.workspace ~= nil then
      workspace_or_window = 'window'
      focus_table[workspace_or_window] = selected
      -- hl.notification.create({timeout=4000, text=workspace_or_window.." "..index.." "..selected.title})
    else
      workspace_or_window = 'workspace'
      -- not sure workspace object does not work for named workspaces
      focus_table[workspace_or_window] = selected.name
      -- focus_table[workspace_or_window] = selected
      -- hl.notification.create({timeout=4000, text=workspace_or_window.." "..index.." "..selected.name})
    end

    hl.dispatch(hl.dsp.focus(focus_table))

    -- delete callback
    callback_functions[k] = nil
  end

  hl.exec_cmd(subcommand)

end)
