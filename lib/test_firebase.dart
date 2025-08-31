import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

class FirebaseTestService {
  static Future<void> testConnection() async {
    try {
      // Test Firebase Core
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase Core initialized successfully');
      
      // Test Firebase Auth
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      print('🔐 Firebase Auth: ${user?.uid ?? "No user signed in"}');
      
      // Test Firestore
      final firestore = FirebaseFirestore.instance;
      final testDoc = await firestore.collection('test').doc('connection').get();
      print('📄 Firestore connection: ${testDoc.exists ? "Document exists" : "Ready to write"}');
      
      // Write a test document
      await firestore.collection('test').doc('connection').set({
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'message': 'Firebase connection successful',
        'app': 'Flow Ai',
      });
      print('📝 Test document written to Firestore');
      
    } catch (e) {
      print('❌ Firebase test failed: $e');
    }
  }
}
