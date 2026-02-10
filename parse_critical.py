import re
import sys
import collections

def parse():
    filename = 'critical_errors.txt'
    content = ""
    try:
        with open(filename, 'r', encoding='utf-16-le') as f:
            content = f.read()
    except:
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                content = f.read()
        except:
             try:
                with open(filename, 'r', encoding='cp1252') as f:
                    content = f.read()
             except Exception as e:
                print(f"Error reading file: {e}")
                return

    # Extract lines with "error"
    # Format: "   error - Message at lib/file.dart:10:5 - code"
    # or "error • Message • lib/file.dart:10:5 • code"
    
    # We want to group by FILE
    
    files_with_errors = collections.defaultdict(list)
    
    lines = content.splitlines()
    print(f"Total lines read: {len(lines)}")
    
    # Simple heuristic: look for "lib/"
    path_pattern = re.compile(r'(lib/[a-zA-Z0-9_./]+\.dart):(\d+):(\d+)')
    
    for line in lines:
        if "info -" in line or "info •" in line:
            continue # Skip infos as requested
            
        if "error" in line.lower():
            match = path_pattern.search(line)
            if match:
                path = match.group(1)
                line_num = match.group(2)
                # Cleanup message
                msg = line.strip()
                files_with_errors[path].append(f"{line_num}: {msg}")

    print(f"\nFiles with Critical Errors: {len(files_with_errors)}")
    for path, errors in files_with_errors.items():
        print(f"\nFILE: {path} ({len(errors)} errors)")
        for e in errors[:3]: # Show first 3 per file
            print(f"  {e}")

if __name__ == '__main__':
    parse()
