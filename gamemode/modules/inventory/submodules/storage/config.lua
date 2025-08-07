local MODULE = MODULE
MODULE.Vehicles = MODULE.Vehicles or {}
MODULE.StorageDefinitions = {
    ["models/props_junk/wood_crate001a.mdl"] = {
        name = "storageWoodCrate",
        desc = "storageWoodCrateDesc",
        invType = "GridInv",
        invData = {
            w = 4,
            h = 4
        }
    },
    ["models/props_c17/lockers001a.mdl"] = {
        name = "storageLocker",
        desc = "storageLockerDesc",
        invType = "GridInv",
        invData = {
            w = 4,
            h = 6
        }
    },
    ["models/props_wasteland/controlroom_storagecloset001a.mdl"] = {
        name = "storageMetalCloset",
        desc = "storageMetalClosetDesc",
        invType = "GridInv",
        invData = {
            w = 5,
            h = 7
        }
    },
    ["models/props_wasteland/controlroom_filecabinet002a.mdl"] = {
        name = "storageFileCabinet",
        desc = "storageFileCabinetDesc",
        invType = "GridInv",
        invData = {
            w = 3,
            h = 6
        }
    },
    ["models/props_c17/furniturefridge001a.mdl"] = {
        name = "storageRefrigerator",
        desc = "storageRefrigeratorDesc",
        invType = "GridInv",
        invData = {
            w = 3,
            h = 4
        }
    },
    ["models/props_wasteland/kitchen_fridge001a.mdl"] = {
        name = "storageLargeRefrigerator",
        desc = "storageLargeRefrigeratorDesc",
        invType = "GridInv",
        invData = {
            w = 4,
            h = 5
        }
    },
    ["models/props_junk/trashbin01a.mdl"] = {
        name = "storageTrashBin",
        desc = "storageTrashBinDesc",
        invType = "GridInv",
        invData = {
            w = 1,
            h = 3
        }
    },
    ["models/items/ammocrate_smg1.mdl"] = {
        name = "storageAmmoCrate",
        desc = "storageAmmoCrateDesc",
        invType = "GridInv",
        invData = {
            w = 5,
            h = 3
        },
        onOpen = function(entity)
            entity:ResetSequence("Close")
            timer.Create("CloseLid" .. entity:EntIndex(), 2, 1, function() if IsValid(entity) then entity:ResetSequence("Open") end end)
        end
    },
    vehicle = {
        name = "storageVehicle",
        desc = "storageVehicleDesc",
        invType = "GridInv",
        invData = {
            w = 6,
            h = 6
        }
    }
}
