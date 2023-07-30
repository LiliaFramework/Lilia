local seasons = {"Spring", "Summer", "Autumn", "Winter"}

local currentSeasonIndex = 1
local currentWeatherIndex = 1

local weather = {
    Spring = {"sunny", "rain", "thunderstorm"},
    Summer = {"sunny", "heatwave"},
    Autumn = {"rain", "windy"},
    Winter = {"snow", "blizzard"}
}

local function ChangeSeason()
    currentSeasonIndex = currentSeasonIndex + 1
    if currentSeasonIndex > #seasons then
        currentSeasonIndex = 1
    end
    currentWeatherIndex = 1 -- Reset weather index

    local currentSeason = seasons[currentSeasonIndex]
    local currentWeather = weather[currentSeason][currentWeatherIndex]
    print("Changed to " .. currentSeason .. " - " .. currentWeather)

    -- Set the weather using StormFox 2
    StormFox2.Weather.Set(currentWeather, 1) -- Assuming intensity 1
end

local function ChangeWeather()
    local currentSeason = seasons[currentSeasonIndex]
    local currentWeather = weather[currentSeason][currentWeatherIndex]
    currentWeatherIndex = currentWeatherIndex + 1
    if currentWeatherIndex > #weather[currentSeason] then
        currentWeatherIndex = 1
    end

    print("Changed to " .. currentSeason .. " - " .. currentWeather)

    -- Set the weather using StormFox 2
    StormFox2.Weather.Set(currentWeather, 1) -- Assuming intensity 1
end

-- Console command to manually change the weather
concommand.Add("changeweather", function()
    ChangeWeather()
end)

-- Console command to list available addon weather types
concommand.Add("listaddonweather", function()
    local addonWeatherTypes = StormFox2.Weather.GetAll()
    print("Available addon weather types:")
    for _, weatherType in ipairs(addonWeatherTypes) do
        print(weatherType)
    end
end)

-- Example usage
hook.Add("Initialize", "ManualSeasonWeatherChange", function()
    ChangeSeason() -- Change to the initial season and weather
end)
