local MODULE = MODULE
local LEGACY_FILTERED_WORDS_KEY = "chatbox_filtered_words"
local FILTERED_WORDS_DATA_DIR = "lilia/global/global"
local FILTERED_WORDS_DATA_FILE = FILTERED_WORDS_DATA_DIR .. "/chatbox.json"
local LEGACY_FILTERED_WORDS_DATA_FILE = FILTERED_WORDS_DATA_DIR .. "/chatbox_filtered_words.json"
local function readFilteredWordsFile(path)
    if not file.Exists(path, "DATA") then return nil end
    local raw = file.Read(path, "DATA")
    if not raw or raw == "" then return nil end
    local decoded = lia.data.deserialize(raw)
    if istable(decoded) then return decoded end
end

local function writeFilteredWordsFile(words)
    file.CreateDir(FILTERED_WORDS_DATA_DIR)
    file.Write(FILTERED_WORDS_DATA_FILE, lia.data.serialize(words or {}))
end

local function normalizeFilteredWord(word)
    word = string.Trim(tostring(word or "")):lower()
    if word == "" then return nil end
    return word
end

local function buildNormalizedWordList(words)
    local normalized = {}
    local lookup = {}
    for _, word in ipairs(words or {}) do
        local cleaned = normalizeFilteredWord(word)
        if cleaned and not lookup[cleaned] then
            lookup[cleaned] = true
            normalized[#normalized + 1] = cleaned
        end
    end

    table.sort(normalized)
    return normalized
end

function MODULE:CanManageFilteredWords(client)
    local hasPrivilege = IsValid(client) and client:hasPrivilege("manageChatFilter") or false
    lia.debug("[Permissions]", "Permission Check for function MODULE:CanManageFilteredWords", "isValidPlayer=", tostring(IsValid(client)), "hasPrivilege(manageChatFilter)=", tostring(hasPrivilege), "finalResult=", tostring(hasPrivilege))
    return hasPrivilege
end

function MODULE:GetFilteredWords()
    self.FilteredWords = buildNormalizedWordList(self.FilteredWords or {})
    return self.FilteredWords
end

function MODULE:LoadData()
    local storedWords = self:getData({})
    if not istable(storedWords) or table.IsEmpty(storedWords) then storedWords = lia.data.get(LEGACY_FILTERED_WORDS_KEY, {}) end
    if not istable(storedWords) or table.IsEmpty(storedWords) then storedWords = readFilteredWordsFile(FILTERED_WORDS_DATA_FILE) end
    if not istable(storedWords) or table.IsEmpty(storedWords) then storedWords = readFilteredWordsFile(LEGACY_FILTERED_WORDS_DATA_FILE) end
    self.FilteredWords = buildNormalizedWordList(storedWords)
    self:setData(self.FilteredWords, true, true)
    writeFilteredWordsFile(self.FilteredWords)
end

function MODULE:InitializedModules()
    if not SERVER or not lia.reloadInProgress then return end
    self:LoadData()
    timer.Simple(0, function()
        if not MODULE then return end
        MODULE:SyncFilteredWords()
    end)
end

function MODULE:PlayerLoadedCharacter(client)
    if not self:CanManageFilteredWords(client) then return end
    self:SyncFilteredWords(client)
end

function MODULE:SaveData()
    self.FilteredWords = buildNormalizedWordList(self.FilteredWords or {})
    self:setData(self.FilteredWords, true, true)
    writeFilteredWordsFile(self.FilteredWords)
end

function MODULE:AddFilteredWord(word)
    word = normalizeFilteredWord(word)
    if not word then return false, "invalid" end
    self.FilteredWords = buildNormalizedWordList(self:GetFilteredWords())
    if table.HasValue(self.FilteredWords, word) then return false, "exists" end
    self.FilteredWords[#self.FilteredWords + 1] = word
    self:SaveData()
    return true, word
end

function MODULE:RemoveFilteredWord(word)
    word = normalizeFilteredWord(word)
    if not word then return false, "invalid" end
    self.FilteredWords = buildNormalizedWordList(self:GetFilteredWords())
    for index, existingWord in ipairs(self.FilteredWords) do
        if existingWord == word then
            table.remove(self.FilteredWords, index)
            self:SaveData()
            return true, word
        end
    end
    return false, "missing"
end

function MODULE:SyncFilteredWords(targets)
    local recipients = {}
    if IsValid(targets) then
        if hook.Run("CanManageFilteredWords", targets) then recipients[#recipients + 1] = targets end
    elseif istable(targets) then
        for _, client in ipairs(targets) do
            if hook.Run("CanManageFilteredWords", client) then recipients[#recipients + 1] = client end
        end
    else
        for _, client in player.Iterator() do
            if hook.Run("CanManageFilteredWords", client) then recipients[#recipients + 1] = client end
        end
    end

    if #recipients == 0 then return end
    local words = self:GetFilteredWords()
    net.Start("liaChatboxSyncFilteredWords")
    net.WriteUInt(#words, 16)
    for _, filteredWord in ipairs(words) do
        net.WriteString(filteredWord)
    end

    net.Send(recipients)
end
