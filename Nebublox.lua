-- // NEBUBLOX UNIVERSAL HUB //
-- This is the public loader script. Point your executor here.
-- Repository: https://github.com/James/Nebublox

local PlaceIds = {
    [98199457453897] = "anime_storm_sim2_anui_v3.lua",
    [133898125416947] = "Anime_Creatures_Anui.lua",
}

-- [CONFIG]
local GitHubUser = "Gamr46" -- [Gamr46] Change this to your GitHub username if different
local GitHubRepo = "Nebublox"
local Branch = "main"

local BaseURL = "https://raw.githubusercontent.com/" .. GitHubUser .. "/" .. GitHubRepo .. "/" .. Branch .. "/"

local function Load(fileName)
    local success, err = pcall(function()
        loadstring(game:HttpGet(BaseURL .. fileName))()
    end)
    if not success then
        warn("[Nebublox] Failed to load " .. fileName .. ":", err)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Nebublox Error",
            Text = "Failed to load script. Check your internet or GitHub path.",
            Duration = 5
        })
    end
end

local placeId = game.PlaceId
if PlaceIds[placeId] then
    Load(PlaceIds[placeId])
else
    -- Fallback/Unrecognized Game Notification
    warn("[Nebublox] Game not supported (PlaceId: " .. placeId .. ")")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Nebublox",
        Text = "This game is not yet supported by Nebublox.",
        Duration = 5
    })
end
