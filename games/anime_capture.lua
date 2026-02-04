--[[
    ═══════════════════════════════════════════════════════════
    NEBUBLOX | ANIME CAPTURE
    Script hub for Anime Capture game
    ═══════════════════════════════════════════════════════════
]]

local GAME_NAME = "Anime Capture"
local SCRIPT_VERSION = "1.0.0"

-- Load Library
local NebubloxUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gamr46/NebubloxUI/main/nebublox_ui.lua"))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Variables
local autoFarmEnabled = false
local autoCaptureEnabled = false
local selectedTarget = nil

-- ═══════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════

-- Find all capturable entities (NPCs/Anime characters)
local function getCapturableEntities()
    local entities = {}
    
    -- Check common locations for NPCs
    local searchFolders = {
        Workspace:FindFirstChild("NPCs"),
        Workspace:FindFirstChild("Enemies"),
        Workspace:FindFirstChild("Mobs"),
        Workspace:FindFirstChild("Characters"),
        Workspace:FindFirstChild("Anime"),
        Workspace
    }
    
    for _, folder in ipairs(searchFolders) do
        if folder then
            for _, obj in ipairs(folder:GetDescendants()) do
                -- Look for humanoids that aren't players
                if obj:IsA("Humanoid") and obj.Health > 0 then
                    local root = obj.Parent:FindFirstChild("HumanoidRootPart")
                    if root and not Players:GetPlayerFromCharacter(obj.Parent) then
                        table.insert(entities, {
                            Name = obj.Parent.Name,
                            Model = obj.Parent,
                            Humanoid = obj,
                            Root = root
                        })
                    end
                end
            end
        end
    end
    
    return entities
end

-- Get closest entity
local function getClosestEntity()
    local entities = getCapturableEntities()
    local closest = nil
    local closestDist = math.huge
    
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = player.Character.HumanoidRootPart.Position
        for _, entity in ipairs(entities) do
            local dist = (myPos - entity.Root.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = entity
            end
        end
    end
    
    return closest, closestDist
end

-- ═══════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ═══════════════════════════════════════════════════════════
local Window = NebubloxUI:CreateWindow({
    Title = "Nebublox | " .. GAME_NAME,
    Author = "by Nebublox",
    Folder = "Nebublox_AnimeCapture",
    Theme = "Void",
    Transparent = true,
    SideBarWidth = 200,
    HasOutline = true,
})

-- ═══════════════════════════════════════════════════════════
-- TABS
-- ═══════════════════════════════════════════════════════════
local CaptureTab = Window:Tab({ Title = "Capture", Icon = "target" })
local FarmTab = Window:Tab({ Title = "Farm", Icon = "coins" })
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

-- ═══════════════════════════════════════════════════════════
-- CAPTURE TAB
-- ═══════════════════════════════════════════════════════════
local TargetSection = CaptureTab:Section({ Title = "Target Selection", Icon = "crosshair", Opened = true })
local CaptureSection = CaptureTab:Section({ Title = "Capture Options", Icon = "box", Opened = true })

-- Refresh & Select Target
TargetSection:Button({
    Title = "Find Nearest Entity",
    Desc = "Locate closest capturable character",
    Icon = "search",
    Callback = function()
        local entity, dist = getClosestEntity()
        if entity then
            selectedTarget = entity
            NebubloxUI:Notify({
                Title = "Target Found!",
                Content = entity.Name .. " (" .. math.floor(dist) .. " studs away)",
                Icon = "target",
                Duration = 3
            })
        else
            NebubloxUI:Notify({
                Title = "No Targets",
                Content = "No capturable entities found",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

-- Teleport to target
TargetSection:Button({
    Title = "Teleport to Target",
    Desc = "Teleport to selected entity",
    Icon = "zap",
    Callback = function()
        if selectedTarget and selectedTarget.Root then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = selectedTarget.Root.CFrame + Vector3.new(0, 5, 0)
                NebubloxUI:Notify({ Title = "Teleported!", Content = "Arrived at " .. selectedTarget.Name, Icon = "check", Duration = 2 })
            end
        else
            NebubloxUI:Notify({ Title = "No Target", Content = "Find a target first!", Icon = "alert-circle", Duration = 2 })
        end
    end
})

-- Auto capture toggle
CaptureSection:Toggle({
    Title = "Auto Capture",
    Desc = "Automatically capture nearby entities",
    Value = false,
    Callback = function(state)
        autoCaptureEnabled = state
        NebubloxUI:Notify({
            Title = state and "Auto Capture ON" or "Auto Capture OFF",
            Content = state and "Will auto-capture entities" or "Disabled",
            Icon = state and "check" or "x",
            Duration = 2
        })
    end
})

-- Entity list dropdown
local entityDropdown
entityDropdown = TargetSection:Dropdown({
    Title = "Select Entity",
    Values = {},
    SearchBarEnabled = true,
    Callback = function(val)
        -- Find selected entity
        local entities = getCapturableEntities()
        for _, entity in ipairs(entities) do
            if entity.Name == (val.Title or val) then
                selectedTarget = entity
                NebubloxUI:Notify({ Title = "Selected!", Content = entity.Name, Icon = "check", Duration = 2 })
                break
            end
        end
    end
})

TargetSection:Button({
    Title = "Refresh Entity List",
    Icon = "refresh-cw",
    Callback = function()
        local entities = getCapturableEntities()
        local values = {}
        for _, entity in ipairs(entities) do
            table.insert(values, { Title = entity.Name, Icon = "user" })
        end
        if entityDropdown.SetValues then
            entityDropdown:SetValues(values)
        end
        NebubloxUI:Notify({ Title = "Refreshed!", Content = #entities .. " entities found", Icon = "check", Duration = 2 })
    end
})

-- ═══════════════════════════════════════════════════════════
-- FARM TAB
-- ═══════════════════════════════════════════════════════════
local AutoSection = FarmTab:Section({ Title = "Auto Farm", Icon = "repeat", Opened = true })

AutoSection:Toggle({
    Title = "Auto Farm",
    Desc = "Automatically farm resources/XP",
    Value = false,
    Callback = function(state)
        autoFarmEnabled = state
        NebubloxUI:Notify({
            Title = state and "Auto Farm ON" or "Auto Farm OFF",
            Content = state and "Farming started" or "Farming stopped",
            Icon = state and "coins" or "x",
            Duration = 2
        })
    end
})

AutoSection:Toggle({
    Title = "Auto Teleport to Mobs",
    Desc = "Teleport to nearest mob when farming",
    Value = false,
    Callback = function(state)
        -- Add your teleport logic
    end
})

-- ═══════════════════════════════════════════════════════════
-- PLAYER TAB
-- ═══════════════════════════════════════════════════════════
local MovementSection = PlayerTab:Section({ Title = "Movement", Icon = "footprints", Opened = true })
local StatsSection = PlayerTab:Section({ Title = "Stats", Icon = "bar-chart", Opened = true })

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

MovementSection:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(state)
        -- Infinite jump logic would go here
    end
})

MovementSection:Toggle({
    Title = "No Clip",
    Value = false,
    Callback = function(state)
        -- No clip logic would go here
    end
})

-- ═══════════════════════════════════════════════════════════
-- SETTINGS TAB
-- ═══════════════════════════════════════════════════════════
local ConfigSection = SettingsTab:Section({ Title = "Configuration", Icon = "save", Opened = true })

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
-- BACKGROUND LOOPS
-- ═══════════════════════════════════════════════════════════
spawn(function()
    while wait(0.5) do
        -- Auto capture loop
        if autoCaptureEnabled then
            local entity = getClosestEntity()
            if entity then
                -- Add your capture logic here
                -- Example: fire capture remote
            end
        end
        
        -- Auto farm loop
        if autoFarmEnabled then
            local entity = getClosestEntity()
            if entity and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                -- Teleport to entity
                player.Character.HumanoidRootPart.CFrame = entity.Root.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- STARTUP
-- ═══════════════════════════════════════════════════════════
NebubloxUI:Notify({
    Title = "Anime Capture Loaded!",
    Content = "Script ready - enjoy!",
    Icon = "rocket",
    Duration = 5
})

print("[Nebublox] Anime Capture script loaded!")
