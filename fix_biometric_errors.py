#!/usr/bin/env python3

import re
import os

def fix_biometric_dashboard_file():
    """Fix all errors in the biometric dashboard screen file"""
    file_path = "/Users/ronos/development/FlowSense/lib/features/biometric/screens/biometric_dashboard_screen.dart"
    
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Fix const const duplication
    content = re.sub(r'\bconst const\b', 'const', content)
    
    # Fix theme variable references in methods by adding proper context parameter
    # Fix theme references in build methods by ensuring theme is properly declared
    content = re.sub(r'(?<!final )theme\.', 'Theme.of(context).', content)
    
    # Fix improper theme declarations
    content = re.sub(r'final theme = theme;', 'final theme = Theme.of(context);', content)
    
    # Fix widget returns that should start with proper widget constructors
    content = re.sub(r'return const Padding\(padding: const', 'return Padding(padding: const', content)
    
    # Fix method-level theme issues by adding context parameters where needed
    fixes = [
        # Fix theme references in helper methods
        (r'(\s+Widget _buildTabContent\([^{]+\{[^}]+)(Theme\.of\(context\)\.)', r'\1theme.'),
        (r'(\s+Widget _buildTrendItem\([^{]+\{[^}]+)(Theme\.of\(context\)\.)', r'\1theme.'),
        (r'(\s+Widget _buildInsightCard\([^{]+\{[^}]+)(Theme\.of\(context\)\.)', r'\1theme.'),
        (r'(\s+Widget _buildNoInsightsCard\([^{]+\{[^}]+)(Theme\.of\(context\)\.)', r'\1theme.'),
        (r'(\s+Widget _buildConnectedDevicesCard\([^{]+\{[^}]+)(Theme\.of\(context\)\.)', r'\1theme.'),
        (r'(\s+Widget _buildSyncSettingsCard\([^{]+\{[^}]+)(Theme\.of\(context\)\.)', r'\1theme.'),
        (r'(\s+Widget _buildDeviceItem\([^{]+\{[^}]+)(Theme\.of\(context\)\.)', r'\1theme.'),
        (r'(\s+Widget _buildLoadingState\([^{]+\{[^}]+)(Theme\.of\(context\)\.)', r'\1theme.'),
        (r'(\s+Widget _buildErrorState\([^{]+\{[^}]+)(Theme\.of\(context\)\.)', r'\1theme.'),
        (r'(\s+Widget _buildEmptyState\([^{]+\{[^}]+)(Theme\.of\(context\)\.)', r'\1theme.'),
        (r'(\s+Widget _buildPermissionState\([^{]+\{[^}]+)(Theme\.of\(context\)\.)', r'\1theme.'),
    ]
    
    for pattern, replacement in fixes:
        content = re.sub(pattern, replacement, content, flags=re.DOTALL)
    
    # Write back fixed content
    with open(file_path, 'w') as f:
        f.write(content)
    
    print(f"Fixed biometric dashboard screen file: {file_path}")

if __name__ == "__main__":
    fix_biometric_dashboard_file()
