-- // NEBUBLOX | ANIME CREATURES //
-- // VERSION: 2.1 (FINAL / GOD MODE) //
-- // UI Library: ANUI //

local ANUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ANHub-Script/ANUI/refs/heads/main/dist/main.lua"))()

-- // GLOBAL CONFIG //
local ScriptTitle = "Nebublox"
local ScriptIcon = "rbxthumb://type=Asset&id=104654406951475&w=150&h=150"

-- // CLOSE OLD INSTANCE //
if _G.NebubloxCapture and type(_G.NebubloxCapture) == "table" then
    if _G.NebubloxCapture.Window then
        pcall(function() _G.NebubloxCapture.Window:Destroy() end)
    end
end

-- // SERVICES //
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager") 
local player = Players.LocalPlayer

-- // 1. CONFIGURATION & MAPPINGS //
local Flags = {
    SmartFarm = false,
    AutoCapture = false,
    AutoEquip = false,
    AutoRebirth = false,
    AutoFreeGifts = false,
    AutoDailyRewards = false,
    AutoSpin = false,
    AutoEventCollect = false,
    AutoCharge = false,
    AntiPopup = true,
    GodMode = false,
    AutoAchievements = false,
    
    SelectedMobs = {},
    SelectedGachaId = "201",
    AutoRollSelected = false,
    SelectedCharge = "1",
}

-- Pre-defined Boss Names
local BossNameMap = {
    ["MapBoss1001"] = "World Boss 1", -- Pirate Village
    ["MapBoss1002"] = "World Boss 2", -- Ninja Village
    ["MapBoss1003"] = "World Boss 3", -- Shirayuki
    ["MapBoss1004"] = "World Boss 4", -- Cursed Arts
    ["MapBoss1005"] = "World Boss 5", -- Arcane City
    ["MapBoss1006"] = "World Boss 6", -- Duck Research
    ["MapBoss1007"] = "World Boss 7", -- Lookout
    ["MapBoss1008"] = "World Boss 8"
}

-- // 2. WINDOW CREATION //
local Window = ANUI:CreateWindow({
    Title = ScriptTitle, 
    Author = "System: v2.1",
    Folder = "NebubloxCapture",
    Icon = ScriptIcon,
    IconSize = 44,
    Theme = "Dark", 
    Transparent = false,
    SideBarWidth = 200,
    HasOutline = true,
})

-- // 3. PROFILE SETUP //
local NugProfile = {
    Banner = "rbxthumb://type=Asset&id=88040798502148&w=768&h=432", 
    Avatar = "rbxthumb://type=Asset&id=121698194718505&w=420&h=420", 
    Status = true,
    Title = "He Who Remains",
    Desc = "Architect of the Multiverse",
    Badges = {
        {
            Icon = "geist:logo-discord", 
            Title = "Community", 
            Desc = "Join Discord", 
            Callback = function() 
                setclipboard("https://discord.gg/kgu3WXGg5m")
                ANUI:Notify({Title = "Discord", Content = "Link Copied!", Icon = "check", Duration = 3})
            end
        }
    }
}

-- // 4. TABS & SECTIONS //

-- [TAB 1: HOME]
local MainTab = Window:Tab({ Title = "Home", Icon = "home", Profile = NugProfile, SidebarProfile = true })
local InfoSection = MainTab:Section({ Title = "Dashboard", Icon = "activity", Opened = true })

InfoSection:Paragraph({
    Title = "System Status",
    Content = "Nebublox v2.1 Loaded.\nEngine: Heartbeat (60hz)\nStatus: Optimal"
})

InfoSection:Button({
    Title = "Join Discord Server",
    Callback = function() setclipboard("https://discord.gg/kgu3WXGg5m") ANUI:Notify({Title = "Discord", Content = "Link Copied!", Icon = "check", Duration = 3}) end
})

-- [TAB 2: FARMING]
local FarmTab = Window:Tab({ Title = "Farming", Icon = "swords", SidebarProfile = false })
local AutoFarm = FarmTab:Section({ Title = "Combat Engine", Icon = "zap", Opened = true })

AutoFarm:Toggle({
    Title = "Auto Capture (Hyper-Spam)",
    Desc = "Spams 'E' Key + Packets physically",
    Value = false,
    Callback = function(state) Flags.AutoCapture = state end
})

local CaptureDropdown = AutoFarm:Dropdown({
    Title = "Target Priority",
    Multi = true,
    Required = false,
    Values = {"Click Refresh below..."}, 
    Callback = function(val)
        Flags.SelectedMobs = {}
        for k, v in pairs(val) do
            if type(k) == "string" and v == true then Flags.SelectedMobs[k] = true
            elseif type(v) == "string" then Flags.SelectedMobs[v] = true end
        end
    end
})

AutoFarm:Button({
    Title = "Refresh Targets",
    Callback = function()
        local validTargets = {}
        local seen = {}
        local stringList = {} 
        
        -- Store globally for the farmer to use
        _G.BossNameMap = BossNameMap
        
        local function AddTarget(mob)
            if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                if Players:GetPlayerFromCharacter(mob) then return end
                
                -- Distance Check (Prevent targeting cross-map and glitching)
                local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local dist = (mob.HumanoidRootPart.Position - myRoot.Position).Magnitude
                    if dist > 3000 then return end 
                end

                local name = mob.Name
                if BossNameMap[name] then name = BossNameMap[name] end
                
                if not seen[name] and mob.Humanoid.Health > 0 then
                    table.insert(stringList, name)
                    seen[name] = true
                end
            end
        end

        -- 1. Scan Common
        if workspace:FindFirstChild("common") and workspace.common:FindFirstChild("Up") then
            for _, island in ipairs(workspace.common.Up:GetChildren()) do
                 local npcFolder = island:FindFirstChild("NPC")
                 if npcFolder then for _, mob in ipairs(npcFolder:GetChildren()) do AddTarget(mob) end end
            end
        end
        -- 2. Scan Bosses
        if workspace:FindFirstChild("enemy") then
             for _, mob in ipairs(workspace.enemy:GetDescendants()) do AddTarget(mob) end
        end
        -- 3. Check Workspace Fallback
        for _, mob in ipairs(workspace:GetChildren()) do
             if mob:IsA("Model") and mob.Name:find("MapBoss") then AddTarget(mob) end
        end
        
        table.sort(stringList)
        if CaptureDropdown and CaptureDropdown.Refresh then CaptureDropdown:Refresh(stringList, true) end
        ANUI:Notify({Title = "System", Content = "Found " .. #stringList .. " targets.", Icon = "target", Duration = 2})
    end
})

AutoFarm:Toggle({
    Title = "Enable God-Mode Farm",
    Desc = "Teleports & Freezes hitbox (Invincible)",
    Value = false,
    Callback = function(state) Flags.SmartFarm = state end
})

-- [TAB 3: GACHA]
local GachaTab = Window:Tab({ Title = "Gacha", Icon = "gift", SidebarProfile = false })
local GachaSection = GachaTab:Section({ Title = "Auto Roll", Icon = "dices", Opened = true })

-- Gacha Mapping
local GachaNames = {
    ["201"] = "Shock Fruit", ["202"] = "Flame Fruit",
    ["203"] = "Sharingan", ["204"] = "Tessen",
    ["205"] = "Nichirin Earring", ["206"] = "Swordsmith Mask",
    ["207"] = "Impression Ring", ["208"] = "Prison Realm", 
    ["209"] = "One Punch", ["210"] = "Monster Cell",
    ["221"] = "Scouter", ["222"] = "Dragon Radar",
    ["223"] = "Speed Mark", ["224"] = "Life Mark",
}

-- Auto-Detect
if workspace:FindFirstChild("common") and workspace.common:FindFirstChild("OtherLotto") then
    for _, lotto in ipairs(workspace.common.OtherLotto:GetChildren()) do
        local id = lotto.Name
        if not GachaNames[id] and tonumber(id) then GachaNames[id] = "Machine " .. id end
    end
end

-- Generate Dropdown with Headers
local GachaList = {}
local function AdHeader(text) table.insert(GachaList, {Title = "--- " .. text .. " ---", Val = "HEADER"}) end
local function AdItem(id)
    local name = GachaNames[id] or ("Machine " .. id)
    table.insert(GachaList, {Title = name, Val = id})
end

AdHeader("Pirate Village (World 1)")
AdItem("201"); AdItem("202")
AdHeader("Ninja Village (World 2)")
AdItem("203"); AdItem("204")
AdHeader("Shirayuki Village (World 3)")
AdItem("205"); AdItem("206")
AdHeader("Cursed Arts Hamlet (World 4)")
AdItem("207"); AdItem("208")
AdHeader("Arcane City Lofts (World 5)")
AdItem("209"); AdItem("210")
AdHeader("Duck Research Center (World 6)")
AdItem("221"); AdItem("222")
AdHeader("Lookout (World 7)")
AdItem("223"); AdItem("224")

GachaSection:Dropdown({
    Title = "Select Machine",
    Multi = false,
    Required = true,
    Values = GachaList,
    Callback = function(val) 
        local selected = val
        if type(val) == "table" then for k,v in pairs(val) do if type(k)=="number" then selected=v else selected=k end end end
        if selected ~= "HEADER" then Flags.SelectedGachaId = selected end
    end
})

GachaSection:Toggle({
    Title = "Auto Roll Selected",
    Value = false,
    Callback = function(state) Flags.AutoRollSelected = state end
})

-- RESTORED CHARGE UI
local ChargeSection = GachaTab:Section({ Title = "World Charges", Icon = "battery-charging", Opened = true })
ChargeSection:Dropdown({
    Title = "Charge Level",
    Multi = false,
    Required = true,
    Values = {"World 1", "World 2", "World 3", "World 4", "World 5", "World 6", "World 7"},
    Callback = function(val)
        local selected = val
        if type(val) == "table" then for k, v in pairs(val) do selected = v end end
        local num = selected:match("%d+")
        if num then Flags.SelectedCharge = num end
    end
})

ChargeSection:Toggle({
    Title = "Auto Charge Selected",
    Value = false,
    Callback = function(state) Flags.AutoCharge = state end
})


-- [TAB 4: AUTOMATION]
local AutoTab = Window:Tab({ Title = "Automation", Icon = "cpu", SidebarProfile = false })
local MiscSection = AutoTab:Section({ Title = "Rewards", Icon = "gift", Opened = true })

MiscSection:Toggle({ Title = "Auto Claim Achievements", Callback = function(s) Flags.AutoAchievements = s end })
MiscSection:Toggle({ Title = "Auto Equip Best", Callback = function(s) Flags.AutoEquip = s end })
MiscSection:Toggle({ Title = "Auto Rebirth", Callback = function(s) Flags.AutoRebirth = s end })
MiscSection:Toggle({ Title = "Auto Free Gifts", Callback = function(s) Flags.AutoFreeGifts = s end })
MiscSection:Toggle({ Title = "Auto Daily Rewards", Callback = function(s) Flags.AutoDailyRewards = s end })
MiscSection:Toggle({ Title = "Auto Spin Wheel", Callback = function(s) Flags.AutoSpin = s end })
MiscSection:Toggle({ Title = "Auto Event Stars", Callback = function(s) Flags.AutoEventCollect = s end })

-- [TAB 5: WORLDS]
local WorldTab = Window:Tab({ Title = "Worlds", Icon = "globe", SidebarProfile = false })
local TeleportSection = WorldTab:Section({ Title = "Fast Travel", Icon = "map-pin", Opened = true })

local Islands = {
    {Name = "Seaside Town", Id = "0"}, {Name = "Pirate Village", Id = "1"},
    {Name = "Ninja Village", Id = "2"}, {Name = "Shirayuki Village", Id = "3"},
    {Name = "Cursed Arts Hamlet", Id = "4"}, {Name = "Arcane City Lofts", Id = "5"},
    {Name = "Duck Research Center", Id = "6"}, {Name = "Lookout", Id = "7"},
}

for _, island in ipairs(Islands) do
    TeleportSection:Button({
        Title = island.Name,
        Callback = function()
            local pIdx = tonumber(island.Id)
            -- 1. Remote Warp
            pcall(function() ReplicatedStorage.Events.Map.PortalEvent:FireServer(pIdx) end)
            
            -- 2. CFrame Backup
            if workspace:FindFirstChild("common") and workspace.common:FindFirstChild("Up") then
                local target = workspace.common.Up:FindFirstChild(island.Id)
                if target then 
                    if island.Id == "1" and target:FindFirstChild("NPC") then target = target.NPC end
                    
                    local cf = nil
                    if target:IsA("Model") then cf = target:GetPivot()
                    elseif target:IsA("BasePart") then cf = target.CFrame 
                    elseif target:IsA("Folder") then
                         local p = target:FindFirstChildWhichIsA("BasePart", true)
                         if p then cf = p.CFrame end
                    end
                    
                    if cf then
                        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if root then root.CFrame = cf + Vector3.new(0, 5, 0) end
                    end
                end
            end
            ANUI:Notify({Title = "Teleport", Content = "Warped to " .. island.Name, Duration = 2})
        end
    })
end

-- // 5. LOGIC ENGINE //

-- Anti-AFK
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Target Finder
local function GetSmartTarget()
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local shortestDist = 750
    local bestTarget = nil
    
    -- Ensure Map is Loaded
    local BossMap = _G.BossNameMap or BossNameMap

    local function CheckMob(mob)
        if mob and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            -- Filter
            if next(Flags.SelectedMobs) ~= nil then
                local rawName = mob.Name
                local prettyName = BossMap[rawName] or rawName
                if not Flags.SelectedMobs[rawName] and not Flags.SelectedMobs[prettyName] then return end
            end
            
            local dist = (mob.HumanoidRootPart.Position - myRoot.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                bestTarget = mob
            end
        end
    end

    -- 1. Map Bosses
    if workspace:FindFirstChild("enemy") then
        for _, mob in ipairs(workspace.enemy:GetDescendants()) do 
            if mob:IsA("Model") then CheckMob(mob) end
        end
    end
    -- 1.5 Fallback Map Bosses
    for _, mob in ipairs(workspace:GetChildren()) do
        if mob:IsA("Model") and mob.Name:find("MapBoss") then CheckMob(mob) end
    end
    -- 2. Common Mobs
    if not bestTarget and workspace:FindFirstChild("common") and workspace.common:FindFirstChild("Up") then
        for _, island in ipairs(workspace.common.Up:GetChildren()) do
             local npc = island:FindFirstChild("NPC")
             if npc then for _, mob in ipairs(npc:GetChildren()) do CheckMob(mob) end end
        end
    end
    
    return bestTarget
end

-- Hyper-Spam Capture
task.spawn(function()
    local captureEvent = nil
    pcall(function() captureEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SetStatEvent", 2) end)
    
    RunService.Heartbeat:Connect(function()
        if Flags.AutoCapture or Flags.SmartFarm then
            pcall(function()
                VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end)
            if captureEvent then
                pcall(function() captureEvent:FireServer("AutoCatchFollow", true) end)
            end
        end
    end)
end)

-- God Mode Movement
RunService.Heartbeat:Connect(function()
    if Flags.SmartFarm then
        local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        
        if myRoot and humanoid then
            if humanoid.Sit then humanoid.Sit = false end
            myRoot.Velocity = Vector3.new(0,0,0) 
            myRoot.RotVelocity = Vector3.new(0,0,0)
            
            local target = GetSmartTarget()
            if target and target:FindFirstChild("HumanoidRootPart") then
                local backPos = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
                myRoot.CFrame = backPos
            end
        end
    end
end)

-- Rewards Loop (Fast)
task.spawn(function()
    while task.wait(0.5) do
        -- Charge Logic
        if Flags.AutoCharge and Flags.SelectedCharge then
             pcall(function()
                 local id = tostring(Flags.SelectedCharge)
                 local currentLv = 11 -- Default max check
                 
                 if workspace:FindFirstChild("common") and workspace.common:FindFirstChild("Up") then
                    local podium = workspace.common.Up:FindFirstChild(id)
                    if podium then
                         for _, label in ipairs(podium:GetDescendants()) do
                            if label:IsA("TextLabel") and (label.Text:find("Lv") or label.Text:find("Level")) then
                                local num = label.Text:match("%d+")
                                if num then currentLv = tonumber(num) break end
                            end
                         end
                    end
                 end
                 -- Fire upgrade
                 ReplicatedStorage.Events.PowerUp.UpLvEvent:FireServer({["id"] = tonumber(id), ["lv"] = currentLv})
             end)
        end
        
        -- Gacha Logic
        if Flags.AutoRollSelected then
             local gid = tonumber(Flags.SelectedGachaId)
             if gid then 
                 pcall(function() ReplicatedStorage.Events.NewLotto.RollOne:FireServer(true, gid) end)
             end
        end
    end
end)

-- Rewards Loop (Slow)
task.spawn(function()
    while task.wait(5) do
        if Flags.AutoEquip then pcall(function() ReplicatedStorage.Events.Equip.EquipBestEvent:FireServer(1) end) end
        if Flags.AutoRebirth then 
            pcall(function() 
                ReplicatedStorage.Events.Rebirth.RebirthEvent:FireServer() 
                ReplicatedStorage.Events.Rebirth.AutoRebirthEvent:FireServer() 
            end) 
        end
        if Flags.AutoFreeGifts then pcall(function() for i=1,12 do ReplicatedStorage.Events.Rewards.ClaimeTaskEvent:FireServer(i) end end) end
        if Flags.AutoDailyRewards then pcall(function() for i=1,7 do ReplicatedStorage.Events.OnceDaily.SignEvent:FireServer(i) end end) end
        if Flags.AutoAchievements then pcall(function() ReplicatedStorage.Events.Achievement.GetAllEvent:FireServer() end) end
        if Flags.AutoEventCollect then pcall(function() for i=1,12 do ReplicatedStorage.Events.Activity.Mix.OnlineTime.GetEvent:FireServer(3, i) end end) end
        if Flags.AutoSpin then
             pcall(function()
                 local TT = ReplicatedStorage.Events.Turntable
                 for i = 1, 7 do TT.ChangeData:FireServer(i, "Claimed") end
                 TT["[C-S]GetRandom"]:InvokeServer()
             end)
        end
    end
end)

-- Module Hook
task.spawn(function()
    local M = player:WaitForChild("PlayerScripts", 10):WaitForChild("Managers")
    if M then
        local Managers = {M.ClientManager, M.ClientFollowManager, M.ClientCircleEftManager}
        for _, mod in pairs(Managers) do pcall(function() require(mod):Init() end) end
        RunService.RenderStepped:Connect(function(dt)
            if Flags.SmartFarm then
                pcall(function()
                    require(M.ClientFollowManager):Update(dt)
                    require(M.ClientCircleEftManager):Update(dt)
                end)
            end
        end)
    end
end)

-- Anti-Popup
player.PlayerGui.DescendantAdded:Connect(function(d)
    if Flags.AntiPopup and d:IsA("TextLabel") and (d.Text:find("insufficient") or d.Text:find("limit")) then
        if d.Parent then d.Parent.Visible = false end
    end
end)

_G.NebubloxCapture = { Window = Window }
ANUI:Notify({Title = "Nebublox", Content = "Systems Overclocked.", Icon = "zap", Duration = 3})