# Hooks

This document describes the hooks available in the Cutscenes module for managing cutscene playback and control.

---

## CutsceneEnded

**Purpose**

Called when a cutscene has completely finished playing.

**Parameters**

* `cutsceneID` (*string*): The ID of the cutscene that ended.

**Realm**

Client.

**When Called**

This hook is triggered when:
- A cutscene has finished playing all scenes
- The cutscene fade out is complete
- The cutscene panel is removed

**Example Usage**

```lua
-- Track cutscene completion
hook.Add("CutsceneEnded", "TrackCutsceneCompletion", function(cutsceneID)
    local char = LocalPlayer():getChar()
    if char then
        local cutscenesWatched = char:getData("cutscenes_watched", 0)
        char:setData("cutscenes_watched", cutscenesWatched + 1)
        
        -- Track specific cutscene
        local cutsceneWatches = char:getData("cutscene_watches", {})
        cutsceneWatches[cutsceneID] = (cutsceneWatches[cutsceneID] or 0) + 1
        char:setData("cutscene_watches", cutsceneWatches)
    end
end)

-- Apply cutscene end effects
hook.Add("CutsceneEnded", "CutsceneEndEffects", function(cutsceneID)
    -- Play end sound
    LocalPlayer():EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 0), 1, 0)
    
    -- Notify player
    LocalPlayer():notify("Cutscene '" .. cutsceneID .. "' ended!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(LocalPlayer():GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Clean up cutscene data
hook.Add("CutsceneEnded", "CleanupCutsceneData", function(cutsceneID)
    -- Clear cutscene state
    LocalPlayer().scene = nil
    
    -- Remove cutscene music
    if lia.cutsceneMusic then
        lia.cutsceneMusic:Stop()
        lia.cutsceneMusic = nil
    end
    
    -- Clear cutscene variables
    LocalPlayer():setData("current_cutscene", nil)
    LocalPlayer():setData("cutscene_start_time", nil)
end)

-- Award cutscene achievements
hook.Add("CutsceneEnded", "CutsceneAchievements", function(cutsceneID)
    local char = LocalPlayer():getChar()
    if char then
        local cutscenesWatched = char:getData("cutscenes_watched", 0)
        
        if cutscenesWatched == 1 then
            LocalPlayer():notify("Achievement: First Cutscene!")
        elseif cutscenesWatched == 10 then
            LocalPlayer():notify("Achievement: Cutscene Enthusiast!")
        elseif cutscenesWatched == 50 then
            LocalPlayer():notify("Achievement: Cutscene Master!")
        end
        
        -- Check for specific cutscene achievements
        local cutsceneWatches = char:getData("cutscene_watches", {})
        if cutsceneWatches[cutsceneID] == 1 then
            LocalPlayer():notify("Achievement: First time watching '" .. cutsceneID .. "'!")
        end
    end
end)
```

---

## CutsceneSceneEnded

**Purpose**

Called when a specific scene within a cutscene ends.

**Parameters**

* `cutsceneID` (*string*): The ID of the cutscene.
* `scene` (*table*): The scene data that ended.

**Realm**

Client.

**When Called**

This hook is triggered when:
- A scene within a cutscene finishes
- The scene fade out is complete
- Before the next scene starts or cutscene ends

**Example Usage**

```lua
-- Track scene completion
hook.Add("CutsceneSceneEnded", "TrackSceneCompletion", function(cutsceneID, scene)
    local char = LocalPlayer():getChar()
    if char then
        local scenesWatched = char:getData("scenes_watched", 0)
        char:setData("scenes_watched", scenesWatched + 1)
        
        -- Track scene duration
        local sceneDuration = char:getData("total_scene_duration", 0)
        char:setData("total_scene_duration", sceneDuration + (scene.duration or 0))
    end
end)

-- Apply scene end effects
hook.Add("CutsceneSceneEnded", "SceneEndEffects", function(cutsceneID, scene)
    -- Play scene end sound
    LocalPlayer():EmitSound("buttons/button15.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 10), 0.5, 0)
    
    -- Notify player
    LocalPlayer():notify("Scene ended in cutscene '" .. cutsceneID .. "'!")
end)

-- Track scene statistics
hook.Add("CutsceneSceneEnded", "TrackSceneStats", function(cutsceneID, scene)
    local char = LocalPlayer():getChar()
    if char then
        -- Track scene types
        local sceneTypes = char:getData("scene_types", {})
        local sceneType = scene.image and "image" or "text"
        sceneTypes[sceneType] = (sceneTypes[sceneType] or 0) + 1
        char:setData("scene_types", sceneTypes)
        
        -- Track scene durations
        local sceneDurations = char:getData("scene_durations", {})
        table.insert(sceneDurations, {
            cutscene = cutsceneID,
            duration = scene.duration or 0,
            time = os.time()
        })
        char:setData("scene_durations", sceneDurations)
    end
end)
```

---

## CutsceneSceneStarted

**Purpose**

Called when a specific scene within a cutscene starts.

**Parameters**

* `cutsceneID` (*string*): The ID of the cutscene.
* `scene` (*table*): The scene data that started.

**Realm**

Client.

**When Called**

This hook is triggered when:
- A scene within a cutscene begins
- The scene image is displayed
- Before any subtitles are shown

**Example Usage**

```lua
-- Track scene start
hook.Add("CutsceneSceneStarted", "TrackSceneStart", function(cutsceneID, scene)
    local char = LocalPlayer():getChar()
    if char then
        local scenesStarted = char:getData("scenes_started", 0)
        char:setData("scenes_started", scenesStarted + 1)
        
        -- Track scene start time
        char:setData("current_scene_start_time", os.time())
    end
end)

-- Apply scene start effects
hook.Add("CutsceneSceneStarted", "SceneStartEffects", function(cutsceneID, scene)
    -- Play scene start sound
    LocalPlayer():EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 50), 1, 0)
    
    -- Notify player
    LocalPlayer():notify("Scene started in cutscene '" .. cutsceneID .. "'!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(LocalPlayer():GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track scene content
hook.Add("CutsceneSceneStarted", "TrackSceneContent", function(cutsceneID, scene)
    local char = LocalPlayer():getChar()
    if char then
        -- Track scene images
        if scene.image then
            local sceneImages = char:getData("scene_images", {})
            sceneImages[scene.image] = (sceneImages[scene.image] or 0) + 1
            char:setData("scene_images", sceneImages)
        end
        
        -- Track scene sounds
        if scene.sound then
            local sceneSounds = char:getData("scene_sounds", {})
            sceneSounds[scene.sound] = (sceneSounds[scene.sound] or 0) + 1
            char:setData("scene_sounds", sceneSounds)
        end
    end
end)

-- Apply scene restrictions
hook.Add("CutsceneSceneStarted", "ApplySceneRestrictions", function(cutsceneID, scene)
    local char = LocalPlayer():getChar()
    if char then
        -- Check if cutscenes are disabled
        if char:getData("cutscenes_disabled", false) then
            LocalPlayer():notify("Cutscenes are disabled!")
            return false
        end
        
        -- Check scene cooldown
        local lastScene = char:getData("last_scene_time", 0)
        if os.time() - lastScene < 5 then -- 5 second cooldown
            LocalPlayer():notify("Please wait before starting another scene!")
            return false
        end
        
        -- Update last scene time
        char:setData("last_scene_time", os.time())
    end
end)
```

---

## CutsceneStarted

**Purpose**

Called when a cutscene begins playing.

**Parameters**

* `cutsceneID` (*string*): The ID of the cutscene that started.

**Realm**

Client.

**When Called**

This hook is triggered when:
- A cutscene begins playing
- The cutscene panel is created
- Before any scenes are displayed

**Example Usage**

```lua
-- Track cutscene start
hook.Add("CutsceneStarted", "TrackCutsceneStart", function(cutsceneID)
    local char = LocalPlayer():getChar()
    if char then
        local cutscenesStarted = char:getData("cutscenes_started", 0)
        char:setData("cutscenes_started", cutscenesStarted + 1)
        
        -- Track cutscene start time
        char:setData("current_cutscene_start_time", os.time())
        char:setData("current_cutscene", cutsceneID)
    end
end)

-- Apply cutscene start effects
hook.Add("CutsceneStarted", "CutsceneStartEffects", function(cutsceneID)
    -- Play start sound
    LocalPlayer():EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 100), 1, 0)
    
    -- Notify player
    LocalPlayer():notify("Cutscene '" .. cutsceneID .. "' started!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(LocalPlayer():GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track cutscene statistics
hook.Add("CutsceneStarted", "TrackCutsceneStats", function(cutsceneID)
    local char = LocalPlayer():getChar()
    if char then
        -- Track cutscene frequency
        local cutsceneFrequency = char:getData("cutscene_frequency", {})
        cutsceneFrequency[cutsceneID] = (cutsceneFrequency[cutsceneID] or 0) + 1
        char:setData("cutscene_frequency", cutsceneFrequency)
        
        -- Track cutscene start times
        local cutsceneStartTimes = char:getData("cutscene_start_times", {})
        table.insert(cutsceneStartTimes, {
            cutscene = cutsceneID,
            time = os.time()
        })
        char:setData("cutscene_start_times", cutsceneStartTimes)
    end
end)

-- Apply cutscene restrictions
hook.Add("CutsceneStarted", "ApplyCutsceneRestrictions", function(cutsceneID)
    local char = LocalPlayer():getChar()
    if char then
        -- Check if cutscenes are disabled
        if char:getData("cutscenes_disabled", false) then
            LocalPlayer():notify("Cutscenes are disabled!")
            return false
        end
        
        -- Check cutscene cooldown
        local lastCutscene = char:getData("last_cutscene_time", 0)
        if os.time() - lastCutscene < 10 then -- 10 second cooldown
            LocalPlayer():notify("Please wait before starting another cutscene!")
            return false
        end
        
        -- Update last cutscene time
        char:setData("last_cutscene_time", os.time())
    end
end)
```

---

## CutsceneSubtitleStarted

**Purpose**

Called when a subtitle within a cutscene starts displaying.

**Parameters**

* `cutsceneID` (*string*): The ID of the cutscene.
* `subtitle` (*table*): The subtitle data that started.

**Realm**

Client.

**When Called**

This hook is triggered when:
- A subtitle begins displaying in a cutscene
- The subtitle text is shown
- Before the subtitle duration timer starts

**Example Usage**

```lua
-- Track subtitle start
hook.Add("CutsceneSubtitleStarted", "TrackSubtitleStart", function(cutsceneID, subtitle)
    local char = LocalPlayer():getChar()
    if char then
        local subtitlesStarted = char:getData("subtitles_started", 0)
        char:setData("subtitles_started", subtitlesStarted + 1)
        
        -- Track subtitle content
        local subtitleContent = char:getData("subtitle_content", {})
        table.insert(subtitleContent, {
            cutscene = cutsceneID,
            text = subtitle.text,
            time = os.time()
        })
        char:setData("subtitle_content", subtitleContent)
    end
end)

-- Apply subtitle start effects
hook.Add("CutsceneSubtitleStarted", "SubtitleStartEffects", function(cutsceneID, subtitle)
    -- Play subtitle sound
    if subtitle.sound then
        LocalPlayer():EmitSound(subtitle.sound, 75, 100)
    end
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 5), 0.5, 0)
    
    -- Notify player
    LocalPlayer():notify("Subtitle: " .. subtitle.text)
end)

-- Track subtitle statistics
hook.Add("CutsceneSubtitleStarted", "TrackSubtitleStats", function(cutsceneID, subtitle)
    local char = LocalPlayer():getChar()
    if char then
        -- Track subtitle duration
        local subtitleDuration = char:getData("total_subtitle_duration", 0)
        char:setData("total_subtitle_duration", subtitleDuration + (subtitle.duration or 0))
        
        -- Track subtitle colors
        if subtitle.color then
            local subtitleColors = char:getData("subtitle_colors", {})
            local colorKey = subtitle.color.r .. "," .. subtitle.color.g .. "," .. subtitle.color.b
            subtitleColors[colorKey] = (subtitleColors[colorKey] or 0) + 1
            char:setData("subtitle_colors", subtitleColors)
        end
        
        -- Track subtitle fonts
        if subtitle.font then
            local subtitleFonts = char:getData("subtitle_fonts", {})
            subtitleFonts[subtitle.font] = (subtitleFonts[subtitle.font] or 0) + 1
            char:setData("subtitle_fonts", subtitleFonts)
        end
    end
end)

-- Apply subtitle restrictions
hook.Add("CutsceneSubtitleStarted", "ApplySubtitleRestrictions", function(cutsceneID, subtitle)
    local char = LocalPlayer():getChar()
    if char then
        -- Check if subtitles are disabled
        if char:getData("subtitles_disabled", false) then
            LocalPlayer():notify("Subtitles are disabled!")
            return false
        end
        
        -- Check subtitle cooldown
        local lastSubtitle = char:getData("last_subtitle_time", 0)
        if os.time() - lastSubtitle < 1 then -- 1 second cooldown
            return false
        end
        
        -- Update last subtitle time
        char:setData("last_subtitle_time", os.time())
    end
end)
```
