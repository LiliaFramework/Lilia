lia.ammo = lia.ammo or {}
lia.anim = lia.anim or {}
lia.anim.DefaultTposingFixer = lia.anim.DefaultTposingFixer or {}
lia.anim.HoldtypeTranslator = lia.anim.HoldtypeTranslator or {}
lia.anim.HoldtypeTranslator = lia.anim.HoldtypeTranslator or {}
lia.anim.PlayerHoldtypeTranslator = lia.anim.PlayerHoldtypeTranslator or {}
lia.anim.PlayerModelTposingFixer = lia.anim.PlayerModelTposingFixer or {}
lia.attribs = lia.attribs or {}
lia.attribs.list = lia.attribs.list or {}
lia.bar = lia.bar or {}
lia.bar.delta = lia.bar.delta or {}
lia.bar.list = lia.bar.list or {}
lia.char = lia.char or {}
lia.char.loaded = lia.char.loaded or {}
lia.char.names = lia.char.names or {}
lia.char.varHooks = lia.char.varHooks or {}
lia.char.vars = lia.char.vars or {}
lia.chat = lia.chat or {}
lia.chat.classes = lia.char.classes or {}
lia.class = lia.class or {}
lia.class.list = lia.class.list or {}
lia.command = lia.command or {}
lia.command.list = lia.command.list or {}
lia.config = lia.config or {}
lia.config.list = lia.config.list or {}
lia.currency = lia.currency or {}
lia.currency.plural = lia.currency.plural or lia.config.PluralDefaultCurrency
lia.currency.singular = lia.currency.singular or lia.config.SingularDefaultCurrency
lia.currency.symbol = lia.currency.symbol or lia.config.DefaultCurrencySymbol
lia.data = lia.data or {}
lia.data.stored = lia.data.stored or {}
lia.ease = lia.ease or {}
lia.faction = lia.faction or {}
lia.faction.indices = lia.faction.indices or {}
lia.faction.teams = lia.faction.teams or {}
lia.flag = lia.flag or {}
lia.flag.list = lia.flag.list or {}
lia.inventory = lia.inventory or {}
lia.inventory.instances = lia.inventory.instances or {}
lia.inventory.types = lia.inventory.types or {}
lia.item = lia.item or {}
lia.item.base = lia.item.base or {}
lia.item.instances = lia.item.instances or {}
lia.item.inventoryTypes = lia.item.inventoryTypes or {}
lia.item.list = lia.item.list or {}
lia.item.list = lia.item.list or {}
lia.lang = lia.lang or {}
lia.lang.names = lia.lang.names or {}
lia.lang.stored = lia.lang.stored or {}
lia.menu = lia.menu or {}
lia.menu.list = lia.menu.list or {}
lia.module = lia.module or {}
lia.module.list = lia.module.list or {}
lia.module.unloaded = lia.module.unloaded or {}
lia.net = lia.net or {}
lia.net.globals = lia.net.globals or {}
lia.playerInteract = lia.playerInteract or {}
lia.playerInteract.currentEnt = lia.playerInteract.currentEnt or {}
lia.playerInteract.funcs = lia.playerInteract.funcs or {}
lia.util.cachedMaterials = lia.util.cachedMaterials or {}
lia.item.defaultfunctions = lia.item.defaultfunctions or {}
lia.item.defaultfunctions = {
	drop = {
		tip = "dropTip",
		icon = "icon16/world.png",
		onRun = function(item)
			local client = item.player

			item:removeFromInventory(true):next(function()
				item:spawn(client)
			end)


			return false
		end,
		onCanRun = function(item)
			return item.entity == nil and not IsValid(item.entity) and not item.noDrop
		end
	},
	take = {
		tip = "takeTip",
		icon = "icon16/box.png",
		onRun = function(item)
			local client = item.player
			local inventory = client:getChar():getInv()
			local entity = item.entity
			if client.itemTakeTransaction and client.itemTakeTransactionTimeout > RealTime() then return false end
			client.itemTakeTransaction = true
			client.itemTakeTransactionTimeout = RealTime()
			if not inventory then return false end
			local d = deferred.new()

			inventory:add(item):next(function(res)
				client.itemTakeTransaction = nil

				if IsValid(entity) then
					entity.liaIsSafe = true
					entity:Remove()
				end

				if not IsValid(client) then return end
				d:resolve()
			end):catch(function(err)
				client.itemTakeTransaction = nil
				client:notifyLocalized(err)
				d:reject()
			end)

			return d
		end,
		onCanRun = function(item)
			return IsValid(item.entity)
		end
	},
}
function GM:PlayerLoadout(client)
	if client:getChar():hasFlags("P") then  
	client:Give("weapon_physgun")
	client:SelectWeapon("weapon_physgun")
	end
	if client:getChar():hasFlags("t") then  
		client:Give("gmod_tool")
		client:SelectWeapon("gmod_tool")
	end
end

if SERVER then
timer.Create("liaSaveData", lia.config.DataSaveInterval, 0, function()
    hook.Run("SaveData")
    hook.Run("PersistenceSave")
end)
resource.AddWorkshop("2959728255")

timer.Simple(0, function()
    hook.Run("SetupDatabase")

    lia.db.connect(function()
        lia.db.loadTables()
        MsgC(Color(0, 255, 0), "Lilia has connected to the database.\n")
        MsgC(Color(0, 255, 0), "Database Type: " .. lia.db.module .. ".\n")
        hook.Run("DatabaseConnected")
    end)
end)

cvars.AddChangeCallback("sbox_persist", function(name, old, new)
    timer.Create("sbox_persist_change_timer", 1, 1, function()
        hook.Run("PersistenceSave", old)
        game.CleanUpMap()
        if new == "" then return end
        hook.Run("PersistenceLoad", new)
    end)
end, "sbox_persist_load")

else
	cvars.AddChangeCallback("lia_cheapblur", function(name, old, new)
		CreateClientConVar("lia_cheapblur", 0, true):GetBool() = (tonumber(new) or 0) > 0
	end)
	
	CreateConVar("cl_weaponcolor", "0.30 1.80 2.10", {FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD}, "The value is a Vector - so between 0-1 - not between 0-255")

	timer.Remove("HintSystem_OpeningMenu")
	timer.Remove("HintSystem_Annoy1")
	timer.Remove("HintSystem_Annoy2")
	
	function GM:HUDPaint()
		if BRANCH ~= "x86-64" then draw.SimpleText("We recommend the use of the x86-64 Garry's Mod Branch for this server, consider swapping as soon as possible.", "liaSmallFont", ScrW() * .5, ScrH() * .97, Color(255, 255, 255, 10), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
	end

nut = lia or {
    util = {},
    meta = {}
}
end


do
    local playerMeta = FindMetaTable("Player")
    playerMeta.liaSteamID64 = playerMeta.liaSteamID64 or playerMeta.SteamID64

    function playerMeta:SteamID64()
        return self:liaSteamID64() or 0
    end

    LiliaTranslateModel = LiliaTranslateModel or player_manager.TranslateToPlayerModelName

    function player_manager.TranslateToPlayerModelName(model)
        model = model:lower():gsub("\\", "/")
        local result = LiliaTranslateModel(model)

        if result == "kleiner" and not model:find("kleiner") then
            local model2 = model:gsub("models/", "models/player/")
            result = LiliaTranslateModel(model2)
            if result ~= "kleiner" then return result end
            model2 = model:gsub("models/humans", "models/player")
            result = LiliaTranslateModel(model2)
            if result ~= "kleiner" then return result end
            model2 = model:gsub("models/zombie/", "models/player/zombie_")
            result = LiliaTranslateModel(model2)
            if result ~= "kleiner" then return result end
        end

        return result
    end
end

function GM:Initialize()
    lia.module.initialize()
end

LIA_MODULES_ALREADY_LOADED = false

function GM:OnReloaded()
    if CLIENT then
        hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
    else
        for _, client in ipairs(player.GetAll()) do
            hook.Run("CreateSalaryTimer", client)
        end
    end

    if not LIA_MODULES_ALREADY_LOADED then
        lia.module.initialize()
        LIA_MODULES_ALREADY_LOADED = true
    end

    lia.faction.formatModelData()
end

if SERVER and game.IsDedicated() then
    concommand.Remove("gm_save")

    concommand.Add("gm_save", function(client, command, arguments)
        print("COMMAND DISABLED")
    end)
end

util.AddNetworkString("liaCharacterInvList")
util.AddNetworkString("liaItemDelete")
util.AddNetworkString("liaItemInstance")
util.AddNetworkString("ixInventoryInit")
util.AddNetworkString("ixInventoryData")
util.AddNetworkString("ixInventoryDelete")
util.AddNetworkString("ixInventoryAdd")
util.AddNetworkString("ixInventoryRemove")
util.AddNetworkString("liaInventoryInit")
util.AddNetworkString("liaInventoryData")
util.AddNetworkString("liaInventoryDelete")
util.AddNetworkString("liaInventoryAdd")
util.AddNetworkString("liaInventoryRemove")
util.AddNetworkString("liaNotify")
util.AddNetworkString("liaNotifyL")
util.AddNetworkString("liaStringReq")
