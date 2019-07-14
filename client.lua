local display = false
local t = {"This is a note."}

RegisterCommand("notepad", function(source, args)
    PlaySound(source, "CANCEL", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
    if args[1] == "open" then -- these args are pretty useless ngl
        SetGui(true)
    elseif args[1] == "close" then 
        SetGui(false)
    else 
        SetGui(not display)
    end
end)
TriggerEvent('chat:addSuggestion', '/notepad', 'Write anything down.', {
    {name="toggle", help="Either 'open' or 'close', or just toggle with no args."}
})

RegisterNUICallback('exit', function(data)
    updateNotes(t)
    SetGui(false)
end)

RegisterNUICallback('error', function(data)
    updateNotes(t)
    SetGui(false)
    notify("~r~Error:~s~\n"..data.error)
end)

RegisterNUICallback('save', function(data)
    SetGui(false)
    table.insert(t, data.main)
    notify("Saved Note ~h~#"..table.length(t))
    updateNotes(t)
end)

RegisterNUICallback('clear', function(data)
    SetGui(false)
    notify("Cleared ~h~"..table.length(t).."~s~ notes")
    t = {}
    updateNotes(t)
end)

Citizen.CreateThread(function()
    while display do
        Citizen.Wait(0)
            DisableControlAction(0, 1, display) -- LookLeftRight
            DisableControlAction(0, 2, display) -- LookUpDown
            DisableControlAction(0, 142, display) -- MeleeAttackAlternate
            DisableControlAction(0, 18, display) -- Enter
            DisableControlAction(0, 322, display) -- ESC
            DisableControlAction(0, 106, display) -- VehicleMouseControlOverride
    end
end)

-- for debugging idk
function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end


 
function SetGui(enable)
    SetNuiFocus(enable, enable)
    display = enable

    SendNUIMessage({
        type = "ui",
        enable = enable,
        data = t
    })
end

function table.length(tbl)
    local cnt = 0
    for _ in pairs(tbl) do cnt = cnt + 1 end
    return cnt
  end

function notify(string)
    SetNotificationTextEntry("STRING")
    AddTextComponentString("~y~~h~"..GetCurrentResourceName()..":~s~~n~"..string)
    DrawNotification(true, false)
    DrawNotificationWithIcon(1,1,"asd")
end

function updateNotes(tbl)
    SendNUIMessage({
        type = "ui",
        data = json.encode(tbl)
    })
end