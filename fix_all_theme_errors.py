#!/usr/bin/env python3

import re
import os
import glob

def fix_file_errors(file_path):
    """Fix all theme and const errors in a single file"""
    try:
        with open(file_path, 'r') as f:
            content = f.read()
        
        original_content = content
        
        # Fix const const duplication
        content = re.sub(r'\bconst const\b', 'const', content)
        
        # Fix theme variable references that are incorrectly declared
        content = re.sub(r'final theme = theme;', 'final theme = Theme.of(context);', content)
        
        # Fix theme usage before declaration issues by ensuring context is available
        content = re.sub(r'(?<!Theme\.of\(context\)\.)(?<!final )(?<!\.\s*)theme\.(?!of\()', 'Theme.of(context).', content)
        
        # Fix widget construction issues
        content = re.sub(r'return const Padding\(padding: const', 'return Padding(padding: const', content)
        content = re.sub(r'return const SizedBox\(', 'return SizedBox(', content)
        content = re.sub(r'return const Text\(', 'return Text(', content)
        content = re.sub(r'return const Column\(', 'return Column(', content)
        content = re.sub(r'return const Row\(', 'return Row(', content)
        content = re.sub(r'return const Container\(', 'return Container(', content)
        
        # Fix invalid constant expressions in string interpolation
        content = re.sub(r'const Text\(\'[^\']*\$[^\']*\'\)', lambda m: m.group(0).replace('const ', ''), content)
        
        # Fix switch and condition statement formatting
        content = re.sub(r'const\s+SizedBox\(\s*width:\s*\d+\s*,\s*height:\s*\d+\s*,\s*child:\s*CircularProgressIndicator\(', 
                        'SizedBox(\n                              width: 20,\n                              height: 20,\n                              child: CircularProgressIndicator(', content)
        
        # Write back if changes were made
        if content != original_content:
            with open(file_path, 'w') as f:
                f.write(content)
            print(f"Fixed: {file_path}")
            return True
        return False
        
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def main():
    """Fix errors in all relevant Flutter files"""
    
    # Target files with theme/const issues
    target_patterns = [
        "/Users/ronos/development/FlowSense/lib/features/biometric/**/*.dart",
        "/Users/ronos/development/FlowSense/lib/features/cycle/**/*.dart", 
        "/Users/ronos/development/FlowSense/lib/core/routing/*.dart",
        "/Users/ronos/development/FlowSense/lib/core/widgets/*.dart"
    ]
    
    files_fixed = 0
    total_files = 0
    
    for pattern in target_patterns:
        for file_path in glob.glob(pattern, recursive=True):
            if file_path.endswith('.dart'):
                total_files += 1
                if fix_file_errors(file_path):
                    files_fixed += 1
    
    print(f"\nCompleted: Fixed {files_fixed} out of {total_files} files")

if __name__ == "__main__":
    main()
