import 'auth_service.dart';
import 'biometric_auth_service.dart';

/// Memory-only lock for an already authenticated account session.
///
/// No passwords, provider tokens, Apple authorisation codes or biometric
/// material are persisted by this service.
class AppLockService {
  static final AppLockService _instance = AppLockService._internal();

  factory AppLockService() => _instance;

  AppLockService._internal();

  final BiometricAuthService _biometricAuth = BiometricAuthService();
  bool _isUnlocked = false;

  bool get isUnlocked => _isUnlocked;

  void markUnlocked() {
    _isUnlocked = true;
  }

  void lock() {
    _isUnlocked = false;
  }

  void reset() {
    _isUnlocked = false;
  }

  Future<bool> shouldRequireLock() async {
    final auth = AuthService();
    if (!auth.isInitialized) {
      await auth.initialize();
    }

    final authenticated = await auth.isAuthenticated;
    return authenticated && auth.isBiometricEnabled() && !_isUnlocked;
  }

  Future<BiometricAuthResult> unlock() async {
    final auth = AuthService();
    if (!auth.isInitialized) {
      await auth.initialize();
    }

    if (!await auth.isAuthenticated) {
      return const BiometricAuthResult(
        status: AuthStatus.failed,
        errorMessage:
            'Your account session has ended. Sign in with your account provider first.',
      );
    }

    if (!auth.isBiometricEnabled()) {
      return const BiometricAuthResult(
        status: AuthStatus.disabled,
        errorMessage: 'Biometric app lock is not enabled.',
      );
    }

    final result = await _biometricAuth.authenticateForAppLock();
    if (result.isSuccess) {
      _isUnlocked = true;
    }
    return result;
  }
}
