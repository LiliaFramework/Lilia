function PLUGIN:ResetCombatStatus(client)
    timer.Simple(0.1, function()
        client:SetNWBool("WarmUpBegin", false)
        client:SetNWBool("MyTurn", false)
        client:SetNWBool("IsInCombat", false)
        client:SetNWBool("WarmUp", false)
        client:SetNWFloat("Timeramount", 0)
        client:SetNWBool("TryingToLeave", false)
        client:SetNWBool("PlayerTurnCheck", false)
        client:SetNWBool("TryingToLeave", false)
    end)
end

function PLUGIN:PlayerSpawn(client)
    if not table.IsEmpty(self.TotalCombats) then
        for k, v in pairs(self.TotalCombats) do
            for k2, v2 in pairs(v) do
                if IsEntity(v2) then
                    if IsValid(v2) then
                        if v2 == client then
                            table.remove(v, k2)
                            table.insert(v, k2, NULL)
                        end
                    end
                end
            end
        end
    end

    self:ResetCombatStatus(client)
end

function PLUGIN:PlayerDeath(client)
    if not table.IsEmpty(self.TotalCombats) then
        for k, v in pairs(self.TotalCombats) do
            for k2, v2 in pairs(v) do
                if IsEntity(v2) then
                    if IsValid(v2) then
                        if v2 == client then
                            table.remove(v, k2)
                            table.insert(v, k2, NULL)
                        end
                    end
                end
            end
        end
    end

    self:ResetCombatStatus(client)
end

-- make this work better, IE ignore NPCs that are on the ignore list
function PLUGIN:EntityTakeDamage(target, dmg)
    target:SetNWBool("TryingToLeave", false)

    if lia.config.get("Turn Based Combat On/Off", true) then
        if (self.IgnoredNPCs[dmg:GetInflictor():GetClass()] == nil) == (self.IgnoredNPCs[target:GetClass()] == nil) then
            -- adds the NPC/player to the combat if they shoot at a player/npc already in that combat
            if not dmg:GetInflictor():GetNWBool("IsInCombat", false) then
                if not table.IsEmpty(self.TotalCombats) then
                    for k, v in pairs(self.TotalCombats) do
                        for k2, v2 in pairs(v) do
                            if target == v2 then
                                if dmg:GetInflictor():GetClass() == "player" and dmg:GetInflictor():Alive() then
                                    dmg:GetInflictor():SetNWBool("WarmUpBegin", true)
                                    --ent:SetMaterial("models/shiny") -- just for testing
                                    dmg:GetInflictor():SetNWBool("WarmUp", true)
                                    dmg:GetInflictor().btimer = false
                                    table.insert(v, #v, dmg:GetInflictor())

                                    if v[1] == "Combat" then
                                        dmg:GetInflictor():SetNWBool("WarmUpBegin", false)
                                    end

                                    dmg:GetInflictor():SetNWBool("IsInCombat", true)
                                    break
                                elseif dmg:GetInflictor():IsNPC() then
                                    --dmg:GetInflictor():SetMaterial("models/shiny") -- just for testing
                                    dmg:GetInflictor():SetNWBool("WarmUp", true)
                                    dmg:GetInflictor():SetNWBool("MyTurn", false)
                                    table.insert(v, #v, dmg:GetInflictor())
                                    dmg:GetInflictor():GetNWBool("MyTurn", false)
                                    dmg:GetInflictor():SetNWBool("IsInCombat", true)
                                    break
                                end
                            end
                        end
                    end
                end
            end

            -- prevents damage from being taken if the player isn't in combat
            if not dmg:GetInflictor():GetNWBool("IsInCombat", false) and (dmg:GetInflictor():IsNPC() or dmg:GetInflictor():GetClass() == "player") then
                dmg:SetDamage(0)
            end

            if not target:GetNWBool("IsInCombat", false) then
                if not (target:IsNPC() and dmg:GetInflictor():IsNPC()) then
                    if target:GetClass() == "player" or target:IsNPC() then
                        for k, v in pairs(ents.GetAll()) do
                            if v:GetClass() == "player" or v:IsNPC() and self.IgnoredNPCs[v:GetClass()] == nil then
                                timer.Simple(0.01, function()
                                    local trace = util.TraceLine{
                                        start = target:EyePos(),
                                        endpos = v:EyePos(),
                                        mask = MASK_SOLID_BRUSHONLY,
                                    }

                                    if not trace.Hit then
                                        if target:EyePos():Distance(v:EyePos()) <= lia.config.get("radius", 500) then
                                            self:BeginWarmUp(v)
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            elseif target:GetNWBool("IsInCombat", false) and not dmg:GetInflictor():GetNWBool("IsInCombat", false) then
                self:AutoJoinCombat(dmg:GetInflictor())
            end
        end
    end
end

function PLUGIN:BeginWarmUp(entity)
    self.Data[1] = "WarmUp" -- current state
    self.Data[2] = lia.config.get("warmuptimer", 5) + CurTime() -- timer for warmup, and turns
    self.Data[3] = 0 -- player counter
    self.Data[4] = 0 -- NPC counter
    self.Data[5] = 6 -- turn pointer

    if entity:GetClass() == "player" then
        entity:SetNWBool("IsInCombat", true)
        entity:SetNWBool("WarmUpBegin", true)
        --entity:SetMaterial("models/shiny") -- just for testing
        entity:SetNWBool("WarmUp", true)
        table.insert(self.Data, entity)
    elseif entity:IsNPC() then
        entity:SetNWBool("IsInCombat", true)
        --entity:SetMaterial("models/shiny") -- just for testing
        entity:SetNWBool("WarmUp", true)
        entity:SetNWBool("MyTurn", false)
        table.insert(self.Data, entity)
    end
end

function PLUGIN:AutoJoinCombat(ent)
    if lia.config.get("Turn Based Combat On/Off", true) then
        if not ent:GetNWBool("IsInCombat", false) then
            if self.IgnoredNPCs[ent:GetClass()] == nil then
                if IsValid(ent) then
                    timer.Simple(0.01, function()
                        -- just for server starts
                        if not table.IsEmpty(self.TotalCombats) then
                            for k, v in pairs(self.TotalCombats) do
                                for k2, v2 in pairs(v) do
                                    if IsEntity(v2) then
                                        if IsValid(v2) then
                                            local trace = util.TraceLine{
                                                start = ent:EyePos(),
                                                endpos = v2:EyePos(),
                                                mask = MASK_SOLID_BRUSHONLY,
                                            }

                                            if not trace.Hit then
                                                if ent:EyePos():Distance(v2:EyePos()) <= lia.config.get("radius", 500) then
                                                    if ent:GetClass() == "player" and ent:Alive() then
                                                        ent:SetNWBool("WarmUpBegin", true)
                                                        --ent:SetMaterial("models/shiny") -- just for testing
                                                        ent:SetNWBool("WarmUp", true)
                                                        ent.btimer = false
                                                        table.insert(v, #v, ent)

                                                        if v[1] == "Combat" then
                                                            ent:SetNWBool("WarmUpBegin", false)
                                                        end

                                                        ent:SetNWBool("IsInCombat", true)
                                                        break
                                                    elseif ent:IsNPC() then
                                                        --ent:SetMaterial("models/shiny") -- just for testing
                                                        ent:SetNWBool("WarmUp", true)
                                                        ent:SetNWBool("MyTurn", false)
                                                        table.insert(v, #v, ent)
                                                        ent:GetNWBool("MyTurn", false)
                                                        ent:SetNWBool("IsInCombat", true)
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
end

function PLUGIN:PlayerTick(player, mv)
    self:AutoJoinCombat(player)
end

function PLUGIN:OnEntityCreated(entity)
    if entity:IsNPC() then
        self:AutoJoinCombat(entity)
    end
end

function PLUGIN:Think()
    timer.Simple(0.01, function()
        for k, v in pairs(ents.GetAll()) do
            if v:IsNPC() then
                if v:IsMoving() then
                    self:AutoJoinCombat(v)
                end
            end
        end

        -- Multidimential table setup
        -- A TON OF BULLSHIT JUST TO GET MULTIDIMENTIONAL TABLES TO BE CREATED
        if not table.IsEmpty(self.Data) then
            local NewTable = {}

            for i, v in pairs(self.Data) do
                NewTable[#NewTable + 1] = v
            end

            table.Empty(self.Data)
            self.TotalCombats[#self.TotalCombats + 1] = NewTable
        end

        -- A work around for players getting bugged into constantly being in combat
        if table.IsEmpty(self.TotalCombats) then
            for k, v in pairs(player.GetAll()) do
                self:ResetCombatStatus(v)
            end
        end

        -- just for server starts
        if not table.IsEmpty(self.TotalCombats) then
            if lia.config.get("Turn Based Combat On/Off", true) then
                -- Goes through the every single combat encounter table
                for k, v in pairs(self.TotalCombats) do
                    -- Warmup Timer
                    if v[1] == "WarmUp" then
                        if v[2] < CurTime() then
                            v[1] = "Combat"
                            v[#v + 1] = "."
                            self:BeginCombat(v)
                        end
                    end

                    -- Player and NPC counter
                    v[3] = 0
                    v[4] = 0

                    for k2, v2 in pairs(v) do
                        if IsEntity(v2) then
                            if IsValid(v2) then
                                if IsEntity(v2) then
                                    if v2:GetClass() == "player" then
                                        v[3] = v[3] + 1
                                        v2:SetNWFloat("Timeramount", v[2])
                                    elseif v2:IsNPC() then
                                        v[4] = v[4] + 1
                                    end
                                end
                            end
                        end
                    end

                    for k2, v2 in pairs(v) do
                        if IsEntity(v2) then
                            if IsValid(v2) then
                                if v2:GetClass() == "player" then
                                    v2:SetNWInt("CombatNPCCount", v[4])
                                    v2:SetNWInt("CombatPlayerCount", v[3])
                                else
                                    -- freeze NPCs
                                    if not v2:GetNWBool("MyTurn", false) then
                                        v2:SetCondition(67)
                                    else -- unfreeze NPCs
                                        v2:SetCondition(68)
                                    end
                                end
                                --else
                                --	table.remove( v, k2 )
                            end
                        end
                    end

                    -- Remove dups
                    timer.Simple(0.1, function()
                        for k2, v2 in pairs(v) do
                            for k3, v3 in pairs(v) do
                                if v2 == v3 and not (k2 == k3) and IsEntity(v2) and IsEntity(v3) then
                                    table.remove(v, k3)
                                end
                            end
                        end
                    end)

                    -- the end condition/table remover
                    timer.Simple(0.1, function()
                        if ((v[4] == 0 and v[3] <= 1) or (v[4] >= 0 and v[3] == 0)) or v[1] == "End Combat" then
                            for k2, v2 in pairs(v) do
                                if IsEntity(v2) then
                                    if IsValid(v2) then
                                        if v2:GetClass() == "player" then
                                            self:ResetCombatStatus(v2)
                                        else
                                            timer.Simple(1, function()
                                                v2:SetCondition(68)
                                                v2:SetNWBool("IsInCombat", false)
                                                --v2:SetMaterial("") -- just for testing
                                                v2:SetNWBool("MyTurn", true)
                                                v2:SetNWBool("WarmUp", false)
                                            end)
                                        end
                                    end
                                end
                            end

                            table.remove(self.TotalCombats, k)
                        end
                    end)

                    -- Turn based combat
                    if v[1] == "Combat" then
                        if IsEntity(v[v[5]]) and IsValid(v[v[5]]) then
                            if v[v[5]]:GetClass() == "player" then
                                -- the code that allows the player to do their turn
                                -- at the start of the players turn ran once
                                if v[2] - lia.config.get("playertimeammount", 10) + 0.1 >= CurTime() then
                                    v[v[5]]:SetNWInt("AP", lia.config.get("playeractionpoints", 3))
                                    v[v[5]]:SetNWVector("StartPos", v[v[5]]:GetPos())
                                    v[v[5]]:SetNWFloat("TurnTimer", v[2])

                                    -- Checks for if the player tried to leave there last turn and checks if all players in combat want to end combat
                                    if v[v[5]]:GetNWBool("PlayerTurnCheck", true) and v[v[5]]:GetNWBool("TryingToLeave", false) then
                                        for k2, v2 in pairs(v) do
                                            if IsEntity(v2) and v2:IsPlayer() then
                                                if v2:GetNWBool("TryingToLeave", false) then
                                                    v[1] = "End Combat"
                                                else
                                                    v[1] = "Combat"
                                                    break
                                                end
                                            end
                                        end
                                    else
                                        v[v[5]]:SetNWBool("PlayerTurnCheck", false)
                                    end
                                end

                                -- The lose of AP when the player moves
                                if v[v[5]]:GetNWVector("StartPos", v[v[5]]:GetPos()):Distance(v[v[5]]:GetPos()) > lia.config.get("movementradius", 10) * v[v[5]]:GetNWInt("AP", lia.config.get("playeractionpoints", 3)) then
                                    local trace = util.TraceLine({
                                        start = v[v[5]]:GetPos() + Vector(0, 0, 30),
                                        endpos = v[v[5]]:GetPos() - Vector(0, 0, 10000),
                                        filter = v[v[5]]
                                    })

                                    v[v[5]]:SetNWVector("StartPos", trace.HitPos)
                                    v[v[5]]:SetNWInt("AP", v[v[5]]:GetNWInt("AP", 3) - 1)
                                end

                                -- skip your turn with walk
                                if v[v[5]]:KeyPressed(IN_WALK) and IsValid(v[v[5]]) and v[v[5]]:Alive() and IsValid(v[v[5]]:GetActiveWeapon()) then
                                    -- if the player uses AP then skips it's not considered tryingtoleave
                                    if v[v[5]]:GetNWInt("AP", 3) == lia.config.get("playeractionpoints", 3) then
                                        v[v[5]]:SetNWBool("TryingToLeave", true)
                                    end

                                    v[v[5]]:SetNWInt("AP", 0)
                                end

                                -- if player fires/holds trigger they lose AP for each second
                                if v[v[5]]:KeyPressed(IN_ATTACK) then
                                    v[v[5]]:SetNWInt("AP", v[v[5]]:GetNWInt("AP", 3) - 1)
                                    v[v[5]]:SetNWFloat("TimeBetweenShots", CurTime() + 1)
                                end

                                if v[v[5]]:KeyDown(IN_ATTACK) and IsValid(v[v[5]]) and v[v[5]]:Alive() and IsValid(v[v[5]]:GetActiveWeapon()) then
                                    timer.Simple(0.01, function()
                                        if v[v[5]]:GetNWFloat("TimeBetweenShots", 0) <= CurTime() then
                                            v[v[5]]:SetNWInt("AP", v[v[5]]:GetNWInt("AP", 3) - 1)
                                            v[v[5]]:SetNWFloat("TimeBetweenShots", CurTime() + 1)
                                        end
                                    end)
                                end

                                --ran constantly in the turn
                                --timer.Simple( 0.11, function()
                                v[v[5]]:SetNWBool("MyTurn", true)
                                v[v[5]]:SetNWBool("WarmUp", false)

                                --end)	
                                -- ran at the end of the players turn
                                -- The timer to count how long the player has till their turn is up
                                if v[2] < CurTime() or v[v[5]]:GetNWInt("AP", 0) <= 0 then
                                    if v[v[5]]:GetNWInt("AP", 0) == lia.config.get("playeractionpoints", 3) then
                                        v[v[5]]:SetNWBool("TryingToLeave", true)
                                    end

                                    if IsValid(v[v[5] + 1]) then
                                        if v[v[5] + 1]:IsNPC() then
                                            v[2] = lia.config.get("npctimeammount", 5) + CurTime()
                                        else
                                            v[2] = lia.config.get("playertimeammount", 10) + CurTime()
                                        end
                                    else
                                        if v[6]:IsNPC() and IsValid(v[6]) then
                                            v[2] = lia.config.get("npctimeammount", 5) + CurTime()
                                        else
                                            v[2] = lia.config.get("playertimeammount", 10) + CurTime()
                                        end
                                    end

                                    if v[v[5]]:GetNWBool("TryingToLeave", false) then
                                        v[v[5]]:SetNWBool("PlayerTurnCheck", true)
                                    end

                                    v[v[5]]:SetNWBool("MyTurn", false)
                                    v[5] = v[5] + 1
                                end
                            elseif v[v[5]]:IsNPC() then
                                -- the code that allows the NPC to do their turn
                                v[v[5]]:SetNWBool("MyTurn", true)

                                -- The timer to count how long the NPC has till their turn is up
                                if v[2] < CurTime() then
                                    if IsValid(v[v[5] + 1]) then
                                        if v[v[5] + 1]:IsNPC() then
                                            v[2] = lia.config.get("npctimeammount", 5) + CurTime()
                                        else
                                            v[2] = lia.config.get("playertimeammount", 10) + CurTime()
                                        end
                                    else
                                        if v[6]:IsNPC() and IsValid(v[6]) then
                                            v[2] = lia.config.get("npctimeammount", 5) + CurTime()
                                        else
                                            v[2] = lia.config.get("playertimeammount", 10) + CurTime()
                                        end
                                    end

                                    v[v[5]]:SetNWBool("MyTurn", false)
                                    v[5] = v[5] + 1
                                end
                            end
                        elseif not IsEntity(v[v[5]]) then
                            v[5] = 6
                        else
                            if IsValid(v[v[5] + 1]) then
                                if v[v[5] + 1]:IsNPC() then
                                    v[2] = lia.config.get("npctimeammount", 5) + CurTime()
                                else
                                    v[2] = lia.config.get("playertimeammount", 10) + CurTime()
                                end
                            end

                            v[5] = v[5] + 1
                        end
                    end
                end
            end
        end
    end)
end

function PLUGIN:BeginCombat(tab)
    for k, v in pairs(tab) do
        if IsEntity(v) then
            if IsValid(v) and v:GetClass() == "player" then
                v:SetNWBool("WarmUpBegin", false)
            end
        end
    end

    tab[2] = lia.config.get("playertimeammount", 10) + CurTime()
end