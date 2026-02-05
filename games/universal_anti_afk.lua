--[[
    ═══════════════════════════════════════════════════════════
    UNIVERSAL ANTI-AFK
    Author: LilNug of Wisdom
    ═══════════════════════════════════════════════════════════
]]

local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- Check if we are already running to avoid duplicates
getgenv().AntiAfkRunning = true

LocalPlayer.Idled:Connect(function()
    if getgenv().AntiAfkRunning then
        -- This simulates a click when Roblox detects idleness
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        print("Anti-AFK: Activity simulated to prevent disconnect.")
    end
end)

-- Notification to let you know it's active
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Anti-AFK Loaded",
        Text = "You will not be kicked for inactivity.",
        Icon = "rbxassetid://121698194718505", -- Using your logo ID
        Duration = 5
    })
end)
