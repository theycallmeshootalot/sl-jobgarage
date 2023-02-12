Config = Config or {}

-- LAW ENFORCEMENT --

Config.LawEnforcementPed = "s_m_y_cop_01"
Config.LawEnforcementPedLocation = vector4(382.97, -1611.83, 28.29, 228.89)
Config.LawEnforcementJobName = "police"

Config.LawEnforcement = {
    VehicleSpawn = vector4(376.59, -1612.71, 28.9, 231.17),
    Garage = {
        pdvehicles = {
            ["police3"] = {
                Name = "2018 Ford Taurus",
                SpawnCode = "police3"
            },
            ["police2"] = {
                Name = "2014 Dodge Charger",
                SpawnCode = "police2"
            },
            ["police"] = {
                Name = "2011 Ford Crown Victoria",
                SpawnCode = "police"
            },
        }
    }
}

-- EMS -- 

Config.EMSPed = "s_m_y_autopsy_01"
Config.EMSLocation = vector4(387.41, -1436.65, 28.43, 228.61)
Config.EMSJobName = "ambulance"

Config.EMS = {
    VehicleSpawn = vector4(393.33, -1434.67, 28.45, 132.84),
    Garage = {
        emsvehicles = {
            ["police3"] = {
                Name = "2013 Ford Ambo",
                SpawnCode = "ambulance"
            },
            ["police2"] = {
                Name = "2015 Ford Fireytruck",
                SpawnCode = "firetruk"
            },
        }
    }
}

-- MECHANIC -- 

Config.MechanicPed = "s_m_m_ccrew_01"
Config.MechanicLocation = vector4(484.51, -1882.93, 25.09, 203.11)
Config.MechanicJobName = "mechanic"

Config.Mechanic = {
    VehicleSpawn = vector4(490.48, -1892.27, 24.75, 23.84),
    Garage = {
        mechanicvehicles = {
            ["flatbed"] = {
                Name = "Flatbed",
                SpawnCode = "flatbed"
            },
            ["towtruck"] = {
                Name = "Tow Truck",
                SpawnCode = "towtruck"
            },
        }
    }
}