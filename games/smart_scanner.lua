-- // NEBUBLOX | SMART ENEMY SCANNER //
-- // Reads Game Configs to get ALL Valid Enemies //

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NpcConfig = require(ReplicatedStorage.Configs:WaitForChild("NpcConfig"))

-- Function to get formatted list for UI Dropdown
getgenv().GetSmartEnemyList = function()
    local enemyList = {}
    local seen = {}
    
    -- Format: {Title = "Name", Icon = "rbxassetid://..."}
    
    for world, mobs in pairs(NpcConfig) do
        -- Check if it's a valid world table
        if type(mobs) == "table" then
            for mobKey, data in pairs(mobs) do
                -- Some entries might be metadata, filter for tables with DisplayName
                if type(data) == "table" and data.DisplayName then
                    local name = data.DisplayName
                    
                    if not seen[name] then
                        table.insert(enemyList, {
                            Title = name,
                            Icon = "swords", -- Default icon
                            -- Extra metadata for farming logic if needed
                            World = world,
                            Key = mobKey,
                            MaxHealth = data.MaxHealth
                        })
                        seen[name] = true
                    end
                end
            end
        end
    end
    
    -- Sort A-Z
    table.sort(enemyList, function(a, b) return a.Title < b.Title end)
    
    return enemyList
end

-- Debug Print
local list = getgenv().GetSmartEnemyList()
print("[Nebulox] Scanned " .. #list .. " enemies.")
for _, e in ipairs(list) do
    print(" - " .. e.Title .. " (" .. (e.World or "Unknown") .. ")")
end

-- Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Nebublox",
    Text = "Smart Scanner Loaded! Check Console (F9)",
    Duration = 5
})
