
filename = r"c:\Users\James\.gemini\antigravity\scratch\ANUI-Library\games\ANUI_source.lua"
keywords = ["Dropdown", "SetValues", "Refresh", "CreateWindow", "Section", "AddDropdown", "AddSection"]

try:
    with open(filename, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
        print(f"File length: {len(content)}")
        
        for kw in keywords:
            index = content.lower().find(kw.lower())
            if index != -1:
                print(f"Found '{kw}' at index {index}")
                start = max(0, index - 50)
                end = min(len(content), index + 100)
                print(f"Context: {content[start:end]!r}")
            else:
                print(f"'{kw}' NOT found")
                
        print("\nLast 500 chars:")
        print(content[-500:])
except Exception as e:
    print(f"Error: {e}")
