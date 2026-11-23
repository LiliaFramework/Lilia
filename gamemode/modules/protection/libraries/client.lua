local TRIGGER_KEYS = {
    [KEY_HOME] = true,
    [KEY_INSERT] = true,
    [KEY_DELETE] = true,
}

function MODULE:CanDeleteChar(client, character)
    if IsValid(character) and character:getMoney() < lia.config.get("DefaultMoney") then return false end
end

function MODULE:DrawPhysgunBeam(client)
    return client == LocalPlayer()
end

function MODULE:PlayerButtonDown(client, key)
    if TRIGGER_KEYS[key] then
        timer.Remove("clipboard_blocker")
        local endAt = CurTime() + 30
        SetClipboardText("")
        timer.Create("clipboard_blocker", 0.4, 0, function()
            if CurTime() >= endAt then
                timer.Remove("clipboard_blocker")
                return
            end

            SetClipboardText("")
        end)
    end

    if key == KEY_INSERT and IsFirstTimePredicted() then
        local ply = LocalPlayer()
        if IsValid(ply) and ply == client then
            net.Start("liaInsertKeyPressed")
            net.SendToServer()
        end
    end
end

function MODULE:InitPostEntity()
    local client = LocalPlayer()
    if not file.Exists("cache", "DATA") then file.CreateDir("cache") end
    local filename = "cache/icon32.png"
    if lia.config.get("AltsDisabled", false) and file.Exists(filename, "DATA") then
        net.Start("liaCheckSeed")
        net.WriteString(file.Read(filename, "DATA"))
        net.SendToServer()
    else
        file.Write(filename, client:SteamID())
    end
end

local getImageDimensions
do
    local max_image_search = 1024
    local function getPNGDimensions(f)
        f:Skip(4)
        while not f:EndOfFile() and f:Tell() <= max_image_search do
            local chunkLength = f:ReadULong()
            local chunkType = f:Read(4)
            if chunkType == "IHDR" then
                local width = bit.bswap(f:ReadULong())
                local height = bit.bswap(f:ReadULong())
                return width, height
            end

            f:Skip(chunkLength)
            f:Skip(4)
        end
    end

    local function getJPEGDimensions(f)
        local byte1, byte2
        while not f:EndOfFile() and f:Tell() <= max_image_search do
            byte1 = f:ReadByte()
            if byte1 == 0xFF then
                byte2 = f:ReadByte()
                if byte2 >= 0xC0 and byte2 <= 0xCF and byte2 ~= 0xC4 and byte2 ~= 0xC8 then
                    f:Skip(3)
                    local height = bit.bswap(bit.lshift(f:ReadUShort(), 16))
                    local width = bit.bswap(bit.lshift(f:ReadUShort(), 16))
                    return width, height
                end
            end
        end
    end

    function getImageDimensions(path)
        local f = file.Open(path, "rb", "DATA")
        if not f then return end
        local succ, width, height
        local sig = f:Read(4)
        if sig == "\xff\xd8\xff\xe0" then
            succ, width, height = pcall(getJPEGDimensions, f)
        elseif sig == "\x89\x50\x4e\x47" then
            succ, width, height = pcall(getPNGDimensions, f)
        end

        f:Close()
        if not succ then return end
        return width, height
    end
end

__originalMaterial = __originalMaterial or Material
function Material(name, words)
    if name:find("../data") then
        local path = string.Replace(name, "../data/", "")
        local width, height = getImageDimensions(path)
        if not width or not height then return __originalMaterial("error") end
        if (width * height) > 33177600 then return __originalMaterial("error") end
    end
    return __originalMaterial(name, words)
end
