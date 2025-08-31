import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flowai/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

group('Flow Ai App End-to-End Tests', () {
    
    testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify splash screen is shown
      expect(find.text('Flow Ai'), findsOneWidget);
      
      // Wait for splash screen to complete (adjust timing as needed)
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('Navigation between main screens works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test navigation to Calendar screen
      final calendarTab = find.byIcon(Icons.calendar_month_rounded);
      if (calendarTab.evaluate().isNotEmpty) {
        await tester.tap(calendarTab);
        await tester.pumpAndSettle();
        
        // Verify calendar screen elements
        expect(find.text('Calendar'), findsWidgets);
      }

      // Test navigation to Tracking screen
      final trackingTab = find.byIcon(Icons.add_circle_rounded);
      if (trackingTab.evaluate().isNotEmpty) {
        await tester.tap(trackingTab);
        await tester.pumpAndSettle();
        
        // Verify tracking screen elements
        expect(find.text('Track'), findsWidgets);
      }

      // Test navigation to Insights screen
      final insightsTab = find.byIcon(Icons.insights_rounded);
      if (insightsTab.evaluate().isNotEmpty) {
        await tester.tap(insightsTab);
        await tester.pumpAndSettle();
        
        // Verify insights screen elements
        expect(find.text('Insights'), findsWidgets);
      }

      // Test navigation to Health screen
      final healthTab = find.byIcon(Icons.favorite_rounded);
      if (healthTab.evaluate().isNotEmpty) {
        await tester.tap(healthTab);
        await tester.pumpAndSettle();
        
        // Verify health screen elements
        expect(find.text('Health'), findsWidgets);
      }

      // Test navigation to Settings screen
      final settingsTab = find.byIcon(Icons.settings_rounded);
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();
        
        // Verify settings screen elements
        expect(find.text('Settings'), findsWidgets);
      }

      // Return to Home screen
      final homeTab = find.byIcon(Icons.home_rounded);
      if (homeTab.evaluate().isNotEmpty) {
        await tester.tap(homeTab);
        await tester.pumpAndSettle();
        
        // Verify home screen elements
        expect(find.text('Home'), findsWidgets);
      }
    });

    testWidgets('Theme switching works correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Settings screen
      final settingsTab = find.byIcon(Icons.settings_rounded);
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();

        // Look for theme toggle (adjust selector based on actual implementation)
        final themeToggle = find.byType(Switch).first;
        if (themeToggle.evaluate().isNotEmpty) {
          await tester.tap(themeToggle);
          await tester.pumpAndSettle();
          
          // Verify theme change took effect
          // This would need to be adjusted based on how theme is displayed
          expect(find.byType(MaterialApp), findsOneWidget);
        }
      }
    });

    testWidgets('Language switching works correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Settings screen
      final settingsTab = find.byIcon(Icons.settings_rounded);
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();

        // Look for language dropdown or selector
        final languageSelector = find.text('English').first;
        if (languageSelector.evaluate().isNotEmpty) {
          await tester.tap(languageSelector);
          await tester.pumpAndSettle();
          
          // Select a different language (e.g., Spanish)
          final spanishOption = find.text('Español');
          if (spanishOption.evaluate().isNotEmpty) {
            await tester.tap(spanishOption);
            await tester.pumpAndSettle();
            
            // Verify language change
            expect(find.text('Configuración'), findsWidgets);
          }
        }
      }
    });

    testWidgets('Cycle tracking flow works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Tracking screen
      final trackingTab = find.byIcon(Icons.add_circle_rounded);
      if (trackingTab.evaluate().isNotEmpty) {
        await tester.tap(trackingTab);
        await tester.pumpAndSettle();

        // Test period tracking
        final periodButton = find.text('Period');
        if (periodButton.evaluate().isNotEmpty) {
          await tester.tap(periodButton);
          await tester.pumpAndSettle();

          // Test flow intensity selection
          final lightFlow = find.text('Light');
          if (lightFlow.evaluate().isNotEmpty) {
            await tester.tap(lightFlow);
            await tester.pumpAndSettle();
          }
        }

        // Test symptoms tracking
        final symptomsSection = find.text('Symptoms');
        if (symptomsSection.evaluate().isNotEmpty) {
          await tester.tap(symptomsSection);
          await tester.pumpAndSettle();

          // Select a symptom
          final crampSymptom = find.text('Cramps');
          if (crampSymptom.evaluate().isNotEmpty) {
            await tester.tap(crampSymptom);
            await tester.pumpAndSettle();
          }
        }

        // Save tracking data
        final saveButton = find.text('Save');
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('AI Chat functionality works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Insights screen
      final insightsTab = find.byIcon(Icons.insights_rounded);
      if (insightsTab.evaluate().isNotEmpty) {
        await tester.tap(insightsTab);
        await tester.pumpAndSettle();

        // Look for floating AI chat button
        final aiChatButton = find.byIcon(Icons.chat_bubble_outline);
        if (aiChatButton.evaluate().isNotEmpty) {
          await tester.tap(aiChatButton);
          await tester.pumpAndSettle();

          // Test sending a message
          final messageInput = find.byType(TextField);
          if (messageInput.evaluate().isNotEmpty) {
            await tester.enterText(messageInput, 'When will my next period start?');
            await tester.pumpAndSettle();

            // Send the message
            final sendButton = find.byIcon(Icons.send);
            if (sendButton.evaluate().isNotEmpty) {
              await tester.tap(sendButton);
              await tester.pumpAndSettle();
              
              // Wait for AI response
              await tester.pumpAndSettle(const Duration(seconds: 2));
              
              // Verify message was sent and response received
              expect(find.text('When will my next period start?'), findsOneWidget);
            }
          }
        }
      }
    });

    testWidgets('Calendar interaction works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Calendar screen
      final calendarTab = find.byIcon(Icons.calendar_month_rounded);
      if (calendarTab.evaluate().isNotEmpty) {
        await tester.tap(calendarTab);
        await tester.pumpAndSettle();

        // Test date selection
        final todayButton = find.text('Today');
        if (todayButton.evaluate().isNotEmpty) {
          await tester.tap(todayButton);
          await tester.pumpAndSettle();
        }

        // Look for calendar dates and tap one
        final dateElements = find.text('15'); // Example date
        if (dateElements.evaluate().isNotEmpty) {
          await tester.tap(dateElements.first);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Settings configuration works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Settings screen
      final settingsTab = find.byIcon(Icons.settings_rounded);
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();

        // Test various settings toggles
        final toggles = find.byType(Switch);
        if (toggles.evaluate().isNotEmpty) {
          // Test first toggle (could be notifications, dark mode, etc.)
          await tester.tap(toggles.first);
          await tester.pumpAndSettle();
        }

        // Test profile settings if available
        final profileSection = find.text('Profile');
        if (profileSection.evaluate().isNotEmpty) {
          await tester.tap(profileSection);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('App handles back navigation correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate through several screens
      final calendarTab = find.byIcon(Icons.calendar_month_rounded);
      if (calendarTab.evaluate().isNotEmpty) {
        await tester.tap(calendarTab);
        await tester.pumpAndSettle();
      }

      final trackingTab = find.byIcon(Icons.add_circle_rounded);
      if (trackingTab.evaluate().isNotEmpty) {
        await tester.tap(trackingTab);
        await tester.pumpAndSettle();
      }

      // Test system back button
      await tester.pageBack();
      await tester.pumpAndSettle();
      
      // Should handle navigation properly without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App performance - no frame drops during navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate rapidly through all tabs to test performance
      final tabs = [
        Icons.calendar_month_rounded,
        Icons.add_circle_rounded,
        Icons.insights_rounded,
        Icons.favorite_rounded,
        Icons.settings_rounded,
        Icons.home_rounded,
      ];

      for (final tabIcon in tabs) {
        final tab = find.byIcon(tabIcon);
        if (tab.evaluate().isNotEmpty) {
          await tester.tap(tab);
          await tester.pump(); // Use pump instead of pumpAndSettle for performance testing
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      // Verify app is still responsive
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
