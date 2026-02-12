$p = "c:\Users\James\.gemini\antigravity\scratch\ANUI-Library\loader.lua"
$c = [System.IO.File]::ReadAllText($p)
$utf8noBOM = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($p, $c, $utf8noBOM)
