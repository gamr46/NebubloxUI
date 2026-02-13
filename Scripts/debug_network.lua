-- [[ NEBUBLOX DEEP DIAGNOSTIC ]]
local HttpService = game:GetService("HttpService")
local Analytics = game:GetService("RbxAnalyticsService")
local StarterGui = game:GetService("StarterGui")

warn("--- [DEEP DIAGNOSTIC START] ---")

-- 1. Try to get HWID (Production Method)
print("Step 1: Retrieving HWID...")
local hwid = "UNKNOWN_HWID"
local hwid_success, hwid_result = pcall(function()
    return (gethwid and gethwid() or Analytics:GetClientId())
end)

if hwid_success then
    print("✅ HWID Retrieved:", tostring(hwid_result))
    hwid = tostring(hwid_result)
else
    warn("❌ HWID Retrieval Failed:", tostring(hwid_result))
    hwid = "FALLBACK_HWID"
end

-- 2. Try Connection with HWID
local url = "https://darkmatterv1.onrender.com/api/verify_key?key=DEBUG_TEST&hwid=" .. hwid
print("Step 2: Requesting URL:", url)

local conn_success, conn_result = pcall(function()
    return game:HttpGet(url)
end)

if conn_success then
    warn("✅ CONNECTION SUCCESS!")
    print("Response:", conn_result)
    StarterGui:SetCore("SendNotification", {Title="Debug Success", Text="Check Console F9", Duration=5})
else
    warn("❌ CONNECTION FAILED!")
    warn("Error:", conn_result)
    StarterGui:SetCore("SendNotification", {Title="Debug Failed", Text=tostring(conn_result), Duration=10})
end

warn("--- [DEEP DIAGNOSTIC END] ---")
