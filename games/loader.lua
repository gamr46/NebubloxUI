-- // NEBUBLOX LOADER //
-- Share this script with others. Keep the main source code private!

local ScriptUrl = "https://raw.githubusercontent.com/YourUsername/YourRepo/main/anime_capture_obfuscated.lua"

-- Use pcall to catch errors if the specific URL fails
local success, err = pcall(function()
    loadstring(game:HttpGet(ScriptUrl))()
end)

if not success then
    warn("Failed to load Nebublox:", err)
    -- Optional: Kick player or show notification
    game.StarterGui:SetCore("SendNotification", {
        Title = "Nebublox Error";
        Text = "Failed to load script. Check your internet or update the script.";
        Duration = 5;
    })
end
