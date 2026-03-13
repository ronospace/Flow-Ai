import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/theme/app_theme.dart';

class BiometricButton extends StatefulWidget {
  final List<BiometricType> availableBiometrics;
  final VoidCallback onBiometricLogin;

  const BiometricButton({
    super.key,
    required this.availableBiometrics,
    required this.onBiometricLogin,
  });

  @override
  State<BiometricButton> createState() => _BiometricButtonState();
}

class _BiometricButtonState extends State<BiometricButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start subtle pulse animation
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Determine which biometric type is available
    IconData biometricIcon = Icons.fingerprint;
    String biometricLabel = 'Fingerprint';

    if (widget.availableBiometrics.contains(BiometricType.face)) {
      biometricIcon = Icons.face;
      biometricLabel = 'Face ID';
    } else if (widget.availableBiometrics.contains(BiometricType.iris)) {
      biometricIcon = Icons.visibility;
      biometricLabel = 'Iris';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onBiometricLogin();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.accentMint.withValues(alpha: 0.1),
                AppTheme.secondaryBlue.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.accentMint.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Biometric Icon with Animation
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.accentMint,
                              AppTheme.secondaryBlue,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentMint.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          biometricIcon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 12),

                // Text Content - Single line only
                Expanded(
                  child: Text(
                    'Sign in with $biometricLabel',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGrey,
                      fontSize: 16,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 8),

                // Arrow Icon
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.accentMint,
                    size: 12,
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
