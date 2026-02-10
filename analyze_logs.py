import sys
import re
import collections

if len(sys.argv) > 1:
    filename = sys.argv[1]
else:
    filename = 'analysis_errors_last.txt'

try:
    with open(filename, 'r', encoding='utf-16-le') as f:
        lines = f.readlines()
except:
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except:
        try:
             with open(filename, 'r', encoding='cp1252') as f:
                 lines = f.readlines()
        except Exception as e:
            print(f"Error reading file: {e}")
            sys.exit(1)

print(f"Total lines: {len(lines)}")

# Regex to find severity and code
# Line format: "   info - Message at path:line:col - error_code"
# We want to extract 'info' and 'error_code'

pattern = re.compile(r'\s*(error|warning|info)\s*-\s*.*-\s*([a-z_]+)\s*$')

counts = collections.Counter()
by_severity = collections.Counter()

for line in lines:
    match = pattern.search(line)
    if match:
        severity = match.group(1)
        code = match.group(2)
        counts[code] += 1
        by_severity[severity] += 1
        
        if severity == 'error':
            print(f"ERROR: {line.strip()}")
            
    elif "error" in line.lower() and "Analyzing" not in line:
         # Fallback for lines that don't match pattern but look like errors
         counts["unknown_format"] += 1

print("\n--- Severity Breakdown ---")
for sev, count in by_severity.items():
    print(f"{sev}: {count}")

print("\n--- Top Error Codes ---")
for code, count in counts.most_common(20):
    print(f"{count}: {code}")
