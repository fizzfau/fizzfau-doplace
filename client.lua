local Coords = {}

RegisterNetEvent("fizzfau-doplace:UpdatePlaced")
AddEventHandler("fizzfau-doplace:UpdatePlaced", function(Placed)
	Coords = Placed
end)

Citizen.CreateThread(function()
	while true do
		local wait = 750
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)
		for k,v in pairs(Coords) do
			if v ~= nil then
				local distance = #(v.coords - coords)
				if distance <= 10 then
					wait = 0
					local text = v.text
					if distance <= 0.75 then
						text = "[E - Sil]" ..text
						if IsControlJustPressed(0, 46) then
							TriggerServerEvent("fizzfau-doplace:server:UpdatePlaced", k)
						end
					end
					DrawText3D(v.coords, text)
				end
			end
		end
		Citizen.Wait(wait)
	end
end)

function DrawText3D(coords, text)
    local onScreen,_x,_y=World3dToScreen2d(coords.x, coords.y, coords.z + 0.5)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
	SetTextFont(4)
    SetTextProportional(1)
	SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 0, 0, 0, 200)
end