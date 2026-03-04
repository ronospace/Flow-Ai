import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/platform_service.dart';
import '../../../core/ui/adaptive_messages.dart';
import '../widgets/biometric_button.dart';

/// 🚀 Futuristic Auth Screen - Gen Z & Alpha Design
/// Features: Glassmorphism, 3D effects, smooth animations, modern color schemes
class FuturisticAuthScreen extends StatefulWidget {
  const FuturisticAuthScreen({super.key});

  @override
  State<FuturisticAuthScreen> createState() => _FuturisticAuthScreenState();
}

class _FuturisticAuthScreenState extends State<FuturisticAuthScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _formController;
  late AnimationController _backgroundController;
  late AnimationController _socialController;

  final LocalAuthentication _localAuth = LocalAuthentication();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _biometricsAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkBiometrics();
    _startAnimations();
  }

  void _initializeAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _formController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _socialController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
  }

  void _startAnimations() {
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _formController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _socialController.forward();
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
      });
    } catch (e) {
      debugPrint('Error checking biometrics: $e');
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _formController.dispose();
    _backgroundController.dispose();
    _socialController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedBackground(size),

          // Glassmorphic content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Futuristic header
                    _buildFuturisticHeader(),

                    const SizedBox(height: 60),

                    // Glassmorphic card with auth form
                    _buildGlassmorphicCard(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Size size) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF6366F1), // Indigo
                  const Color(0xFFA855F7), // Purple
                  _backgroundController.value,
                )!,
                Color.lerp(
                  const Color(0xFFA855F7), // Purple
                  const Color(0xFFEC4899), // Pink
                  _backgroundController.value,
                )!,
                Color.lerp(
                  const Color(0xFFEC4899), // Pink
                  const Color(0xFF6366F1), // Indigo
                  _backgroundController.value,
                )!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFuturisticHeader() {
    return Column(
      children: [
        // 3D floating logo effect
        Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(0.1)
                ..rotateY(0.1),
              alignment: Alignment.center,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFF0ABFC)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                    BoxShadow(
                      color: const Color(0xFFA855F7).withValues(alpha: 0.6),
                      blurRadius: 80,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 60,
                  color: Color(0xFFA855F7),
                ),
              ),
            )
            .animate(controller: _headerController)
            .scale(
              begin: const Offset(0, 0),
              duration: 800.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(),

        const SizedBox(height: 32),

        // App name with gradient
        ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFF0ABFC)],
              ).createShader(bounds),
              child: const Text(
                'Flow Ai',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
            )
            .animate(controller: _headerController)
            .slideY(begin: -0.5, duration: 600.ms, curve: Curves.easeOut)
            .fadeIn(delay: 200.ms),

        const SizedBox(height: 12),

        // Subtitle with blur effect
        Text(
              '✨ Your AI-Powered Wellness Companion',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: 0.5,
              ),
            )
            .animate(controller: _headerController)
            .fadeIn(delay: 400.ms)
            .slideY(begin: 0.3, duration: 600.ms),
      ],
    );
  }

  Widget _buildGlassmorphicCard() {
    return ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Tab selector
                  _buildModernTabSelector(),

                  const SizedBox(height: 32),

                  // Biometric button
                  if (_biometricsAvailable && _isLogin) ...[
                    _buildModernBiometricButton(),
                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 24),
                  ],

                  // Form fields
                  _buildFormFields(),

                  const SizedBox(height: 32),

                  // Submit button
                  _buildModernSubmitButton(),

                  const SizedBox(height: 28),

                  // Social login
                  _buildModernSocialButtons(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        )
        .animate(controller: _formController)
        .scale(
          begin: const Offset(0.8, 0.8),
          duration: 800.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn();
  }

  Widget _buildModernTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTab('Sign In', _isLogin)),
          Expanded(child: _buildTab('Sign Up', !_isLogin)),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (!_isLoading) {
          setState(() {
            _isLogin = text == 'Sign In';
          });
          HapticFeedback.selectionClick();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(colors: [Colors.white, Color(0xFFF0ABFC)])
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isActive
                ? const Color(0xFF6366F1)
                : Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildModernBiometricButton() {
    return Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFBBF24).withValues(alpha: 0.3),
                const Color(0xFFF59E0B).withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFBBF24).withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: BiometricButton(
            availableBiometrics: _availableBiometrics,
            onBiometricLogin: _handleBiometricLogin,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.3));
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Email
        _buildModernTextField(
          controller: _emailController,
          hintText: 'Email address',
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 16),

        // Display Name (Sign Up only)
        if (!_isLogin) ...[
          _buildModernTextField(
            controller: _displayNameController,
            hintText: 'Display name',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 16),
        ],

        // Password
        _buildModernTextField(
          controller: _passwordController,
          hintText: 'Password',
          icon: Icons.lock_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
              HapticFeedback.selectionClick();
            },
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Confirm Password (Sign Up only)
        if (!_isLogin) ...[
          _buildModernTextField(
            controller: _confirmPasswordController,
            hintText: 'Confirm password',
            icon: Icons.lock_rounded,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
                HapticFeedback.selectionClick();
              },
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],

        // Forgot password (Login only)
        if (_isLogin) ...[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isLoading ? null : _handleForgotPassword,
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        enabled: !_isLoading,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 16,
          ),
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildModernSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF0ABFC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleSubmit,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin ? 'Sign In' : 'Create Account',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF6366F1),
                        size: 24,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernSocialButtons() {
    return Column(
      children: [
        Text(
          'Or continue with',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 20),

        Row(
              children: [
                // Google button
                Expanded(
                  child: _buildSocialButton(
                    icon: Icons.g_mobiledata,
                    label: 'Google',
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    colors: [const Color(0xFF4285F4), const Color(0xFF34A853)],
                  ),
                ),

                const SizedBox(width: 16),

                // Apple button (iOS only)
                if (PlatformService().platformInfo.platform ==
                    TargetPlatform.iOS)
                  Expanded(
                    child: _buildSocialButton(
                      icon: Icons.apple,
                      label: 'Apple',
                      onPressed: _isLoading ? null : _handleAppleSignIn,
                      colors: [
                        const Color(0xFF000000),
                        const Color(0xFF434343),
                      ],
                    ),
                  ),

                // Spacer if not iOS
                if (PlatformService().platformInfo.platform !=
                    TargetPlatform.iOS)
                  const Expanded(child: SizedBox()),
              ],
            )
            .animate(controller: _socialController)
            .slideY(begin: 0.3, duration: 600.ms, curve: Curves.easeOut)
            .fadeIn(),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required List<Color> colors,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed != null
              ? () {
                  HapticFeedback.lightImpact();
                  onPressed();
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Auth handlers (same as before)
  Future<void> _handleBiometricLogin() async {
    // Same implementation as original auth_screen.dart
  }

  Future<void> _handleSubmit() async {
    // Same implementation as original auth_screen.dart
  }

  Future<void> _handleGoogleSignIn() async {
    // Same implementation as original auth_screen.dart
  }

  Future<void> _handleAppleSignIn() async {
    // Same implementation as original auth_screen.dart
  }

  void _handleForgotPassword() {
    // Same implementation as original auth_screen.dart
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

  Widget _buildFuturisticButton({
    required String text,
    required VoidCallback? onPressed,
    required List<Color> colors,
    required IconData icon,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed != null
              ? () {
                  HapticFeedback.mediumImpact();
                  onPressed();
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
