--[[
    ═══════════════════════════════════════════════════════════
    NEBUBLOX | EXAMPLE PVP GAME
    Example script showing enemy detection and combat features
    ═══════════════════════════════════════════════════════════
]]

local GAME_NAME = "PVP Arena"
local SCRIPT_VERSION = "1.0.0"

-- Load Library
local NebubloxUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gamr46/NebubloxUI/main/nebublox_ui.lua"))()

-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Variables
local autoTeleportEnabled = false
local teleportDistance = 5

-- ═══════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ═══════════════════════════════════════════════════════════
local Window = NebubloxUI:CreateWindow({
    Title = "Nebublox | " .. GAME_NAME,
    Author = "by Nebublox",
    Folder = "Nebublox_PVP",
    Theme = "Void",
    Transparent = true,
})

-- ═══════════════════════════════════════════════════════════
-- TABS
-- ═══════════════════════════════════════════════════════════
local CombatTab = Window:Tab({ Title = "Combat", Icon = "swords" })
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

-- ═══════════════════════════════════════════════════════════
-- COMBAT TAB
-- ═══════════════════════════════════════════════════════════
local TeleportSection = CombatTab:Section({ Title = "Enemy Teleport", Icon = "target", Opened = true })

-- Helper: Get all enemies (different team)
local function getEnemies()
    local enemies = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Team ~= player.Team then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(enemies, p.Name)
            end
        end
    end
    return enemies
end

-- Helper: Get closest enemy
local function getClosestEnemy()
    local closestEnemy = nil
    local closestDistance = math.huge
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Team ~= player.Team then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if dist < closestDistance then
                        closestDistance = dist
                        closestEnemy = p
                    end
                end
            end
        end
    end
    
    return closestEnemy
end

-- Teleport to closest enemy
TeleportSection:Button({
    Title = "Teleport to Closest Enemy",
    Desc = "Instantly teleport to nearest enemy",
    Icon = "zap",
    Callback = function()
        local enemy = getClosestEnemy()
        if enemy and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = enemy.Character.HumanoidRootPart.CFrame + Vector3.new(0, teleportDistance, 0)
            NebubloxUI:Notify({ Title = "Teleported!", Content = "Teleported to " .. enemy.Name, Icon = "check", Duration = 2 })
        else
            NebubloxUI:Notify({ Title = "No Enemies", Content = "No enemies found", Icon = "x", Duration = 2 })
        end
    end
})

-- Distance slider
TeleportSection:Slider({
    Title = "Teleport Height",
    Value = { Min = 0, Max = 20, Default = 5 },
    Step = 1,
    Callback = function(val)
        teleportDistance = val
    end
})

-- Auto teleport toggle
TeleportSection:Toggle({
    Title = "Auto Teleport",
    Desc = "Continuously teleport to closest enemy",
    Value = false,
    Callback = function(state)
        autoTeleportEnabled = state
        if state then
            NebubloxUI:Notify({ Title = "Auto Teleport", Content = "Enabled - targeting enemies", Icon = "target", Duration = 3 })
        end
    end
})

-- Enemy dropdown (refreshes on open)
local enemyDropdown = TeleportSection:Dropdown({
    Title = "Select Enemy",
    Values = {},
    Callback = function(val)
        -- Find and teleport to selected enemy
        local target = Players:FindFirstChild(val.Title or val)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, teleportDistance, 0)
        end
    end
})

-- Refresh enemies button
TeleportSection:Button({
    Title = "Refresh Enemy List",
    Icon = "refresh-cw",
    Callback = function()
        local enemies = getEnemies()
        local values = {}
        for _, name in ipairs(enemies) do
            table.insert(values, { Title = name, Icon = "user" })
        end
        enemyDropdown:SetValues(values)
        NebubloxUI:Notify({ Title = "Refreshed!", Content = #enemies .. " enemies found", Icon = "check", Duration = 2 })
    end
})

-- ═══════════════════════════════════════════════════════════
-- PLAYER TAB
-- ═══════════════════════════════════════════════════════════
local MovementSection = PlayerTab:Section({ Title = "Movement", Icon = "footprints", Opened = true })

MovementSection:Slider({
    Title = "WalkSpeed",
    Value = { Min = 16, Max = 200, Default = 16 },
    Callback = function(val)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = val
        end
    end
})

MovementSection:Slider({
    Title = "JumpPower",
    Value = { Min = 50, Max = 500, Default = 50 },
    Callback = function(val)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = val
        end
    end
})

-- ═══════════════════════════════════════════════════════════
-- AUTO TELEPORT LOOP
-- ═══════════════════════════════════════════════════════════
spawn(function()
    while wait(1) do
        if autoTeleportEnabled then
            local enemy = getClosestEnemy()
            if enemy and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = enemy.Character.HumanoidRootPart.CFrame + Vector3.new(0, teleportDistance, 0)
                end
            end
        end
    end
end)

-- Startup
NebubloxUI:Notify({
    Title = "PVP Script Loaded!",
    Content = "Combat features ready",
    Icon = "swords",
    Duration = 5
})

print("[Nebublox] PVP Arena script loaded!")
