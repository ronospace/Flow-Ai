
import 'auth_result.dart';

class AuthService {
  bool get isAuthenticated => true;
  dynamic get currentUser => null;
  Duration get sessionTimeout => Duration(minutes:30);

  Future<void> initialize() async {}
  Future<void> checkAuthState() async {}
  Future<void> signOut() async {}

  Future<AuthResult> signInWithEmail({required String email, required String password}) async => AuthResult.success();
  Future<AuthResult> signUpWithEmail({required String email, required String password, required String displayName}) async => AuthResult.success();
  Future<AuthResult> resetPassword({required String email}) async => AuthResult.success();
  Future<AuthResult> createDemoAccount() async => AuthResult.success();
  Future<AuthResult> signInWithGoogle() async => AuthResult.success();
  Future<AuthResult> signInWithApple() async => AuthResult.success();

  Future<bool> isBiometricEnabled() async => true;
  Future<bool> authenticateWithBiometrics() async => true;
  Future<bool> isEmailRegistered(String email) async => false;
  Future<void> setBiometricEnabled(bool value) async {}

  Future<void> setCurrentUser(dynamic user) async {}
  Future<void> updateUserProfile(String name, String? email) async {}
  Future<dynamic> getCurrentUser() async => null;
  Future<dynamic> getUserData() async => null;

  bool isValidEmail(String email) => email.contains('@');
  bool isValidPassword(String password) => password.length>5;
}
