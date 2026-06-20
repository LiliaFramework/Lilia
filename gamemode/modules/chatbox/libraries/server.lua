local MODULE = MODULE
local FILTER_DATA_KEY = "chatbox_filtered_words"
local function getWordFilterModule()
    local wordFilterModule = lia.module and lia.module.get and lia.module.get("wordfilter")
    if wordFilterModule == MODULE then return nil end
    return wordFilterModule
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

local function applyWordsToWordFilterModule(words)
    local wordFilterModule = getWordFilterModule()
    if not wordFilterModule then return end
    wordFilterModule.WordBlackList = buildNormalizedWordList(words)
end

function MODULE:CanManageFilteredWords(client)
    local hasPrivilege = IsValid(client) and client:hasPrivilege("manageChatFilter") or false
    lia.debug("[Permissions]", "Permission Check for function MODULE:CanManageFilteredWords", "isValidPlayer=", tostring(IsValid(client)), "hasPrivilege(manageChatFilter)=", tostring(hasPrivilege), "finalResult=", tostring(hasPrivilege))
    return hasPrivilege
end

function MODULE:GetFilteredWords()
    local wordFilterModule = getWordFilterModule()
    if wordFilterModule and istable(wordFilterModule.WordBlackList) then
        self.FilteredWords = buildNormalizedWordList(wordFilterModule.WordBlackList)
        return self.FilteredWords
    end

    self.FilteredWords = buildNormalizedWordList(self.FilteredWords or {})
    return self.FilteredWords
end

function MODULE:LoadData()
    local stored = lia.data.get(FILTER_DATA_KEY, {})
    local wordFilterModule = getWordFilterModule()
    if wordFilterModule and istable(wordFilterModule.WordBlackList) then
        self.FilteredWords = #stored > 0 and stored or wordFilterModule.WordBlackList
    else
        self.FilteredWords = stored
    end

    self:SaveData()
end

function MODULE:SaveData()
    self.FilteredWords = buildNormalizedWordList(self.FilteredWords or {})
    applyWordsToWordFilterModule(self.FilteredWords)
    lia.data.set(FILTER_DATA_KEY, self.FilteredWords)
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
        if self:CanManageFilteredWords(targets) then recipients[#recipients + 1] = targets end
    elseif istable(targets) then
        for _, client in ipairs(targets) do
            if self:CanManageFilteredWords(client) then recipients[#recipients + 1] = client end
        end
    else
        for _, client in player.Iterator() do
            if self:CanManageFilteredWords(client) then recipients[#recipients + 1] = client end
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

function MODULE:SyncFilteredWordsFromModule()
    local wordFilterModule = getWordFilterModule()
    if not (wordFilterModule and istable(wordFilterModule.WordBlackList)) then return end
    self.FilteredWords = buildNormalizedWordList(wordFilterModule.WordBlackList)
    self:SaveData()
end
