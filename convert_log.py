import sys

filename = 'final_analysis.txt'

try:
    with open(filename, 'r', encoding='utf-16-le') as f:
        content = f.read()
except:
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading: {e}")
        sys.exit(1)

with open('final_analysis_utf8.txt', 'w', encoding='utf-8') as f:
    f.write(content)

print("Converted to UTF-8")
