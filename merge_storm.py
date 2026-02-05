import os

# Paths
ui_path = "C:/Users/James/.gemini/antigravity/scratch/ANUI-Library/nebublox_ui.lua"
game_path = "C:/Users/James/.gemini/antigravity/scratch/ANUI-Library/games/anime_storm_sim2.lua"
output_path = "C:/Users/James/.gemini/antigravity/scratch/ANUI-Library/games/anime_storm_sim2_combined.lua"

try:
    with open(ui_path, "r", encoding="utf-8") as f:
        ui_content = f.read()

    with open(game_path, "r", encoding="utf-8") as f:
        game_content = f.read()

    # Prepare game content by removing the loadstring block
    # We look for the specific block lines 24-28 approx
    # "local success, ANUI = pcall(function()"
    
    game_lines = game_content.splitlines()
    new_game_lines = []
    skip = False
    
    for line in game_lines:
        if "local success, ANUI = pcall(function()" in line:
            skip = True
        
        if not skip:
            new_game_lines.append(line)
            
        if "end)" in line and skip:
            skip = False
            # Check if next line is the error check and skip it too
            continue
            
        if "if not success or not ANUI then" in line and not skip:
             # This line might have been skipped if it was part of the block, 
             # but if it was separate, we skip it manually
             continue

    # Reconstruct game content
    # We need to manually inject the ANUI initialization where the loadstring was
    # Actually, simpler approach:
    # 1. Paste UI Lib
    # 2. Add "local ANUI = a.load('Z')"
    # 3. Paste Game Script (minus the loadstring part)

    cleaned_game_content = ""
    skip_block = False
    
    for line in game_lines:
        if "-- // UI LOAD //" in line:
            continue
        if "local success, ANUI = pcall(function()" in line:
            skip_block = True
            continue
        if skip_block and "end)" in line:
            skip_block = False
            continue
        if "if not success or not ANUI then" in line:
            continue
            
        if not skip_block:
            cleaned_game_content += line + "\n"

    final_content = f"""{ui_content}

-- // UI INITIALIZATION //
local ANUI = a.load('Z')

-- // GAME SCRIPT //
{cleaned_game_content}
"""

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(final_content)

    print(f"Successfully merged to {output_path}")

except Exception as e:
    print(f"Error: {e}")
