import os

file_path = "C:/Users/James/.gemini/antigravity/scratch/ANUI-Library/games/anime_storm_sim2_combined.lua"
split_line = 14623

user_code = r'''
-- // UI INITIALIZATION //
local ANUI = a.load('Z')

-- // GAME SCRIPT //
--[[
    ═══════════════════════════════════════════════════════════
    Nebublox | ANIME STORM SIMULATOR 2 (v1.1 Fixed)
    Features: Smart Kill, Auto Farm, Config Save, Safe Mode
    ═══════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- // SINGLE INSTANCE CHECK //
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("Nebublox") then CoreGui.Nebublox:Destroy() end
if player.PlayerGui:FindFirstChild("Nebublox") then player.PlayerGui.Nebublox:Destroy() end

local Window = ANUI:CreateWindow({
    Title = "Nebublox | Storm Sim 2 v1.1", 
    Author = "LilNug of Wisdom",
    Folder = "Nebublox",
    Icon = "rbxassetid://121698194718505",
    Theme = "Dark"
})

getgenv().NebubloxInstance = Window

-- // UNIVERSAL ANTI-AFK //
getgenv().AntiAfkRunning = true
player.Idled:Connect(function()
    if getgenv().AntiAfkRunning then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- // SETTINGS & FLAGS //
local Flags = {
    Farm = false, Rebirth = false, 
    Equip = false, Daily = false, 
    RollCrew = false, RollFruit = false, 
    RollSaiyan = false, KiProgression = false,
    RollTailedBeast = false, RollClan = false, RollKekkei = false,
    RollDomain = false, CursedProgression = false,
    BossRush = false, JjkBossRush = false, AutoHop = false,
    AutoSkills = false, AutoQuest = false, AutoHatch = false,
    AutoTrial = false, AutoChest = false,
    BuyTicket = false, BuyStrPot = false, BuyDropPot = false, BuyLuckPot = false, BuyGemPot = false,
    AutoAchievement = false,
    PotStr = false, PotDrop = false, PotLuck = false, PotGem = false,
    AutoPickup = false, DropESP = false
}

local Settings = {
    PriorityNames = {"Boss", "Legendary", "Event", "Mythic", "Shiny"}, 
    SearchRadius = 500,
    DropdownRadius = 1000,
    GachaTarget = "Shock Element",
    Debug = true,
    Blacklist = {"NPC", "Effect", "Part"}, 
    HopStart = nil,
    SelectedTargets = {},
    SelectedEgg = "Egg1"
}

local GuiElements = {}

-- // CONFIG SYSTEM //
local ConfigFile = "Nebublox_StormSim_Config.json"

local function SaveSettings()
    local success, json = pcall(function() return HttpService:JSONEncode(Flags) end)
    if success then writefile(ConfigFile, json) end
end

local function LoadSettings()
    if isfile(ConfigFile) then
        local success, content = pcall(function() return readfile(ConfigFile) end)
        if success then
            local decoded = HttpService:JSONDecode(content)
            for k, v in pairs(decoded) do
                if Flags[k] ~= nil then Flags[k] = v end
            end
        end
    end
end
-- Auto Save Loop
task.spawn(function()
    while task.wait(10) do SaveSettings() end
end)
-- Load on startup
LoadSettings()

-- // TWEEN SETUP //
local currentTween = nil

local function TweenTo(targetCFrame)
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local dist = (myRoot.Position - targetCFrame.Position).Magnitude
    if dist < 5 then
        myRoot.CFrame = targetCFrame
        return
    end
    
    local info = TweenInfo.new(dist / 300, Enum.EasingStyle.Linear)
    if currentTween then currentTween:Cancel() end
    currentTween = TweenService:Create(myRoot, info, {CFrame = targetCFrame})
    currentTween:Play()
end

-- // UTILS //
local function GetEnemyFolder()
    local maps = Workspace:FindFirstChild("Maps")
    if maps then
        for _, world in ipairs(maps:GetChildren()) do
            local enemies = world:FindFirstChild("Enemies") or world:FindFirstChild("Mobs") or world:FindFirstChild("NPCs")
            if enemies then return enemies end
        end
    end

    local function get(parent, name)
        if not parent then return nil end
        return parent:FindFirstChild(name) or parent:FindFirstChild(name:lower()) or parent:FindFirstChild(name:upper())
    end
    
    local possiblePaths = {
        get(Workspace, "Enemies"),
        get(Workspace, "NPCs"),
        get(Workspace, "Mobs"),
        get(get(Workspace, "World"), "Enemies")
    }
    
    for _, folder in ipairs(possiblePaths) do
        if folder then return folder end
    end
    
    return nil
end

local function GetNearbyEnemyNames()
    local names = {}
    local seen = {}
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then return {"Character Not Ready"} end

    local enemyFolder = GetEnemyFolder()
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

local function collectChests()
    local chests = Workspace:FindFirstChild("Chest")
    if not chests then return end
    
    for _, chest in ipairs(chests:GetChildren()) do
        local prompt = chest:FindFirstChild("ProximityPrompt", true) or chest:FindFirstChildOfClass("ProximityPrompt")
        if not prompt then
             for _, v in ipairs(chest:GetDescendants()) do
                 if v:IsA("ProximityPrompt") then prompt = v break end
             end
        end
        
        if prompt then
            if fireproximityprompt then
                fireproximityprompt(prompt)
            end
        end
    end
end

-- // TABS //
local MainTab = Window:Tab({ Title = "Main", Icon = "zap" })
local EggsTab = Window:Tab({ Title = "Eggs", Icon = "egg" })
local GachaTab = Window:Tab({ Title = "Gacha", Icon = "star" })
local UpgradeTab = Window:Tab({ Title = "Upgrades", Icon = "box" })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "settings" })

-- // TAB 1: MAIN //
local FarmSec = MainTab:Section({ Title = "Auto Farm", Opened = true })

FarmSec:Toggle({ 
    Title = "Auto Attack (Clicker + Range)", 
    Value = Flags.Farm, -- Load from config
    Callback = function(v) 
        Flags.Farm = v 
        if v then
            if Remotes.AttackRange then
                pcall(function() Remotes.AttackRange:FireServer("Enable") end)
            end
            EnableAutoClicker()
        end
    end 
})

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
    end
})

-- // TAB 1.5: EGGS //
local HatchSec = EggsTab:Section({ Title = "Auto Hatch", Opened = true })

HatchSec:Input({
    Title = "Egg Name",
    Default = "Egg1",
    Callback = function(v) Settings.SelectedEgg = v end
})

HatchSec:Toggle({
    Title = "Auto Hatch Selected Egg",
    Value = Flags.AutoHatch,
    Callback = function(v) Flags.AutoHatch = v end
})

-- // TAB 2: GACHA //
local PirateGachaSec = GachaTab:Section({ Title = "Pirate World Gacha", Opened = true })
PirateGachaSec:Toggle({ Title = "Auto Roll OnePiece Crew", Value = Flags.RollCrew, Callback = function(v) Flags.RollCrew = v end })
PirateGachaSec:Toggle({ Title = "Auto Roll OnePiece Fruit", Value = Flags.RollFruit, Callback = function(v) Flags.RollFruit = v end })

local DbzGachaSec = GachaTab:Section({ Title = "DBZ World Gacha", Opened = true })
DbzGachaSec:Toggle({ Title = "Auto Roll DBZ Saiyan", Value = Flags.RollSaiyan, Callback = function(v) Flags.RollSaiyan = v end })
DbzGachaSec:Toggle({ Title = "Auto Upgrade Ki Progression", Value = Flags.KiProgression, Callback = function(v) Flags.KiProgression = v end })

local NarutoGachaSec = GachaTab:Section({ Title = "Shinobi World Gacha", Opened = true })
NarutoGachaSec:Toggle({ Title = "Auto Roll Tailed Beast", Value = Flags.RollTailedBeast, Callback = function(v) Flags.RollTailedBeast = v end })
NarutoGachaSec:Toggle({ Title = "Auto Roll Naruto Clan", Value = Flags.RollClan, Callback = function(v) Flags.RollClan = v end })
NarutoGachaSec:Toggle({ Title = "Auto Roll Kekkei Genkai", Value = Flags.RollKekkei, Callback = function(v) Flags.RollKekkei = v end })

local JjkGachaSec = GachaTab:Section({ Title = "Cursed World Gacha", Opened = true })
JjkGachaSec:Toggle({ Title = "Auto Roll JJK Domain", Value = Flags.RollDomain, Callback = function(v) Flags.RollDomain = v end })
JjkGachaSec:Toggle({ Title = "Auto Upgrade Cursed Energy", Value = Flags.CursedProgression, Callback = function(v) Flags.CursedProgression = v end })

-- // TAB 3: UPGRADES //
local UpSec = UpgradeTab:Section({ Title = "Automation", Opened = true })
UpSec:Toggle({ Title = "Auto Rebirth", Value = Flags.Rebirth, Callback = function(v) Flags.Rebirth = v end })
UpSec:Toggle({ Title = "Auto Equip Best", Value = Flags.Equip, Callback = function(v) Flags.Equip = v end })
UpSec:Toggle({ Title = "Auto Use Skills", Value = Flags.AutoSkills, Callback = function(v) Flags.AutoSkills = v end })

local PotSec = UpgradeTab:Section({ Title = "Potions (Auto Drink)", Opened = true })
PotSec:Toggle({ Title = "Auto Strength Potion", Value = Flags.PotStr, Callback = function(v) Flags.PotStr = v end })
PotSec:Toggle({ Title = "Auto Drops Potion", Value = Flags.PotDrop, Callback = function(v) Flags.PotDrop = v end })
PotSec:Toggle({ Title = "Auto Luck Potion", Value = Flags.PotLuck, Callback = function(v) Flags.PotLuck = v end })
PotSec:Toggle({ Title = "Auto Gem Potion", Value = Flags.PotGem, Callback = function(v) Flags.PotGem = v end })

-- // TAB 4: MISC //
local WorldSec = MiscTab:Section({ Title = "World Teleportation", Opened = true })
WorldSec:Button({ Title = "Teleport to Pirate World", Callback = function() if Remotes.World then Remotes.World:FireServer("OnePiece", "Teleport") end end })
WorldSec:Button({ Title = "Teleport to DBZ World", Callback = function() if Remotes.World then Remotes.World:FireServer("Dbz", "Teleport") end end })
WorldSec:Button({ Title = "Teleport to Shinobi World", Callback = function() if Remotes.World then Remotes.World:FireServer("Naruto", "Teleport") end end })
WorldSec:Button({ Title = "Teleport to Cursed World", Callback = function() if Remotes.World then Remotes.World:FireServer("Jjk", "Teleport") end end })

local BossRushSec = MiscTab:Section({ Title = "Boss Rush Mode", Opened = true })
BossRushSec:Toggle({
    Title = "Auto Start DBZ Boss Rush",
    Value = Flags.BossRush,
    Callback = function(v)
        Flags.BossRush = v
        if v then
            if Remotes.BossRushRemote then Remotes.BossRushRemote:FireServer("OpenBossRushFrame", "DbzBossRush") end
            if Remotes.BossRushStart then Remotes.BossRushStart:FireServer("StartUi", "DbzBossRush") end
        end
    end
})
BossRushSec:Toggle({
    Title = "Auto Start JJK Boss Rush",
    Value = Flags.JjkBossRush,
    Callback = function(v)
        Flags.JjkBossRush = v
        if v then
            if Remotes.BossRushRemote then Remotes.BossRushRemote:FireServer("OpenBossRushFrame", "JjkBossRush") end
            if Remotes.BossRushStart then Remotes.BossRushStart:FireServer("StartUi", "JjkBossRush") end
        end
    end
})

local TrialSec = MiscTab:Section({ Title = "Time Trials", Opened = true })
TrialSec:Toggle({
    Title = "Auto Easy Trial (XX:15 & XX:45)",
    Value = Flags.AutoTrial,
    Callback = function(v)
        Flags.AutoTrial = v
        if v then
            local date = os.date("!*t")
            if date.min == 15 or date.min == 45 then Flags.Farm = true end
        end
    end
})

local ShopSec = MiscTab:Section({ Title = "Time Trial Shop", Opened = true })
ShopSec:Toggle({ Title = "Auto Buy Storm Ticket", Value = Flags.BuyTicket, Callback = function(v) Flags.BuyTicket = v end })
ShopSec:Toggle({ Title = "Auto Buy Strength Potion", Value = Flags.BuyStrPot, Callback = function(v) Flags.BuyStrPot = v end })
ShopSec:Toggle({ Title = "Auto Buy Drops Potion", Value = Flags.BuyDropPot, Callback = function(v) Flags.BuyDropPot = v end })
ShopSec:Toggle({ Title = "Auto Buy Luck Potion", Value = Flags.BuyLuckPot, Callback = function(v) Flags.BuyLuckPot = v end })
ShopSec:Toggle({ Title = "Auto Buy Gem Potion", Value = Flags.BuyGemPot, Callback = function(v) Flags.BuyGemPot = v end })

local HopSec = MiscTab:Section({ Title = "Server Control", Opened = true })
HopSec:Toggle({ Title = "Auto Server Hop", Value = Flags.AutoHop, Callback = function(v) Flags.AutoHop = v end })
HopSec:Button({ Title = "Force Server Hop", Callback = function() ANUI:Notify({Title = "Hopping...", Content = "Searching...", Duration = 3}) Settings.ForceHop = true end })

local RewSec = MiscTab:Section({ Title = "Daily Rewards", Opened = true })
RewSec:Toggle({ Title = "Auto Daily Sign-in", Value = Flags.Daily, Callback = function(v) Flags.Daily = v end })
RewSec:Toggle({ Title = "Auto Collect Chests", Value = Flags.AutoChest, Callback = function(v) Flags.AutoChest = v end })
RewSec:Toggle({ Title = "Auto Claim Achievements", Value = Flags.AutoAchievement, Callback = function(v) Flags.AutoAchievement = v end })

-- // REMOTES //
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 5)
local AttackRangeFolder = RemotesFolder and RemotesFolder:FindFirstChild("AttackRange")
local SpecialPerkFolder = RemotesFolder and RemotesFolder:FindFirstChild("SpecialPerkRemotes")
local BossRushFolder = RemotesFolder and RemotesFolder:FindFirstChild("BossRush")

local Remotes = {
    Rebirth = RemotesFolder and RemotesFolder:FindFirstChild("Rebirth"),
    AutoClicker = RemotesFolder and RemotesFolder:FindFirstChild("AutoClicker"),
    AttackRange = AttackRangeFolder and AttackRangeFolder:FindFirstChild("AttackRangeRemote"),
    SpecialPerk = SpecialPerkFolder and SpecialPerkFolder:FindFirstChild("SpecialPerk"),
    SpecialProgression = RemotesFolder and RemotesFolder:FindFirstChild("SpecialProgression"),
    Egg = (RemotesFolder and RemotesFolder:FindFirstChild("Egg")) and RemotesFolder.Egg:FindFirstChild("Egg"),
    TimeTrial = RemotesFolder and RemotesFolder:FindFirstChild("TimeTrial"),
    World = RemotesFolder and RemotesFolder:FindFirstChild("World"),
    BossRushRemote = BossRushFolder and BossRushFolder:FindFirstChild("BossRushRemote"),
    BossRushStart = BossRushFolder and BossRushFolder:FindFirstChild("BossRushStart"),
    DailyLogin = RemotesFolder and RemotesFolder:FindFirstChild("DailyLogin"),
    BoosterLogin = RemotesFolder and RemotesFolder:FindFirstChild("BoosterLogin"),
    TimedRewards = RemotesFolder and RemotesFolder:FindFirstChild("TimedRewards"),
    Achievement = RemotesFolder and RemotesFolder:FindFirstChild("Achievement"),
    TimeTrialShop = (RemotesFolder and RemotesFolder:FindFirstChild("TimeTrial")) and RemotesFolder.TimeTrial:FindFirstChild("TimeTrialShop"),
    PetEquip = (RemotesFolder and RemotesFolder:FindFirstChild("Pets")) and RemotesFolder.Pets:FindFirstChild("PetEquip"),
    GetData = RemotesFolder and RemotesFolder:FindFirstChild("GetData"),
    UseItem = RemotesFolder and RemotesFolder:FindFirstChild("UseItem"),
    Attack = nil, -- Needs manual finding if needed, usually handled by AttackRange or AutoClicker
}

-- // AUTO CLICKER FUNCTION //
local function EnableAutoClicker()
    if not Remotes.AutoClicker then return end
    pcall(function()
        local success = pcall(function() Remotes.AutoClicker:InvokeServer("AutoClicker") end)
        if not success then Remotes.AutoClicker:InvokeServer("FreeClicker") end
    end)
end

-- // OPTIMIZED SMART TARGETING //
function getSmartTarget()
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local bestTarget = nil
    local highestScore = -99999
    local safeRadius = Settings.SearchRadius
    
    local candidates = {}
    local enemyFolder = GetEnemyFolder()
    
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

-- // SERVER HOP FUNCTION //
function ServerHop()
    local PlaceId = game.PlaceId
    local servers = {}
    pcall(function()
        local req = game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        local data = HttpService:JSONDecode(req)
        if data and data.data then
            for _, server in ipairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(servers, server.id)
                end
            end
        end
    end)
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], player)
    end
end

-- // MAIN LOOP //
local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    if frameCount % 9 == 0 then 
        if Flags.Farm then
            pcall(function()
                local target = getSmartTarget()
                
                -- Auto Hop
                if not target and Flags.AutoHop and Flags.Farm then
                      if not Settings.HopStart then Settings.HopStart = tick() end
                      if tick() - Settings.HopStart > 8 then ServerHop() end
                else
                      Settings.HopStart = nil
                end

                -- Farm Action
                if Flags.Farm and player.Character then
                    local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    local hum = player.Character:FindFirstChild("Humanoid")
                    
                    -- Safe Mode
                    if hum and hum.Health > 0 and hum.Health < (hum.MaxHealth * 0.3) then
                         local safePlate = Workspace:FindFirstChild("NebuSafePlate")
                         if not safePlate then
                             safePlate = Instance.new("Part")
                             safePlate.Name = "NebuSafePlate"
                             safePlate.Size = Vector3.new(50, 1, 50)
                             safePlate.Position = Vector3.new(0, 5000, 0)
                             safePlate.Anchored = true
                             safePlate.Transparency = 0.5
                             safePlate.Parent = Workspace
                         end
                         myRoot.CFrame = safePlate.CFrame + Vector3.new(0, 5, 0)
                         return -- Don't attack if low health
                    end

                    if target then
                        local tRoot = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Torso") or target.PrimaryPart
                        if tRoot and myRoot then
                            local farmCFrame = tRoot.CFrame * CFrame.new(0, 5, 4)
                            TweenTo(farmCFrame)
                            
                            myRoot.AssemblyLinearVelocity = Vector3.zero
                            myRoot.AssemblyAngularVelocity = Vector3.zero
                            
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
local achTick = 0
local potTick = 0 
task.spawn(function()
    while task.wait(0.5) do
         achTick = achTick + 1
         pcall(function()
            if Flags.Rebirth and Remotes.Rebirth then Remotes.Rebirth:FireServer("Rebirth") end
            
            if Flags.Daily then
                 if Remotes.DailyLogin then Remotes.DailyLogin:FireServer("GetData"); for i = 1, 7 do Remotes.DailyLogin:FireServer("Claim", i) end end
                 if Remotes.BoosterLogin then Remotes.BoosterLogin:FireServer("GetData"); for i = 1, 7 do Remotes.BoosterLogin:FireServer("Claim", i) end end
                 if Remotes.TimedRewards then for i = 1, 8 do Remotes.TimedRewards:FireServer("TimedReward"..i) end end
                 if Remotes.Achievement and Flags.AutoAchievement and achTick % 20 == 0 then
                    Remotes.Achievement:FireServer("ClaimAll")
                    for i = 1, 30 do Remotes.Achievement:FireServer("Claim", i) end
                 end
            end
            
            if Flags.Equip and Remotes.PetEquip then 
                task.spawn(function() pcall(function() Remotes.PetEquip:InvokeServer("EquipBest") end) end)
            end
            
            -- Gacha & Upgrades
            if Flags.RollCrew and Remotes.SpecialPerk then Remotes.SpecialPerk:FireServer("Spin", "OnePieceCrew") end
            if Flags.RollFruit and Remotes.SpecialPerk then Remotes.SpecialPerk:FireServer("Spin", "OnePieceFruit") end
            if Flags.RollSaiyan and Remotes.SpecialPerk then Remotes.SpecialPerk:FireServer("Spin", "DbzSaiyan") end
            if Flags.KiProgression and Remotes.SpecialProgression then Remotes.SpecialProgression:FireServer("UpgradeProgression", "KiProgression") end
            if Flags.RollTailedBeast and Remotes.SpecialPerk then Remotes.SpecialPerk:FireServer("Spin", "NarutoTailedBeast") end
            if Flags.RollClan and Remotes.SpecialPerk then Remotes.SpecialPerk:FireServer("Spin", "NarutoClan") end
            if Flags.RollKekkei and Remotes.SpecialPerk then Remotes.SpecialPerk:FireServer("Spin", "NarutoKekkeiGenkai") end
            if Flags.RollDomain and Remotes.SpecialPerk then Remotes.SpecialPerk:FireServer("Spin", "JjkDomain") end
            if Flags.CursedProgression and Remotes.SpecialProgression then Remotes.SpecialProgression:FireServer("UpgradeProgression", "CursedEnergyProgression") end
            
            -- Auto Hatch
            if Flags.AutoHatch and Remotes.Egg and Settings.SelectedEgg then
                Remotes.Egg:FireServer("Buy", Settings.SelectedEgg)
                Remotes.Egg:FireServer("Open", Settings.SelectedEgg)
            end
            
            -- Auto Chests
            if Flags.AutoChest then collectChests() end
            
            -- Auto Buy Shop
            if Remotes.TimeTrialShop then
                local function buy(item) Remotes.TimeTrialShop:FireServer("Buy", item); Remotes.TimeTrialShop:FireServer("Purchase", item) end
                if Flags.BuyTicket then buy("StormTicket") end
                if Flags.BuyStrPot then buy("StrengthPotion") end
                if Flags.BuyDropPot then buy("DropsPotion") end
                if Flags.BuyLuckPot then buy("LuckPotion") end
                if Flags.BuyGemPot then buy("GemPotion") end
            end
            
            -- Auto Potions (Throttled 30s)
            potTick = potTick + 1
            if potTick % 60 == 0 and Remotes.GetData then
                 local function checkAndUse(name)
                     local success, count = pcall(function() return Remotes.GetData:InvokeServer("Item", name) end)
                     if success and type(count) == "number" and count > 0 then
                         if Remotes.UseItem then Remotes.UseItem:FireServer(name) end
                         local inv = RemotesFolder:FindFirstChild("Inventory")
                         if inv then inv:FireServer("Use", name) end
                         local pot = RemotesFolder:FindFirstChild("Potion")
                         if pot then pot:FireServer("Use", name) end
                     end
                 end
                 if Flags.PotStr then checkAndUse("StrengthPotion") end
                 if Flags.PotDrop then checkAndUse("DropsPotion") end
                 if Flags.PotLuck then checkAndUse("LuckPotion") end
                 if Flags.PotGem then checkAndUse("GemPotion") end
            end
        end)
    end
end)

ANUI:Notify({ Title = "Storm Sim 2 v1.1", Content = "Script Loaded Successfully!", Duration = 3 })
'''

try:
    with open(file_path, "r", encoding="utf-8") as f:
        # Read only up to the split line to keep the UI part
        lines = f.readlines()
        
    if len(lines) > split_line:
        ui_part = "".join(lines[:split_line])
        final_content = ui_part + "\n" + user_code
        
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(final_content)
            
        print("Successfully updated combined script with user fix.")
    else:
        print(f"Error: File is smaller than split line {split_line}")
        
except Exception as e:
    print(f"Error: {e}")
