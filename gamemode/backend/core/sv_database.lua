
--------------------------------------------------------------------------------------------------------
timer.Simple(0, function()
    hook.Run("SetupDatabase")

    lia.db.connect(function()
        lia.db.loadTables()
        MsgC(Color(0, 255, 0), "Lilia has connected to the database.\n")
        MsgC(Color(0, 255, 0), "Database Type: " .. lia.db.module .. ".\n")
        hook.Run("DatabaseConnected")
    end)
end)
--------------------------------------------------------------------------------------------------------
function GM:OnMySQLOOConnected()
	hook.Run("RegisterPreparedStatements")
	MYSQLOO_PREPARED = true
end
--------------------------------------------------------------------------------------------------------
function GM:RegisterPreparedStatements()
	MsgC(Color(0, 255, 0), "[Lilia] ADDED 5 PREPARED STATEMENTS\n")

	lia.db.prepare("itemData", "UPDATE lia_items SET _data = ? WHERE _itemID = ?", {1, 0})

	lia.db.prepare("itemx", "UPDATE lia_items SET _x = ? WHERE _itemID = ?", {0, 0})

	lia.db.prepare("itemy", "UPDATE lia_items SET _y = ? WHERE _itemID = ?", {0, 0})

	lia.db.prepare("itemq", "UPDATE lia_items SET _quantity = ? WHERE _itemID = ?", {0, 0})

	lia.db.prepare("itemInstance", "INSERT INTO lia_items (_invID, _uniqueID, _data, _x, _y, _quantity) VALUES (?, ?, ?, ?, ?, ?)", {0, 1, 1, 0, 0, 0,})
end
--------------------------------------------------------------------------------------------------------