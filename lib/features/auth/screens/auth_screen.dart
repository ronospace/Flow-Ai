import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_auth/local_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart'; // Temporarily disabled for iOS compatibility
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
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

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _formController;
  late AnimationController _socialController;
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  // final GoogleSignIn _googleSignIn = GoogleSignIn(); // Temporarily disabled for iOS compatibility
  final AuthService _authService = AuthService();
  
  final PageController _pageController = PageController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _biometricsAvailable = false;
  bool _biometricsEnabled = false;
  List<BiometricType> _availableBiometrics = [];
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _checkBiometrics();
    _startAnimations();
  }
  
  void _initializeControllers() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _socialController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }
  
  void _startAnimations() {
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _formController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _socialController.forward();
    });
  }
  
  Future<void> _checkBiometrics() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      setState(() {
        _biometricsAvailable = isAvailable && isDeviceSupported;
        _availableBiometrics = availableBiometrics;
        // Check if user has previously enabled biometrics
        _biometricsEnabled = _biometricsAvailable; // You can load this from SharedPreferences
      });
    } catch (e) {
      debugPrint('Error checking biometrics: $e');
    }
  }
  
  @override
  void dispose() {
    _headerController.dispose();
    _formController.dispose();
    _socialController.dispose();
    _pageController.dispose();
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryRose.withValues(alpha: 0.1),
              AppTheme.primaryPurple.withValues(alpha: 0.05),
              AppTheme.accentMint.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              _buildHeader(theme, l10n),
              
              // Form Section with adaptive scroll physics
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: context.adaptiveScrollPhysics,
                  children: [
                    _buildAuthForm(theme, l10n),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          // Flow AI Logo
                        FlowAiLogo(
            size: 120,
            showWordmark: false,
          ).animate(controller: _headerController)
            .scale(begin: const Offset(0.5, 0.5))
            .fadeIn(),
          
          const SizedBox(height: 24),
          
          // App Name
          Text(
            'Flow Ai',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGrey,
              fontSize: 32,
            ),
          ).animate(controller: _headerController)
            .slideY(begin: 0.3, end: 0)
            .fadeIn(delay: 200.ms),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            'Smart Period & Wellness Tracking',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.mediumGrey,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ).animate(controller: _headerController)
            .slideY(begin: 0.3, end: 0)
            .fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
  
  Widget _buildAuthForm(ThemeData theme, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Tab Selector
          _buildTabSelector(theme),
          
          const SizedBox(height: 32),
          
          // Biometric Login (if available and on login page)
          if (_biometricsAvailable && _isLogin) ...[
            BiometricButton(
              availableBiometrics: _availableBiometrics,
              onBiometricLogin: _handleBiometricLogin,
            ).animate(controller: _formController)
              .slideY(begin: 0.3, end: 0)
              .fadeIn(),
            
            const SizedBox(height: 24),
            
            // Divider
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Or continue with',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.mediumGrey,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ).animate(controller: _formController)
              .fadeIn(delay: 100.ms),
            
            const SizedBox(height: 24),
          ],
          
          // Email Field - using adaptive text field
          AdaptiveComponents.adaptiveTextField(
            context: context,
            controller: _emailController,
            labelText: 'Email address',
            hintText: 'Enter your email',
            prefixIcon: const Icon(Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
            textInputAction: TextInputAction.next,
          ).animate(controller: _formController)
            .slideY(begin: 0.3, end: 0)
            .fadeIn(delay: _biometricsAvailable && _isLogin ? 200.ms : 0.ms),
          
          const SizedBox(height: 16),
          
          // Display Name Field (Sign Up only) - using adaptive text field
          if (!_isLogin) ...[
            AdaptiveComponents.adaptiveTextField(
              context: context,
              controller: _displayNameController,
              labelText: 'Display name',
              hintText: 'Enter your display name',
              prefixIcon: const Icon(Icons.person_outline),
              enabled: !_isLoading,
              textInputAction: TextInputAction.next,
            ).animate(controller: _formController)
              .slideY(begin: 0.3, end: 0)
              .fadeIn(delay: 100.ms),
            
            const SizedBox(height: 16),
          ],
          
          // Password Field - using adaptive text field
          AdaptiveComponents.adaptiveTextField(
            context: context,
            controller: _passwordController,
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock_outline),
            obscureText: _obscurePassword,
            enabled: !_isLoading,
            textInputAction: _isLogin ? TextInputAction.done : TextInputAction.next,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
                context.hapticFeedback(HapticFeedbackType.selection);
              },
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.mediumGrey,
              ),
            ),
          ).animate(controller: _formController)
            .slideY(begin: 0.3, end: 0)
            .fadeIn(delay: _biometricsAvailable && _isLogin ? 300.ms : 100.ms),
          
          const SizedBox(height: 16),
          
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
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                  context.hapticFeedback(HapticFeedbackType.selection);
                },
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.mediumGrey,
                ),
              ),
            ).animate(controller: _formController)
              .slideY(begin: 0.3, end: 0)
              .fadeIn(delay: 200.ms),
            
            const SizedBox(height: 16),
          ],
          
          // Forgot Password (Login only) - using adaptive button
          if (_isLogin) ...[
            Align(
              alignment: Alignment.centerRight,
              child: AdaptiveComponents.adaptiveButton(
                context: context,
                text: 'Forgot Password?',
                onPressed: _isLoading ? null : _handleForgotPassword,
                isPrimary: false,
                height: 36,
              ),
            ).animate(controller: _formController)
              .slideX(begin: 0.3, end: 0)
              .fadeIn(delay: 400.ms),
            
            const SizedBox(height: 8),
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
            height: 56,
            icon: _isLoading 
                ? null 
                : (_isLogin ? Icons.login : Icons.person_add),
          ).animate(controller: _formController)
            .slideY(begin: 0.3, end: 0)
            .fadeIn(delay: 500.ms),
          
          const SizedBox(height: 32),
          
          // Social Login Section
          _buildSocialLogin(theme),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildTabSelector(ThemeData theme) {
    // Use adaptive segmented control for better platform integration
    return AdaptiveComponents.adaptiveSegmentedControl<bool>(
      context: context,
      options: const {
        true: 'Sign In',
        false: 'Sign Up',
      },
      selectedValue: _isLogin,
      onChanged: (bool isLogin) {
        setState(() {
          _isLogin = isLogin;
        });
        // Use platform-appropriate haptic feedback
        context.hapticFeedback(HapticFeedbackType.selection);
      },
      enabled: !_isLoading,
    ).animate(controller: _formController)
      .slideY(begin: -0.3, end: 0)
      .fadeIn();
  }
  
  Widget _buildSocialLogin(ThemeData theme) {
    return Column(
      children: [
        // Social Login Title
        Text(
          'Or continue with',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.mediumGrey,
            fontWeight: FontWeight.w500,
          ),
        ).animate(controller: _socialController)
          .fadeIn(),
        
        const SizedBox(height: 20),
        
        // Social Login Buttons
        Row(
          children: [
            // Google Sign-In (hidden on iOS due to dependency conflicts)
            if (PlatformService().platformInfo.platform != TargetPlatform.iOS) ...[
              Expanded(
                child: SocialLoginButton(
                  icon: Icons.g_mobiledata,
                  label: 'Google',
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  backgroundColor: Colors.white,
                  iconColor: const Color(0xFF4285F4),
                ),
              ),
              const SizedBox(width: 16),
            ],
            // Apple Sign-In
            Expanded(
              child: SocialLoginButton(
                icon: Icons.apple,
                label: 'Apple',
                onPressed: _isLoading ? null : _handleAppleSignIn,
                backgroundColor: Colors.black,
                iconColor: Colors.white,
                textColor: Colors.white,
              ),
            ),
            // If on iOS and Google is hidden, fill the space
            if (PlatformService().platformInfo.platform == TargetPlatform.iOS) const Expanded(child: SizedBox()),
          ],
        ).animate(controller: _socialController)
          .slideY(begin: 0.3, end: 0)
          .fadeIn(delay: 200.ms),
      ],
    );
  }
  
  Future<void> _handleBiometricLogin() async {
    if (!_biometricsAvailable) {
      _showErrorMessage('Biometric authentication is not available on this device');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Initialize auth service first
      await _authService.initialize();
      
      final result = await _authService.authenticateWithBiometrics();
      
      if (result.isSuccess) {
        HapticFeedback.lightImpact();
        _showSuccessMessage('Biometric authentication successful!');
        
        // Sync user data immediately to ensure username is captured and available
        try {
          final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
          // Force an immediate sync to capture fresh auth data
          await settingsProvider.forceUserDataSync();
          debugPrint('✅ User settings synced successfully after biometric authentication');
        } catch (syncError) {
          debugPrint('⚠️ Warning: Could not sync user settings after biometric auth: $syncError');
        }
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Navigate to main app
        if (mounted) {
          context.go('/home');
        }
      } else {
        _showErrorMessage(result.error ?? 'Biometric authentication failed');
      }
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      _showErrorMessage('Biometric authentication failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _handleSubmit() async {
    if (_isLoading) return;
    
    // Basic validation
    if (_emailController.text.trim().isEmpty) {
      _showErrorMessage('Please enter your email address');
      return;
    }
    
    if (_passwordController.text.isEmpty) {
      _showErrorMessage('Please enter your password');
      return;
    }
    
    if (!_isLogin) {
      if (_displayNameController.text.trim().isEmpty) {
        _showErrorMessage('Please enter a display name');
        return;
      }
      
      if (_passwordController.text != _confirmPasswordController.text) {
        _showErrorMessage('Passwords do not match');
        return;
      }
      
      if (_passwordController.text.length < 8) {
        _showErrorMessage('Password must be at least 8 characters long');
        return;
      }
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Initialize auth service if needed
      try {
        await _authService.initialize();
      } catch (initError) {
        debugPrint('⚠️ Auth service initialization warning: $initError');
        // Continue anyway as we have local fallback
      }
      
      if (_isLogin) {
        // Handle login
        final result = await _authService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (!result.isSuccess) {
          throw Exception(result.error);
        }
        _showSuccessMessage('Welcome back!');
      } else {
        // Check if email already exists before attempting sign up
        final emailExists = await _authService.isEmailRegistered(_emailController.text.trim());
        if (emailExists) {
          // Email exists, suggest sign in instead
          setState(() {
            _isLoading = false;
            _isLogin = true; // Switch to login mode
          });
          _showErrorMessage('An account with this email already exists. Please sign in instead.');
          return; // Exit early
        }
        
        // Handle sign up
        final result = await _authService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _displayNameController.text.trim(),
        );
        if (!result.isSuccess) {
          throw Exception(result.error);
        }
        _showSuccessMessage('Account created successfully!');
      }
      
      // Sync user data immediately to ensure username is captured and available
      try {
        final settingsProvider = SettingsProvider();
        await settingsProvider.initializeSettings();
        // Force an immediate sync to capture fresh auth data
        await settingsProvider.forceUserDataSync();
        debugPrint('✅ User settings synced successfully after authentication');
      } catch (syncError) {
        debugPrint('⚠️ Warning: Could not sync user settings after auth: $syncError');
      }
      
      // Navigate to main app
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      debugPrint('❌ Auth error: $e');
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      _showErrorMessage(_isLogin 
          ? 'Sign in failed: $errorMessage' 
          : 'Sign up failed: $errorMessage');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    
    // Show coming soon message
    _showInfoMessage('Google Sign-In is coming soon! 🚀\n\nWe\'re working on integrating Google authentication with enhanced security features. For now, please use email authentication to create your account.');
  }
  
  Future<void> _handleAppleSignIn() async {
    if (_isLoading) return;
    
    // Show coming soon message
    _showInfoMessage('Apple Sign-In is coming soon! 🍎\n\nWe\'re working on integrating Apple Sign-In with enhanced privacy features. For now, please use email authentication to create your account.');
  }
  
  void _handleForgotPassword() {
    // Show forgot password dialog
    _showForgotPasswordDialog();
  }
  
  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();
    bool isResetting = false;
    
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
                          colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
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
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      'Enter your email address and we\'ll send you a link to reset your password.',
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
                      hintText: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isResetting,
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ModernButton(
                            text: 'Cancel',
                            onPressed: isResetting ? null : () {
                              Navigator.of(dialogContext).pop();
                            },
                            type: ModernButtonType.secondary,
                            size: ModernButtonSize.medium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ModernButton(
                            text: isResetting ? 'Sending...' : 'Send Reset Link',
                            isLoading: isResetting,
                            onPressed: isResetting ? null : () async {
                              // Validate email
                              if (resetEmailController.text.trim().isEmpty) {
                                _showErrorMessage('Please enter your email address');
                                return;
                              }
                              
                              setState(() => isResetting = true);
                              
                              try {
                                // Initialize auth service if needed
                                await _authService.initialize();
                                
                                final result = await _authService.resetPassword(
                                  resetEmailController.text.trim(),
                                );
                                
                                if (result.isSuccess) {
                                  Navigator.of(dialogContext).pop();
                                  _showSuccessMessage(
                                    'Password reset link sent! Check your email.',
                                  );
                                } else {
                                  throw Exception(result.error);
                                }
                              } catch (e) {
                                _showErrorMessage(
                                  'Failed to send reset email. Please try again.',
                                );
                              } finally {
                                setState(() => isResetting = false);
                              }
                            },
                            size: ModernButtonSize.medium,
                          ),
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
    );
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
  }
  
  void _showInfoMessage(String message) {
    if (mounted) {
      AdaptiveMessages.showInfo(context, message);
    }
  }
}
