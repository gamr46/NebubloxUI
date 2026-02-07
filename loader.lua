-- // NEBUBLOX MASTER LOADER //
-- // loadstring(game:HttpGet("https://raw.githubusercontent.com/gamr46/NebubloxUI/main/loader.lua"))() //

local ANUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ANHub-Script/ANUI/refs/heads/main/dist/main.lua"))()

-- Game Detection
local PlaceId = game.PlaceId
local GameName = "Unknown"

local GameIds = {
    -- Anime Capture
    [15498808459] = {Name = "Anime Capture", Script = "anime_capture"},
    -- Anime Destroyers (add actual PlaceId when known)
    [0] = {Name = "Anime Destroyers", Script = "anime_destroyers"},
    -- Anime Storm Simulator 2 (add actual PlaceId when known)
    [12345678] = {Name = "Anime Storm Simulator 2", Script = "anime_storm_sim2"},
}

-- Base URL (UPDATE THIS with your GitHub raw URL)
local BaseURL = "https://raw.githubusercontent.com/gamr46/NebubloxUI/main/games/"

-- Function to load a specific game script
local function LoadGameScript(scriptName)
    local url = BaseURL .. scriptName .. "_anui.lua"
    local success, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    if not success then
        ANUI:Notify({Title = "Error", Content = "Failed to load: " .. tostring(err), Icon = "alert-triangle", Duration = 5})
    end
end

-- Check if we're in a supported game
local DetectedGame = GameIds[PlaceId]

if DetectedGame then
    -- Auto-load the correct script
    ANUI:Notify({Title = "Nebublox", Content = "Detected: " .. DetectedGame.Name, Icon = "check", Duration = 3})
    task.wait(1)
    LoadGameScript(DetectedGame.Script)
else
    -- Show game selector UI
    local Window = ANUI:CreateWindow({
        Title = "Nebublox",
        Author = "by He Who Remains Lil'Nug",
        Folder = "NebubloxLoader",
        Icon = "rbxassetid://121698194718505",
        IconSize = 44,
        Theme = "Dark",
        Transparent = false,
        SideBarWidth = 200,
        HasOutline = true,
    })
    
    local MainTab = Window:Tab({ Title = "Games", Icon = "gamepad-2", SidebarProfile = false })
    local GamesSection = MainTab:Section({ Title = "Select Game", Icon = "list", Opened = true })
    
    GamesSection:Paragraph({
        Title = "Game Not Detected",
        Content = "PlaceId: " .. tostring(PlaceId) .. "\n\nSelect a script manually below, or the game isn't supported yet."
    })
    
    GamesSection:Button({
        Title = "Anime Capture",
        Callback = function()
            Window:Destroy()
            LoadGameScript("anime_capture")
        end
    })
    
    GamesSection:Button({
        Title = "Anime Destroyers",
        Callback = function()
            Window:Destroy()
            LoadGameScript("anime_destroyers")
        end
    })
    
    GamesSection:Button({
        Title = "Anime Storm Simulator 2",
        Callback = function()
            Window:Destroy()
            LoadGameScript("anime_storm_sim2")
        end
    })
    
    -- Info Section
    local InfoSection = MainTab:Section({ Title = "Info", Icon = "info", Opened = false })
    
    InfoSection:Button({
        Title = "Copy Discord Invite",
        Callback = function()
            setclipboard("https://discord.gg/kgu3WXGg5m")
            ANUI:Notify({Title = "Discord", Content = "Link copied!", Icon = "check", Duration = 3})
        end
    })
    
    InfoSection:Paragraph({
        Title = "Nebublox",
        Content = "Universal Script Hub\nVersion: 1.0\n\nCreated by He Who Remains Lil'Nug"
    })
end
