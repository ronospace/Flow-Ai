import 'package:flow_ai/core/services/app_lock_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flow_ai/core/deeplinks/pending_deep_link_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_auth/local_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/layout/app_layout_metrics.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/services/platform_service.dart';
import '../../../core/ui/adaptive_components.dart';
import '../../../core/ui/adaptive_messages.dart';
import '../../../generated/app_localizations.dart';
import '../../../core/widgets/modern_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';
import '../widgets/biometric_button.dart';
import '../../../core/widgets/flow_ai_logo.dart';
import '../../settings/providers/settings_provider.dart';
import '../services/auth_provider_coordinator.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialIsLogin = true});

  final bool initialIsLogin;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  GoRouter get _router => GoRouter.of(context);
  SettingsProvider get _settingsProvider => context.read<SettingsProvider>();

  late AnimationController _headerController;
  late AnimationController _socialController;

  final LocalAuthentication _localAuth = LocalAuthentication();
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late bool _isLogin;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _biometricsAvailable = false;
  List<BiometricType> _availableBiometrics = [];
  bool _showForgotPassword = false; // Only show after failed login attempt
  String? _emailError;
  String? _passwordError;
  String? _displayNameError;
  String? _confirmPasswordError;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialIsLogin;
    _initializeControllers();
    _checkBiometrics();
    _startAnimations();
  }

  void _initializeControllers() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _socialController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  void _startAnimations() {
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      _socialController.forward();
    });
  }

  Future<void> _checkBiometrics() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (!mounted) return;

      setState(() {
        _biometricsAvailable =
            isAvailable && isDeviceSupported && availableBiometrics.isNotEmpty;
        _availableBiometrics = availableBiometrics;
      });
    } catch (e) {}
  }

  @override
  void dispose() {
    _headerController.dispose();
    _socialController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Use adaptive scaffold that automatically adjusts to platform conventions
    return AdaptiveComponents.adaptiveScaffold(
      context: context,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryRose.withValues(alpha: 0.12),
              AppTheme.primaryPurple.withValues(alpha: 0.045),
              theme.brightness == Brightness.dark
                  ? AppTheme.darkBackground
                  : Colors.white,
            ],
            stops: const [0.0, 0.42, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mq = MediaQuery.of(context);



              final keyboardInset = mq.viewInsets.bottom;
              final availableHeight = constraints.maxHeight > keyboardInset
                  ? constraints.maxHeight - keyboardInset
                  : 0.0;


              final authScrollView = SingleChildScrollView(
                physics: context.adaptiveScrollPhysics,
                padding: EdgeInsets.only(bottom: keyboardInset),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: availableHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header Section
                      _buildHeader(theme, l10n, availableHeight),

                      // Unified authentication hub
                      _buildAuthForm(theme, l10n),
                    ],
                  ),
                ),
              );


              return authScrollView;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    AppLocalizations l10n,
    double availableHeight,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppLayoutMetrics.authHeaderHorizontal,
        AppLayoutMetrics.authHeaderTop,
        AppLayoutMetrics.authHeaderHorizontal,
        AppLayoutMetrics.authHeaderBottomForHeight(availableHeight),
      ),
      child: KeyedSubtree(
        child:
            FlowAiLogo(size: AppLayoutMetrics.authLogoSize, showWordmark: false)
                .animate(controller: _headerController)
                .scale(
                  begin: const Offset(
                    AppLayoutMetrics.authLogoEntranceScale,
                    AppLayoutMetrics.authLogoEntranceScale,
                  ),
                )
                .fadeIn(),
      ),
    );
  }

  Widget _buildAuthForm(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppLayoutMetrics.authOuterHorizontal,
        0,
        AppLayoutMetrics.authOuterHorizontal,
        AppLayoutMetrics.authOuterBottom,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayoutMetrics.authCardMaxWidth,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppLayoutMetrics.authCardHorizontal,
              AppLayoutMetrics.authCardTop,
              AppLayoutMetrics.authCardHorizontal,
              AppLayoutMetrics.authCardBottom,
            ),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.surface
                  : Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(
                AppLayoutMetrics.authCardRadius,
              ),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? theme.colorScheme.outline
                    : Colors.white.withValues(alpha: 0.9),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.06),
                  blurRadius: AppLayoutMetrics.authCardShadowBlur,
                  offset: const Offset(
                    0,
                    AppLayoutMetrics.authCardShadowYOffset,
                  ),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'Flow Ai',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: AppLayoutMetrics.authWordmarkLetterSpacing,
                    ),
                  ),
                ),
                const SizedBox(height: AppLayoutMetrics.gap),
                _buildSocialLogin(theme),

                if (_biometricsAvailable && _isLogin) ...[
                  const SizedBox(height: AppLayoutMetrics.gap),
                  BiometricButton(
                    availableBiometrics: _availableBiometrics,
                    onBiometricLogin: _handleBiometricLogin,
                  ).animate().slideY(begin: 0.2, end: 0).fadeIn(),
                ],

                const SizedBox(height: AppLayoutMetrics.authDividerGap),
                _buildManualDivider(theme),
                const SizedBox(height: AppLayoutMetrics.authDividerGap),

                // Email Field - using adaptive text field
                AdaptiveComponents.adaptiveTextField(
                      context: context,
                      controller: _emailController,
                      labelText: 'E-mail address:',
                      hintText: 'Enter your E-mail',
                      prefixIcon: const Icon(Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                      errorText: _emailError,
                      onChanged: (_) {
                        if (_emailError != null || _formError != null) {
                          setState(() {
                            _emailError = null;
                            _formError = null;
                          });
                        }
                      },
                      textInputAction: TextInputAction.next,
                    )
                    .animate()
                    .slideY(begin: 0.3, end: 0)
                    .fadeIn(delay: _isLogin ? 200.ms : 0.ms),

                const SizedBox(height: AppLayoutMetrics.authFieldGap),

                // Display Name Field (Sign Up only) - using adaptive text field
                if (!_isLogin) ...[
                  AdaptiveComponents.adaptiveTextField(
                    context: context,
                    controller: _displayNameController,
                    labelText: 'Display name',
                    hintText: 'Enter your display name',
                    prefixIcon: const Icon(Icons.person_outline),
                    enabled: !_isLoading,
                    errorText: _displayNameError,
                    onChanged: (_) {
                      if (_displayNameError != null || _formError != null) {
                        setState(() {
                          _displayNameError = null;
                          _formError = null;
                        });
                      }
                    },
                    textInputAction: TextInputAction.next,
                  ).animate().slideY(begin: 0.3, end: 0).fadeIn(delay: 100.ms),

                  const SizedBox(height: AppLayoutMetrics.authFieldGap),
                ],

                // Password Field - using adaptive text field
                AdaptiveComponents.adaptiveTextField(
                      context: context,
                      controller: _passwordController,
                      labelText: 'Password:',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      obscureText: _obscurePassword,
                      enabled: !_isLoading,
                      textInputAction: _isLogin
                          ? TextInputAction.done
                          : TextInputAction.next,
                      errorText: _passwordError,
                      onChanged: (_) {
                        if (_passwordError != null || _formError != null) {
                          setState(() {
                            _passwordError = null;
                            _formError = null;
                          });
                        }
                      },
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                          context.hapticFeedback(HapticFeedbackType.selection);
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppTheme.mediumGrey,
                        ),
                      ),
                    )
                    .animate()
                    .slideY(begin: 0.3, end: 0)
                    .fadeIn(delay: _isLogin ? 300.ms : 100.ms),

                // Forgot Password (Login only) - only show after failed login attempt
                if (_isLogin && _showForgotPassword) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _handleForgotPassword,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryRose,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(),
                ],

                const SizedBox(height: AppLayoutMetrics.authFieldGap),

                // Confirm Password Field (Sign Up only) - using adaptive text field
                if (!_isLogin) ...[
                  AdaptiveComponents.adaptiveTextField(
                    context: context,
                    controller: _confirmPasswordController,
                    labelText: 'Confirm password',
                    hintText: 'Re-enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    obscureText: _obscureConfirmPassword,
                    enabled: !_isLoading,
                    textInputAction: TextInputAction.done,
                    errorText: _confirmPasswordError,
                    onChanged: (_) {
                      if (_confirmPasswordError != null || _formError != null) {
                        setState(() {
                          _confirmPasswordError = null;
                          _formError = null;
                        });
                      }
                    },
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                        context.hapticFeedback(HapticFeedbackType.selection);
                      },
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.mediumGrey,
                      ),
                    ),
                  ).animate().slideY(begin: 0.3, end: 0).fadeIn(delay: 200.ms),

                  const SizedBox(height: AppLayoutMetrics.authFieldGap),
                ],

                if (_formError != null) ...[
                  _buildInlineFormError(theme),
                  const SizedBox(height: AppLayoutMetrics.authFieldGap),
                ],

                // Submit Button - using adaptive button with platform-specific styling
                AdaptiveComponents.adaptiveButton(
                  context: context,
                  text: _isLoading
                      ? (_isLogin ? 'Signing In...' : 'Creating Account...')
                      : (_isLogin ? 'Sign In' : 'Create Account'),
                  onPressed: _isLoading ? null : _handleSubmit,
                  isPrimary: true,
                  width: double.infinity,
                  height: AppLayoutMetrics.authPrimaryActionHeight,
                  padding: EdgeInsets.zero,
                ).animate().slideY(begin: 0.3, end: 0).fadeIn(delay: 500.ms),

                const SizedBox(height: AppLayoutMetrics.authSubmitModeGap),

                _buildAccountModeAction(theme),

                const SizedBox(
                  height: AppLayoutMetrics.authCardBottomContentGap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInlineFormError(ThemeData theme) {
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const ValueKey('auth_inline_error'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.error.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: theme.colorScheme.onErrorContainer,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _formError!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setFormError(String message) {
    if (!mounted) return;
    setState(() => _formError = message);
  }

  void _switchAuthMode(bool isLogin) {
    if (_isLoading || _isLogin == isLogin) return;

    setState(() {
      _isLogin = isLogin;
      _showForgotPassword = false;
      _formError = null;
      _emailError = null;
      _passwordError = null;
      _displayNameError = null;
      _confirmPasswordError = null;
    });

    context.hapticFeedback(HapticFeedbackType.selection);
  }

  Widget _buildAccountModeAction(ThemeData theme) {
    final prefix = _isLogin ? 'New here?' : 'Already have an account?';
    final action = _isLogin ? 'Create account' : 'Sign in';

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          prefix,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : () => _switchAuthMode(!_isLogin),
          child: Text(action),
        ),
      ],
    );
  }

  Widget _buildManualDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerColor.withValues(alpha: 0.28),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayoutMetrics.authDividerLabelHorizontal,
          ),
          child: Text(
            'Or use E-mail',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.mediumGrey,
              fontSize: AppLayoutMetrics.authDividerLabelFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerColor.withValues(alpha: 0.28),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildSocialLogin(ThemeData theme) {
    final isIOS = PlatformService().platformInfo.platform == TargetPlatform.iOS;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isIOS)
          SocialLoginButton(
            icon: Icons.apple,
            label: 'Continue with Apple',
            onPressed: _isLoading ? null : _handleAppleSignIn,
            backgroundColor: Colors.black,
            iconColor: Colors.white,
            textColor: Colors.white,
          )
        else
          SocialLoginButton(
            icon: Icons.g_mobiledata,
            label: 'Continue with Google',
            onPressed: _isLoading ? null : _handleGoogleSignIn,
            backgroundColor: Colors.white,
            iconColor: const Color(0xFF4285F4),
          ),
      ],
    );
  }

  Future<void> _handleBiometricLogin() async {
    await _authService.initialize();
    final biometricName = Theme.of(context).platform == TargetPlatform.iOS
        ? 'Face ID'
        : 'fingerprint';

    if (!await _authService.isAuthenticated ||
        !_authService.isBiometricEnabled()) {
      await _showBiometricError(
        'Sign in first to enable $biometricName login.',
      );
      return;
    }

    if (!_biometricsAvailable) {
      try {
        final isDeviceSupported = await _localAuth.isDeviceSupported();
        final canCheckBiometrics = await _localAuth.canCheckBiometrics;
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        final biometricsEnabled = _authService.isBiometricEnabled();

        if (!isDeviceSupported || !canCheckBiometrics) {
          await _showBiometricError(
            'Biometric login is not supported on this device.',
          );
          return;
        }

        if (availableBiometrics.isEmpty) {
          await _showBiometricError(
            'No fingerprint or biometric is enrolled. '
            'Set one up in your device settings.',
          );
          return;
        }

        if (!biometricsEnabled) {
          await _showBiometricError(
            'Biometric login is not enabled for this account. '
            'Sign in with your password, then enable it in Settings.',
          );
          return;
        }
      } catch (error) {
        await _showBiometricError(
          'Unable to check biometric availability. Please try again.',
        );
        return;
      }
    }
    setState(() {
      _isLoading = true;
    });

    try {
      if (!mounted) return;
      final result = await _authService.authenticateWithBiometrics();

      if (!mounted) return;

      if (result.isSuccess) {
        AppLockService().markUnlocked();
        HapticFeedback.lightImpact();
        // suppressed biometric banner

        // Sync user data immediately to ensure username is captured and available
        try {
          // _settingsProvider captured above
          // Force an immediate sync to capture fresh auth data
          await _settingsProvider.forceUserDataSync();

          if (!mounted) return;
        } catch (syncError) {}

        Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // Navigate to main app
        if (mounted) {
          await _navigateAfterAuth(result);
        }
      } else {
        await _showBiometricError(
          result.error ?? 'Biometric authentication failed',
        );
      }
    } catch (e) {
      await _showBiometricError(
        'Biometric authentication failed. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showBiometricError(String message) async {
    if (!mounted) return;
    _setFormError(message);
  }

  Future<void> _navigateAfterAuth(AuthResult result) async {
    final route = await AppStateService().getPostAuthRoute(
      isNewUser: result.isNewUser,
    );

    if (!mounted) return;

    if (route == '/home') {
      final pending = PendingDeepLinkService.consumePendingRoute();
      _router.go(pending ?? '/home');
      PendingDeepLinkService.clearPendingRoute();
      return;
    }

    _router.go(route);
  }

  Future<void> _handleSubmit() async {
    if (_isLoading) return;

    final emailError = _emailController.text.trim().isEmpty
        ? 'Enter your E-mail address.'
        : null;
    final passwordError = _passwordController.text.isEmpty
        ? 'Enter your password.'
        : (!_isLogin && _passwordController.text.length < 8
              ? 'Use at least 8 characters.'
              : null);
    final displayNameError =
        !_isLogin && _displayNameController.text.trim().isEmpty
        ? 'Enter your display name.'
        : null;
    final confirmPasswordError =
        !_isLogin && _confirmPasswordController.text != _passwordController.text
        ? 'Passwords do not match.'
        : null;

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _displayNameError = displayNameError;
      _confirmPasswordError = confirmPasswordError;
      _formError = null;
    });

    if (emailError != null ||
        passwordError != null ||
        displayNameError != null ||
        confirmPasswordError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      late final AuthResult result;

      if (_isLogin) {
        // Handle login
        result = await _authService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (!result.isSuccess) {
          // Show forgot password after failed login attempt
          setState(() {
            _showForgotPassword = true;
          });
          throw Exception(result.error);
        }
        // Reset forgot password visibility on successful login
        setState(() {
          _showForgotPassword = false;
        });
      } else {
        // Check if email already exists before attempting sign up
        // router + _settingsProvider captured before async gaps

        final emailExists = await _authService.isEmailKnownOnDevice(
          _emailController.text.trim(),
        );
        if (emailExists) {
          // Email exists, suggest sign in instead
          setState(() {
            _isLoading = false;
            _isLogin = true; // Switch to login mode
            _showForgotPassword = false; // Reset when switching to login
          });
          _showErrorMessage(
            'An account with this E-mail already exists. Please sign in instead.',
          );
          return; // Exit early
        }

        // Handle sign up
        result = await _authService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _displayNameController.text.trim(),
        );
        if (!result.isSuccess) {
          throw Exception(result.error);
        }
      }

      // Sync user data immediately to ensure username is captured and available
      try {
        _settingsProvider.initializeSettings();
        if (!mounted) return;
        // Force an immediate sync to capture fresh auth data
        await _settingsProvider.forceUserDataSync();
        if (!mounted) return;
      } catch (syncError) {}

      // Navigate to main app
      Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;

      await _navigateAfterAuth(result);
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      _showErrorMessage(_formatAuthError(errorMessage, isLogin: _isLogin));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    await _handleProviderSignIn(AuthProviderType.google);
  }

  Future<void> _handleAppleSignIn() async {
    await _handleProviderSignIn(AuthProviderType.apple);
  }

  Future<void> _handleProviderSignIn(AuthProviderType provider) async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _formError = null;
    });

    try {
      final result = await AuthProviderCoordinator().authenticate(
        context: context,
        provider: provider,
      );

      if (!mounted || result.isSuccess || result.isCancelled) {
        return;
      }

      _setFormError(result.error ?? 'Authentication could not be completed.');
    } catch (_) {
      if (!mounted) {
        return;
      }

      _setFormError('Authentication could not be completed. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleForgotPassword() {
    // Show forgot password dialog
    _showForgotPasswordDialog();
  }

  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();
    bool isResetting = false;
    bool didCloseDialog = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).cardColor,
                      Theme.of(context).cardColor.withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.primaryRose.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryRose.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.primaryRose,
                            AppTheme.primaryPurple,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Reset Password',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkGrey,
                          ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Enter your E-mail address and we\'ll send you a link to reset your password.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.mediumGrey,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // Email Input
                    AuthTextField(
                      controller: resetEmailController,
                      hintText: 'Enter your E-mail',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isResetting,
                    ),

                    const SizedBox(height: 28),

                    // Full-width actions prevent label truncation and
                    // provide a 48 logical-pixel interaction height.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ModernButton(
                          text: isResetting ? 'Sending...' : 'Send Reset Link',
                          isLoading: isResetting,
                          isExpanded: true,
                          onPressed: isResetting
                              ? null
                              : () async {
                                  if (resetEmailController.text
                                      .trim()
                                      .isEmpty) {
                                    _showErrorMessage(
                                      'Please enter your email address',
                                    );
                                    return;
                                  }

                                  setState(() => isResetting = true);

                                  try {
                                    final dialogNavigator = Navigator.of(
                                      dialogContext,
                                    );

                                    if (!mounted) return;

                                    final result = await _authService
                                        .resetPassword(
                                          resetEmailController.text.trim(),
                                        );

                                    if (!mounted) return;
                                    if (result.isSuccess) {
                                      didCloseDialog = true;
                                      dialogNavigator.pop();
                                      _showSuccessMessage(
                                        'If an account exists for this email, '
                                        'a reset link has been sent.',
                                      );
                                    } else {
                                      throw Exception(result.error);
                                    }
                                  } catch (_) {
                                    _showErrorMessage(
                                      'We could not send the reset email. '
                                      'Please try again.',
                                    );
                                  } finally {
                                    if (!didCloseDialog &&
                                        dialogContext.mounted) {
                                      setState(() => isResetting = false);
                                    }
                                  }
                                },
                          size: ModernButtonSize.large,
                        ),
                        const SizedBox(height: 12),
                        ModernButton(
                          text: 'Cancel',
                          isExpanded: true,
                          onPressed: isResetting
                              ? null
                              : () {
                                  Navigator.of(dialogContext).pop();
                                },
                          type: ModernButtonType.secondary,
                          size: ModernButtonSize.large,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(resetEmailController.dispose);
  }

  String _formatAuthError(String message, {required bool isLogin}) {
    final normalized = message
        .replaceFirst('Exception: ', '')
        .replaceFirst('Sign in failed: ', '')
        .replaceFirst('Sign up failed: ', '')
        .trim();

    if (normalized == 'No account found with this email') {
      return 'No account found for this email address.';
    }

    if (normalized == 'Invalid password') {
      return 'The password entered is incorrect.';
    }

    if (normalized == 'Account is deactivated') {
      return 'This account is currently deactivated.';
    }

    if (normalized == 'Local storage not initialized' ||
        normalized == 'Authentication service not properly initialized') {
      return 'Sign-in is temporarily unavailable. Please try again shortly.';
    }

    if (normalized.isEmpty) {
      return isLogin
          ? 'We could not sign you in. Please try again.'
          : 'We could not create your account. Please try again.';
    }

    return isLogin
        ? 'We could not sign you in. $normalized'
        : 'We could not create your account. $normalized';
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      AdaptiveMessages.showSuccess(context, message);
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      AdaptiveMessages.showError(context, message);
    }
  } // ignore: unused_element// ignore: unused_element

  // ignore: unused_element
  void _showInfoMessage(String message) {
    if (mounted) {
      AdaptiveMessages.showInfo(context, message);
    }
  }
}
