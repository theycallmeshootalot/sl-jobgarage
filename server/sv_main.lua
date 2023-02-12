local QBCore = exports['qb-core']:GetCoreObject()
local src = source
local Player = QBCore.Functions.GetPlayer(src)
local plate = nil

local function GeneratePlate()
    local plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)
    local result = MySQL.scalar.await('SELECT plate FROM jobgarage_vehicles WHERE plate = ?', {plate})
    if result then
        return GeneratePlate()
    else
        return plate:upper()
    end
end

RegisterNetEvent('sl-jobgarage:server:issueVehicle', function(data)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local Target = QBCore.Functions.GetPlayer(data.target)
    local CSN = Target.PlayerData.citizenid
    local vehicle = data.vehicle.Name
    local vehicleSpawnCode = data.vehicle.SpawnCode
    local vehicleHashKey = GetHashKey(data.vehicle.SpawnCode)
    local name = Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname
    local plate = "GOV-"..Target.PlayerData.metadata["callsign"]

	if Target then
		TriggerClientEvent('QBCore:Notify', src, "You have given "..name.." a "..vehicle, "info")
		TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, "You have been given a "..vehicle, "info")

        MySQL.insert('INSERT INTO jobgarage_vehicles (license, citizenid, vehicle, hash, plate, garage) VALUES (?, ?, ?, ?, ?, ?)', {
            Target.PlayerData.license,
            CSN,
            vehicleSpawnCode,
            vehicleHashKey,
            plate,
            Target.PlayerData.job.name,
        })
	end
end)

RegisterNetEvent('sl-jobgarage:server:emergencyselfissueVehicle', function(data)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local CSN = Player.PlayerData.citizenid
    local vehicle = data.vehicle.Name
    local vehicleSpawnCode = data.vehicle.SpawnCode
    local vehicleHashKey = GetHashKey(data.vehicle.SpawnCode)
    local name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    local plate = "GOV-"..Player.PlayerData.metadata["callsign"]

	TriggerClientEvent('QBCore:Notify', src, "You have given yourself a "..vehicle, "info")

    MySQL.insert('INSERT INTO jobgarage_vehicles (license, citizenid, vehicle, hash, plate, garage) VALUES (?, ?, ?, ?, ?, ?)', {
        Player.PlayerData.license,
        CSN,
        vehicleSpawnCode,
        vehicleHashKey,
        plate,
        Player.PlayerData.job.name,
    })
end)

RegisterNetEvent('sl-jobgarage:server:selfissueVehicle', function(data)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local CSN = Player.PlayerData.citizenid
    local vehicle = data.vehicle.Name
    local vehicleSpawnCode = data.vehicle.SpawnCode
    local vehicleHashKey = GetHashKey(data.vehicle.SpawnCode)
    local name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    local plate = GeneratePlate()

	TriggerClientEvent('QBCore:Notify', src, "You have given yourself a "..vehicle, "info")

    MySQL.insert('INSERT INTO jobgarage_vehicles (license, citizenid, vehicle, hash, plate, garage) VALUES (?, ?, ?, ?, ?, ?)', {
        Player.PlayerData.license,
        CSN,
        vehicleSpawnCode,
        vehicleHashKey,
        plate,
        Player.PlayerData.job.name,
    })
end)

QBCore.Functions.CreateCallback('sl-jobgarage:server:spawnVehicle', function (source, cb, vehInfo, coords, warp)
    local veh = QBCore.Functions.SpawnVehicle(source, vehInfo.vehicle, coords, warp)
    SetEntityHeading(veh, coords.w)
    cb(netId)
end)

QBCore.Functions.CreateCallback("sl-jobgarage:server:getVehicles", function(source, cb, garage, type, category)
    local src = source
    local pData = QBCore.Functions.GetPlayer(src)
    MySQL.query('SELECT * FROM jobgarage_vehicles WHERE citizenid = ? AND garage = ?', {pData.PlayerData.citizenid, pData.PlayerData.job.name}, function(result)
        if result[1] then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

QBCore.Functions.CreateCallback('sl-jobgarage:server:getnearestemployee', function(source, cb)
	local src = source
	local players = {}
	local PlayerPed = GetPlayerPed(src)
	local pCoords = GetEntityCoords(PlayerPed)
	for _, v in pairs(QBCore.Functions.GetPlayers()) do
		local Target = GetPlayerPed(v)
		local tCoords = GetEntityCoords(Target)
		local dist = #(pCoords - tCoords)
		if PlayerPed ~= Target and dist < 10 then
			local ped = QBCore.Functions.GetPlayer(v)
			players[#players+1] = {
			id = v,
			coords = GetEntityCoords(Target),
			name = ped.PlayerData.charinfo.firstname .. " " .. ped.PlayerData.charinfo.lastname,
			citizenid = ped.PlayerData.citizenid,
            grade = ped.PlayerData.job.grade,
            job = ped.PlayerData.job.name,
			joblabel = ped.PlayerData.job.label,
			sources = GetPlayerPed(ped.PlayerData.source),
			sourceplayer = ped.PlayerData.source
			}
		end
	end
		table.sort(players, function(a, b)
			return a.name < b.name
		end)
	cb(players)
end)
