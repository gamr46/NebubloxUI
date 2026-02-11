-- // UNIVERSAL HUB LOADER //
-- // Supports: Anime Storm 2, Anime Destroyers, Anime Creatures //

local ANUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ANHub-Script/ANUI/refs/heads/main/dist/main.lua"))()
local player = game:GetService("Players").LocalPlayer

-- [ROBUST LOADER FUNCTION]
local function LoadScript(url)
    local success, result = pcall(function() return game:HttpGet(url) end)
    if success then return loadstring(result)() end

    success, result = pcall(function() return HttpGet(url) end)
    if success then return loadstring(result)() end

    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if req then
        local response = req({Url = url, Method = "GET"})
        if response.Success or response.StatusCode == 200 then
            return loadstring(response.Body)()
        end
    end
    
    ANUI:Notify({Title = "Error", Content = "Failed to load script!", Icon = "alert-triangle", Duration = 5})
end

-- [GAME CONFIGURATION]
local PlaceId = game.PlaceId
local GameIds = {
    [98199457453897] = { Name = "[UPD 1] Anime Storm 2", Url = "https://gist.githubusercontent.com/gamr46/7598b43325781f41fc4e9274434ea431/raw/Anime%2520Storm%25202" },
    [136063393518705] = { Name = "[Release] Anime Destroyers", Url = "https://raw.githubusercontent.com/gamr46/NebubloxUI/main/games/anime_destroyers_anui.lua" },
    [133898125416947] = { Name = "[Release🔥] Anime Creatures💥", Url = "https://raw.githubusercontent.com/gamr46/NebubloxUI/main/games/anime_creatures_anui.lua" },
    [15498808459] = { Name = "Anime Capture", Url = "https://raw.githubusercontent.com/gamr46/NebubloxUI/main/games/anime_capture_anui.lua" }
}

-- [AUTO-LOAD LOGIC]
local DetectedGame = GameIds[PlaceId]

if DetectedGame then
    ANUI:Notify({Title = "Universal Hub", Content = "Loading: " .. DetectedGame.Name, Icon = "check", Duration = 3})
    task.wait(1)
    LoadScript(DetectedGame.Url)
else
    -- [MANUAL SELECTION UI]
    local Window = ANUI:CreateWindow({
        Title = "Universal Hub",
        Author = "by He Who Remains",
        Folder = "UniversalHub",
        Icon = "rbxthumb://type=Asset&id=132367447015620&w=150&h=150", 
        IconSize = 44,
        Theme = "Dark",
        Transparent = false,
        SideBarWidth = 200,
        HasOutline = true,
    })
    
    -- [TAB 1: ABOUT] (First Tab)
    local MainTab = Window:Tab({ Title = "About", Icon = "info" })
    
    -- Banner Injection Logic
    local BannerSection = MainTab:Section({ Title = "", Icon = "", Opened = true })
    BannerSection:Paragraph({ Title = "Loading Banner...", Content = "" })
    
    task.spawn(function()
        task.wait(1.5)
        local imgId = "rbxthumb://type=Asset&id=132367447015620&w=768&h=432"
        local function FindAndInjectImage(root)
            if not root then return end
            for _, obj in ipairs(root:GetDescendants()) do
                if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Text == "Loading Banner..." then
                    local paragraph = obj.Parent
                    local section = paragraph and paragraph.Parent
                    if section then
                        local frame = Instance.new("ImageLabel")
                        frame.Name = "Banner"
                        frame.Size = UDim2.new(1, 0, 0, 150) -- Adjusted for loader
                        frame.Position = paragraph.Position
                        frame.BackgroundTransparency = 1
                        frame.Image = imgId
                        frame.ScaleType = Enum.ScaleType.Crop
                        frame.Parent = section
                        paragraph:Destroy()
                        return true
                    end
                end
            end
        end
        if not FindAndInjectImage(game:GetService("CoreGui")) then FindAndInjectImage(player.PlayerGui) end
    end)

    local InfoSection = MainTab:Section({ Title = "Information", Icon = "shield", Opened = true })
    
    InfoSection:Paragraph({
        Title = "Universal Script Hub",
        Content = "Welcome! This hub automatically detects supported games.\nIf your game is not detected, use the 'Games' tab below."
    })
    
    InfoSection:Button({
        Title = "Join Discord Community",
        Callback = function()
            setclipboard("https://discord.gg/nebublox")
            ANUI:Notify({Title = "Discord", Content = "Invite copied!", Icon = "check", Duration = 3})
        end
    })

    -- [TAB 2: GAMES]
    local GamesTab = Window:Tab({ Title = "Games List", Icon = "gamepad-2" })
    local GamesSection = GamesTab:Section({ Title = "Select Game Manually", Icon = "list", Opened = true })
    
    GamesSection:Paragraph({
        Title = "Current Place Identification",
        Content = "Your Place ID: " .. tostring(PlaceId) .. "\n(Not recognized as a supported game)"
    })
    
    local sortedGames = {}
    for id, data in pairs(GameIds) do table.insert(sortedGames, data) end
    table.sort(sortedGames, function(a,b) return a.Name < b.Name end)
    
    for _, data in ipairs(sortedGames) do
        GamesSection:Button({
            Title = "Load: " .. data.Name,
            Callback = function()
                Window:Destroy()
                ANUI:Notify({Title = "Loading...", Content = data.Name, Icon = "download", Duration = 2})
                LoadScript(data.Url)
            end
        })
    end
end
