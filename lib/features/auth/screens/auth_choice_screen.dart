import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/platform_service.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/social_login_button.dart';
import '../../../core/widgets/flow_ai_logo.dart';
import '../services/auth_provider_coordinator.dart';


class AuthChoiceScreen extends StatefulWidget {
  const AuthChoiceScreen({super.key});

  @override
  State<AuthChoiceScreen> createState() => _AuthChoiceScreenState();
}

class _AuthChoiceScreenState extends State<AuthChoiceScreen> {
  static const List<String> _headlines = [
    'Understand your health',
    'See the patterns',
    'Feel more in control',
  ];

  static const List<String> _supportingCopy = [
    'Notice the signals your body gives you every day',
    'Connect your cycle, symptoms, mood, sleep and energy over time',
    'Make everyday choices with clearer personal insight',
  ];

  bool _showAllMethods = false;
  int _headlineIndex = 0;
  Timer? _headlineTimer;
  bool _reduceMotion = false;
  bool _storyVisible = true;
  AuthProviderType? _activeProvider;

  bool get _isIOS =>
      PlatformService().platformInfo.platform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final media = MediaQuery.maybeOf(context);
    final reduceMotion =
        (media?.disableAnimations ?? false) ||
        (media?.accessibleNavigation ?? false);

    if (_reduceMotion == reduceMotion && _headlineTimer != null) {
      return;
    }

    _reduceMotion = reduceMotion;
    _headlineTimer?.cancel();
    _headlineTimer = null;

    if (_reduceMotion) {
      _headlineIndex = 0;
      _storyVisible = true;
      return;
    }

    _scheduleNextStory();
  }

  void _scheduleNextStory() {
    _headlineTimer?.cancel();

    if (_reduceMotion || !mounted) return;

    _headlineTimer = Timer(const Duration(milliseconds: 2750), () {
      if (!mounted || _reduceMotion) return;

      setState(() {
        _storyVisible = false;
      });

      _headlineTimer = Timer(const Duration(milliseconds: 420), () {
        if (!mounted || _reduceMotion) return;

        setState(() {
          _headlineIndex = (_headlineIndex + 1) % _headlines.length;
        });

        _headlineTimer = Timer(const Duration(milliseconds: 90), () {
          if (!mounted || _reduceMotion) return;

          setState(() {
            _storyVisible = true;
          });

          _scheduleNextStory();
        });
      });
    });
  }

  @override
  void dispose() {
    _headlineTimer?.cancel();
    super.dispose();
  }

  Future<void> _openProvider(String provider) async {
    HapticFeedback.lightImpact();

    final providerType = switch (provider) {
      'apple' => AuthProviderType.apple,
      'google' => AuthProviderType.google,
      _ => null,
    };

    if (providerType == null || _activeProvider != null) {
      return;
    }

    _headlineTimer?.cancel();
    _headlineTimer = null;

    setState(() {
      _activeProvider = providerType;
    });

    // Commit the dedicated provider-processing presentation before native
    // provider authentication UI opens.
    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) {
      return;
    }

    final result = await AuthProviderCoordinator().authenticate(
      context: context,
      provider: providerType,
    );

    if (!mounted || result.isSuccess) {
      return;
    }

    setState(() {
      _activeProvider = null;
    });

    if (!_reduceMotion) {
      _scheduleNextStory();
    }

    if (result.isCancelled) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            result.error ?? 'Authentication could not be completed.',
          ),
        ),
      );
  }

  void _openEmail() {
    HapticFeedback.lightImpact();
    context.go('/auth');
  }

  void _showMethods() {
    HapticFeedback.selectionClick();

    setState(() {
      _showAllMethods = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_activeProvider != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF09090B),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _EntryBackground(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 56,
                      ),
                      child: Center(child: _buildProviderProcessing()),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _EntryBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 56,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMessage(),
                        SizedBox(height: constraints.maxHeight < 700 ? 36 : 56),
                        _buildEntryActions(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderProcessing() {
    final provider = _activeProvider;

    if (provider == null) {
      return const SizedBox.shrink();
    }

    final providerLabel = switch (provider) {
      AuthProviderType.apple => 'Apple',
      AuthProviderType.google => 'Google',
    };

    return Column(
      key: const ValueKey('provider-processing'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLaunchLogo(),
        const SizedBox(height: 32),
        Text(
          'Connecting to $providerLabel',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            height: 1.15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.25,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Complete sign-in in the $providerLabel window.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.68),
            fontSize: 15,
            height: 1.4,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 30),
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLaunchLogo() {
    return const FlowAiLogo(size: 120, showWordmark: false);
  }

  TextStyle _headlineStyle() {
    return const TextStyle(
      fontFamily: 'PlayfairDisplay',
      color: Colors.white,
      fontSize: 41,
      height: 1.03,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.85,
    );
  }

  TextStyle _supportingStyle() {
    return TextStyle(
      color: Colors.white.withValues(alpha: 0.70),
      fontSize: 16,
      height: 1.46,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.04,
    );
  }

  Widget _buildStoryContent() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 154),
      child: Center(
        child: AnimatedOpacity(
          opacity: _storyVisible ? 1 : 0,
          duration: _reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 420),
          curve: Curves.easeInOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _headlines[_headlineIndex],
                maxLines: 2,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
                style: _headlineStyle(),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 410),
                child: Text(
                  _supportingCopy[_headlineIndex],
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                  style: _supportingStyle(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return Column(
      children: [
        _reduceMotion
            ? _buildLaunchLogo()
            : _buildLaunchLogo()
                  .animate()
                  .fadeIn(delay: 120.ms, duration: 650.ms)
                  .scale(
                    begin: const Offset(0.92, 0.92),
                    end: const Offset(1, 1),
                  ),
        const SizedBox(height: 34),
        _buildStoryContent(),
        const SizedBox(height: 18),
        _buildStoryProgress(),
      ],
    );
  }

  Widget _buildStoryProgress() {
    return Semantics(
      label: 'Story ${_headlineIndex + 1} of ${_headlines.length}',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_headlines.length, (index) {
          final active = index == _headlineIndex;

          return AnimatedContainer(
            duration: _reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 420),
            curve: Curves.easeInOutCubic,
            width: active ? 18 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              color: active
                  ? AppTheme.primaryRose
                  : Colors.white.withValues(alpha: 0.18),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEntryActions() {
    return AnimatedSize(
      duration: _reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: _showAllMethods ? _buildExpandedMethods() : _buildPrimaryEntry(),
    );
  }

  Widget _buildPrimaryEntry() {
    final isIOS = _isIOS;
    final provider = isIOS ? 'apple' : 'google';

    return Column(
          children: [
            SocialLoginButton(
              icon: isIOS ? Icons.apple : Icons.g_mobiledata,
              label: isIOS ? 'Continue with Apple' : 'Continue with Google',
              onPressed: () => _openProvider(provider),
              backgroundColor: Colors.white,
              iconColor: isIOS ? Colors.black : const Color(0xFF4285F4),
              textColor: Colors.black,
            ),
            const SizedBox(height: 12),
            _SecondaryButton(label: 'Continue', onPressed: _showMethods),
          ],
        )
        .animate()
        .fadeIn(delay: 260.ms, duration: 520.ms)
        .slideY(begin: 0.12, end: 0);
  }

  Widget _buildExpandedMethods() {
    return Column(
      children: [
        if (_isIOS) ...[
          SocialLoginButton(
            icon: Icons.apple,
            label: 'Continue with Apple',
            onPressed: () => _openProvider('apple'),
            backgroundColor: Colors.white,
            iconColor: Colors.black,
            textColor: Colors.black,
          ),
          const SizedBox(height: 12),
        ],
        SocialLoginButton(
          icon: Icons.g_mobiledata,
          label: 'Continue with Google',
          onPressed: () => _openProvider('google'),
          backgroundColor: Colors.white,
          iconColor: const Color(0xFF4285F4),
          textColor: Colors.black,
        ),
        const SizedBox(height: 12),
        _SecondaryButton(
          icon: Icons.mail_outline_rounded,
          label: 'Continue with E-mail',
          onPressed: _openEmail,
        ),
      ],
    ).animate().fadeIn(duration: 380.ms).slideY(begin: 0.08, end: 0);
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
          backgroundColor: Colors.white.withValues(alpha: 0.055),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 21),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryBackground extends StatelessWidget {
  const _EntryBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF070709), Color(0xFF0C0B10), Color(0xFF09090B)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -180,
            left: -110,
            child: _Glow(
              size: 330,
              color: AppTheme.primaryPurple,
              opacity: 0.13,
            ),
          ),
          Positioned(
            right: -160,
            top: 180,
            child: _Glow(size: 320, color: AppTheme.primaryRose, opacity: 0.11),
          ),
          Positioned(
            bottom: -190,
            left: 30,
            child: _Glow(
              size: 350,
              color: AppTheme.secondaryBlue,
              opacity: 0.08,
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color, required this.opacity});

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
