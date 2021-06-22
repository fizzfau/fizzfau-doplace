local Placed = {}

RegisterCommand('doplace', function(source, args, raw)
    local text = raw:gsub('ş','s')
    :gsub('ğ','g')
    :gsub('Ş','S')
    :gsub('Ğ','G')
    :sub(8)
    if #text < 1 then return end
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local arrayid = math.random(1,999999999999999999)
    Placed[arrayid] = {
        text = text,
        coords = coords,
        time = 60
    }
    local id = getid(source)
    dclog(Config.Webhook, "fizzfau-doplace - Added ID:"..arrayid, "__**Player Infos**__ \n **Player Identifiers**: " .. json.encode(id).. "\n **Player Name: ** " .. GetPlayerName(source).. "\n **Text:**" ..text)
    TriggerClientEvent("fizzfau-doplace:UpdatePlaced", -1, Placed)
end)

RegisterServerEvent("fizzfau-doplace:server:UpdatePlaced")
AddEventHandler("fizzfau-doplace:server:UpdatePlaced", function(arrayid)
    local id = getid(source)
    dclog(Config.Webhook, "fizzfau-doplace - Removed ID:"..arrayid, "__**Player Infos**__ \n **Player Identifiers**: " .. json.encode(id).. "\n **Player Name: ** " .. GetPlayerName(source).. "\n **Text:**" ..Placed[tonumber(arrayid)].text)
    Placed[tonumber(arrayid)] = nil
    TriggerClientEvent("fizzfau-doplace:UpdatePlaced", -1, Placed)
end)

Citizen.CreateThread(function()
    while true do
        for k,v in pairs(Placed) do
            if v.time > 0 then
                Placed[k].time = Placed[k].time - 1
            else
                Placed[k] = nil
                TriggerClientEvent("fizzfau-doplace:UpdatePlaced", -1, Placed)
            end
        end
        Citizen.Wait(60 * 1000 * Config.RefreshMinute)
    end
end)

AddEventHandler("playerConnecting", function()
    TriggerClientEvent("fizzfau-doplace:UpdatePlaced", source, Placed)
end)

dclog = function(webhook, title, text, target)
    local ts = os.time()
    local time = os.date('%Y-%m-%d %H:%M:%S', ts)
    local connect = {
        {
            ["color"] = 3092790,
            ["title"] = title,
            ["description"] = text,
            ["footer"] = {
                ["text"] = "by fizzfau                             " ..time,
                ["icon_url"] = "https://i.ytimg.com/vi/RciuGXnHhR8/hqdefault.jpg",
            },
        }
    }
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "fizzfau-logsystem", embeds = connect}), { ['Content-Type'] = 'application/json' })
end

getid = function(source)
    local identifier = {}
    local identifiers = {}
	identifiers = GetPlayerIdentifiers(source)
    for i = 1, #identifiers do
        if string.match(identifiers[i], "discord:") then
            identifier["discord"] = string.sub(identifiers[i], 9)
            identifier["discord"] = "<@"..identifier["discord"]..">"
        end
        if string.match(identifiers[i], "steam:") then
            identifier["steam"] = identifiers[i]
		end
        if string.match(identifiers[i], "license:") then
            identifier["license"] = identifiers[i]
		end

    end
    if identifier["discord"] == nil then
        identifier["discord"] = "Bilinmiyor"
    end
    return identifier
end