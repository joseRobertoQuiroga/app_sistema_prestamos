import json
import sys
import collections

def parse():
    filename = 'analysis.json'
    content = ""
    try:
        with open(filename, 'r', encoding='utf-16-le') as f:
            content = f.read()
    except:
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"Error reading file: {e}")
            return

    try:
        data = json.loads(content)
    except json.JSONDecodeError:
        # Sometimes list is not wrapped in [], or multiple objects
        # flutter analyze --machine outputs a list of objects?
        # Docs say: "[{...}, {...}]"
        print("JSON Decode Error. Trying to fix...")
        # If it's empty, return
        if not content.strip():
            print("File is empty")
            return
        print(f"Content excerpt: {content[:100]}")
        return

    # Filter errors
    errors = [item for item in data if item.get('severity') == 'ERROR']
    infos = [item for item in data if item.get('severity') == 'INFO']
    
    print(f"Total Issues: {len(data)}")
    print(f"Errors: {len(errors)}")
    print(f"Infos: {len(infos)}")
    
    if errors:
        print("\n--- CRITICAL ERRORS ---")
        by_file = collections.defaultdict(list)
        for e in errors:
            by_file[e.get('file', 'unknown')].append(e)
            
        for f, errs in by_file.items():
            print(f"\nFILE: {f}")
            for e in errs:
                print(f"  Line {e.get('startLine')}: {e.get('type')} - {e.get('code')} - {e.get('problemMessage')}")

if __name__ == '__main__':
    parse()
