--[[
    ═══════════════════════════════════════════════════════════
    Nebublox | ANIME CAPTURE (Void v6.4 - SPAM & FILTER)
    Features: Local Dropdown Only, Turbo E-Spam, Syntax Fix
    ═══════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

-- // SINGLE INSTANCE CHECK //
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("Nebublox") then CoreGui.Nebublox:Destroy() end
if player.PlayerGui:FindFirstChild("Nebublox") then player.PlayerGui.Nebublox:Destroy() end

-- // UI LOAD //
local success, ANUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ANHub-Script/ANUI/refs/heads/main/dist/main.lua"))()
end)

if not success or not ANUI then warn("VOID: Failed to load UI") return end

local Window = ANUI:CreateWindow({
    Title = "Nebublox | VOID v6.4", 
    Author = "LilNug of Wisdom",
    Folder = "Nebublox",
    Icon = "rbxassetid://121698194718505",
    Theme = "Dark"
})

getgenv().NebubloxInstance = Window

-- // SETTINGS & FLAGS //
local Flags = {
    Farm = false, Capture = false, Click = false, Rebirth = false, 
    Equip = false, Daily = false, FreeGifts = false, EventClaim = false, 
    Roll = false, ESP = false, SafeMode = false, AutoHop = false
}

local Settings = {
    PriorityNames = {"Boss", "Legendary", "Event", "Mythic", "Shiny"}, 
    SearchRadius = 500, -- Kill Radius
    DropdownRadius = 1000, -- How far to look for the Dropdown list
    GachaTarget = "Shock Fruit",
    Debug = true,
    Blacklist = {"Mapboss524", "animate", "Effect", "Part"}, 
    HopStart = nil,
    SelectedTargets = {}
}

local GuiElements = {}

-- // UTILS //
local function GetMapBossFolder()
    local function get(parent, name)
        if not parent then return nil end
        return parent:FindFirstChild(name) or parent:FindFirstChild(name:lower()) or parent:FindFirstChild(name:upper())
    end
    return get(get(Workspace, "Floor") or Workspace, "enemy") and get(get(get(Workspace, "Floor") or Workspace, "enemy"), "mapboss")
end

-- // SCANNER FOR DROPDOWN (LOCAL ONLY) //
local function GetNearbyEnemyNames()
    local names = {}
    local seen = {}
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    -- If character isn't loaded, return empty to prevent crash
    if not myRoot then return {"Character Not Ready"} end

    local enemyFolder = GetMapBossFolder()
    local candidates = {}
    
    if enemyFolder then
        candidates = enemyFolder:GetDescendants()
    else
        local function scan(parent)
            for _, v in ipairs(parent:GetChildren()) do
                if v:IsA("Model") and v:FindFirstChild("Humanoid") then table.insert(candidates, v) end
                if v:IsA("Folder") then scan(v) end
            end
        end
        scan(Workspace)
    end
    
    for _, mob in ipairs(candidates) do
        if mob:IsA("Model") and mob ~= player.Character then
            local hum = mob:FindFirstChild("Humanoid")
            local root = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso") or mob.PrimaryPart
            
            if hum and root and hum.Health > 0 and not Players:GetPlayerFromCharacter(mob) then
                -- DISTANCE FILTER: Only show enemies close to me
                if (root.Position - myRoot.Position).Magnitude < Settings.DropdownRadius then
                    if not seen[mob.Name] then
                        table.insert(names, mob.Name)
                        seen[mob.Name] = true
                    end
                end
            end
        end
    end
    
    table.sort(names)
    return names
end

-- // TABS //
local MainTab = Window:Tab({ Title = "Main", Icon = "moon" })
local GachaTab = Window:Tab({ Title = "Gacha", Icon = "star" })
local UpgradeTab = Window:Tab({ Title = "Upgrades", Icon = "box" })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "settings" })

-- // TAB 1: MAIN //
local FarmSec = MainTab:Section({ Title = "Auto Farm", Opened = true })
FarmSec:Toggle({ Title = "Smart Kill (Direct TP)", Value = false, Callback = function(v) Flags.Farm = v end })
FarmSec:Toggle({ Title = "Auto Capture (E-Spam)", Value = false, Callback = function(v) Flags.Capture = v end })

-- DROPDOWN SECTION
FarmSec:Button({
    Title = "Refresh Nearby Enemies",
    Callback = function()
        local list = GetNearbyEnemyNames()
        if #list == 0 then list = {"No Enemies Nearby"} end
        GuiElements.EnemyDropdown:Refresh(list, true)
        ANUI:Notify({Title = "Refreshed", Content = "Found " .. #list .. " nearby enemies.", Duration = 2})
    end
})

GuiElements.EnemyDropdown = FarmSec:Dropdown({
    Title = "Select Specific Targets",
    Multi = true,
    Options = {"Click Refresh First"},
    Callback = function(v)
        local cleanList = {}
        for key, val in pairs(v) do
            if type(key) == "number" then table.insert(cleanList, val) 
            elseif val == true then table.insert(cleanList, key) end
        end
        Settings.SelectedTargets = cleanList
        if Settings.Debug then print("Selected:", table.concat(cleanList, ", ")) end
    end
})

-- // TAB 2: GACHA //
local GachaSec = GachaTab:Section({ Title = "Roll System", Opened = true })
GachaSec:Toggle({ Title = "Auto Roll Selected", Value = false, Callback = function(v) Flags.Roll = v end })
GachaSec:Input({ Title = "Target Item Name", Default = "Shock Fruit", Callback = function(v) Settings.GachaTarget = v end })

-- // TAB 3: UPGRADES //
local UpSec = UpgradeTab:Section({ Title = "Automation", Opened = true })
UpSec:Toggle({ Title = "Auto Clicker", Value = false, Callback = function(v) Flags.Click = v end })
UpSec:Toggle({ Title = "Auto Rebirth", Value = false, Callback = function(v) Flags.Rebirth = v end })
UpSec:Toggle({ Title = "Auto Equip Best", Value = false, Callback = function(v) Flags.Equip = v end })

-- // TAB 4: MISC //
local HopSec = MiscTab:Section({ Title = "Smart Server Control", Opened = true })
HopSec:Toggle({ Title = "Debug Mode (F9)", Value = false, Callback = function(v) Settings.Debug = v end })
HopSec:Button({
    Title = "Test Scanner (F9 Log)",
    Callback = function()
        local tgt = getSmartTarget()
        if tgt then print("Target Found: " .. tgt.Name) else warn("No Target Found") end
    end
})
HopSec:Toggle({ Title = "Auto Server Hop", Value = false, Callback = function(v) Flags.AutoHop = v end })
HopSec:Button({ 
    Title = "Force Server Hop", 
    Callback = function() 
        ANUI:Notify({Title = "Hopping...", Content = "Searching...", Duration = 3})
        Settings.ForceHop = true
    end 
})

local RewSec = MiscTab:Section({ Title = "Daily Rewards", Opened = true })
RewSec:Toggle({ Title = "Auto Daily Sign-in", Value = false, Callback = function(v) Flags.Daily = v end })

-- // REMOTES //
local Events = ReplicatedStorage:WaitForChild("Events")
local function getRemote(folder, name)
    if folder and Events:FindFirstChild(folder) then return Events[folder]:FindFirstChild(name) end
    return Events:FindFirstChild(name, true)
end

local Remotes = {
    Click     = getRemote("Click", "ClickEvent"),
    SetEnemy  = getRemote(nil, "SetEnemyEvent"),
    Attack    = getRemote(nil, "PlayerAttack"),
    Daily     = getRemote("EveryDayGift", "SignEvent"),
    Rebirth   = getRemote("Rebirth", "RebirthEvent"),
    Equip     = getRemote("Equip", "EquipBestEvent"),
    Roll      = getRemote("NewLotto", "RollOne") or getRemote("Gacha", "RollOne")
}

-- // OPTIMIZED SMART TARGETING //
function getSmartTarget()
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local bestTarget = nil
    local highestScore = -99999
    local safeRadius = 500
    
    local candidates = {}
    local enemyFolder = GetMapBossFolder()
    
    if enemyFolder then
        candidates = enemyFolder:GetDescendants()
    else
        local function scan(parent)
            for _, v in ipairs(parent:GetChildren()) do
                if v:IsA("Model") and v:FindFirstChild("Humanoid") then table.insert(candidates, v) end
                if v:IsA("Folder") then scan(v) end
            end
        end
        scan(Workspace)
    end

    local useSpecific = #Settings.SelectedTargets > 0

    for _, mob in ipairs(candidates) do
        if mob ~= player.Character then
            local root = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso") or mob.PrimaryPart
            local hum = mob:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                
                local shouldProcess = true
                if useSpecific then
                    local found = false
                    for _, name in ipairs(Settings.SelectedTargets) do
                        if mob.Name == name then found = true break end
                    end
                    if not found then shouldProcess = false end
                end

                if shouldProcess then
                    local isBlacklisted = false
                    for _, badName in ipairs(Settings.Blacklist) do
                        if string.find(mob.Name, badName) then isBlacklisted = true break end
                    end

                    if not isBlacklisted then
                        local dist = (root.Position - myRoot.Position).Magnitude
                        if dist < safeRadius then
                            local score = 1000 - dist
                            for _, pName in ipairs(Settings.PriorityNames) do
                                if string.find(mob.Name, pName) then score = score + 50000 break end
                            end
                            if score > highestScore then
                                highestScore = score
                                bestTarget = mob
                            end
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

-- // MAIN LOOP //
local frameCount = 0

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    
    if frameCount % 9 == 0 then 
        if Flags.Farm or Flags.Capture then
            pcall(function()
                local target = getSmartTarget()
                
                -- Auto Hop Logic
                if not target and Flags.AutoHop and Flags.Farm then
                      if not Settings.HopStart then Settings.HopStart = tick() end
                      if tick() - Settings.HopStart > 8 then ServerHop() end
                else
                      Settings.HopStart = nil
                end

                -- Action
                if target and player.Character then
                    local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    local targetRoot = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Torso") or target.PrimaryPart
                    
                    if myRoot and targetRoot then
                        myRoot.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 3, 0))
                        
                        myRoot.AssemblyLinearVelocity = Vector3.zero
                        myRoot.AssemblyAngularVelocity = Vector3.zero
                        
                        if Flags.Capture then
                            -- // SPAM E (TURBO MODE) //
                            -- Presses E 5 times rapidly per loop
                            for i=1, 5 do
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                task.wait() -- Minimal yield to allow key register
                            end
                        else
                             if Remotes.SetEnemy then Remotes.SetEnemy:FireServer(target) end
                             if Remotes.Attack then Remotes.Attack:FireServer(target) end
                             if Remotes.Click then Remotes.Click:FireServer() end
                             
                             VirtualUser:CaptureController()
                             VirtualUser:ClickButton1(Vector2.new(999,999))
                        end
                    end
                end
            end)
        end
    end
    
    if Settings.ForceHop then Settings.ForceHop = false ServerHop() end
end)

-- // SLOW LOOP //
task.spawn(function()
    while task.wait(0.5) do
         pcall(function()
            if Flags.Click and Remotes.Click then Remotes.Click:FireServer() end
            if Flags.Rebirth and Remotes.Rebirth then Remotes.Rebirth:FireServer() end
            if Flags.Daily and Remotes.Daily then Remotes.Daily:FireServer() end
            if Flags.Equip and Remotes.Equip then Remotes.Equip:FireServer() end
            if Flags.Roll and Remotes.Roll then Remotes.Roll:FireServer(Settings.GachaTarget or "Shock Fruit") end
        end)
    end
end)

ANUI:Notify({ Title = "Void v6.4", Content = "E-Spam + Local Filter", Duration = 3 })
