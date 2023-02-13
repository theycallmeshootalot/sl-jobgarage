local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then 
        PlayerJob = QBCore.Functions.GetPlayerData().job 
        MechanicPed()
    end
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
    MechanicPed()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

RegisterNetEvent('sl-jobgarage:client:mechspawnVehicle', function(data)
    local vehicle = data.vehicle
    local location = Config.Mechanic.VehicleSpawn

    QBCore.Functions.TriggerCallback('sl-jobgarage:server:spawnVehicle', function(netId)
        local veh = NetToVeh(netId)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
    end, vehicle, location, true)
end)

RegisterNetEvent('sl-jobgarage:client:mechapprovedvehiclesmenu', function(data)
    local VehicleList = {
        {
            icon = "fas fa-car",
            header = "Your Issued Vehicles",
            isMenuHeader = true
        }
    }
    QBCore.Functions.TriggerCallback("sl-jobgarage:server:getVehicles", function(result)
        if result == nil then 
            VehicleList[#VehicleList+1] = {
                header = "No vehicles has been issued to you"
            }
        else
            for _, v in pairs(result) do
                local vname = QBCore.Shared.Vehicles[v.vehicle].name

                VehicleList[#VehicleList+1] = {
                    header = vname,
                    icon = "fa-solid fa-file-pen",
                    txt = "Plate: "..v.plate,
                    params = {
                        event = "sl-jobgarage:client:mechspawnVehicle",
                        args = {
                            vehicle = v,
                        }
                    }
                }
            end
        end

    VehicleList[#VehicleList+1] = {
        icon = "fas fa-x",
        header = "Close",
        params = {
            event = "qb-menu:client:closeMenu"
        }
    }

     exports['qb-menu']:openMenu(VehicleList)
    end)
end)

RegisterNetEvent('sl-jobgarage:client:mechissuevehiclesmenu', function(data)
    local IssueVehicleList = {
        {
            icon = "fas fa-car",
            header = "Issue Work-Related Vehicles",
            isMenuHeader = true
        },
    }
    QBCore.Functions.TriggerCallback('sl-jobgarage:server:getnearestemployee', function(players)
        for _, vp in pairs(players) do
            if vp and vp ~= PlayerId() then
                if vp.job == Config.MechanicJobName then
                    IssueVehicleList[#IssueVehicleList + 1] = {
                        header = vp.name,
                        txt = "Player ID: " ..vp.sourceplayer.. " | Job Name: "..vp.joblabel.." | Job Rank: "..vp.grade.name,
                        icon = "fa-solid fa-user-check",
                        params = {
                            event = "sl-jobgarage:client:mechvehiclesmenu",
                            args = {
                                player = vp
                            }
                        }
                    }
                end
            end
        end

        IssueVehicleList[#IssueVehicleList+1] = {
            icon = "fas fa-x",
            header = "Close",
            txt = "",
            params = {
                event = "qb-menu:client:closeMenu"
            }
        }

        exports['qb-menu']:openMenu(IssueVehicleList)
    end)
end)

RegisterNetEvent('sl-jobgarage:client:mechvehiclesmenu', function(data)
    local VehicleList = {
        {
            icon = "fas fa-car",
            header = "Issue Work-Related Vehicles",
            isMenuHeader = true
        },
    }
    for _, v in pairs(Config.Mechanic.Garage.mechanicvehicles) do
        VehicleList[#VehicleList+1] = {
                header = v.Name,
                icon = "fa-solid fa-file-pen",
                txt = "Click to issue this vehicle to "..data.player.name,
                params = {
                    isServer = true,
                    event = 'sl-jobgarage:server:issueVehicle',
                    args = {
                        vehicle = v,
                        target = data.player.sourceplayer
                    }
                }
            }
        end

        VehicleList[#VehicleList+1] = {
            icon = "fa-solid fa-angle-left",
            header = "Return",
            params = {
                event = "sl-jobgarage:client:mechissuevehiclesmenu"
            }
        }
    exports['qb-menu']:openMenu(VehicleList)
end)

RegisterNetEvent('sl-jobgarage:client:mechselfissuevehiclesmenu', function(data)
    local VehicleList = {
        {
            icon = "fas fa-car",
            header = "Issue Work-Related Vehicles",
            isMenuHeader = true
        },
    }
    for _, v in pairs(Config.Mechanic.Garage.mechanicvehicles) do
        VehicleList[#VehicleList+1] = {
                header = v.Name,
                icon = "fa-solid fa-file-pen",
                txt = "Click to issue this vehicle to yourself",
                params = {
                    isServer = true,
                    event = 'sl-jobgarage:server:selfissueVehicle',
                    args = {
                        vehicle = v,
                    }
                }
            }
        end

        VehicleList[#VehicleList+1] = {
            icon = "fa-solid fa-angle-left",
            header = "Return",
            params = {
                event = "sl-jobgarage:client:mechissuevehiclesmenu"
            }
        }
    exports['qb-menu']:openMenu(VehicleList)
end)

function MechanicPed()
    if not DoesEntityExist(mechanicmodel) then
        RequestModel(Config.MechanicPed)
        while not HasModelLoaded(Config.MechanicPed) do
            Wait(0)
        end

        mechanicmodel = CreatePed(1, Config.MechanicPed, Config.MechanicLocation.x, Config.MechanicLocation.y, Config.MechanicLocation.z, Config.MechanicLocation.w, false, false)
        SetEntityAsMissionEntity(mechanicmodel)
        SetBlockingOfNonTemporaryEvents(mechanicmodel, true)
        SetEntityInvincible(mechanicmodel, true)
        FreezeEntityPosition(mechanicmodel, true)
        TaskStartScenarioInPlace(mechanicmodel, "WORLD_HUMAN_CLIPBOARD", 0, true)

        exports['qb-target']:AddTargetEntity(mechanicmodel, {
            options = {
                {
                    num = 1,
                    type = "client",
                    event = "sl-jobgarage:client:mechapprovedvehiclesmenu",
                    icon = "fa-solid fa-car",
                    label = "View Issued Vehicles",
                    canInteract = function()
                        if PlayerJob.name == Config.MechanicJobName and PlayerJob.isboss then return false end 
                        return true 
                    end,
                },
                {
                    num = 2,
                    type = "client",
                    event = "sl-jobgarage:client:mechissuevehiclesmenu",
                    icon = "fa-solid fa-list",
                    label = "Issue Work-Related Vehicle",
                    canInteract = function()
                        if PlayerJob.name == Config.MechanicJobName and PlayerJob.isboss then return false end 
                        return true 
                    end,
                },
                {
                    num = 3,
                    type = "client",
                    event = "sl-jobgarage:client:mechselfissuevehiclesmenu",
                    icon = "fa-solid fa-user",
                    label = "Self-Issue Work-Related Vehicle",
                    canInteract = function()
                        if PlayerJob.name == Config.MechanicJobName and PlayerJob.isboss then return false end 
                        return true 
                    end,
                },
            },
            distance = 2.5,
        })
    end
end