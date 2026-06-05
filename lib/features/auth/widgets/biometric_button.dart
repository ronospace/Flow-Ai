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

class _BiometricButtonState extends State<BiometricButton> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 260,
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.mediumGrey.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                biometricIcon,
                color: AppTheme.darkGrey,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Use $biometricLabel',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkGrey,
                  fontSize: 14,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
