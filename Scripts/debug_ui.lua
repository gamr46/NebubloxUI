local ANUI_URL = "https://raw.githubusercontent.com/ANHub-Script/ANUI/refs/heads/main/dist/main.lua"
local s, r = pcall(function() return game:HttpGet(ANUI_URL) end)
if not s then warn("Failed to fetch ANUI") return end

local ANUI = loadstring(r)()
local Window = ANUI:CreateWindow({Title="Debug UI", Author="Test", Folder="Test"})
local Tab = Window:Tab({Title="Locked Tab", Icon="lock", Locked=true})

warn("--- [UI DEBUG START] ---")
print("Tab Object:", Tab)

if type(Tab) == "table" then
    print("Listing Tab Keys:")
    for k,v in pairs(Tab) do 
        print(" > ", k, ":", tostring(v)) 
    end
else
    warn("Tab is NOT a table:", type(Tab))
end

print("Test 1: :Unlock()...")
if Tab.Unlock then
    local s, e = pcall(function() Tab:Unlock() end)
    print(" > Result:", s, "Error:", e)
else
    warn(" > method :Unlock() missing!")
end

print("Test 2: .Locked = false...")
Tab.Locked = false
print(" > Property set.")

warn("--- [UI DEBUG END] ---")
warn("CHECK IF THE 'LOCKED TAB' IS NOW CLICKABLE!")
