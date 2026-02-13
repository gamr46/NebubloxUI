-- // UNIVERSAL HUB LOADER //
-- // Supports: Anime Storm 2, Anime Destroyers, Anime Creatures, Anime Capture //

-- [1] SCRIPT KILLER / RELOAD LOGIC
local getgenv = getgenv or function() return _G end
if getgenv().Nebublox_Window then
    pcall(function() getgenv().Nebublox_Window:Destroy() end)
    getgenv().Nebublox_Window = nil
end

if getgenv().UniversalHubLoaded then
    getgenv().UniversalHubLoaded = false
end

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local UniverseId = game.GameId

local function CleanupGui(name)
    if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
        LocalPlayer.PlayerGui[name]:Destroy()
    end
end

CleanupGui("NebubloxAuth")
CleanupGui("UniversalHub")

-- [2] LIBRARY LOADER
local ANUI_URL = "https://raw.githubusercontent.com/LilNugOfWisdom/NebubloxUI/main/Library/anui_source.lua"
local success, libraryCode = pcall(function() return game:HttpGet(ANUI_URL) end)

if not success or not libraryCode or libraryCode:find("404: Not Found") then
    return
end

local libFunc = loadstring(libraryCode)
if not libFunc then return end

local ANUI = libFunc()
getgenv().UniversalHubLoaded = true

-- [3] HELPER FUNCTIONS
local function SafeNotify(data)
    task.defer(function() 
        pcall(function() ANUI:Notify(data) end) 
    end)
end

local function LoadScript(url)
    SafeNotify({Title = "Fetching...", Content = "Downloading script data...", Icon = "download", Duration = 2})
    
    local function Fetch(targetUrl)
        local s, content = pcall(function() return game:HttpGet(targetUrl) end)
        if s and content and not content:find("404: Not Found") and #content > 100 then
            return content
        end
        return nil
    end

    local content = Fetch(url)
    if not content and url:find("/games/") then
        content = Fetch(url:gsub("/games/", "/"))
    end
    
    if content then
        local func = loadstring(content)
        if func then
            task.spawn(function()
                local runSuccess = pcall(func)
                if not runSuccess then
                    SafeNotify({Title = "Runtime Error", Content = "Script crashed.", Icon = "alert-triangle", Duration = 5})
                end
            end)
        else
            SafeNotify({Title = "Syntax Error", Content = "Script contains code errors.", Icon = "alert-octagon", Duration = 5})
        end
    else
        SafeNotify({Title = "Connection Error", Content = "Failed to reach GitHub.", Icon = "wifi-off", Duration = 7})
    end
end

-- [4] GAME CONFIGURATION
local GameIds = {
    [98199457453897] = { Name = "[UPD 1] Anime Storm 2", Url = "https://raw.githubusercontent.com/LilNugOfWisdom/NebubloxUI/main/Scripts/anime_storm_sim2_anui.lua" },
    [133898125416947] = { Name = "[Release🔥] Anime Creatures💥", Url = "https://raw.githubusercontent.com/LilNugOfWisdom/NebubloxUI/main/Scripts/Anime_Creatures_Anui.lua" },
    [136063393518705] = { Name = "[Release] Anime Destroyers", Url = "https://raw.githubusercontent.com/LilNugOfWisdom/NebubloxUI/main/Scripts/anime_destroyers_anui.lua" },
    [15498808459] = { Name = "Anime Capture", Url = "https://raw.githubusercontent.com/LilNugOfWisdom/NebubloxUI/main/Scripts/anime_capture_anui.lua" }
}

-- [5] KEY SYSTEM
local KeySystem = {}
KeySystem.__index = KeySystem

local API_URL_KEY = "https://darkmatterv1.onrender.com/api/verify_key"
local SETTINGS_FILE_KEY = "nebublox_key.data"
local DISCORD_INVITE_KEY = "https://discord.gg/T2vw3QuJ9K"

function KeySystem.new()
    local self = setmetatable({}, KeySystem)
    self.Key = ""
    self.Tier = "Free"
    self.IsVerified = false
    return self
end

function KeySystem:Validate(inputKey)
    local keyToCheck = inputKey or (isfile(SETTINGS_FILE_KEY) and readfile(SETTINGS_FILE_KEY))
    if not keyToCheck or keyToCheck == "" then return false, "No key provided" end
    
    keyToCheck = keyToCheck:gsub("%s+", "")
    local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
    
    if not httpRequest then return false, "Executor unsupported" end

    local urls = {"http://127.0.0.1:10000/api/verify_key", API_URL_KEY}
    for _, url in ipairs(urls) do
        local success, response = pcall(function()
            return httpRequest({
                Url = url .. "?key=" .. keyToCheck .. "&hwid=" .. (gethwid and gethwid() or game:GetService("RbxAnalyticsService"):GetClientId()),
                Method = "GET"
            })
        end)

        if success and response.StatusCode == 200 then
            local data = HttpService:JSONDecode(response.Body)
            if data.valid then
                self.IsVerified = true
                self.Tier = data.tier
                writefile(SETTINGS_FILE_KEY, keyToCheck)
                return true, "Success"
            end
        end
    end
    return false, "Invalid Key or Connection Failed"
end

function KeySystem:ShowUI(onSuccess)
    if self:Validate() then
        SafeNotify({Title = "Welcome Back", Content = "Logged in as " .. tostring(self.Tier) .. " User", Icon = "check", Duration = 5})
        onSuccess()
        return
    end

    local Window = ANUI:CreateWindow({
        Title = "Nebublox Auth",
        Author = "v1.0",
        Folder = "NebubloxAuth",
        Icon = "rbxassetid://121698194718505", 
        IconSize = 44,
        Theme = "Dark",
        SideBarWidth = 0,
    })

    getgenv().Nebublox_Window = Window
    local MainTab = Window:Tab({ Title = "Key System", Icon = "key" })
    local Section = MainTab:Section({ Title = "Authentication", Opened = true })
    
    local KeyInput = ""
    Section:TextBox({ Title = "License Key", Placeholder = "Paste Key (BLOX-...)", Callback = function(t) KeyInput = t end })
    
    Section:Button({
        Title = "Verify Key",
        Callback = function()
            if KeyInput == "" then return end
            local valid, msg = self:Validate(KeyInput)
            if valid then
                Window:Destroy()
                onSuccess()
            else
                SafeNotify({Title = "Denied", Content = msg, Icon = "x", Duration = 4})
            end
        end
    })
    
    Section:Button({
        Title = "Copy Discord Link",
        Callback = function()
            setclipboard(DISCORD_INVITE_KEY)
            SafeNotify({Title = "Copied", Content = "Link copied!", Icon = "link", Duration = 2})
        end
    })
end

-- [6] MAIN HUB LOGIC
local function StartHub()
    local DetectedGame = GameIds[PlaceId] or GameIds[UniverseId]

    if DetectedGame then
        SafeNotify({Title = "Universal Hub", Content = "Detected: " .. DetectedGame.Name, Icon = "check", Duration = 3})
        task.wait(0.5)
        LoadScript(DetectedGame.Url)
    else
        local Window = ANUI:CreateWindow({
            Title = "Universal Hub",
            Author = "by He Who Remains",
            Folder = "UniversalHub",
            Icon = "rbxthumb://type=Asset&id=132367447015620&w=150&h=150", 
            IconSize = 44,
            Theme = "Dark",
            SideBarWidth = 200,
            HasOutline = true,
        })

        getgenv().Nebublox_Window = Window
        local MainTab = Window:Tab({ Title = "About", Icon = "info" })
        local BannerSection = MainTab:Section({ Title = "", Opened = true })
        BannerSection:Paragraph({ Title = "Universal Hub", Content = "Select a game from the list." })
        
        local GamesTab = Window:Tab({ Title = "Games List", Icon = "gamepad-2" })
        local GamesSection = GamesTab:Section({ Title = "Available Scripts", Opened = true })
        
        local sortedGames = {}
        for id, data in pairs(GameIds) do table.insert(sortedGames, data) end
        table.sort(sortedGames, function(a,b) return a.Name < b.Name end)
        
        for _, data in ipairs(sortedGames) do
            GamesSection:Button({
                Title = data.Name,
                Callback = function()
                    pcall(function() Window:Destroy() end)
                    LoadScript(data.Url)
                end
            })
        end
    end
end

-- [7] INITIATE
local Auth = KeySystem.new()
Auth:ShowUI(StartHub)