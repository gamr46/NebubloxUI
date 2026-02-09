-- // NEBUBLOX | ANIME STORM 2 | AUTO EASY TRIAL //
-- // Author: Nebublox Team //

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local TimeTrial = Remotes:WaitForChild("TimeTrial")
local UpdateUi = TimeTrial:WaitForChild("UpdateUi")
local TrialEffects = TimeTrial:WaitForChild("TrialEffects")

getgenv().AutoEasyTrial = not getgenv().AutoEasyTrial

if not getgenv().AutoEasyTrial then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Nebublox",
        Text = "Auto Easy Trial DISABLED",
        Duration = 3
    })
    return
end

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Nebublox",
    Text = "Auto Easy Trial ENABLED",
    Duration = 3
})

-- // 1. CONFIGURATION //
local TRIAL_MAP_PREFIX = "EasyTrial" 
-- Mobs are usually in workspace.Maps.EasyTrial.EasyTrial1.NpcSpawns.Mob

-- // 2. AUTO JOIN //
local function EnableAutoJoin()
    TrialEffects.OnClientEvent:Connect(function(action, trialType)
        if not getgenv().AutoEasyTrial then return end
        
        if action == "NotifyBeforeStart" and trialType == "EasyTrial" then
            print("[Nebulox] Easy Trial Announced! Joining in 2s...")
            task.wait(2) 
            UpdateUi:FireServer("JoinTrial", "EasyTrial")
            
            -- Auto Confirm if GUI pops up
            task.delay(1, function()
                local gui = LocalPlayer.PlayerGui:FindFirstChild("GamemodeWarning")
                if gui and gui.Buttons and gui.Buttons.Confirm then
                    for _, c in pairs(getconnections(gui.Buttons.Confirm.MouseButton1Up)) do
                        c:Fire()
                    end
                end
            end)
        end
    end)
    print("[Nebulox] Auto Join Listener Active.")
end

-- // 3. TARGET FINDING //
local function GetTrialTarget()
    -- Find the active trial map
    local maps = Workspace:FindFirstChild("Maps")
    if not maps then return nil end
    
    local trialFolder = maps:FindFirstChild("EasyTrial")
    if not trialFolder then return nil end
    
    -- It might be named EasyTrial1, EasyTrial2...
    local activeMap = nil
    for _, child in ipairs(trialFolder:GetChildren()) do
        if child.Name:match("EasyTrial") then
            activeMap = child
            break
        end
    end
    
    if not activeMap then return nil end
    
    -- Find Mobs
    local npcSpawns = activeMap:FindFirstChild("NpcSpawns")
    local mobs = npcSpawns and npcSpawns:FindFirstChild("Mob")
    
    if not mobs then return nil end
    
    local bestTarget = nil
    local dist = math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then return nil end

    for _, mob in ipairs(mobs:GetChildren()) do
        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
            -- Optional: Prioritize bosses?
            local mag = (myRoot.Position - mob.HumanoidRootPart.Position).Magnitude
            if mag < dist then
                bestTarget = mob
                dist = mag
            end
        end
    end
    
    return bestTarget
end

-- // 4. ATTACK LOOP //
task.spawn(function()
    EnableAutoJoin()
    
    while task.wait() do
        if not getgenv().AutoEasyTrial then break end
        
        pcall(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            
            -- Check if we are physically in the trial context?
            -- Or just always check for trial mobs. If they exist, we farm them.
            -- To avoid teleporting from the lobby, we might check distance or relying on the user enabling it WHEN inside or to Join.
            
            local target = GetTrialTarget()
            if target then
                 local root = char.HumanoidRootPart
                 local tRoot = target.HumanoidRootPart
                 
                 -- Teleport Behind
                 root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
                 
                 -- Face Target
                 root.CFrame = CFrame.new(root.Position, tRoot.Position)
                 
                 -- Attack
                 VirtualUser:CaptureController()
                 VirtualUser:ClickButton1(Vector2.new())
                 
                 -- Physics freeze
                 root.AssemblyLinearVelocity = Vector3.zero
            end
        end)
    end
end)

-- Notify User
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Nebublox",
    Text = "Auto Easy Trial Enabled",
    Duration = 5
})
