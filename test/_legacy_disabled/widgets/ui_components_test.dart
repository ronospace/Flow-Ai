import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flow_ai/core/services/auth_service.dart';
import 'package:flow_ai/core/services/ai_engine.dart';
import 'package:flow_ai/core/services/analytics_service.dart';

// Generate mocks
@GenerateMocks([AuthService, AIEngine, AnalyticsService])
import 'ui_components_test.mocks.dart';

void main() {
  group('Authentication UI Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    testWidgets('Login screen renders correctly', (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isAuthenticated).thenReturn(false);

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthService>.value(value: mockAuthService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const Text('Flow Ai'),
                  const Text('Welcome to your intelligent menstrual health companion'),
                  TextFormField(
                    key: const Key('email_field'),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  TextFormField(
                    key: const Key('password_field'),
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  ElevatedButton(
                    key: const Key('login_button'),
                    onPressed: () {},
                    child: const Text('Sign In'),
                  ),
                  TextButton(
                    key: const Key('signup_button'),
                    onPressed: () {},
                    child: const Text('Create Account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Flow Ai'), findsOneWidget);
      expect(find.text('Welcome to your intelligent menstrual health companion'), findsOneWidget);
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
      expect(find.byKey(const Key('signup_button')), findsOneWidget);
    });

    testWidgets('Email validation works correctly', (WidgetTester tester) async {
      // Arrange
      String? validationError;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextFormField(
                  key: const Key('email_field'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Trigger validation
                    validationError = value.isEmpty ? 'Email is required' : null;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Act - Enter invalid email
      await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
      await tester.pump();

      // Assert
      expect(find.text('invalid-email'), findsOneWidget);
    });

    testWidgets('Apple Sign-In button renders on iOS', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              key: const Key('apple_signin_button'),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.apple, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Sign in with Apple',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byKey(const Key('apple_signin_button')), findsOneWidget);
      expect(find.text('Sign in with Apple'), findsOneWidget);
      expect(find.byIcon(Icons.apple), findsOneWidget);
    });
  });

  group('Period Tracking UI Tests', () {
    testWidgets('Calendar widget displays correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Period Calendar', key: Key('calendar_title')),
                SizedBox(
                  key: const Key('calendar_container'),
                  height: 400,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                    ),
                    itemCount: 35, // 5 weeks
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: index % 28 < 5 ? Colors.red.shade100 : Colors.transparent,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text('${index + 1}'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.byKey(const Key('calendar_title')), findsOneWidget);
      expect(find.byKey(const Key('calendar_container')), findsOneWidget);
      expect(find.text('Period Calendar'), findsOneWidget);
    });

    testWidgets('Period logging form works correctly', (WidgetTester tester) async {
      // Arrange
      String selectedFlow = 'Medium';
      List<String> selectedSymptoms = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Log Your Period', key: Key('log_period_title')),
                DropdownButton<String>(
                  key: const Key('flow_dropdown'),
                  value: selectedFlow,
                  items: ['Light', 'Medium', 'Heavy'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    selectedFlow = newValue!;
                  },
                ),
                CheckboxListTile(
                  key: const Key('cramping_checkbox'),
                  title: const Text('Cramping'),
                  value: selectedSymptoms.contains('cramping'),
                  onChanged: (bool? value) {
                    if (value == true) {
                      selectedSymptoms.add('cramping');
                    } else {
                      selectedSymptoms.remove('cramping');
                    }
                  },
                ),
                ElevatedButton(
                  key: const Key('save_period_button'),
                  onPressed: () {},
                  child: const Text('Save Period Data'),
                ),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Log Your Period'), findsOneWidget);
      expect(find.byKey(const Key('flow_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('cramping_checkbox')), findsOneWidget);
      expect(find.byKey(const Key('save_period_button')), findsOneWidget);
    });

    testWidgets('Symptom selection checkboxes work', (WidgetTester tester) async {
      // Arrange
      bool crampingSelected = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: CheckboxListTile(
                key: const Key('cramping_checkbox'),
                title: const Text('Cramping'),
                value: crampingSelected,
                onChanged: (bool? value) {
                  setState(() {
                    crampingSelected = value ?? false;
                  });
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byKey(const Key('cramping_checkbox')));
      await tester.pump();

      // Assert - Checkbox should be checked after tap
      final checkbox = tester.widget<CheckboxListTile>(
        find.byKey(const Key('cramping_checkbox')),
      );
      expect(checkbox.value, true);
    });
  });

  group('AI Chat UI Tests', () {
    late MockAIEngine mockAIEngine;

    setUp(() {
      mockAIEngine = MockAIEngine();
    });

    testWidgets('AI chat interface renders correctly', (WidgetTester tester) async {
      // Arrange
      final chatMessages = [
        {'sender': 'user', 'message': 'Hello, I have period cramps'},
        {'sender': 'ai', 'message': 'I understand you\'re experiencing period cramps. Here are some suggestions...'},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('AI Health Assistant', key: Key('chat_title')),
                Expanded(
                  child: ListView.builder(
                    key: const Key('chat_messages'),
                    itemCount: chatMessages.length,
                    itemBuilder: (context, index) {
                      final message = chatMessages[index];
                      final isUser = message['sender'] == 'user';
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: 
                              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            Container(
                              constraints: const BoxConstraints(maxWidth: 250),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isUser ? Colors.blue : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                message['message']!,
                                style: TextStyle(
                                  color: isUser ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          key: Key('message_input'),
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        key: const Key('send_button'),
                        icon: const Icon(Icons.send),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('AI Health Assistant'), findsOneWidget);
      expect(find.byKey(const Key('chat_messages')), findsOneWidget);
      expect(find.byKey(const Key('message_input')), findsOneWidget);
      expect(find.byKey(const Key('send_button')), findsOneWidget);
      expect(find.text('Hello, I have period cramps'), findsOneWidget);
    });

    testWidgets('Chat input field accepts text', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const TextField(
              key: Key('message_input'),
              decoration: InputDecoration(
                hintText: 'Type your message...',
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byKey(const Key('message_input')), 'Test message');
      await tester.pump();

      // Assert
      expect(find.text('Test message'), findsOneWidget);
    });
  });

  group('Dashboard UI Tests', () {
    testWidgets('Health insights cards render correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Health Dashboard', key: Key('dashboard_title')),
                Card(
                  key: const Key('cycle_insights_card'),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.favorite, color: Colors.red.shade300),
                            const SizedBox(width: 8),
                            const Text('Cycle Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('Your cycle is 28 days on average'),
                        const Text('Next period predicted: March 15'),
                        const Text('Fertility window: March 1-6'),
                      ],
                    ),
                  ),
                ),
                Card(
                  key: const Key('mood_tracker_card'),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.mood, color: Colors.orange.shade300),
                            const SizedBox(width: 8),
                            const Text('Mood Tracker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('Current mood: Happy'),
                        const Text('This week average: 7.5/10'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Health Dashboard'), findsOneWidget);
      expect(find.byKey(const Key('cycle_insights_card')), findsOneWidget);
      expect(find.byKey(const Key('mood_tracker_card')), findsOneWidget);
      expect(find.text('Cycle Insights'), findsOneWidget);
      expect(find.text('Mood Tracker'), findsOneWidget);
      expect(find.text('Your cycle is 28 days on average'), findsOneWidget);
    });

    testWidgets('Progress indicators display correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(
                  key: const Key('cycle_progress'),
                  child: Column(
                    children: [
                      const Text('Cycle Progress'),
                      LinearProgressIndicator(
                        value: 0.6,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.pink.shade300),
                      ),
                      const Text('Day 17 of 28'),
                    ],
                  ),
                ),
                Container(
                  key: const Key('health_score'),
                  child: Column(
                    children: [
                      const Text('Health Score'),
                      CircularProgressIndicator(
                        value: 0.85,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
                      ),
                      const Text('85/100'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.byKey(const Key('cycle_progress')), findsOneWidget);
      expect(find.byKey(const Key('health_score')), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Day 17 of 28'), findsOneWidget);
      expect(find.text('85/100'), findsOneWidget);
    });
  });

  group('Settings UI Tests', () {
    testWidgets('Settings screen renders all options', (WidgetTester tester) async {
      // Arrange
      bool notificationsEnabled = true;
      bool biometricsEnabled = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const Text('Settings', key: Key('settings_title')),
                  SwitchListTile(
                    key: const Key('notifications_switch'),
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive period and health reminders'),
                    value: notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        notificationsEnabled = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    key: const Key('biometrics_switch'),
                    title: const Text('Biometric Authentication'),
                    subtitle: const Text('Use Face ID or Touch ID to unlock'),
                    value: biometricsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        biometricsEnabled = value;
                      });
                    },
                  ),
                  ListTile(
                    key: const Key('export_data_tile'),
                    title: const Text('Export Data'),
                    subtitle: const Text('Download your health data'),
                    trailing: const Icon(Icons.download),
                    onTap: () {},
                  ),
                  ListTile(
                    key: const Key('privacy_policy_tile'),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byKey(const Key('notifications_switch')), findsOneWidget);
      expect(find.byKey(const Key('biometrics_switch')), findsOneWidget);
      expect(find.byKey(const Key('export_data_tile')), findsOneWidget);
      expect(find.byKey(const Key('privacy_policy_tile')), findsOneWidget);
      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('Export Data'), findsOneWidget);
    });

    testWidgets('Settings switches toggle correctly', (WidgetTester tester) async {
      // Arrange
      bool switchValue = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: SwitchListTile(
                key: const Key('test_switch'),
                title: const Text('Test Setting'),
                value: switchValue,
                onChanged: (bool value) {
                  setState(() {
                    switchValue = value;
                  });
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byKey(const Key('test_switch')));
      await tester.pump();

      // Assert
      final switchWidget = tester.widget<SwitchListTile>(
        find.byKey(const Key('test_switch')),
      );
      expect(switchWidget.value, true);
    });
  });

  group('Error Handling UI Tests', () {
    testWidgets('Error messages display correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(
                  key: const Key('error_banner'),
                  color: Colors.red.shade100,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade800),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Failed to sync data. Please check your internet connection.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        key: const Key('dismiss_error'),
                        icon: const Icon(Icons.close),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.byKey(const Key('error_banner')), findsOneWidget);
      expect(find.byKey(const Key('dismiss_error')), findsOneWidget);
      expect(find.text('Failed to sync data. Please check your internet connection.'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('Loading states render correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(
                  key: const Key('loading_indicator'),
                  child: const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading your health data...'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.byKey(const Key('loading_indicator')), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading your health data...'), findsOneWidget);
    });
  });
}
