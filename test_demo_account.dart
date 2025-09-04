// Quick test script to verify demo account creation
// Run this with: dart test_demo_account.dart

import 'lib/core/services/local_user_service.dart';

void main() async {
  print('🧪 Testing demo account creation...');
  
  try {
    final service = LocalUserService();
    await service.initialize();
    
    // Try to sign in with demo credentials
    final result = await service.signInUser(
      email: 'ronos.ai@icloud.com',
      password: 'Jubemol1',
    );
    
    if (result.isSuccess) {
      print('✅ SUCCESS: Demo account login works!');
      print('📧 Email: ${result.user?.email}');
      print('👤 Name: ${result.user?.displayName}');
      print('🔤 Username: ${result.user?.username}');
      print('📝 Notes: ${result.user?.profileData.notes.length} notes');
      print('🔢 Age: ${result.user?.profileData.age}');
      print('📅 Last Period: ${result.user?.profileData.lastPeriodDate}');
      
      // Print sample notes to verify data
      if (result.user?.profileData.notes.isNotEmpty ?? false) {
        print('📋 First note: "${result.user!.profileData.notes.first}"');
      }
      
      print('\n🎉 Demo account is ready for App Store reviewers!');
    } else {
      print('❌ FAILED: ${result.error}');
    }
  } catch (e) {
    print('❌ ERROR: $e');
  }
}
