local PLUGIN = PLUGIN

function PLUGIN:openNotes(client, target, edit)
    if IsValid(target) and target:getChar() then
        local charID = target:getChar():getID()
        local path = "lilia/" .. SCHEMA.folder .. "/charnotes/" .. charID

        --this thing basically builds the panels
        local notes = {
            [1] = {
                name = "Mind: " .. target:Nick(), --name of panel
                data = file.Read(path .. ".txt") or "", --data displayed in the panel
                size = {400, 400},
                pos = {0.29, 0.5},
                saveFunc = "lia_charNoteSave",
            },
            [2] = {
                name = "Body",
                data = file.Read(path .. "I.txt") or "",
                size = {400, 400},
                pos = {0.5, 0.5},
                saveFunc = "lia_charNoteSaveI",
            },
            [3] = {
                name = "Effects",
                data = file.Read(path .. "E.txt") or "",
                size = {400, 400},
                pos = {0.4, 0.13},
                saveFunc = "lia_charNoteSaveE",
            },
        }

        --sends them gui thing
        netstream.Start(client, "lia_charNoteOpen", charID, notes, edit)
    end
end

function PLUGIN:LoadData()
    local path = "lilia/" .. SCHEMA.folder .. "/charnotes/"

    if not file.Exists(path, "DATA") then
        file.CreateDir("lilia/" .. SCHEMA.folder .. "/charnotes/")
    end
end

netstream.Hook("lia_charNoteSave", function(client, charID, notes)
    local path = "lilia/" .. SCHEMA.folder .. "/charnotes/" .. charID .. ".txt"
    file.Write(path, notes)
end)

netstream.Hook("lia_charNoteSaveI", function(client, charID, notes)
    local path = "lilia/" .. SCHEMA.folder .. "/charnotes/" .. charID .. "I.txt"
    file.Write(path, notes)
end)

netstream.Hook("lia_charNoteSaveE", function(client, charID, notes)
    local path = "lilia/" .. SCHEMA.folder .. "/charnotes/" .. charID .. "E.txt"
    file.Write(path, notes)
end)