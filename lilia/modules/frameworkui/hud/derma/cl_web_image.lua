
local c = {}

c.__index = c

if not file.IsDir("webimage", "DATA") then file.CreateDir("webimage") end

function c:Download()
    if self:IsDownloading() or self:IsReady() then return end
    local uid = util.CRC(self.Path)
    self.UID = uid
    http.Fetch(
        self.Path,
        function(body, _, _, _)
            file.Write("webimage/" .. self.UID .. "." .. self.ext, body)
            self.Downloading = false
            self.Ready = true
        end,
        function(err) ErrorNoHalt("Error fetching texture '" .. self.Path .. "': " .. err .. "\n") end
    )
end


function c:IsReady()
    return self.Ready
end


function c:IsDownloading()
    return self.Downloading
end


function c:GetMaterial()
    if self:IsDownloading() or not self:IsReady() then return end
    return Material("../data/webimage/" .. self.UID .. "." .. self.ext, self.Flags)
end


function WebMaterial(path, flags)
    local ext = path:Split(".")
    ext = ext[#ext]
    return     setmetatable(
        {
            Path = path,
            Flags = flags,
            Ready = false,
            ext = ext,
            Downloading = false
        },
        c
    )
end

