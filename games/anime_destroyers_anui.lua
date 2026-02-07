-- // NEBUBLOX | ANIME DESTROYERS //
-- // UI Library: ANUI //

local ANUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ANHub-Script/ANUI/refs/heads/main/dist/main.lua"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

-- // 1. CONFIGURATION //
local Flags = {
    AutoClick = false
}

-- // Helper: MakeProfile //
local function MakeProfile(config) return config end

-- // 2. WINDOW CREATION //
local Window = ANUI:CreateWindow({
    Title = "Nebublox", 
    Author = "by He Who Remains Lil'Nug",
    Folder = "NebubloxDestroyers",
    Icon = "rbxassetid://121698194718505", -- User Avatar
    IconSize = 44,
    
    Theme = "Dark", 
    Transparent = false,
    SideBarWidth = 200,
    HasOutline = true,
})

-- // 3. PROFILE SETUP //
local NugProfile = MakeProfile({
    -- Valid user-provided Asset IDs
    Banner = "rbxthumb://type=Asset&id=88040798502148&w=768&h=432", 
    Avatar = "rbxthumb://type=Asset&id=121698194718505&w=420&h=420", 
    Status = true,
    Title = "He Who Remains Lil'Nug",
    Desc = "@thearchitectofthemultiverse",
    Badges = {
        {
            Icon = "geist:logo-discord", 
            Title = "Discord", 
            Desc = "Join Community", 
            Callback = function() 
                setclipboard("https://discord.gg/kgu3WXGg5m")
                ANUI:Notify({Title = "Discord", Content = "Link Copied!", Icon = "check", Duration = 3})
            end
        }
    }
})

-- // 4. TABS & SECTIONS //

-- [TAB 1: MAIN]
local MainTab = Window:Tab({ Title = "Main", Icon = "home", Profile = NugProfile, SidebarProfile = true })
local InfoSection = MainTab:Section({ Title = "Info", Icon = "info", Opened = true })

InfoSection:Paragraph({
    Title = "He Who Remains Lil'Nug",
    Content = "ID: 607677349718261783\nUser: @thearchitectofthemultiverse\nStatus: Online"
})

InfoSection:Button({
    Title = "Discord Server",
    Callback = function() setclipboard("https://discord.gg/kgu3WXGg5m") ANUI:Notify({Title = "Discord", Content = "Link Copied!", Icon = "check", Duration = 3}) end
})

-- [TAB 2: AUTOMATION]
local AutoTab = Window:Tab({ Title = "Automation", Icon = "cpu", SidebarProfile = false })
local MainSection = AutoTab:Section({ Title = "Farming", Icon = "zap", Opened = true })

-- Placeholder Feature
MainSection:Toggle({
    Title = "Auto Click / Attack",
    Desc = "Placeholder for your requested features",
    Value = false,
    Callback = function(state) Flags.AutoClick = state end
})

-- // 5. LOGIC //
task.spawn(function()
    while task.wait(0.1) do
        if Flags.AutoClick then
            -- Placeholder logic
        end
    end
end)

ANUI:Notify({Title = "Nebublox", Content = "Anime Destroyers Loaded!", Icon = "check", Duration = 5})
