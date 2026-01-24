# Time Library

Time manipulation, formatting, and calculation system for the Lilia framework.

---

Overview

The time library provides comprehensive functionality for time manipulation, formatting, and calculation within the Lilia framework. It handles time parsing, formatting, relative time calculations, and date/time display with support for both 24-hour and 12-hour (American) time formats. The library operates on both server and client sides, providing consistent time handling across the gamemode. It includes functions for calculating time differences, formatting durations, parsing date strings, and generating localized time displays. The library ensures proper time zone handling and supports configurable time format preferences.

---

<details class="realm-shared">
<summary><a id=lia.time.timeSince></a>lia.time.timeSince(strTime, "YYYY)</summary>
<a id="liatimetimesince"></a>
<p>Produce a localized "time since" string from a date stamp or Unix time.</p>
<p>Anywhere UI or logs need relative time (e.g., last seen, ban info).</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|number</a></span> <span class="parameter">strTime</span> "YYYY-MM-DD" style date or Unix timestamp (seconds).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">"YYYY</span> MM-DD" style date or Unix timestamp (seconds).</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Localized human-friendly delta (seconds/minutes/hours/days ago).</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Build a rich status string for a ban record and a last-seen stamp.
    local function formatBanStatus(ply)
        local lastSeen = lia.time.timeSince(ply:getNetVar("lastSeenAt"))
        local banStarted = lia.time.timeSince(ply:getNetVar("banStart"))
        local banEnds = lia.time.formatDHM(ply:getNetVar("banEnd") - os.time())
        return string.format("%s • banned %s • expires in %s", lastSeen, banStarted, banEnds)
    end
    hook.Add("ScoreboardShow", "ShowBanTiming", function()
        for _, ply in ipairs(player.GetAll()) do
            local status = formatBanStatus(ply)
            chat.AddText(Color(200, 200, 50), ply:Name(), Color(180, 180, 180), " - ", status)
        end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.time.toNumber></a>lia.time.toNumber(str)</summary>
<a id="liatimetonumber"></a>
<p>Parse a date/time string in "YYYY-MM-DD HH:MM:SS" format into a numeric date table.</p>
<p>When converting date strings to components for calculations or storage.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">str</span> Date/time string in "YYYY-MM-DD HH:MM:SS" format. Defaults to current date/time if omitted.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Table containing numeric date components: {year, month, day, hour, min, sec}.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Normalize a date string into a timestamp for storage.
    local function normalizeDate(inputStr)
        local parts = lia.time.toNumber(inputStr)
        if not parts.year then return nil end
        return os.time(parts)
    end
    net.Receive("liaSubmitEvent", function(_, ply)
        local eventDateStr = net.ReadString()
        local ts = normalizeDate(eventDateStr)
        if not ts then
            ply:notifyLocalized("invalidDate")
            return
        end
        lia.log.add(ply, "eventScheduled", os.date("%c", ts))
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.time.getDate></a>lia.time.getDate()</summary>
<a id="liatimegetdate"></a>
<p>Return the current date/time as a localized formatted string.</p>
<p>For HUD clocks, chat timestamps, or admin panels showing server time.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Localized date/time in 24h or American 12h format based on config.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Display server time in a HUD corner, honoring American/24h format.
    hook.Add("HUDPaint", "DrawServerClock", function()
        local text = lia.time.getDate()
        surface.SetFont("liaSmallFont")
        local w, h = surface.GetTextSize(text)
        draw.RoundedBox(4, ScrW() - w - 20, 16, w + 12, h + 8, Color(0, 0, 0, 170))
        draw.SimpleText(text, "liaSmallFont", ScrW() - 14, 20, color_white, TEXT_ALIGN_RIGHT)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.time.formatDHM></a>lia.time.formatDHM(seconds)</summary>
<a id="liatimeformatdhm"></a>
<p>Format a duration into days, hours, and minutes.</p>
<p>Cooldowns, jail timers, rental durations, or any long-running countdown.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">seconds</span> Duration in seconds.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Localized `X days Y hours Z minutes`.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Show detention duration and remaining parole time in an admin panel.
    local function buildDetentionRow(char)
        local remainingSeconds = math.max(char:getDetainTime() - os.time(), 0)
        local formatted = lia.time.formatDHM(remainingSeconds)
        return string.format("%s (%s)", char:getName(), formatted)
    end
    hook.Add("OnAdminPanelOpened", "PopulateDetentions", function(panel)
        for _, char in ipairs(lia.char.loaded) do
            if char:isDetained() then
                panel:AddLine(buildDetentionRow(char))
            end
        end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.time.getHour></a>lia.time.getHour()</summary>
<a id="liatimegethour"></a>
<p>Get the current hour string honoring 12h/24h configuration.</p>
<p>HUD clocks or schedule checks that need the current hour formatted.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|number</a></span> "12am/pm" string in American mode; numeric 0-23 otherwise.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Trigger different ambiance based on configured hour format and time.
    local function applyAmbientByHour()
        local hour = lia.time.getHour()
        local numericHour = tonumber(hour) or (tostring(hour):find("pm") and (tonumber(hour:match("%d+")) % 12) + 12 or tonumber(hour:match("%d+")) % 12)
        if numericHour &gt;= 20 or numericHour &lt; 6 then
            RunConsoleCommand("stopsound")
            surface.PlaySound("ambient/atmosphere/city_silent.wav")
        else
            surface.PlaySound("ambient/atmosphere/underground_hall.wav")
        end
    end
    hook.Add("InitPostEntity", "ApplyAmbientHourly", applyAmbientByHour)
</code></pre>
</details>

---

