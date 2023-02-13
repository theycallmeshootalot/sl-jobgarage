local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then 
        PlayerJob = QBCore.Functions.GetPlayerData().job 
        LawEnforcementPed()
        EMSPed()
        MechanicPed()
    end
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
    LawEnforcementPed()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

RegisterNetEvent('sl-jobgarage:client:spawnVehicle', function(data)
    local vehicle = data.vehicle
    local location = Config.LawEnforcement.VehicleSpawn

    QBCore.Functions.TriggerCallback('sl-jobgarage:server:Spawnvehicle', function(netId)
        local veh = NetToVeh(netId)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
    end, vehicle, location, true)
end)

RegisterNetEvent('sl-jobgarage:client:approvedvehiclesmenu', function(data)
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
                        event = "sl-jobgarage:client:spawnVehicle",
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

RegisterNetEvent('sl-jobgarage:client:issuevehiclesmenu', function(data)
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
                if vp.job == Config.LawEnforcementJobName then
                    IssueVehicleList[#IssueVehicleList + 1] = {
                        header = vp.name,
                        txt = "Player ID: " ..vp.sourceplayer.. " | Job Name: "..vp.joblabel.." | Job Rank: "..vp.grade.name,
                        icon = "fa-solid fa-user-check",
                        params = {
                            event = "sl-jobgarage:client:vehiclesmenu",
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

RegisterNetEvent('sl-jobgarage:client:vehiclesmenu', function(data)
    local VehicleList = {
        {
            icon = "fas fa-car",
            header = "Issue Work-Related Vehicles",
            isMenuHeader = true
        },
    }
    for _, v in pairs(Config.LawEnforcement.Garage.pdvehicles) do
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
                event = "sl-jobgarage:client:issuevehiclesmenu"
            }
        }
    exports['qb-menu']:openMenu(VehicleList)
end)

RegisterNetEvent('sl-jobgarage:client:selfissuevehiclesmenu', function(data)
    local VehicleList = {
        {
            icon = "fas fa-car",
            header = "Issue Work-Related Vehicles",
            isMenuHeader = true
        },
    }
    for _, v in pairs(Config.LawEnforcement.Garage.pdvehicles) do
        VehicleList[#VehicleList+1] = {
                header = v.Name,
                icon = "fa-solid fa-file-pen",
                txt = "Click to issue this vehicle to yourself",
                params = {
                    isServer = true,
                    event = 'sl-jobgarage:server:emergencyselfissueVehicle',
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
                event = "sl-jobgarage:client:issuevehiclesmenu"
            }
        }
    exports['qb-menu']:openMenu(VehicleList)
end)

function LawEnforcementPed()
    if not DoesEntityExist(leomodel) then
        RequestModel(Config.LawEnforcementPed)
        while not HasModelLoaded(Config.LawEnforcementPed) do
            Wait(0)
        end

        leomodel = CreatePed(1, Config.LawEnforcementPed, Config.LawEnforcementPedLocation.x, Config.LawEnforcementPedLocation.y, Config.LawEnforcementPedLocation.z, Config.LawEnforcementPedLocation.w, false, false)
        SetEntityAsMissionEntity(leomodel)
        SetBlockingOfNonTemporaryEvents(leomodel, true)
        SetEntityInvincible(leomodel, true)
        FreezeEntityPosition(leomodel, true)
        TaskStartScenarioInPlace(leomodel, "WORLD_HUMAN_CLIPBOARD", 0, true)

        exports['qb-target']:AddTargetEntity(leomodel, {
            options = {
                {
                    num = 1,
                    type = "client",
                    event = "sl-jobgarage:client:approvedvehiclesmenu",
                    icon = "fa-solid fa-car",
                    label = "View Issued Vehicles",
                    canInteract = function()
                        if PlayerJob.name == Config.LawEnforcementJobName and PlayerJob.isboss then return false end 
                        return true 
                    end,
                },
                {
                    num = 2,
                    type = "client",
                    event = "sl-jobgarage:client:issuevehiclesmenu",
                    icon = "fa-solid fa-list",
                    label = "Issue Work-Related Vehicle",
                    canInteract = function()
                        if PlayerJob.name == Config.LawEnforcementJobName and PlayerJob.isboss then return false end 
                        return true 
                    end,
                },
                {
                    num = 3,
                    type = "client",
                    event = "sl-jobgarage:client:selfissuevehiclesmenu",
                    icon = "fa-solid fa-user",
                    label = "Self-Issue Work-Related Vehicle",
                    canInteract = function()
                        if PlayerJob.name == Config.LawEnforcementJobName and PlayerJob.isboss then return false end 
                        return true 
                    end,
                },
            },
            distance = 2.5,
        })
    end
end