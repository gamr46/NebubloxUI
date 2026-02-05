# Add Anti-AFK to combined script
with open(r'games\anime_capture_combined.lua', 'r', encoding='utf-8') as f:
    content = f.read()

# Find the insertion point
insert_marker = 'getgenv().NebubloxInstance = Window'
insert_pos = content.find(insert_marker)

if insert_pos == -1:
    print("ERROR: Could not find insertion point!")
    exit(1)

# Move to end of that line
insert_pos = content.find('\n', insert_pos) + 1

# Anti-AFK code to insert
anti_afk_code = '''
-- // UNIVERSAL ANTI-AFK //
getgenv().AntiAfkRunning = true
player.Idled:Connect(function()
    if getgenv().AntiAfkRunning then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        print("Anti-AFK: Activity simulated to prevent disconnect.")
    end
end)
'''

# Insert the code
new_content = content[:insert_pos] + anti_afk_code + content[insert_pos:]

# Write back
with open(r'games\anime_capture_combined.lua', 'w', encoding='utf-8') as f:
    f.write(new_content)

print("✓ Anti-AFK code added successfully!")
print(f"✓ New file size: {len(new_content)} bytes")
