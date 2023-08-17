--------------------------------------------------------------------------------------------------------
function lia.config.LoadToolPermissions()
    lia.config.CustomToolAccess = true

    lia.config.BlockedProperties = {"persist", "bonemanipulate", "drive"}

    lia.config.RestrictedEntityList = {"prop_door_rotating", "lia_vendor",}

    lia.config.BlockedEntities = {"ent_chess_board", "ent_draughts_board", "rock_big", "rock_medium", "rock_small ", "lia_bodygroupcloset", "lia_craftingtable", "carvendor", "sh_teller", "permaweapons", "stockbook", "lia_stash", "valet", "lia_vendor", "telephone", "lia_salary", "spruce", "pinetree", "oaktree", "beechtree", "npc_import_drug", "cardealer", "delivery_crate", "npcdelivery", "housing_npc", "jailer_npc", "sergeant_dornan", "npctaxi",}

    lia.config.DisallowedTools = {"rope", "light", "lamp", "dynamite", "physprop", "faceposer",}

    lia.config.DuplicatorBlackList = {"lia_storage", "lia_money"}

    lia.config.CustomToolAccessTable = {
        ["remover"] = {
            IsAdmin = false,
            IsSuperAdmin = false,
            ToolAllowedUsergroup = {"superadmin", "admin", "user"},
            ExtraCheck = function(client, trace, tool, entity)
                if client:IsSuperAdmin() then return true end

                if table.HasValue(lia.config.BlockedEntities, entity:GetClass()) then
                    return false
                else
                    if entity:GetCreator() == client then
                        return true
                    else
                        if client:Team() ~= FACTION_STAFF and not client:IsAdmin() then
                            return false
                        elseif client:Team() == FACTION_STAFF or client:IsAdmin() then
                            return true
                        end
                    end
                end

                return false
            end,
        },
        ["editentity"] = {
            IsAdmin = true,
            IsSuperAdmin = true,
            ToolAllowedUsergroup = {"superadmin", "admin"},
            ExtraCheck = function(client, trace, tool)
                return true
            end,
        },
        ["collision"] = {
            IsAdmin = true,
            IsSuperAdmin = true,
            ToolAllowedUsergroup = {"superadmin"},
            ExtraCheck = function(client, trace, tool)
                return true
            end,
        },
        ["advdupe2"] = {
            IsAdmin = false,
            IsSuperAdmin = false,
            ToolAllowedUsergroup = {"superadmin"},
            ExtraCheck = function(client, trace, tool)
                if client:IsSuperAdmin() then return true end

                if table.HasValue(lia.config.DuplicatorBlackList, entity:GetClass()) then
                    return false
                else
                    return true
                end
            end,
        },
    }
end
--------------------------------------------------------------------------------------------------------