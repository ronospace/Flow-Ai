// Provides default English fallbacks for AI chat localization keys
// in case they are missing from the generated AppLocalizations.

import 'app_localizations.dart';

extension AppLocalizationsExtras on AppLocalizations {
  // Greetings and general
  String get aiGreeting => "Hi {userName}! 👋 I'm Mira, your Flow Ai assistant. I'm here to help you understand your cycle, provide personalized health insights, and answer any questions about reproductive wellness. How can I help you today?";
  String get aiWelcomeBack => "Hello again! 👋 I'm ready to help you with any questions about your reproductive health and cycle tracking. What can I assist you with today?";

  String get aiGreetingHello1 => "Hello! 😊 How can I help you with your reproductive health today?";
  String get aiGreetingHello2 => "Hi there! I'm here to support your menstrual health journey. What would you like to know?";
  String get aiGreetingHello3 => "Welcome back! Ready to dive into some health insights or track your cycle?";

  String get aiGreetingThanks1 => "You're very welcome! 💕 I'm always here to help with your health questions and cycle tracking needs.";
  String get aiGreetingThanks2 => "Happy to help! Feel free to ask me anything about reproductive health, cycle tracking, or using the app.";
  String get aiGreetingThanks3 => "Anytime! Remember, consistent tracking leads to better insights and predictions. Keep up the great work!";

  // Period responses
  String get aiPeriodResponse1 => "I can help you track your menstrual cycle! 🩸 When did your last period start? You can log this in the Period Tracker section, and I'll help predict your next cycle.";
  String get aiPeriodResponse2 => "Understanding your period patterns is key to reproductive health. The average cycle is 21-35 days. Have you noticed any changes in your cycle lately?";
  String get aiPeriodResponse3 => "Period tracking helps identify patterns in flow intensity, duration, and symptoms. Would you like me to guide you through logging your current period?";
  String get aiPeriodResponse4 => "Irregular periods can be influenced by stress, diet, exercise, or hormonal changes. If you're concerned about irregularities, consider consulting with a healthcare provider.";

  // Mood/PMS
  String get aiMoodResponse1 => "PMS affects up to 85% of menstruating people. 💭 Tracking mood changes can help identify patterns. Are you experiencing mood swings, irritability, or anxiety?";
  String get aiMoodResponse2 => "Mood fluctuations during your cycle are completely normal due to hormonal changes. Try logging your daily mood to see patterns emerge over time.";
  String get aiMoodResponse3 => "For PMS symptoms, consider: gentle exercise, adequate sleep, reducing caffeine, and stress management techniques. What symptoms are you experiencing?";
  String get aiMoodResponse4 => "Cramps and mood changes often peak 1-2 days before your period. Heat therapy, gentle stretching, and staying hydrated can help manage discomfort.";

  // Fertility
  String get aiFertilityResponse1 => "Ovulation typically occurs 14 days before your next period. 🥚 Are you tracking fertility to conceive or for natural family planning?";
  String get aiFertilityResponse2 => "Your fertile window is usually 5 days before ovulation and the day of ovulation. Tracking basal body temperature and cervical mucus can help identify this window.";
  String get aiFertilityResponse3 => "Fertility awareness involves understanding your body's natural signs. Would you like me to explain the different fertility tracking methods?";
  String get aiFertilityResponse4 => "If you're trying to conceive, focus on the fertile window. If preventing pregnancy, remember that natural methods require consistency and education.";

  // Symptoms
  String get aiSymptomsResponse1 => "Tracking symptoms helps identify patterns and potential triggers. 📊 What symptoms are you experiencing? I can help you log them properly.";
  String get aiSymptomsResponse2 => "Common cycle-related symptoms include bloating, breast tenderness, headaches, and fatigue. Are these new symptoms or part of your regular pattern?";
  String get aiSymptomsResponse3 => "Severe or unusual symptoms should be discussed with a healthcare provider. I can help you prepare questions and track symptoms to share with them.";
  String get aiSymptomsResponse4 => "Pain management techniques include heat therapy, gentle exercise, anti-inflammatory medications, and relaxation techniques. What type of pain are you experiencing?";

  // Health/wellness
  String get aiHealthResponse1 => "A balanced lifestyle supports menstrual health! 🌟 Regular exercise, adequate sleep, stress management, and proper nutrition all play important roles.";
  String get aiHealthResponse2 => "Exercise can help reduce PMS symptoms and regulate cycles. Low-impact activities like walking, yoga, and swimming are excellent choices during your cycle.";
  String get aiHealthResponse3 => "Nutrition during your cycle: focus on iron-rich foods, complex carbohydrates, and staying hydrated. Limit caffeine and alcohol if they worsen symptoms.";
  String get aiHealthResponse4 => "Stress significantly impacts menstrual health. Consider meditation, deep breathing exercises, or other stress-reduction techniques that work for you.";

  // App usage
  String get aiAppUsageResponse1 => "Great question! 📱 To track your period: go to Period Tracker → tap the calendar → select start date → log flow intensity and symptoms daily.";
  String get aiAppUsageResponse2 => "The AI Insights section provides personalized analysis based on your tracking data. The more you log, the more accurate your insights become!";
  String get aiAppUsageResponse3 => "You can log symptoms in the Symptoms section, track mood and energy levels, and even add notes about your daily experiences.";
  String get aiAppUsageResponse4 => "For predictions: ensure you've logged at least 2-3 complete cycles for accurate forecasting. The AI learns from your patterns to make better predictions.";

  // Predictions
  String get aiPredictionResponse1 => "Cycle predictions become more accurate with consistent tracking! 🔮 Based on your historical data, I can predict your next period with 85-95% accuracy.";
  String get aiPredictionResponse2 => "Your next period prediction is based on your average cycle length and recent patterns. Have you noticed any factors that might affect your cycle timing?";
  String get aiPredictionResponse3 => "Predictions consider cycle length, symptoms, and hormonal patterns. Factors like stress, travel, illness, or lifestyle changes can affect timing.";
  String get aiPredictionResponse4 => "For the most accurate predictions, log your period start and end dates consistently. I'll analyze patterns and provide increasingly accurate forecasts.";

  // Contextual/general
  String get aiContextualResponse1 => "That's an interesting question! 🤔 Can you provide more details? I'd love to help you understand your reproductive health better.";
  String get aiContextualResponse2 => "I want to make sure I give you the most helpful response. Could you elaborate on what specific aspect you're curious about?";
  String get aiContextualResponse3 => "Great question! Reproductive health is complex and individual. What specific information would be most helpful for your situation?";
  String get aiContextualResponse4 => "I'm here to help with all aspects of menstrual and reproductive health. Feel free to ask about periods, symptoms, predictions, or general wellness!";
  String get aiContextualResponse5 => "Every person's experience is unique! 🌸 The more specific you can be about your question, the better I can tailor my advice to your needs.";

  // Suggestions
  String get aiQuickSuggestion1 => "When will my next period start?";
  String get aiQuickSuggestion2 => "How do I track symptoms?";
  String get aiQuickSuggestion3 => "What causes PMS?";
  String get aiQuickSuggestion4 => "Help with fertility tracking";
  String get aiQuickSuggestion5 => "Exercise during period";
  String get aiQuickSuggestion6 => "Understanding my cycle";
  String get aiQuickSuggestion7 => "Irregular periods";
  String get aiQuickSuggestion8 => "Managing cramps";
}

