--[[
    Folder: Hooks
    File:  shared.md
]]
--[[
    Shared Hooks

    Shared hook system for the Lilia framework.
    These hooks run on both client and server and are used for shared functionality and data synchronization.
]]
--[[
    Overview:
        Shared hooks in the Lilia framework handle functionality available on both client and server, typically for data synchronization, shared utilities, and cross-realm features. They follow the Garry's Mod hook system and can be overridden or extended by addons and modules.
]]
function AdjustCreationData(client, data, newData, originalData)
end
