#!/usr/bin/env dart
// Script to generate all 36 language ARB files for Flow Ai
// Run with: dart generate_languages.dart

import 'dart:io';
import 'dart:convert';

// The 36 languages Flow Ai supports
final Map<String, Map<String, String>> languageTranslations = {
  'ar': { // Arabic
    'locale': 'ar',
    'appName': 'Flow Ai',
    'appTagline': 'تتبع الدورة الشهرية بالذكاء الاصطناعي',
    'home': 'الرئيسية',
    'calendar': 'التقويم',
    'tracking': 'التتبع',
    'insights': 'الأفكار',
    'settings': 'الإعدادات',
    'welcome': 'مرحباً بك في Flow Ai',
    'getStarted': 'البدء',
    'yes': 'نعم',
    'no': 'لا',
    'save': 'حفظ',
    'cancel': 'إلغاء'
  },
  'zh': { // Chinese Simplified
    'locale': 'zh',
    'appName': 'Flow Ai',
    'appTagline': 'AI 生理期和周期跟踪',
    'home': '首页',
    'calendar': '日历',
    'tracking': '跟踪',
    'insights': '洞察',
    'settings': '设置',
    'welcome': '欢迎使用 Flow Ai',
    'getStarted': '开始',
    'yes': '是',
    'no': '否',
    'save': '保存',
    'cancel': '取消'
  },
  'hi': { // Hindi
    'locale': 'hi',
    'appName': 'Flow Ai',
    'appTagline': 'AI-संचालित मासिक धर्म और चक्र ट्रैकिंग',
    'home': 'होम',
    'calendar': 'कैलेंडर',
    'tracking': 'ट्रैकिंग',
    'insights': 'इनसाइट्स',
    'settings': 'सेटिंग्स',
    'welcome': 'Flow Ai में आपका स्वागत है',
    'getStarted': 'शुरू करें',
    'yes': 'हां',
    'no': 'नहीं',
    'save': 'सेव करें',
    'cancel': 'रद्द करें'
  },
  'bn': { // Bengali
    'locale': 'bn',
    'appName': 'Flow Ai',
    'appTagline': 'AI-চালিত পিরিয়ড এবং সাইকেল ট্র্যাকিং',
    'home': 'হোম',
    'calendar': 'ক্যালেন্ডার',
    'tracking': 'ট্র্যাকিং',
    'insights': 'ইনসাইট',
    'settings': 'সেটিংস',
    'welcome': 'Flow Ai-এ স্বাগতম',
    'getStarted': 'শুরু করুন',
    'yes': 'হ্যাঁ',
    'no': 'না',
    'save': 'সেভ করুন',
    'cancel': 'বাতিল'
  },
  'pt': { // Portuguese
    'locale': 'pt',
    'appName': 'Flow Ai',
    'appTagline': 'Rastreamento de Período e Ciclo com IA',
    'home': 'Início',
    'calendar': 'Calendário',
    'tracking': 'Rastreamento',
    'insights': 'Insights',
    'settings': 'Configurações',
    'welcome': 'Bem-vinda ao Flow Ai',
    'getStarted': 'Começar',
    'yes': 'Sim',
    'no': 'Não',
    'save': 'Salvar',
    'cancel': 'Cancelar'
  },
  'ru': { // Russian
    'locale': 'ru',
    'appName': 'Flow Ai',
    'appTagline': 'ИИ-трекер менструального цикла',
    'home': 'Главная',
    'calendar': 'Календарь',
    'tracking': 'Отслеживание',
    'insights': 'Аналитика',
    'settings': 'Настройки',
    'welcome': 'Добро пожаловать в Flow Ai',
    'getStarted': 'Начать',
    'yes': 'Да',
    'no': 'Нет',
    'save': 'Сохранить',
    'cancel': 'Отмена'
  },
  'ja': { // Japanese
    'locale': 'ja',
    'appName': 'Flow Ai',
    'appTagline': 'AIによる生理・月経周期トラッキング',
    'home': 'ホーム',
    'calendar': 'カレンダー',
    'tracking': '記録',
    'insights': '洞察',
    'settings': '設定',
    'welcome': 'Flow Aiへようこそ',
    'getStarted': '始める',
    'yes': 'はい',
    'no': 'いいえ',
    'save': '保存',
    'cancel': 'キャンセル'
  },
  'ko': { // Korean
    'locale': 'ko',
    'appName': 'Flow Ai',
    'appTagline': 'AI 기반 생리주기 추적',
    'home': '홈',
    'calendar': '달력',
    'tracking': '추적',
    'insights': '인사이트',
    'settings': '설정',
    'welcome': 'Flow Ai에 오신 것을 환영합니다',
    'getStarted': '시작하기',
    'yes': '예',
    'no': '아니오',
    'save': '저장',
    'cancel': '취소'
  },
  'de': { // German
    'locale': 'de',
    'appName': 'Flow Ai',
    'appTagline': 'KI-gestütztes Periode & Zyklus Tracking',
    'home': 'Start',
    'calendar': 'Kalender',
    'tracking': 'Verfolgung',
    'insights': 'Einblicke',
    'settings': 'Einstellungen',
    'welcome': 'Willkommen bei Flow Ai',
    'getStarted': 'Loslegen',
    'yes': 'Ja',
    'no': 'Nein',
    'save': 'Speichern',
    'cancel': 'Abbrechen'
  },
  'it': { // Italian
    'locale': 'it',
    'appName': 'Flow Ai',
    'appTagline': 'Tracciamento del Ciclo Mestruale con AI',
    'home': 'Home',
    'calendar': 'Calendario',
    'tracking': 'Tracciamento',
    'insights': 'Approfondimenti',
    'settings': 'Impostazioni',
    'welcome': 'Benvenuta in Flow Ai',
    'getStarted': 'Inizia',
    'yes': 'Sì',
    'no': 'No',
    'save': 'Salva',
    'cancel': 'Annulla'
  },
  'tr': { // Turkish
    'locale': 'tr',
    'appName': 'Flow Ai',
    'appTagline': 'AI Destekli Adet ve Döngü Takibi',
    'home': 'Ana Sayfa',
    'calendar': 'Takvim',
    'tracking': 'Takip',
    'insights': 'Görüşler',
    'settings': 'Ayarlar',
    'welcome': 'Flow Ai\'e Hoş Geldiniz',
    'getStarted': 'Başlayın',
    'yes': 'Evet',
    'no': 'Hayır',
    'save': 'Kaydet',
    'cancel': 'İptal'
  },
  'vi': { // Vietnamese
    'locale': 'vi',
    'appName': 'Flow Ai',
    'appTagline': 'Theo dõi Chu kỳ và Kinh nguyệt với AI',
    'home': 'Trang chủ',
    'calendar': 'Lịch',
    'tracking': 'Theo dõi',
    'insights': 'Thông tin',
    'settings': 'Cài đặt',
    'welcome': 'Chào mừng đến với Flow Ai',
    'getStarted': 'Bắt đầu',
    'yes': 'Có',
    'no': 'Không',
    'save': 'Lưu',
    'cancel': 'Hủy'
  },
  'th': { // Thai
    'locale': 'th',
    'appName': 'Flow Ai',
    'appTagline': 'การติดตามรอบเดือนด้วย AI',
    'home': 'หน้าแรก',
    'calendar': 'ปฏิทิน',
    'tracking': 'การติดตาม',
    'insights': 'ข้อมูลเชิงลึก',
    'settings': 'การตั้งค่า',
    'welcome': 'ยินดีต้อนรับสู่ Flow Ai',
    'getStarted': 'เริ่มต้น',
    'yes': 'ใช่',
    'no': 'ไม่',
    'save': 'บันทึก',
    'cancel': 'ยกเลิก'
  },
  'pl': { // Polish
    'locale': 'pl',
    'appName': 'Flow Ai',
    'appTagline': 'Śledzenie Cyklu Menstruacyjnego z AI',
    'home': 'Strona główna',
    'calendar': 'Kalendarz',
    'tracking': 'Śledzenie',
    'insights': 'Wglądy',
    'settings': 'Ustawienia',
    'welcome': 'Witaj w Flow Ai',
    'getStarted': 'Rozpocznij',
    'yes': 'Tak',
    'no': 'Nie',
    'save': 'Zapisz',
    'cancel': 'Anuluj'
  },
  'nl': { // Dutch
    'locale': 'nl',
    'appName': 'Flow Ai',
    'appTagline': 'AI-gedreven Menstruatie Tracking',
    'home': 'Home',
    'calendar': 'Kalender',
    'tracking': 'Tracking',
    'insights': 'Inzichten',
    'settings': 'Instellingen',
    'welcome': 'Welkom bij Flow Ai',
    'getStarted': 'Beginnen',
    'yes': 'Ja',
    'no': 'Nee',
    'save': 'Opslaan',
    'cancel': 'Annuleren'
  },
  'sv': { // Swedish
    'locale': 'sv',
    'appName': 'Flow Ai',
    'appTagline': 'AI-driven Menstruationsspårning',
    'home': 'Hem',
    'calendar': 'Kalender',
    'tracking': 'Spårning',
    'insights': 'Insikter',
    'settings': 'Inställningar',
    'welcome': 'Välkommen till Flow Ai',
    'getStarted': 'Kom igång',
    'yes': 'Ja',
    'no': 'Nej',
    'save': 'Spara',
    'cancel': 'Avbryt'
  },
  'da': { // Danish
    'locale': 'da',
    'appName': 'Flow Ai',
    'appTagline': 'AI-drevet Menstruations Tracking',
    'home': 'Hjem',
    'calendar': 'Kalender',
    'tracking': 'Tracking',
    'insights': 'Indsigter',
    'settings': 'Indstillinger',
    'welcome': 'Velkommen til Flow Ai',
    'getStarted': 'Kom i gang',
    'yes': 'Ja',
    'no': 'Nej',
    'save': 'Gem',
    'cancel': 'Annuller'
  },
  'no': { // Norwegian
    'locale': 'no',
    'appName': 'Flow Ai',
    'appTagline': 'AI-drevet Menstruasjonssporing',
    'home': 'Hjem',
    'calendar': 'Kalender',
    'tracking': 'Sporing',
    'insights': 'Innsikter',
    'settings': 'Innstillinger',
    'welcome': 'Velkommen til Flow Ai',
    'getStarted': 'Kom i gang',
    'yes': 'Ja',
    'no': 'Nei',
    'save': 'Lagre',
    'cancel': 'Avbryt'
  },
  'fi': { // Finnish
    'locale': 'fi',
    'appName': 'Flow Ai',
    'appTagline': 'AI-pohjainen Kuukautiskierron Seuranta',
    'home': 'Koti',
    'calendar': 'Kalenteri',
    'tracking': 'Seuranta',
    'insights': 'Oivallukset',
    'settings': 'Asetukset',
    'welcome': 'Tervetuloa Flow Aien',
    'getStarted': 'Aloita',
    'yes': 'Kyllä',
    'no': 'Ei',
    'save': 'Tallenna',
    'cancel': 'Peruuta'
  },
  'he': { // Hebrew
    'locale': 'he',
    'appName': 'Flow Ai',
    'appTagline': 'מעקב מחזור חודשי מונע בינה מלאכותית',
    'home': 'בית',
    'calendar': 'לוח שנה',
    'tracking': 'מעקב',
    'insights': 'תובנות',
    'settings': 'הגדרות',
    'welcome': 'ברוכים הבאים ל-Flow Ai',
    'getStarted': 'התחלה',
    'yes': 'כן',
    'no': 'לא',
    'save': 'שמור',
    'cancel': 'בטל'
  },
  'cs': { // Czech
    'locale': 'cs',
    'appName': 'Flow Ai',
    'appTagline': 'AI Sledování Menstruačního Cyklu',
    'home': 'Domů',
    'calendar': 'Kalendář',
    'tracking': 'Sledování',
    'insights': 'Poznatky',
    'settings': 'Nastavení',
    'welcome': 'Vítejte ve Flow Ai',
    'getStarted': 'Začít',
    'yes': 'Ano',
    'no': 'Ne',
    'save': 'Uložit',
    'cancel': 'Zrušit'
  },
  'hu': { // Hungarian
    'locale': 'hu',
    'appName': 'Flow Ai',
    'appTagline': 'MI-alapú Menstruációs Ciklus Követés',
    'home': 'Kezdőlap',
    'calendar': 'Naptár',
    'tracking': 'Követés',
    'insights': 'Betekintések',
    'settings': 'Beállítások',
    'welcome': 'Üdvözöljük a Flow Ai-ben',
    'getStarted': 'Kezdés',
    'yes': 'Igen',
    'no': 'Nem',
    'save': 'Mentés',
    'cancel': 'Mégse'
  },
  'uk': { // Ukrainian
    'locale': 'uk',
    'appName': 'Flow Ai',
    'appTagline': 'ШІ-трекер менструального циклу',
    'home': 'Головна',
    'calendar': 'Календар',
    'tracking': 'Відстеження',
    'insights': 'Аналітика',
    'settings': 'Налаштування',
    'welcome': 'Ласкаво просимо до Flow Ai',
    'getStarted': 'Почати',
    'yes': 'Так',
    'no': 'Ні',
    'save': 'Зберегти',
    'cancel': 'Скасувати'
  },
  'el': { // Greek
    'locale': 'el',
    'appName': 'Flow Ai',
    'appTagline': 'Παρακολούθηση Εμμηνορροίας με AI',
    'home': 'Αρχική',
    'calendar': 'Ημερολόγιο',
    'tracking': 'Παρακολούθηση',
    'insights': 'Γνώσεις',
    'settings': 'Ρυθμίσεις',
    'welcome': 'Καλώς ήρθατε στο Flow Ai',
    'getStarted': 'Ξεκινήστε',
    'yes': 'Ναι',
    'no': 'Όχι',
    'save': 'Αποθήκευση',
    'cancel': 'Ακύρωση'
  },
  'bg': { // Bulgarian
    'locale': 'bg',
    'appName': 'Flow Ai',
    'appTagline': 'ИИ проследяване на менструалния цикъл',
    'home': 'Начало',
    'calendar': 'Календар',
    'tracking': 'Проследяване',
    'insights': 'Прозрения',
    'settings': 'Настройки',
    'welcome': 'Добре дошли във Flow Ai',
    'getStarted': 'Започнете',
    'yes': 'Да',
    'no': 'Не',
    'save': 'Запази',
    'cancel': 'Отказ'
  },
  'ro': { // Romanian
    'locale': 'ro',
    'appName': 'Flow Ai',
    'appTagline': 'Urmărirea Ciclului Menstrual cu AI',
    'home': 'Acasă',
    'calendar': 'Calendar',
    'tracking': 'Urmărire',
    'insights': 'Perspective',
    'settings': 'Setări',
    'welcome': 'Bine ați venit la Flow Ai',
    'getStarted': 'Începeți',
    'yes': 'Da',
    'no': 'Nu',
    'save': 'Salvați',
    'cancel': 'Anulați'
  },
  'hr': { // Croatian
    'locale': 'hr',
    'appName': 'Flow Ai',
    'appTagline': 'AI Praćenje Menstrualnog Ciklusa',
    'home': 'Početna',
    'calendar': 'Kalendar',
    'tracking': 'Praćenje',
    'insights': 'Uvidi',
    'settings': 'Postavke',
    'welcome': 'Dobrodošli u Flow Ai',
    'getStarted': 'Započnite',
    'yes': 'Da',
    'no': 'Ne',
    'save': 'Spremi',
    'cancel': 'Otkaži'
  },
  'sk': { // Slovak
    'locale': 'sk',
    'appName': 'Flow Ai',
    'appTagline': 'AI Sledovanie Menštruačného Cyklu',
    'home': 'Domov',
    'calendar': 'Kalendár',
    'tracking': 'Sledovanie',
    'insights': 'Poznatky',
    'settings': 'Nastavenia',
    'welcome': 'Vitajte vo Flow Ai',
    'getStarted': 'Začať',
    'yes': 'Áno',
    'no': 'Nie',
    'save': 'Uložiť',
    'cancel': 'Zrušiť'
  },
  'sl': { // Slovenian
    'locale': 'sl',
    'appName': 'Flow Ai',
    'appTagline': 'AI Sledenje Menstrualnega Cikla',
    'home': 'Domov',
    'calendar': 'Koledar',
    'tracking': 'Sledenje',
    'insights': 'Vpogledi',
    'settings': 'Nastavitve',
    'welcome': 'Dobrodošli v Flow Ai',
    'getStarted': 'Začnite',
    'yes': 'Da',
    'no': 'Ne',
    'save': 'Shrani',
    'cancel': 'Prekliči'
  },
  'lt': { // Lithuanian
    'locale': 'lt',
    'appName': 'Flow Ai',
    'appTagline': 'II Menstruacinio Ciklo Stebėjimas',
    'home': 'Pradžia',
    'calendar': 'Kalendorius',
    'tracking': 'Stebėjimas',
    'insights': 'Įžvalgos',
    'settings': 'Nustatymai',
    'welcome': 'Sveiki atvykę į Flow Ai',
    'getStarted': 'Pradėti',
    'yes': 'Taip',
    'no': 'Ne',
    'save': 'Išsaugoti',
    'cancel': 'Atšaukti'
  },
  'lv': { // Latvian
    'locale': 'lv',
    'appName': 'Flow Ai',
    'appTagline': 'AI Menstruālā Cikla Uzraudzība',
    'home': 'Sākums',
    'calendar': 'Kalendārs',
    'tracking': 'Izsekošana',
    'insights': 'Ieskati',
    'settings': 'Iestatījumi',
    'welcome': 'Laipni lūdzam Flow Ai',
    'getStarted': 'Sākt',
    'yes': 'Jā',
    'no': 'Nē',
    'save': 'Saglabāt',
    'cancel': 'Atcelt'
  },
  'et': { // Estonian
    'locale': 'et',
    'appName': 'Flow Ai',
    'appTagline': 'AI Menstruaaltsükli Jälgimine',
    'home': 'Avaleht',
    'calendar': 'Kalender',
    'tracking': 'Jälgimine',
    'insights': 'Teadmised',
    'settings': 'Seaded',
    'welcome': 'Tere tulemast Flow Ai\'i',
    'getStarted': 'Alusta',
    'yes': 'Jah',
    'no': 'Ei',
    'save': 'Salvesta',
    'cancel': 'Tühista'
  },
  'mt': { // Maltese
    'locale': 'mt',
    'appName': 'Flow Ai',
    'appTagline': 'Traċċjar taċ-Ċiklu Mestruwali bl-AI',
    'home': 'Id-Dar',
    'calendar': 'Kalendarju',
    'tracking': 'Traċċjar',
    'insights': 'Għarfien',
    'settings': 'Settings',
    'welcome': 'Merħba fil-Flow Ai',
    'getStarted': 'Ibda',
    'yes': 'Iva',
    'no': 'Le',
    'save': 'Ħżen',
    'cancel': 'Ikkanċella'
  },
  'is': { // Icelandic
    'locale': 'is',
    'appName': 'Flow Ai',
    'appTagline': 'AI Tíðablóðrásareftirlit',
    'home': 'Heim',
    'calendar': 'Dagatal',
    'tracking': 'Eftirlit',
    'insights': 'Innsýn',
    'settings': 'Stillingar',
    'welcome': 'Velkomin í Flow Ai',
    'getStarted': 'Byrja',
    'yes': 'Já',
    'no': 'Nei',
    'save': 'Vista',
    'cancel': 'Hætta við'
  },
  'ga': { // Irish
    'locale': 'ga',
    'appName': 'Flow Ai',
    'appTagline': 'Rianadh Timthriall Mhíosta le hAI',
    'home': 'Baile',
    'calendar': 'Féilire',
    'tracking': 'Rianadh',
    'insights': 'Léargais',
    'settings': 'Socruithe',
    'welcome': 'Fáilte go Flow Ai',
    'getStarted': 'Tosaigh',
    'yes': 'Tá',
    'no': 'Níl',
    'save': 'Sábháil',
    'cancel': 'Cealaigh'
  },
  'cy': { // Welsh
    'locale': 'cy',
    'appName': 'Flow Ai',
    'appTagline': 'Olrhain Cylchred Misglwyf gyda AI',
    'home': 'Cartref',
    'calendar': 'Calendr',
    'tracking': 'Olrhain',
    'insights': 'Mewnwelediadau',
    'settings': 'Gosodiadau',
    'welcome': 'Croeso i Flow Ai',
    'getStarted': 'Dechrau',
    'yes': 'Ie',
    'no': 'Na',
    'save': 'Cadw',
    'cancel': 'Canslo'
  }
};

void main() async {
  print('🌍 Generating 36 language ARB files for Flow Ai...\n');
  
  final l10nDir = Directory('lib/l10n');
  if (!await l10nDir.exists()) {
    await l10nDir.create(recursive: true);
  }

  int created = 0;
  for (final entry in languageTranslations.entries) {
    final locale = entry.key;
    final translations = entry.value;
    
    // Skip if we already have manually created comprehensive versions
    if (locale == 'en' || locale == 'es' || locale == 'fr') {
      print('📋 Skipping $locale (already has comprehensive version)');
      continue;
    }
    
    final filename = 'app_$locale.arb';
    final filepath = 'lib/l10n/$filename';
    final file = File(filepath);
    
    // Create ARB content
    final Map<String, dynamic> arbContent = {
      '@@locale': locale,
      '@@last_modified': DateTime.now().toUtc().toIso8601String(),
    };
    
    // Add translations
    translations.forEach((key, value) {
      if (key != 'locale') {
        arbContent[key] = value;
      }
    });
    
    // Write file
    final jsonContent = JsonEncoder.withIndent('  ').convert(arbContent);
    await file.writeAsString(jsonContent);
    
    created++;
    print('✅ Created $filename (${translations.length - 1} strings)');
  }
  
  print('\n🎉 Successfully generated $created language files!');
  print('📊 Total supported languages: ${languageTranslations.length}');
  print('\nSupported locales:');
  for (var locale in languageTranslations.keys) {
    print('  • $locale');
  }
}
