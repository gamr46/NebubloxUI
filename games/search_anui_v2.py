
filename = r"c:\Users\James\.gemini\antigravity\scratch\ANUI-Library\games\ANUI_source.lua"
targets = ["Dropdown={", ":Dropdown", "SetValues", "Refresh", "Update", "Set"]

try:
    with open(filename, "rb") as f:
        content_bytes = f.read()
        content = content_bytes.decode("utf-8", errors="ignore")
        
        print(f"File length: {len(content)}")
        
        for t in targets:
            index = content.find(t)
            if index != -1:
                print(f"\n--- Found '{t}' at index {index} ---")
                start = max(0, index - 100)
                end = min(len(content), index + 500)
                print(content[start:end])
            else:
                print(f"'{t}' NOT found")

except Exception as e:
    print(f"Error: {e}")
