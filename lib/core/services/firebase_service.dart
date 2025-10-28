import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firebase service for managing authentication and cloud sync
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  bool _initialized = false;

  /// Get Firebase Auth instance
  FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return _auth!;
  }

  /// Get Firestore instance
  FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return _firestore!;
  }

  /// Check if Firebase is initialized
  bool get isInitialized => _initialized;

  /// Get current user
  User? get currentUser => _auth?.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Initialize Firebase
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('✅ Firebase already initialized');
      return;
    }

    try {
      debugPrint('🔥 Initializing Firebase...');
      
      // Initialize Firebase
      await Firebase.initializeApp();
      
      // Get instances
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      
      // Configure Firestore settings for optimal performance
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
      _initialized = true;
      
      debugPrint('✅ Firebase initialized successfully');
      debugPrint('   Auth: ${_auth != null}');
      debugPrint('   Firestore: ${_firestore != null}');
      debugPrint('   User: ${currentUser?.email ?? "Not signed in"}');
      
    } catch (e, stackTrace) {
      debugPrint('❌ Firebase initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Don't throw - allow app to continue without Firebase
      _initialized = false;
    }
  }

  /// Sign in anonymously
  Future<UserCredential?> signInAnonymously() async {
    try {
      debugPrint('🔑 Signing in anonymously...');
      final credential = await auth.signInAnonymously();
      debugPrint('✅ Anonymous sign in successful: ${credential.user?.uid}');
      return credential;
    } catch (e) {
      debugPrint('❌ Anonymous sign in failed: $e');
      return null;
    }
  }

  /// Sign in with email and password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      debugPrint('🔑 Signing in with email: $email');
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ Email sign in successful: ${credential.user?.email}');
      return credential;
    } catch (e) {
      debugPrint('❌ Email sign in failed: $e');
      return null;
    }
  }

  /// Create account with email and password
  Future<UserCredential?> createAccountWithEmail(
    String email,
    String password,
  ) async {
    try {
      debugPrint('📝 Creating account with email: $email');
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ Account created successfully: ${credential.user?.email}');
      return credential;
    } catch (e) {
      debugPrint('❌ Account creation failed: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      debugPrint('🚪 Signing out...');
      await auth.signOut();
      debugPrint('✅ Sign out successful');
    } catch (e) {
      debugPrint('❌ Sign out failed: $e');
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('📧 Sending password reset email to: $email');
      await auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent');
      return true;
    } catch (e) {
      debugPrint('❌ Password reset email failed: $e');
      return false;
    }
  }

  /// Get user document reference
  DocumentReference getUserDocument(String userId) {
    return firestore.collection('users').doc(userId);
  }

  /// Get user cycles collection reference
  CollectionReference getUserCyclesCollection(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('cycles');
  }

  /// Get user tracking data collection reference
  CollectionReference getUserTrackingCollection(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('tracking');
  }

  /// Save user data to Firestore
  Future<bool> saveUserData(Map<String, dynamic> data) async {
    if (!isSignedIn) {
      debugPrint('⚠️ Cannot save user data: Not signed in');
      return false;
    }

    try {
      debugPrint('💾 Saving user data for: ${currentUser!.uid}');
      await getUserDocument(currentUser!.uid).set(
        {
          ...data,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      debugPrint('✅ User data saved successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to save user data: $e');
      return false;
    }
  }

  /// Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    if (!isSignedIn) {
      debugPrint('⚠️ Cannot get user data: Not signed in');
      return null;
    }

    try {
      debugPrint('📖 Loading user data for: ${currentUser!.uid}');
      final doc = await getUserDocument(currentUser!.uid).get();
      
      if (doc.exists) {
        debugPrint('✅ User data loaded successfully');
        return doc.data() as Map<String, dynamic>?;
      } else {
        debugPrint('⚠️ User document does not exist');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Failed to get user data: $e');
      return null;
    }
  }

  /// Sync cycle data to Firestore
  Future<bool> syncCycleData(Map<String, dynamic> cycleData) async {
    if (!isSignedIn) {
      debugPrint('⚠️ Cannot sync cycle data: Not signed in');
      return false;
    }

    try {
      final cycleId = cycleData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      debugPrint('🔄 Syncing cycle data: $cycleId');
      
      await getUserCyclesCollection(currentUser!.uid).doc(cycleId).set(
        {
          ...cycleData,
          'syncedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      
      debugPrint('✅ Cycle data synced successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to sync cycle data: $e');
      return false;
    }
  }

  /// Sync tracking data to Firestore
  Future<bool> syncTrackingData(
    DateTime date,
    Map<String, dynamic> trackingData,
  ) async {
    if (!isSignedIn) {
      debugPrint('⚠️ Cannot sync tracking data: Not signed in');
      return false;
    }

    try {
      final dateKey = date.toIso8601String().split('T')[0];
      debugPrint('🔄 Syncing tracking data for: $dateKey');
      
      await getUserTrackingCollection(currentUser!.uid).doc(dateKey).set(
        {
          ...trackingData,
          'date': Timestamp.fromDate(date),
          'syncedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      
      debugPrint('✅ Tracking data synced successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to sync tracking data: $e');
      return false;
    }
  }

  /// Listen to user data changes
  Stream<DocumentSnapshot> watchUserData() {
    if (!isSignedIn) {
      throw Exception('Cannot watch user data: Not signed in');
    }
    return getUserDocument(currentUser!.uid).snapshots();
  }

  /// Listen to cycles collection
  Stream<QuerySnapshot> watchCycles() {
    if (!isSignedIn) {
      throw Exception('Cannot watch cycles: Not signed in');
    }
    return getUserCyclesCollection(currentUser!.uid)
        .orderBy('startDate', descending: true)
        .snapshots();
  }

  /// Delete user account and all data
  Future<bool> deleteAccount() async {
    if (!isSignedIn) {
      debugPrint('⚠️ Cannot delete account: Not signed in');
      return false;
    }

    try {
      final userId = currentUser!.uid;
      debugPrint('🗑️ Deleting account: $userId');
      
      // Delete user data from Firestore
      await getUserDocument(userId).delete();
      
      // Delete user account from Firebase Auth
      await currentUser!.delete();
      
      debugPrint('✅ Account deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete account: $e');
      return false;
    }
  }
}
