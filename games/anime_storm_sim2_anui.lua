-- // NEBUBLOX | ANIME STORM SIMULATOR 2 (Simplified Teleport) //
-- // UI Library: ANUI //

local ANUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ANHub-Script/ANUI/refs/heads/main/dist/main.lua"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

-- // 1. CONFIGURATION //
local Flags = {
    -- Auto Farm / Teleport
    SmartFarm = false, -- New Logic
    
    AutoTrial = false,        -- Joins the trial
    AutoTrialFarm = false,    -- Teleports inside the trial
    
    -- Boss Rush
    BossRushDBZ = false, BossRushJJK = false,
    
    -- Gacha
    OnePieceFruit = false, OnePieceCrew = false,
    DbzSaiyan = false,
    NarutoKekkeiGenkai = false, NarutoClan = false, NarutoTailedBeast = false,
    JjkDomain = false,
    
    -- Progression
    KiProgression = false, CursedProgression = false
}

-- Settings
local Settings = {
    TrialDebounce = false
}

-- // Helper: MakeProfile //
local function MakeProfile(config) return config end

-- // 2. WINDOW CREATION //
local Window = ANUI:CreateWindow({
    Title = "Nebublox", 
    Author = "by He Who Remains Lil'Nug",
    Folder = "Nebublox",
    Icon = "rbxassetid://121698194718505", -- User Avatar
    IconSize = 44,
    
    Theme = "Dark", 
    Transparent = false,
    SideBarWidth = 200,
    HasOutline = true,
})

-- // 3. PROFILE SETUP //
-- // 3. PROFILE SETUP //
local NugProfile = MakeProfile({
    -- Reverting to valid user-provided Asset IDs (Discord placeholders)
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

-- [TAB 2: TELEPORT]
local TeleportTab = Window:Tab({ Title = "Teleport", Icon = "map-pin", SidebarProfile = false })
local FarmSection = TeleportTab:Section({ Title = "Smart Farm", Icon = "zap", Opened = true })

-- Local Dropdown Variable (Safer)
local TargetDropdown = FarmSection:Dropdown({
    Title = "Enemy List",
    Multi = true, -- Reverted to true for flexibility
    Required = false,
    Values = { {Title = "Refresh to load...", Icon = "loader"} },
    Callback = function(val) 
        -- Optional: Logic to target specific selected mob could go here
    end
})

FarmSection:Button({
    Title = "Refresh Enemies",
    Callback = function()
        -- Manually trigger the refresh logic from the bottom of script
        local validEnemies = {}
        local seen = {}
        local npcFolder = Workspace:FindFirstChild("Npc")
        if npcFolder then
            for _, mob in ipairs(npcFolder:GetDescendants()) do
                if mob:IsA("Model") and mob:FindFirstChild("Humanoid") then
                   if not seen[mob.Name] then
                       table.insert(validEnemies, {Title = mob.Name, Icon = "swords"}) 
                       seen[mob.Name] = true
                   end
                end
            end
        end
        table.sort(validEnemies, function(a, b) return a.Title < b.Title end)
        
        if TargetDropdown and TargetDropdown.SetValues then
            TargetDropdown:SetValues(validEnemies)
            ANUI:Notify({Title = "Scanned", Content = "Found " .. #validEnemies .. " mobs", Icon = "check", Duration = 2})
        else
             ANUI:Notify({Title = "Error", Content = "Dropdown not found!", Icon = "alert-triangle", Duration = 3})
        end
    end
})

FarmSection:Toggle({
    Title = "Enable Smart Tween Farm",
    Desc = "Auto targets & attacks enemies",
    Value = false,
    Callback = function(state) Flags.SmartFarm = state end
})

-- [SECTION: TRIALS] (Moved under Teleport)
local TrialSection = TeleportTab:Section({ Title = "Auto Trial", Icon = "skull", Opened = false })

TrialSection:Toggle({
    Title = "Auto Join Trial (XX:15 & XX:45)",
    Desc = "Auto-clicks join button when trial starts",
    Value = false,
    Callback = function(state) Flags.AutoTrial = state end
})

TrialSection:Toggle({
    Title = "Auto Kill Trial Mobs",
    Desc = "Teleports to ANY mob inside the trial room",
    Value = false,
    Callback = function(state) Flags.AutoTrialFarm = state end
})

-- [TAB 4: BOSS RUSH]
local BossTab = Window:Tab({ Title = "Boss Rush", Icon = "swords", SidebarProfile = false })
local BossSection = BossTab:Section({ Title = "Auto Farm Loops", Icon = "repeat", Opened = true })
BossSection:Toggle({ Title = "Auto DBZ Boss Rush", Value = false, Callback = function(state) Flags.BossRushDBZ = state end })
BossSection:Toggle({ Title = "Auto JJK Boss Rush", Value = false, Callback = function(state) Flags.BossRushJJK = state end })

-- [TAB 5: GACHA]
local GachaTab = Window:Tab({ Title = "Gacha", Icon = "gift", SidebarProfile = false })
local OPSection = GachaTab:Section({ Title = "One Piece", Icon = "anchor", Opened = true })
OPSection:Toggle({ Title = "Auto Roll Fruits", Value = false, Callback = function(s) Flags.OnePieceFruit = s end })
OPSection:Toggle({ Title = "Auto Roll Crews", Value = false, Callback = function(s) Flags.OnePieceCrew = s end })

local DBZSection = GachaTab:Section({ Title = "Dragon Ball", Icon = "zap", Opened = false })
DBZSection:Toggle({ Title = "Auto Roll Saiyan", Value = false, Callback = function(s) Flags.DbzSaiyan = s end })
DBZSection:Toggle({ Title = "Auto Ki Progression", Value = false, Callback = function(s) Flags.KiProgression = s end })

local NarutoSection = GachaTab:Section({ Title = "Naruto", Icon = "eye", Opened = false })
NarutoSection:Toggle({ Title = "Auto Roll Kekkei Genkai", Value = false, Callback = function(s) Flags.NarutoKekkeiGenkai = s end })
NarutoSection:Toggle({ Title = "Auto Roll Clans", Value = false, Callback = function(s) Flags.NarutoClan = s end })
NarutoSection:Toggle({ Title = "Auto Roll Tailed Beasts", Value = false, Callback = function(s) Flags.NarutoTailedBeast = s end })

local JJKSection = GachaTab:Section({ Title = "Jujutsu Kaisen", Icon = "flame", Opened = false })
JJKSection:Toggle({ Title = "Auto Roll Domains", Value = false, Callback = function(s) Flags.JjkDomain = s end })
JJKSection:Toggle({ Title = "Auto Cursed Energy", Value = false, Callback = function(s) Flags.CursedProgression = s end })

-- [TAB 6: STATS & MISC]
local StatsTab = Window:Tab({ Title = "Misc", Icon = "layout-grid", SidebarProfile = false })
local ProgSection = StatsTab:Section({ Title = "Automation", Icon = "cpu", Opened = true })

ProgSection:Toggle({
    Title = "Auto Rebirth",
    Desc = "Automatically ranks up when ready",
    Value = false,
    Callback = function(state) Flags.AutoRebirth = state end
})

ProgSection:Toggle({
    Title = "Auto Claim Timed Rewards",
    Desc = "Claims playtime rewards automatically",
    Value = false,
    Callback = function(state) Flags.AutoTimedRewards = state end
})

-- // 5. LOGIC (The Brains) //

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
if not Remotes then
    ANUI:Notify({Title = "Error", Content = "Remotes failed to load. Re-execute!", Icon = "alert-triangle", Duration = 5})
    return -- Stop the script from running further
end
local SpecialPerkRemote = Remotes and Remotes:WaitForChild("SpecialPerkRemotes"):WaitForChild("SpecialPerk")
local SpecialProgressionRemote = Remotes and Remotes:WaitForChild("SpecialProgression")
local RebirthRemote = Remotes and Remotes:WaitForChild("Rebirth")
local TimedRewardsRemote = Remotes and Remotes:WaitForChild("TimedRewards")

-- [SMART TARGET FINDER] --
local function GetSmartTarget()
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local bestTarget = nil
    local shortestDist = 999999
    
    -- Helper to get folder safely
    local function GetFolder(...)
        local current = Workspace
        for _, name in ipairs({...}) do
            current = current:FindFirstChild(name)
            if not current then return nil end
        end
        return current
    end

    -- User's specific target folders
    local possibleFolders = {
        GetFolder("Npc", "Dbz"),
        GetFolder("Npc", "Jjk"),
        GetFolder("Npc", "Naruto"),
        GetFolder("Npc", "OnePiece"),
        GetFolder("Npc"), 
        GetFolder("TrialRoomNpc", "EasyTrial"),
    }
    
    -- Filter out nils so ipairs doesn't stop early
    local scanFolders = {}
    for _, f in pairs(possibleFolders) do
        if f then table.insert(scanFolders, f) end
    end
    
    for _, folder in ipairs(scanFolders) do
        -- Use GetDescendants to capture nested mobs (e.g. Dbz -> Container -> Raditz)
        for _, mob in ipairs(folder:GetDescendants()) do 
             -- Basic sanity check for a mob
             if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                if mob.Humanoid.Health > 0 then
                    local dist = (mob.HumanoidRootPart.Position - myRoot.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        bestTarget = mob
                    end
                end
             end
        end
    end
    
    return bestTarget
end

-- Boss Spawns (Static)
local function GetBossSpawn(mode)
    local maps = Workspace:FindFirstChild("Maps")
    if not maps then return nil end
    if mode == "Jjk" and maps:FindFirstChild("JjkBossRush") then return maps.JjkBossRush.NpcSpawns.Boss end
    if mode == "Dbz" and maps:FindFirstChild("dbzBossRush") then return maps.dbzBossRush.NpcSpawns.Boss end
    return nil
end

-- Loop 1: Physics (Speed Lock)
RunService.RenderStepped:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        if player.Character.Humanoid.WalkSpeed ~= 70 then player.Character.Humanoid.WalkSpeed = 70 end
    end
end)

-- Loop 2: Movement & Attack Logic
task.spawn(function()
    local currentTween = nil
    
    while task.wait(0.1) do 
        pcall(function()
            local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            
            -- PRIORITY 1: BOSS RUSH (Overrides Smart Farm)
            if Flags.BossRushDBZ or Flags.BossRushJJK then
                -- Cancel any active tween so we don't fight physics
                if currentTween then currentTween:Cancel() currentTween = nil end
                
                local targetCFrame = nil
                if Flags.BossRushDBZ then 
                    local s = GetBossSpawn("Dbz"); if s then targetCFrame = s.CFrame * CFrame.new(0,0,2) end
                elseif Flags.BossRushJJK then
                    local s = GetBossSpawn("Jjk"); if s then targetCFrame = s.CFrame * CFrame.new(0,0,2) end
                end
                 
                if targetCFrame then
                     myRoot.CFrame = targetCFrame
                     myRoot.AssemblyLinearVelocity = Vector3.zero
                     
                     -- Attack
                     VirtualUser:CaptureController()
                     VirtualUser:ClickButton1(Vector2.new())
                end

            -- PRIORITY 2: SMART FARM (Only runs if Boss Rush is OFF)
            elseif Flags.SmartFarm then
                local target = GetSmartTarget()
                if target and target:FindFirstChild("HumanoidRootPart") then
                    local targetPos = target.HumanoidRootPart.CFrame * CFrame.new(0, 5, 2)
                    local dist = (targetPos.Position - myRoot.Position).Magnitude
                    
                    -- Only tween if we are far away (>5 studs) to prevent stuttering
                    if dist > 5 then
                        local tweenInfo = TweenInfo.new(
                            dist / 60, -- Speed
                            Enum.EasingStyle.Linear
                        )
                        -- Only create a new tween if one isn't playing or target changed wildly
                        -- (Simplified for stability: Overwrite is safer than checking PlaybackState in loops)
                        if currentTween then currentTween:Cancel() end
                        currentTween = TweenService:Create(myRoot, tweenInfo, {CFrame = targetPos})
                        currentTween:Play()
                    else
                        -- Close enough: Stop tween and hold position
                        if currentTween then currentTween:Cancel() currentTween = nil end
                        myRoot.CFrame = targetPos
                        myRoot.AssemblyLinearVelocity = Vector3.zero 
                    end
                    
                    -- Attack if close
                    if dist < 20 then
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new())
                    end
                else
                    -- No target? Stop moving.
                    if currentTween then currentTween:Cancel() currentTween = nil end
                end
            else
                -- If nothing is enabled, cancel tween so user can walk
                if currentTween then currentTween:Cancel() currentTween = nil end
            end
        end)
    end
end)

-- Loop 3: Server Actions
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            -- BOSS START
            local BossRushRemote = Remotes:FindFirstChild("BossRush"):FindFirstChild("BossRushRemote")
            local BossRushStart = Remotes:FindFirstChild("BossRush"):FindFirstChild("BossRushStart")
            
            if BossRushRemote and BossRushStart then
                if Flags.BossRushDBZ then
                    BossRushRemote:FireServer("OpenBossRushFrame", "DbzBossRush")
                    BossRushStart:FireServer("StartUi", "DbzBossRush")
                end
                if Flags.BossRushJJK then
                    BossRushRemote:FireServer("OpenBossRushFrame", "JjkBossRush")
                    BossRushStart:FireServer("StartUi", "JjkBossRush")
                end
            end

            -- GACHA
            if SpecialPerkRemote then
                local function Roll(name) SpecialPerkRemote:FireServer("Spin", name) end
                if Flags.OnePieceFruit then Roll("OnePieceFruit") end
                if Flags.OnePieceCrew then Roll("OnePieceCrew") end
                if Flags.DbzSaiyan then Roll("DbzSaiyan") end
                if Flags.NarutoKekkeiGenkai then Roll("NarutoKekkeiGenkai") end
                if Flags.NarutoClan then Roll("NarutoClan") end
                if Flags.NarutoTailedBeast then Roll("NarutoTailedBeast") end
                if Flags.JjkDomain then Roll("JjkDomain") end
            end
            
            if SpecialProgressionRemote then
                if Flags.KiProgression then SpecialProgressionRemote:FireServer("UpgradeProgression", "KiProgression") end
                if Flags.CursedProgression then SpecialProgressionRemote:FireServer("UpgradeProgression", "CursedEnergyProgression") end
            end

            -- MISC AUTOMATION
            if Flags.AutoRebirth and RebirthRemote then
                RebirthRemote:FireServer("Rebirth")
            end
            
            if Flags.AutoTimedRewards and TimedRewardsRemote then
                -- Attempt to use the game's config to get exact keys
                local success, config = pcall(function() 
                    return require(ReplicatedStorage.Configs.TimedRewardsConfig) 
                end)
                
                if success and config then
                    for key, _ in pairs(config) do
                        TimedRewardsRemote:FireServer(key)
                    end
                else
                    -- Fallback if require fails (e.g. some executors)
                    for i = 1, 12 do 
                        TimedRewardsRemote:FireServer(tostring(i))
                        TimedRewardsRemote:FireServer("Reward" .. i)
                    end
                end
            end
            
            
            -- AUTO TRIAL JOIN (XX:14/44 Check)
            if Flags.AutoTrial then
                local date = os.date("!*t")
                local isTime = (date.min == 14 or date.min == 44 or date.min == 15 or date.min == 45)
                
                if isTime and not Settings.TrialDebounce then
                    local tt = Remotes:FindFirstChild("TimeTrial")
                    if tt and tt:FindFirstChild("UpdateUi") then
                        tt.UpdateUi:FireServer("JoinTrial", "EasyTrial")
                        Settings.TrialDebounce = true
                        
                        -- Auto Confirm Button Click
                        task.delay(1, function()
                             local gui = player.PlayerGui:FindFirstChild("GuiHandler")
                             if gui then
                                 local prompt = gui:FindFirstChild("EasyTrial") or gui:FindFirstChild("GamemodeWarning")
                                 if prompt and prompt:FindFirstChild("Buttons") then
                                     firesignal(prompt.Buttons.Confirm.MouseButton1Up)
                                 end
                             end
                        end)
                        task.delay(120, function() Settings.TrialDebounce = false end)
                    end
                end
            end
        end)
    end
end)

-- // 6. ANTI-AFK //
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Automatically refresh the enemy list on load so the user doesn't have to click it


ANUI:Notify({Title = "Nebublox", Content = "Script Loaded!", Icon = "check", Duration = 5})
