#!/usr/bin/env python3

import os
import re
import sys
from pathlib import Path

def fix_theme_references():
    """Fix undefined theme references by adding proper theme declarations."""
    print("🎨 Fixing theme references...")
    
    files_to_fix = [
        'lib/features/biometric/widgets/biometric_chart_widget.dart',
        'lib/features/biometric/widgets/biometric_sync_status.dart', 
        'lib/features/biometric/widgets/correlation_insights_card.dart',
        'lib/features/cycle/widgets/tracking_summary_card.dart'
    ]
    
    for file_path in files_to_fix:
        if os.path.exists(file_path):
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Check if theme is used but not declared
            if 'theme.' in content and 'final theme = ' not in content:
                # Find the build method and add theme declaration
                build_pattern = r'(@override\s+Widget build\(BuildContext context\)\s*{)'
                if re.search(build_pattern, content):
                    replacement = r'\1\n    final theme = Theme.of(context);'
                    content = re.sub(build_pattern, replacement, content)
                    
                    # Also add theme declarations in other widget methods
                    widget_method_pattern = r'(Widget _build\w+\([^{]*\)\s*{)'
                    content = re.sub(widget_method_pattern, r'\1\n    final theme = Theme.of(context);', content)
                    
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    print(f"  ✅ Fixed theme references in {file_path}")

def fix_auth_service_methods():
    """Fix missing authentication service methods."""
    print("🔐 Fixing authentication service methods...")
    
    auth_service_path = 'lib/core/services/auth_service.dart'
    if os.path.exists(auth_service_path):
        with open(auth_service_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Add missing authentication methods
        if 'signInWithEmailAndPassword' not in content:
            methods_to_add = '''
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print('Email sign-in error: $e');
      return null;
    }
  }

  Future<User?> createUserWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(displayName);
      return credential.user;
    } catch (e) {
      print('Email sign-up error: $e');
      return null;
    }
  }
'''
            # Insert before the last closing brace
            content = content.replace('}', methods_to_add + '}')
            
            with open(auth_service_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print("  ✅ Added missing authentication methods")

def fix_user_preferences():
    """Fix missing biometric properties in user preferences."""
    print("👤 Fixing user preferences model...")
    
    user_prefs_path = 'lib/core/models/user_preferences.dart'
    if os.path.exists(user_prefs_path):
        with open(user_prefs_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        if 'biometricEnabled' not in content:
            # Add biometric property
            biometric_property = '''
  final bool biometricEnabled;
'''
            # Add to constructor parameters
            constructor_param = ', this.biometricEnabled = false'
            
            # Find class declaration and add property
            class_pattern = r'(class UserPreferences\s*{[^}]*?)(})'
            if re.search(class_pattern, content, re.DOTALL):
                content = re.sub(r'(class UserPreferences\s*{)', r'\1' + biometric_property, content)
                
                # Add to constructor
                content = re.sub(r'(\s+required this\.\w+,?\s*)', r'\1' + constructor_param, content, count=1)
                
                with open(user_prefs_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print("  ✅ Added biometric properties to user preferences")

def remove_unused_variables():
    """Remove unused variables and imports."""
    print("🧹 Removing unused variables...")
    
    dart_files = list(Path('lib').rglob('*.dart'))
    
    for file_path in dart_files:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        modified = False
        new_lines = []
        
        for line in lines:
            # Skip lines with unused local variables (simple cases)
            if re.search(r'final \w+ = [^;]+;\s*//.*unused', line):
                modified = True
                continue
            # Remove unused theme variables that are immediately declared
            if re.search(r'final theme = theme;', line):
                new_lines.append('    final theme = Theme.of(context);\n')
                modified = True
                continue
                
            new_lines.append(line)
        
        if modified:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)

def fix_const_issues():
    """Fix const keyword issues."""
    print("🔧 Fixing const keyword issues...")
    
    dart_files = list(Path('lib').rglob('*.dart'))
    
    for file_path in dart_files:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        modified = False
        
        # Remove unnecessary const keywords
        patterns = [
            (r'const const ', 'const '),  # Double const
            (r'unnecessary_const', ''),   # Remove unnecessary const comments
        ]
        
        for pattern, replacement in patterns:
            if re.search(pattern, content):
                content = re.sub(pattern, replacement, content)
                modified = True
        
        if modified:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)

def fix_deprecated_usage():
    """Fix deprecated API usage."""
    print("⚠️ Fixing deprecated API usage...")
    
    dart_files = list(Path('lib').rglob('*.dart'))
    
    for file_path in dart_files:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        modified = False
        
        # Fix withOpacity -> withValues
        withopacity_pattern = r'\.withOpacity\(([^)]+)\)'
        if re.search(withopacity_pattern, content):
            content = re.sub(withopacity_pattern, r'.withValues(alpha: \1)', content)
            modified = True
        
        # Fix deprecated theme properties
        deprecated_replacements = [
            ('background:', 'surface:'),
            ('onBackground:', 'onSurface:'),
            ('surfaceVariant:', 'surfaceContainerHighest:'),
        ]
        
        for old, new in deprecated_replacements:
            if old in content:
                content = content.replace(old, new)
                modified = True
        
        if modified:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)

def create_missing_directories():
    """Create missing asset directories."""
    print("📁 Creating missing asset directories...")
    
    directories = [
        'assets/icons',
        'assets/images', 
        'assets/animations'
    ]
    
    for directory in directories:
        os.makedirs(directory, exist_ok=True)
        print(f"  ✅ Created directory: {directory}")

def main():
    print("🚀 Starting FlowSense Production Cleanup...")
    print("=" * 50)
    
    # Change to project directory
    os.chdir('/Users/ronos/development/FlowSense')
    
    # Run cleanup functions
    fix_theme_references()
    fix_auth_service_methods() 
    fix_user_preferences()
    remove_unused_variables()
    fix_const_issues()
    fix_deprecated_usage()
    create_missing_directories()
    
    print("=" * 50)
    print("✅ Production cleanup completed!")
    print("🔍 Run 'flutter analyze' to check remaining issues.")

if __name__ == "__main__":
    main()
