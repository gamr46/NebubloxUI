# Read the UI library
$lib = Get-Content 'nebublox_ui.lua' -Raw

# Read the game script
$gameRaw = Get-Content 'games\anime_capture.lua' -Raw
$gameLines = $gameRaw -split "`r?`n"

# Remove the loadstring block (lines 24-28)
$filteredLines = @()
$skipMode = $false

for ($i = 0; $i -lt $gameLines.Length; $i++) {
    $line = $gameLines[$i]
    
    # Start skipping at line 24 (0-indexed = 23)
    if ($i -eq 23) {
        $skipMode = $true
    }
    
    # Stop skipping after line 28 (0-indexed = 27)
    if ($i -gt 27) {
        $skipMode = $false
    }
    
    if (-not $skipMode) {
        $filteredLines += $line
    }
}

$gameFiltered = $filteredLines -join "`r`n"

# Combine: Library + Init Line + Game Script
$combined = $lib + "`r`n`r`nlocal ANUI = a.load('Z')`r`n`r`n" + $gameFiltered

# Write to output file
$combined | Set-Content 'games\anime_capture_combined.lua' -NoNewline

Write-Host "Combined script created successfully!"
Write-Host "Output: games\anime_capture_combined.lua"
