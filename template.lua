--[[
    ═══════════════════════════════════════════════════════════
    NEBUBLOX UI TEMPLATE
    Copy this file and customize it for each game!
    ═══════════════════════════════════════════════════════════
    
    Quick Start:
    1. Copy this template
    2. Change GAME_NAME below
    3. Add your game-specific tabs and features
    4. Enjoy!
]]

-- ═══════════════════════════════════════════════════════════
-- CONFIGURATION
-- ═══════════════════════════════════════════════════════════
local GAME_NAME = "My Game"           -- Change this for each game
local SCRIPT_VERSION = "1.0.0"        -- Your script version

-- ═══════════════════════════════════════════════════════════
-- LOAD LIBRARY
-- ═══════════════════════════════════════════════════════════
local NebubloxUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gamr46/NebubloxUI/main/nebublox_ui.lua"))()

-- ═══════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ═══════════════════════════════════════════════════════════
local Window = NebubloxUI:CreateWindow({
    Title = "Nebublox | " .. GAME_NAME,
    Author = "by Nebublox",
    Folder = "Nebublox_" .. GAME_NAME:gsub(" ", "_"),
    Theme = "Void",
    Transparent = true,
    SideBarWidth = 200,
    HasOutline = true,
})

-- ═══════════════════════════════════════════════════════════
-- TABS (Add your game-specific tabs here)
-- ═══════════════════════════════════════════════════════════
local MainTab = Window:Tab({ Title = "Main", Icon = "home" })
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

-- ═══════════════════════════════════════════════════════════
-- SECTIONS
-- ═══════════════════════════════════════════════════════════
local InfoSection = MainTab:Section({ Title = "Info", Icon = "info", Opened = true })
local FeaturesSection = MainTab:Section({ Title = "Features", Icon = "star", Opened = true })
local MovementSection = PlayerTab:Section({ Title = "Movement", Icon = "footprints", Opened = true })
local ConfigSection = SettingsTab:Section({ Title = "Config", Icon = "save", Opened = true })

-- ═══════════════════════════════════════════════════════════
-- DEFAULT ELEMENTS (Customize below)
-- ═══════════════════════════════════════════════════════════

-- Info Section
InfoSection:Button({
    Title = "Welcome to " .. GAME_NAME,
    Desc = "Script v" .. SCRIPT_VERSION,
    Icon = "rocket",
    Callback = function()
        NebubloxUI:Notify({
            Title = "Welcome!",
            Content = "Thanks for using Nebublox Hub!",
            Icon = "heart",
            Duration = 5
        })
    end
})

-- Player Movement
MovementSection:Slider({
    Title = "WalkSpeed",
    Value = { Min = 16, Max = 200, Default = 16 },
    Step = 1,
    Callback = function(val)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = val
        end
    end
})

MovementSection:Slider({
    Title = "JumpPower",
    Value = { Min = 50, Max = 500, Default = 50 },
    Step = 5,
    Callback = function(val)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = val
        end
    end
})

-- Config Buttons
ConfigSection:Button({
    Title = "Save Config",
    Icon = "save",
    Callback = function()
        NebubloxUI:Notify({ Title = "Saved!", Content = "Config saved", Icon = "check", Duration = 3 })
    end
})

ConfigSection:Button({
    Title = "Load Config",
    Icon = "folder-open",
    Callback = function()
        NebubloxUI:Notify({ Title = "Loaded!", Content = "Config loaded", Icon = "check", Duration = 3 })
    end
})

-- ═══════════════════════════════════════════════════════════
-- ADD YOUR GAME-SPECIFIC FEATURES BELOW
-- ═══════════════════════════════════════════════════════════

-- Example:
-- FeaturesSection:Toggle({
--     Title = "Auto Farm",
--     Value = false,
--     Callback = function(state)
--         -- Your auto farm code here
--     end
-- })

-- ═══════════════════════════════════════════════════════════
-- STARTUP NOTIFICATION
-- ═══════════════════════════════════════════════════════════
NebubloxUI:Notify({
    Title = "Nebublox Loaded!",
    Content = GAME_NAME .. " script ready",
    Icon = "rocket",
    Duration = 5
})

print("[Nebublox] " .. GAME_NAME .. " script loaded successfully!")
