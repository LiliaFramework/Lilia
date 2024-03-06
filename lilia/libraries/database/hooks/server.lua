local GM = GM or GAMEMODE
local resetCalled = 0
function GM:RegisterPreparedStatements()
    MsgC(Color(0, 255, 0), "[Lilia] ADDED 5 PREPARED STATEMENTS\n")
    lia.db.prepare("itemData", "UPDATE lia_items SET _data = ? WHERE _itemID = ?", {MYSQLOO_STRING, MYSQLOO_INTEGER})
    lia.db.prepare("itemx", "UPDATE lia_items SET _x = ? WHERE _itemID = ?", {MYSQLOO_INTEGER, MYSQLOO_INTEGER})
    lia.db.prepare("itemy", "UPDATE lia_items SET _y = ? WHERE _itemID = ?", {MYSQLOO_INTEGER, MYSQLOO_INTEGER})
    lia.db.prepare("itemq", "UPDATE lia_items SET _quantity = ? WHERE _itemID = ?", {MYSQLOO_INTEGER, MYSQLOO_INTEGER})
    lia.db.prepare("itemInstance", "INSERT INTO lia_items (_invID, _uniqueID, _data, _x, _y, _quantity) VALUES (?, ?, ?, ?, ?, ?)", {MYSQLOO_INTEGER, MYSQLOO_STRING, MYSQLOO_STRING, MYSQLOO_INTEGER, MYSQLOO_INTEGER, MYSQLOO_INTEGER,})
end

function GM:SetupDatabase()
    local databasePath = engine.ActiveGamemode() .. "/database.json"
    local databaseOverrideExists = file.Exists(databasePath, "DATA")
    if databaseOverrideExists then
        local databaseConfig = file.Read(databasePath, "DATA")
        if databaseConfig then
            lia.db.config = databaseConfig
            for k, v in pairs(util.JSONToTable(lia.db.config)) do
                lia.db[k] = v
            end
        end
    end

    if not lia.db.config then
        MsgC(Color(255, 0, 0), "MySQL Database not configured. Falling back to SQLite.\n")
        for k, v in pairs(DefaultDatabase) do
            lia.db[k] = v
        end
    end
end

function GM:OnMySQLOOConnected()
    hook.Run("RegisterPreparedStatements")
    MYSQLOO_PREPARED = true
end

function GM:LiliaTablesLoaded()
    local ignore = function() end
    lia.db.query("SHOW COLUMNS FROM lia_characters WHERE Field = 'recognized_as'"):next(function(result)
        if result and result[1] and result[1].Field == "recognized_as" then
            print("Renaming SQL table...")
            lia.db.query("ALTER TABLE lia_characters CHANGE recognized_as _recognized_as TEXT NOT NULL COLLATE 'utf8mb4_general_ci'"):catch(ignore)
        end
    end):catch(ignore)

    lia.db.query("ALTER TABLE IF EXISTS lia_players ADD COLUMN _firstJoin DATETIME"):catch(ignore)
    lia.db.query("ALTER TABLE IF EXISTS lia_players ADD COLUMN _lastJoin DATETIME"):catch(ignore)
    lia.db.query("ALTER TABLE IF EXISTS lia_items ADD COLUMN _quantity INTEGER"):catch(ignore)
end
