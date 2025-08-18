#!/usr/bin/env python3

import os
import re
import glob

def fix_with_opacity_in_file(file_path):
    """Replace .withOpacity(value) with .withValues(alpha: value) in a file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Pattern to match .withOpacity(number) where number can be decimal
        pattern = r'\.withOpacity\(([0-9]*\.?[0-9]+)\)'
        replacement = r'.withValues(alpha: \1)'
        
        # Count matches before replacement
        matches = re.findall(pattern, content)
        if not matches:
            return 0
        
        # Replace all occurrences
        new_content = re.sub(pattern, replacement, content)
        
        # Write back to file
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"✅ Fixed {len(matches)} withOpacity calls in {file_path}")
        return len(matches)
    
    except Exception as e:
        print(f"❌ Error processing {file_path}: {e}")
        return 0

def main():
    """Fix all withOpacity calls in Dart files"""
    print("🔧 Fixing deprecated withOpacity calls...")
    
    # Find all Dart files in lib directory
    dart_files = glob.glob('lib/**/*.dart', recursive=True)
    
    total_fixes = 0
    files_processed = 0
    
    for file_path in dart_files:
        fixes = fix_with_opacity_in_file(file_path)
        if fixes > 0:
            total_fixes += fixes
            files_processed += 1
    
    print(f"\n🎉 Complete!")
    print(f"📊 Fixed {total_fixes} withOpacity calls across {files_processed} files")
    print(f"🚀 Your app is now using the modern withValues API!")

if __name__ == "__main__":
    main()
