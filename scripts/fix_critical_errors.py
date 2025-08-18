#!/usr/bin/env python3

import os
import re
from pathlib import Path

def fix_tracking_summary_card():
    """Fix tracking summary card theme references and const issues."""
    print("🔧 Fixing tracking summary card...")
    
    file_path = 'lib/features/cycle/widgets/tracking_summary_card.dart'
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Add theme variable to build method
        if 'Widget build(BuildContext context)' in content and 'final theme = Theme.of(context);' not in content:
            content = re.sub(
                r'(@override\s+Widget build\(BuildContext context\)\s*{)',
                r'\1\n    final theme = Theme.of(context);',
                content
            )
        
        # Add theme to other widget methods that use theme
        widget_methods = ['_buildHeader', '_buildContent', '_buildStatistics']
        for method in widget_methods:
            pattern = f'Widget {method}\\([^{{]*\\)\\s*{{'
            if re.search(pattern, content) and f'{method}' in content:
                replacement = f'Widget {method}(BuildContext context) {{\n    final theme = Theme.of(context);'
                content = re.sub(pattern, replacement, content)
        
        # Fix invalid const expressions
        const_fixes = [
            (r'const Container\([^)]*theme\.[^}]*\)', lambda m: m.group(0).replace('const ', '')),
            (r'const\s+([^;]*theme[^;]*;)', r'\1'),
            (r'const\s+([^;]*Theme\.of\(context\)[^;]*;)', r'\1'),
        ]
        
        for pattern, replacement in const_fixes:
            content = re.sub(pattern, replacement, content)
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  ✅ Fixed {file_path}")

def fix_biometric_widgets():
    """Fix remaining biometric widgets."""
    print("🔧 Fixing biometric widgets...")
    
    widgets = [
        'lib/features/biometric/widgets/biometric_sync_status.dart',
        'lib/features/biometric/widgets/correlation_insights_card.dart',
        'lib/features/biometric/widgets/health_metrics_card.dart'
    ]
    
    for widget_path in widgets:
        if os.path.exists(widget_path):
            with open(widget_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Add theme to build method if missing
            if 'Widget build(BuildContext context)' in content:
                if 'final theme = Theme.of(context);' not in content:
                    content = re.sub(
                        r'(@override\s+Widget build\(BuildContext context\)\s*{)',
                        r'\1\n    final theme = Theme.of(context);',
                        content
                    )
            
            # Add theme to widget methods that need it
            widget_method_pattern = r'(Widget _build\w+\([^{]*\)\s*{)'
            content = re.sub(
                widget_method_pattern,
                r'\1\n    final theme = Theme.of(context);',
                content
            )
            
            # Remove invalid const expressions
            const_patterns = [
                (r'const\s+Container\([^)]*theme\.[^}]*\)', lambda m: m.group(0).replace('const ', '')),
                (r'const\s+([^;]*Theme\.of\(context\)[^;]*)', r'\1'),
                (r'const\s+(.*?)\s*\(\s*color:\s*theme\.[^)]*\)', r'\1(color: theme.'),
                (r'invalid_constant', ''),
                (r'const_with_non_const', ''),
            ]
            
            for pattern, replacement in const_patterns:
                if callable(replacement):
                    content = re.sub(pattern, replacement, content)
                else:
                    content = re.sub(pattern, replacement, content)
            
            with open(widget_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  ✅ Fixed {widget_path}")

def fix_cycle_phase_indicator():
    """Fix cycle phase indicator const issue."""
    print("🔧 Fixing cycle phase indicator...")
    
    file_path = 'lib/features/cycle/widgets/cycle_phase_indicator.dart'
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Remove const from expressions with dynamic values
        content = re.sub(r'const\s+([^;]*phase\.[^;]*)', r'\1', content)
        content = re.sub(r'const\s+([^;]*Colors\.[^;]*)', r'\1', content)
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  ✅ Fixed {file_path}")

def fix_remaining_withopacity():
    """Fix remaining withOpacity usage."""
    print("⚠️ Fixing remaining withOpacity usage...")
    
    dart_files = list(Path('lib').rglob('*.dart'))
    
    for file_path in dart_files:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        if '.withOpacity(' in content:
            content = re.sub(r'\.withOpacity\(([^)]+)\)', r'.withValues(alpha: \1)', content)
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)

def fix_unused_variables():
    """Remove common unused variables."""
    print("🧹 Removing unused variables...")
    
    dart_files = list(Path('lib').rglob('*.dart'))
    
    for file_path in dart_files:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        new_lines = []
        for line in lines:
            # Skip unused theme variables
            if 'final theme = theme;' in line:
                new_lines.append('    final theme = Theme.of(context);\n')
            elif re.search(r'final \w+ = [^;]+;\s*$', line) and 'unused' in line.lower():
                continue  # Skip obviously unused variables
            else:
                new_lines.append(line)
        
        if len(new_lines) != len(lines):
            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)

def main():
    print("🚀 Starting Critical Error Fixes...")
    print("=" * 50)
    
    # Change to project directory
    os.chdir('/Users/ronos/development/FlowSense')
    
    # Apply fixes
    fix_tracking_summary_card()
    fix_biometric_widgets()
    fix_cycle_phase_indicator() 
    fix_remaining_withopacity()
    fix_unused_variables()
    
    print("=" * 50)
    print("✅ Critical error fixes completed!")
    print("🔍 Run 'flutter analyze' to check remaining issues.")

if __name__ == "__main__":
    main()
