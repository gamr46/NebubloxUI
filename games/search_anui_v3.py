
filename = r"c:\Users\James\.gemini\antigravity\scratch\ANUI-Library\games\ANUI_source.lua"
targets = ["Dropdown={", ":Dropdown", "SetValues", "Refresh", "Update", "Set"]
outfile = r"c:\Users\James\.gemini\antigravity\scratch\ANUI-Library\games\search_output.txt"

try:
    with open(filename, "rb") as f:
        content_bytes = f.read()
        content = content_bytes.decode("utf-8", errors="ignore")
        
    with open(outfile, "w", encoding="utf-8") as out:
        out.write(f"File length: {len(content)}\n")
        
        for t in targets:
            index = content.find(t)
            if index != -1:
                out.write(f"\n--- Found '{t}' at index {index} ---\n")
                start = max(0, index - 200)
                end = min(len(content), index + 1000)
                context = content[start:end]
                # Replace newlines with space to separate logic if minified
                out.write(context)
                out.write("\n")
            else:
                out.write(f"'{t}' NOT found\n")

except Exception as e:
    with open(outfile, "w") as out:
        out.write(f"Error: {e}")
