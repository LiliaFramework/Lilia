--------------------------------------------------------------------------------------------------------------------------
lia.config.StorageDefinitions = lia.config.StorageDefinitions or {}
--------------------------------------------------------------------------------------------------------------------------
lia.config.SaveStorage = true
--------------------------------------------------------------------------------------------------------------------------
lia.config.PasswordDelay = 1
--------------------------------------------------------------------------------------------------------------------------
lia.config.StorageOpenTime = 0.7
--------------------------------------------------------------------------------------------------------------------------
lia.config.StorageDefinitions["models/props_junk/wood_crate001a.mdl"] = {
    name = "Wood Crate",
    desc = "A crate made out of wood.",
    invType = "grid",
    invData = {
        w = 4,
        h = 4
    }
}

--------------------------------------------------------------------------------------------------------------------------
lia.config.StorageDefinitions["models/props_c17/lockers001a.mdl"] = {
    name = "Locker",
    desc = "A white locker.",
    invType = "grid",
    invData = {
        w = 4,
        h = 6
    }
}

--------------------------------------------------------------------------------------------------------------------------
lia.config.StorageDefinitions["models/props_wasteland/controlroom_storagecloset001a.mdl"] = {
    name = "Metal Closet",
    desc = "A green storage closet.",
    invType = "grid",
    invData = {
        w = 5,
        h = 7
    }
}

--------------------------------------------------------------------------------------------------------------------------
lia.config.StorageDefinitions["models/props_wasteland/controlroom_filecabinet002a.mdl"] = {
    name = "File Cabinet",
    desc = "A metal file cabinet.",
    invType = "grid",
    invData = {
        w = 3,
        h = 6
    }
}

--------------------------------------------------------------------------------------------------------------------------
lia.config.StorageDefinitions["models/props_c17/furniturefridge001a.mdl"] = {
    name = "Refrigerator",
    desc = "A metal box to keep food in",
    invType = "grid",
    invData = {
        w = 3,
        h = 4
    }
}

--------------------------------------------------------------------------------------------------------------------------
lia.config.StorageDefinitions["models/props_wasteland/kitchen_fridge001a.mdl"] = {
    name = "Large Refrigerator",
    desc = "A large metal box to keep even more food in.",
    invType = "grid",
    invData = {
        w = 4,
        h = 5
    }
}

--------------------------------------------------------------------------------------------------------------------------
lia.config.StorageDefinitions["models/props_junk/trashbin01a.mdl"] = {
    name = "Trash Bin",
    desc = "A container for junk.",
    invType = "grid",
    invData = {
        w = 1,
        h = 3
    }
}

--------------------------------------------------------------------------------------------------------------------------
lia.config.StorageDefinitions["models/items/ammocrate_smg1.mdl"] = {
    name = "Ammo Crate",
    desc = "A heavy crate for storing ammunition.",
    invType = "grid",
    invData = {
        w = 5,
        h = 3
    },
    onOpen = function(entity, activator)
        entity:ResetSequence("Close")
        timer.Create("CloseLid" .. entity:EntIndex(), 2, 1, function() if IsValid(entity) then entity:ResetSequence("Open") end end)
    end
}
--------------------------------------------------------------------------------------------------------------------------
CAMI.RegisterPrivilege(
    {
        Name = "Lilia - Staff Permissions - Can Spawn Storage",
        MinAccess = "superadmin",
        Description = "Allows access to Spawning Storage.",
    }
)
--------------------------------------------------------------------------------------------------------------------------
