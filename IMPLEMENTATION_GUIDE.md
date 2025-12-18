# Flow Ai/iQ Implementation Guide
## Quick Reference for All 4 Requested Features + Flow iQ Integration

---

## 1. Multi-Select Journal Quick Notes ✅

### Current Implementation
**File**: `lib/features/cycle/screens/tracking_screen.dart` (lines 968-1005)

Currently, quick notes (`🌙 Sleep quality`, `🍎 Food cravings`, etc.) append text to the notes field when tapped. They disappear once the user starts typing.

### Required Changes

#### Step 1: Create a Multi-Select State Variable
```dart
// Add to _TrackingScreenState class
Set<String> _selectedQuickNotes = {};
```

#### Step 2: Modify _buildQuickNote Widget
**Location**: Line 997
```dart
Widget _buildQuickNote(String emoji, String label) {
  final theme = Theme.of(context);
  final isSelected = _selectedQuickNotes.contains(label);
  
  return GestureDetector(
    onTap: () {
      setState(() {
        if (isSelected) {
          _selectedQuickNotes.remove(label);
        } else {
          _selectedQuickNotes.add(label);
        }
      });
      _markUnsavedChanges();
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppTheme.primaryRose.withValues(alpha: 0.15)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? AppTheme.primaryRose 
              : theme.dividerColor,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: AppTheme.primaryRose.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected 
                  ? AppTheme.primaryRose 
                  : theme.colorScheme.onSurface,
            ),
          ),
          if (isSelected) ...[\n            const SizedBox(width: 6),
            Icon(
              Icons.check_circle,
              size: 16,
              color: AppTheme.primaryRose,
            ),
          ],
        ],
      ),
    ),
  );
}
```

#### Step 3: Remove Conditional Hiding
**Location**: Line 969 - Remove the `if (_notesController.text.isEmpty)` condition

Change from:
```dart
if (_notesController.text.isEmpty) ...[\n  Text('Quick Notes', ...),
  // widgets
],
```

To:
```dart
Text('Quick Notes', ...),
const SizedBox(height: 16),
Wrap(
  spacing: 12,
  runSpacing: 12,
  children: [
    _buildQuickNote('🌙', 'Sleep quality'),
    _buildQuickNote('🍎', 'Food cravings'),
    _buildQuickNote('💧', 'Hydration'),
    _buildQuickNote('🏃‍♀️', 'Exercise'),
    _buildQuickNote('😴', 'Energy levels'),
    _buildQuickNote('🧘‍♀️', 'Stress management'),
  ],
),
```

#### Step 4: Save Selected Notes
**Location**: In `_saveTrackingData()` method
```dart
// Add this to the save logic
final quickNotesText = _selectedQuickNotes.isEmpty 
    ? '' 
    : '\n\nQuick Tags: ${_selectedQuickNotes.join(', ')}';

final fullNotes = _notes + quickNotesText;
// Save fullNotes instead of just _notes
```

---

## 2. Remove Demo Account Auto-Login ✅

### Current Implementation
The app has demo account logic in onboarding. Need to disable auto-login.

### Required Changes

#### Step 1: Find Demo Account Logic
Search for:
- `lib/features/onboarding/providers/onboarding_provider.dart`
- `lib/features/auth/` folder

#### Step 2: Modify Sign-In Screen
**File**: Look for sign-in screen (likely `lib/features/auth/screens/sign_in_screen.dart`)

**Remove or Comment Out**:
```dart
// Remove this button or move to developer settings
ElevatedButton(
  child: Text('Demo Account Info'),
  onPressed: () => _loginWithDemo(),
),
```

**Alternative**: Keep for testing, but hide behind developer mode:
```dart
if (kDebugMode) ...[\n  TextButton(
    child: Text('Use Demo Account (Dev Only)'),
    onPressed: () => _loginWithDemo(),
  ),
],
```

#### Step 3: Ensure Proper Auth Flow
**File**: `lib/main.dart` or router configuration

Ensure the initial route logic checks authentication:
```dart
initialRoute: AppStateService().isAuthenticated ? '/home' : '/signin',
```

Do NOT automatically log in demo user on app start.

---

## 3. Settings Icon Visibility Enhancement ✅

### Current Issue
Settings is the 6th tab in bottom nav, requires horizontal scroll/swipe to access.

### Solution A: Add Settings Icon to App Bar (Easiest)

#### Step 1: Modify Home Screen
**File**: `lib/features/cycle/screens/home_screen.dart`

Add to AppBar:
```dart
AppBar(
  title: Text('Flow Ai'),
  actions: [
    IconButton(
      icon: Icon(Icons.settings_outlined),
      tooltip: 'Settings',
      onPressed: () => context.go('/settings'),
    ),
  ],
),
```

#### Step 2: Add to All Major Screens
Add the same settings icon to:
- Calendar screen app bar
- Tracking screen app bar  
- Insights screen app bar
- Health screen app bar

### Solution B: Restructure Bottom Nav (Recommended for Production)

#### Reduce to 5 Tabs
**File**: `lib/features/navigation/` (find main navigation widget)

Change from:
```
Home | Calendar | Track | Insights | Health | Settings (6 tabs)
```

To:
```
Home | Calendar | Track | Insights | Profile (5 tabs)
```

Where Profile includes:
- User info
- Settings (gear icon button)
- Health dashboard link
- Account management

---

## 4. Horizontal Swipe Navigation ✅

### Implementation

#### Step 1: Find Main Navigation Widget
Look for file with `BottomNavigationBar` - likely in:
- `lib/features/navigation/main_navigation.dart` or
- `lib/main.dart` with `Scaffold` + `BottomNavigationBar`

#### Step 2: Refactor to PageView

**Before** (typical structure):
```dart
Scaffold(
  body: _screens[_selectedIndex],
  bottomNavigationBar: BottomNavigationBar(
    currentIndex: _selectedIndex,
    onTap: (index) => setState(() => _selectedIndex = index),
    items: [...],
  ),
)
```

**After** (with PageView):
```dart
class _MainNavigationState extends State<MainNavigation> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          HomeScreen(),
          CalendarScreen(),
          TrackingScreen(),
          InsightsScreen(),
          HealthScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Track'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Insights'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Health'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
```

#### Step 3: Add Physics for Better UX (Optional)
```dart
PageView(
  controller: _pageController,
  physics: const BouncingScrollPhysics(), // iOS-style bounce
  onPageChanged: (index) {
    setState(() => _selectedIndex = index);
  },
  children: [...],
)
```

---

## 5. Flow Ai ↔ Flow iQ Clinical Integration 🏥

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         User Device                          │
│                                                              │
│  ┌────────────────────┐         ┌──────────────────────┐   │
│  │     Flow Ai        │         │     Flow iQ SDK      │   │
│  │  (Consumer App)    │◄────────┤   (Embedded Lib)    │   │
│  │                    │         └──────────────────────┘   │
│  │ • Cycle tracking   │                    │               │
│  │ • Symptoms         │                    │               │
│  │ • AI insights      │                    │               │
│  │ • Biometrics       │                    ▼               │
│  └────────────────────┘         ┌──────────────────────┐   │
│                                  │  Clinical Consent    │   │
│                                  │  & Data Sharing UI   │   │
│                                  └──────────────────────┘   │
└──────────────────────│───────────────────────────────────────┘
                       │
                       │ HTTPS/TLS 1.3
                       │ End-to-End Encrypted
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                  ZyraFlow Cloud Backend                      │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │            Flow iQ Sync API                            │ │
│  │  • Patient data ingestion (pseudonymized)             │ │
│  │  • Real-time webhooks                                 │ │
│  │  • Clinician authentication                           │ │
│  │  • HIPAA-compliant audit logs                         │ │
│  └────────────────────────────────────────────────────────┘ │
│                           │                                  │
│                           ▼                                  │
│  ┌────────────────────────────────────────────────────────┐ │
│  │         FlowSense™ AI Engine (ZyraFlow Labs)          │ │
│  │  • Shared ML models                                   │ │
│  │  • Cycle predictions                                  │ │
│  │  • PCOS/Endometriosis detection                       │ │
│  └────────────────────────────────────────────────────────┘ │
└──────────────────────│───────────────────────────────────────┘
                       │
                       │ Clinical Dashboard API
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                 Flow iQ Clinician Portal                     │
│                 (Web + Mobile Dashboard)                     │
│                                                              │
│  • Patient monitoring dashboards                            │
│  • Irregularity alerts                                      │
│  • Research export tools                                    │
│  • Population analytics                                     │
└─────────────────────────────────────────────────────────────┘
```

### Implementation Phase 1: Flow Ai Clinical Features

#### A. Create Clinical Data Models

**File**: `lib/features/clinical/models/clinical_consent.dart`
```dart
enum DataType {
  cycles,
  symptoms,
  biometrics,
  medications,
  notes,
  aiInsights,
}

class ClinicalConsent {
  final String id;
  final String userId;
  final String clinicianId;
  final String clinicianName;
  final String clinicName;
  final List<DataType> authorizedData;
  final DateTime consentDate;
  final DateTime? expirationDate;
  final DateTime? revokedDate;
  final bool autoSync;
  final String? accessCode; // QR code or clinic code

  ClinicalConsent({
    required this.id,
    required this.userId,
    required this.clinicianId,
    required this.clinicianName,
    required this.clinicName,
    required this.authorizedData,
    required this.consentDate,
    this.expirationDate,
    this.revokedDate,
    this.autoSync = true,
    this.accessCode,
  });

  bool get isActive => revokedDate == null && 
      (expirationDate == null || DateTime.now().isBefore(expirationDate!));

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'clinicianId': clinicianId,
    'clinicianName': clinicianName,
    'clinicName': clinicName,
    'authorizedData': authorizedData.map((d) => d.name).toList(),
    'consentDate': consentDate.toIso8601String(),
    'expirationDate': expirationDate?.toIso8601String(),
    'revokedDate': revokedDate?.toIso8601String(),
    'autoSync': autoSync,
    'accessCode': accessCode,
  };
}

class ClinicalSyncStatus {
  final DateTime lastSync;
  final bool isConnected;
  final int pendingRecords;
  final List<String> errors;

  ClinicalSyncStatus({
    required this.lastSync,
    required this.isConnected,
    this.pendingRecords = 0,
    this.errors = const [],
  });
}
```

#### B. Create Clinical Sync Service

**File**: `lib/features/clinical/services/clinical_sync_service.dart`
```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/clinical_consent.dart';
import '../../../core/api/flowiq_api_client.dart';

class ClinicalSyncService {
  static final ClinicalSyncService _instance = ClinicalSyncService._internal();
  factory ClinicalSyncService() => _instance;
  ClinicalSyncService._internal();

  final FlowIQApiClient _apiClient = FlowIQApiClient();
  ClinicalConsent? _activeConsent;
  Timer? _syncTimer;
  
  bool get isConnected => _activeConsent?.isActive ?? false;
  ClinicalConsent? get activeConsent => _activeConsent;

  /// Initialize clinical sync with consent
  Future<void> initialize(ClinicalConsent consent) async {
    _activeConsent = consent;
    if (consent.autoSync) {
      _startAutoSync();
    }
    debugPrint('🏥 Clinical sync initialized for ${consent.clinicName}');
  }

  /// Connect to clinician using access code
  Future<ClinicalConsent> connectWithCode(String accessCode) async {
    // API call to verify code and get clinician info
    final response = await _apiClient.verifyAccessCode(accessCode);
    
    // Create consent (user will review and authorize data types)
    final consent = ClinicalConsent(
      id: response['consentId'],
      userId: 'current_user_id', // Get from auth
      clinicianId: response['clinicianId'],
      clinicianName: response['clinicianName'],
      clinicName: response['clinicName'],
      authorizedData: [], // User selects in next step
      consentDate: DateTime.now(),
      accessCode: accessCode,
    );
    
    return consent;
  }

  /// Start automatic sync (hourly for routine data)
  void _startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(hours: 1), (_) {
      syncData();
    });
  }

  /// Sync all authorized data to Flow iQ
  Future<void> syncData() async {
    if (!isConnected) return;
    
    try {
      final dataToSync = await _prepareDataForSync();
      await _apiClient.syncClinicalData(_activeConsent!.id, dataToSync);
      debugPrint('✅ Clinical data synced successfully');
    } catch (e) {
      debugPrint('❌ Clinical sync failed: $e');
    }
  }

  /// Prepare anonymized data for sync
  Future<Map<String, dynamic>> _prepareDataForSync() async {
    final data = <String, dynamic>{};
    
    if (_activeConsent!.authorizedData.contains(DataType.cycles)) {
      // Fetch cycle data from local DB
      data['cycles'] = await _getCycleData();
    }
    
    if (_activeConsent!.authorizedData.contains(DataType.symptoms)) {
      data['symptoms'] = await _getSymptomData();
    }
    
    if (_activeConsent!.authorizedData.contains(DataType.biometrics)) {
      data['biometrics'] = await _getBiometricData();
    }
    
    // Pseudonymize: remove PII
    return _anonymizeData(data);
  }

  /// Remove personally identifiable information
  Map<String, dynamic> _anonymizeData(Map<String, dynamic> data) {
    // Replace real user ID with pseudonymized patient ID
    final pseudoId = _generatePseudoId(_activeConsent!.userId);
    return {
      'patientId': pseudoId,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  String _generatePseudoId(String userId) {
    // Use deterministic hash for consistent pseudonymization
    return userId.hashCode.toRadixString(36).toUpperCase();
  }

  /// Revoke consent and stop sync
  Future<void> revokeConsent() async {
    if (_activeConsent == null) return;
    
    await _apiClient.revokeConsent(_activeConsent!.id);
    _syncTimer?.cancel();
    _activeConsent = null;
    debugPrint('🚫 Clinical consent revoked');
  }

  // Placeholder methods - implement with actual DB queries
  Future<List<Map<String, dynamic>>> _getCycleData() async => [];
  Future<List<Map<String, dynamic>>> _getSymptomData() async => [];
  Future<List<Map<String, dynamic>>> _getBiometricData() async => [];

  void dispose() {
    _syncTimer?.cancel();
  }
}
```

#### C. Create Clinical Connection Screen

**File**: `lib/features/clinical/screens/clinical_connection_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; // Add to pubspec.yaml
import '../services/clinical_sync_service.dart';
import '../models/clinical_consent.dart';

class ClinicalConnectionScreen extends StatefulWidget {
  const ClinicalConnectionScreen({super.key});

  @override
  State<ClinicalConnectionScreen> createState() => _ClinicalConnectionScreenState();
}

class _ClinicalConnectionScreenState extends State<ClinicalConnectionScreen> {
  final _codeController = TextEditingController();
  final _syncService = ClinicalSyncService();
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect with Clinician'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Securely share your health data with your healthcare provider for personalized care.',
                      style: TextStyle(color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Manual code entry
            Text(
              'Enter Clinic Code',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: 'e.g., CLINIC-12345',
                prefixIcon: const Icon(Icons.medical_services),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _connectWithCode(_codeController.text),
                icon: const Icon(Icons.link),
                label: const Text('Connect with Code'),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Divider
            Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('OR'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // QR code scanner
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _scanQRCode,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Clinic QR Code'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connectWithCode(String code) async {
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a clinic code')),
      );
      return;
    }

    try {
      // Verify code and get clinician info
      final consent = await _syncService.connectWithCode(code);
      
      // Navigate to consent review screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConsentReviewScreen(consent: consent),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid code: $e')),
      );
    }
  }

  Future<void> _scanQRCode() async {
    // Implement QR scanner
    // When scanned, call _connectWithCode(scannedCode)
  }
}
```

#### D. Add to Settings Screen

**File**: `lib/features/settings/screens/settings_screen.dart`

Add this tile to settings:
```dart
ListTile(
  leading: const Icon(Icons.medical_services, color: Colors.blue),
  title: const Text('Clinical Data Sharing'),
  subtitle: ClinicalSyncService().isConnected
      ? const Text('Connected • Auto-sync enabled')
      : const Text('Not connected'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ClinicalConnectionScreen(),
    ),
  ),
),
```

### GitHub Repository Structure

Create separate repository for Flow iQ:

```
/Flow-iQ/
├── README.md
├── lib/
│   ├── main.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── clinician_auth_service.dart
│   │   │   └── clinician_login_screen.dart
│   │   ├── dashboard/
│   │   │   ├── patient_list_screen.dart
│   │   │   ├── patient_detail_screen.dart
│   │   │   └── alerts_dashboard.dart
│   │   ├── analytics/
│   │   │   ├── population_analytics.dart
│   │   │   └── research_export.dart
│   │   └── models/
│   │       ├── patient_data.dart
│   │       └── clinical_alert.dart
│   └── core/
│       ├── api/
│       │   └── flow_ai_sync_api.dart
│       └── services/
│           └── real_time_sync_service.dart
├── web/
├── test/
└── pubspec.yaml
```

---

## Security & Compliance Checklist

### HIPAA Compliance
- [ ] All data encrypted in transit (TLS 1.3)
- [ ] At-rest encryption (AES-256)
- [ ] Audit logs for all data access
- [ ] User-controlled granular permissions
- [ ] Right to revoke consent
- [ ] Data anonymization (pseudonymized patient IDs)

### GDPR Compliance
- [ ] Explicit user consent before data sharing
- [ ] Right to data portability
- [ ] Right to be forgotten
- [ ] Data minimization (only share authorized types)
- [ ] Purpose limitation (clinical care only)

---

## Testing Recommendations

### Unit Tests
- Multi-select quick notes state management
- Clinical consent model validation
- Data anonymization logic

### Integration Tests
- Flow Ai → Flow iQ data sync
- Real-time webhook delivery
- Consent revocation flow

### UI Tests
- Swipe navigation between tabs
- Settings icon visibility on all screens
- Clinical connection QR scan flow

---

## Deployment Priority

1. **Week 1**: Multi-select journal + Demo account fix (user-facing)
2. **Week 2**: Settings visibility + Swipe navigation (UX polish)
3. **Week 3-4**: Flow iQ clinical models and UI (Flow Ai side)
4. **Month 2**: Flow iQ backend API + clinician portal
5. **Month 3**: Production launch with clinical beta testers

---

**Document Prepared**: December 6, 2025  
**For**: ZyraFlow Inc. - Flow Ai/iQ Integration  
**Next Review**: After Phase 1 implementation
