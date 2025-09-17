# Hooks

This document describes the hooks available in the Cards module for managing card-related functionality.

---

## CardsCommandUsed

**Purpose**

Called when the cards command is used by a player.

**Parameters**

* `client` (*Player*): The player who used the cards command.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player executes the `cards` command
- Before the card drawing logic is executed
- When the command validation passes

**Example Usage**

```lua
-- Track cards command usage
hook.Add("CardsCommandUsed", "TrackCardsCommandUsage", function(client)
    print(client:Name(), "used the cards command")
    
    -- Log to server console
    local char = client:getChar()
    if char then
        local cardsCommandUsage = char:getData("cards_command_usage", 0)
        char:setData("cards_command_usage", cardsCommandUsage + 1)
    end
end)

-- Apply custom effects for cards command
hook.Add("CardsCommandUsed", "CardsCommandEffects", function(client)
    -- Play sound effect
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 215, 0, 20), 0.5, 0)
    
    -- Notify player
    client:notify("Cards command used!")
end)

-- Modify cards command behavior
hook.Add("CardsCommandUsed", "ModifyCardsCommandBehavior", function(client)
    local char = client:getChar()
    if char then
        -- Check if player has special card deck
        if char:getData("special_card_deck", false) then
            -- Use special card deck logic
            local specialCards = {"Ace of Spades", "King of Hearts", "Queen of Diamonds", "Jack of Clubs"}
            local card = table.Random(specialCards)
            lia.chat.send(client, "me", "draws a special card: " .. card)
            return true -- Prevent default behavior
        end
        
        -- Check if player is in a restricted area
        if char:getData("in_card_restricted_area", false) then
            client:notify("You cannot use cards in this area!")
            return false -- Prevent card drawing
        end
    end
end)

-- Log cards command usage
hook.Add("CardsCommandUsed", "LogCardsCommandUsage", function(client)
    -- Log to server console
    print("CARDS COMMAND:", client:Name(), "used cards command at", os.date())
    
    -- Log to file if needed
    file.Append("cards_log.txt", os.date() .. " - " .. client:Name() .. " - Cards command used\n")
end)
```

---

## CardDrawn

**Purpose**

Called when a card is successfully drawn by a player.

**Parameters**

* `client` (*Player*): The player who drew the card.
* `card` (*string*): The card that was drawn (e.g., "Ace of Spades").

**Realm**

Server.

**When Called**

This hook is triggered when:
- A card is successfully drawn from the deck
- After the card drawing logic completes
- When the card result is determined

**Example Usage**

```lua
-- Track card draws
hook.Add("CardDrawn", "TrackCardDraws", function(client, card)
    print(client:Name(), "drew:", card)
    
    -- Log to server console
    local char = client:getChar()
    if char then
        local cardDraws = char:getData("card_draws", 0)
        char:setData("card_draws", cardDraws + 1)
        
        -- Track specific cards drawn
        local cardsDrawn = char:getData("cards_drawn", {})
        table.insert(cardsDrawn, {
            card = card,
            timestamp = os.time()
        })
        char:setData("cards_drawn", cardsDrawn)
    end
end)

-- Apply custom effects for card draws
hook.Add("CardDrawn", "CardDrawEffects", function(client, card)
    -- Play sound effect based on card type
    if card:find("Ace") then
        client:EmitSound("buttons/button15.wav", 75, 100)
    elseif card:find("King") or card:find("Queen") then
        client:EmitSound("buttons/button14.wav", 75, 100)
    else
        client:EmitSound("buttons/button13.wav", 75, 100)
    end
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 20), 0.3, 0)
    
    -- Notify player
    client:notify("Card drawn: " .. card)
end)

-- Modify card draw behavior
hook.Add("CardDrawn", "ModifyCardDrawBehavior", function(client, card)
    local char = client:getChar()
    if char then
        -- Check for special card combinations
        local cardsDrawn = char:getData("cards_drawn", {})
        if #cardsDrawn >= 3 then
            -- Check for three of a kind
            local lastThree = {}
            for i = #cardsDrawn - 2, #cardsDrawn do
                if cardsDrawn[i] then
                    local rank = cardsDrawn[i].card:match("(%w+)")
                    table.insert(lastThree, rank)
                end
            end
            
            if lastThree[1] == lastThree[2] and lastThree[2] == lastThree[3] then
                client:notify("Three of a kind! Bonus points!")
                char:setData("bonus_points", (char:getData("bonus_points", 0) + 100))
            end
        end
        
        -- Check for royal flush
        if card:find("Ace") or card:find("King") or card:find("Queen") or card:find("Jack") then
            client:notify("Royal card drawn! Special effect!")
            -- Apply special effect
            client:ScreenFade(SCREENFADE.IN, Color(255, 215, 0, 50), 1, 0)
        end
    end
end)

-- Track card statistics
hook.Add("CardDrawn", "TrackCardStatistics", function(client, card)
    local char = client:getChar()
    if char then
        -- Track card frequency
        local cardFrequency = char:getData("card_frequency", {})
        cardFrequency[card] = (cardFrequency[card] or 0) + 1
        char:setData("card_frequency", cardFrequency)
        
        -- Track suit frequency
        local suit = card:match("(%w+)$")
        if suit then
            local suitFrequency = char:getData("suit_frequency", {})
            suitFrequency[suit] = (suitFrequency[suit] or 0) + 1
            char:setData("suit_frequency", suitFrequency)
        end
        
        -- Track rank frequency
        local rank = card:match("(%w+)")
        if rank then
            local rankFrequency = char:getData("rank_frequency", {})
            rankFrequency[rank] = (rankFrequency[rank] or 0) + 1
            char:setData("rank_frequency", rankFrequency)
        end
    end
end)

-- Log card draws
hook.Add("CardDrawn", "LogCardDraws", function(client, card)
    -- Log to server console
    print("CARD DRAWN:", client:Name(), "drew", card, "at", os.date())
    
    -- Log to file if needed
    file.Append("cards_log.txt", os.date() .. " - " .. client:Name() .. " - Drew: " .. card .. "\n")
end)
```

---

## Usage Examples

### Complete Card System

```lua
-- Track all card-related activity
hook.Add("CardsCommandUsed", "TrackAllCardActivity", function(client)
    local char = client:getChar()
    if char then
        local totalActivity = char:getData("total_card_activity", 0)
        char:setData("total_card_activity", totalActivity + 1)
    end
end)

hook.Add("CardDrawn", "TrackAllCardActivity", function(client, card)
    local char = client:getChar()
    if char then
        local totalActivity = char:getData("total_card_activity", 0)
        char:setData("total_card_activity", totalActivity + 1)
    end
end)
```

### Card-Based Rewards System

```lua
-- Reward system based on cards drawn
hook.Add("CardDrawn", "CardRewardSystem", function(client, card)
    local char = client:getChar()
    if char then
        local rewards = {
            ["Ace of Spades"] = 100,
            ["King of Hearts"] = 50,
            ["Queen of Diamonds"] = 25,
            ["Jack of Clubs"] = 10
        }
        
        local reward = rewards[card]
        if reward then
            char:setData("card_rewards", (char:getData("card_rewards", 0) + reward))
            client:notify("Card reward: " .. reward .. " points!")
        end
    end
end)
```

### Card Statistics Tracking

```lua
-- Comprehensive card statistics
hook.Add("CardDrawn", "ComprehensiveCardStats", function(client, card)
    local char = client:getChar()
    if char then
        local stats = char:getData("card_stats", {
            total_draws = 0,
            aces_drawn = 0,
            face_cards_drawn = 0,
            spades_drawn = 0,
            hearts_drawn = 0,
            diamonds_drawn = 0,
            clubs_drawn = 0
        })
        
        stats.total_draws = stats.total_draws + 1
        
        if card:find("Ace") then
            stats.aces_drawn = stats.aces_drawn + 1
        end
        
        if card:find("King") or card:find("Queen") or card:find("Jack") then
            stats.face_cards_drawn = stats.face_cards_drawn + 1
        end
        
        if card:find("Spades") then
            stats.spades_drawn = stats.spades_drawn + 1
        elseif card:find("Hearts") then
            stats.hearts_drawn = stats.hearts_drawn + 1
        elseif card:find("Diamonds") then
            stats.diamonds_drawn = stats.diamonds_drawn + 1
        elseif card:find("Clubs") then
            stats.clubs_drawn = stats.clubs_drawn + 1
        end
        
        char:setData("card_stats", stats)
    end
end)
```
