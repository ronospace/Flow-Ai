#!/usr/bin/env dart
// Script to clean up ARB files by removing invalid comment keys
// Run with: dart clean_arb_files.dart

import 'dart:io';
import 'dart:convert';

void main() async {
  print('🧹 Cleaning ARB files to remove invalid comment keys...\n');

  final l10nDir = Directory('lib/l10n');
  if (!await l10nDir.exists()) {
    print('❌ l10n directory not found');
    return;
  }

  final arbFiles = await l10nDir
      .list()
      .where((entity) => entity is File && entity.path.endsWith('.arb'))
      .cast<File>()
      .toList();

  int processedFiles = 0;
  int totalKeysRemoved = 0;

  for (final file in arbFiles) {
    try {
      final content = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);

      // Remove all keys that start with "_comment_"
      final keysToRemove = data.keys
          .where((key) => key.startsWith('_comment_'))
          .toList();

      if (keysToRemove.isNotEmpty) {
        for (final key in keysToRemove) {
          data.remove(key);
        }

        // Write cleaned content back to file
        final cleanedContent = JsonEncoder.withIndent('  ').convert(data);
        await file.writeAsString(cleanedContent);

        processedFiles++;
        totalKeysRemoved += keysToRemove.length;
        print(
          '✅ Cleaned ${file.path.split('/').last} (removed ${keysToRemove.length} comment keys)',
        );
      }
    } catch (e) {
      print('❌ Error processing ${file.path.split('/').last}: $e');
    }
  }

  print('\n🎉 Cleaning complete!');
  print('📊 Processed $processedFiles files');
  print('🗑️ Removed $totalKeysRemoved comment keys in total');
}
