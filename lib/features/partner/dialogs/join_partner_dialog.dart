import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class JoinPartnerDialog extends StatefulWidget {
  final String? initialCode;
  final Future<void> Function(String) onJoinWithCode;

  const JoinPartnerDialog({super.key, this.initialCode, required this.onJoinWithCode});

  @override
  State<JoinPartnerDialog> createState() => _JoinPartnerDialogState();
}

class _JoinPartnerDialogState extends State<JoinPartnerDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    if (widget.initialCode != null && widget.initialCode!.isNotEmpty) {
      _codeController.text = widget.initialCode!;
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              insetPadding: const EdgeInsets.fromLTRB(16, 74, 16, 30),
              backgroundColor: Colors.transparent,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final dialogHeight = (constraints.maxHeight * 0.78)
                      .clamp(320.0, 680.0)
                      .toDouble();

                  return Padding(
                    padding: const EdgeInsets.only(top: 48, bottom: 48),
                    child: Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 420,
                          maxHeight: dialogHeight,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                const Color(0xFFFF6B8A).withValues(alpha: 0.02),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: const Color(0xFFFF6B8A).withValues(alpha: 0.2),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B8A).withValues(alpha: 0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHeader(),
                              Flexible(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: _buildContent(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B8A).withValues(alpha: 0.1),
            AppTheme.accentMint.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [const Color(0xFFFF6B8A), AppTheme.accentMint],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.group_add, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Join Partner',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                ),
                Text(
                  'Use your invitation code',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGrey),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppTheme.mediumGrey),
          ),
        ],
      ),
    ).animate().slideY(begin: -0.3, end: 0);
  }

  Widget _buildContent() {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Enter the invitation code your partner shared with you.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGrey,
              ),
            ),
            const SizedBox(height: 12),
            _buildCodeInput(),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorMessage(),
            ],
            const SizedBox(height: 16),
SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: (_isLoading || _codeController.text.trim().length != 6)
        ? null
        : _handleJoin,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFF6B8A),
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    child: _isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.link, size: 18),
              SizedBox(width: 8),
              Text(
                'Connect with Partner',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
  ),
),
const SizedBox(height: 16),
SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: () {
      Navigator.pop(context);
      context.push('/qr-join');
    },
    icon: const Icon(Icons.qr_code_scanner, size: 20),
    label: const Text('Scan QR Code'),
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFFFF6B8A),
      side: const BorderSide(color: Color(0xFFFF6B8A)),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  ),
),

_buildAlternativeOptions(),
          ],
        ),
      );
  }

  Widget _buildCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Invitation Code',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the 6-character code from your partner\'s invitation.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGrey),
        ),
        const SizedBox(height: 16),
        Row(
              mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                controller: _codeController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                  LengthLimitingTextInputFormatter(6),
                  UpperCaseTextFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: 'ABCDEFG8',
                  hintStyle: TextStyle(
                    color: AppTheme.lightGrey,
                    letterSpacing: 4,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 4),
                    child: Icon(
                      Icons.vpn_key,
                      size: 18,
                      color: const Color(0xFFFF6B8A),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppTheme.lightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: const Color(0xFFFF6B8A),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.98),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the invitation code';
                  }
                  if (value.length != 6) {
                    return 'Code must be 6 characters';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() => _errorMessage = null);
                  if (value.length == 6) {
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: _pasteFromClipboard,
              icon: Icon(Icons.content_paste, color: const Color(0xFFFF6B8A)),
              tooltip: 'Paste from clipboard',
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B8A).withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ],
      ),
    ).animate().shake();
  }

  Widget _buildAlternativeOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
              mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Divider(color: AppTheme.lightGrey, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: TextStyle(color: AppTheme.mediumGrey, fontSize: 11),
              ),
            ),
            Expanded(child: Divider(color: AppTheme.lightGrey, thickness: 1)),
          ],
        ),
        const SizedBox(height: 12),
        _buildAlternativeOption(
          'Request New Invitation',
          'Ask your partner to send a new invitation',
          Icons.refresh,
          () {
            Navigator.pop(context);
            _showRequestInvitationDialog();
          },
        ),
        const SizedBox(height: 6),
        _buildAlternativeOption(
          'Manual Connection',
          'Connect using partner\'s email address',
          Icons.alternate_email,
          () {
            Navigator.pop(context);
            _showManualConnectionDialog();
          },
        ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildAlternativeOption(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 74, 16, 30),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.lightGrey, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.mediumGrey, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.darkGrey,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: AppTheme.mediumGrey, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppTheme.lightGrey, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null) {
        final text = data!.text!.toUpperCase().replaceAll(
          RegExp(r'[^A-Z0-9]'),
          '',
        );
        if (text.length >= 8) {
          setState(() {
            _codeController.text = text.substring(0, 6);
            _errorMessage = null;
          });
        }
      }
    } catch (e) {
      // Handle clipboard access error
    }
  }

  void _handleJoin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Validate code format (6 characters, alphanumeric)
        final code = _codeController.text.trim().toUpperCase();
        if (code.length != 6 || !RegExp(r'^[A-Z0-9]{6}$').hasMatch(code)) {
          throw Exception('Invalid code format. Code must be 6 characters.');
        }

        // Call the callback - parent will handle PartnerService call
        await widget.onJoinWithCode(code);

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  void _showRequestInvitationDialog() {
    // TODO: Implement request invitation dialog
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text('Request invitation feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showManualConnectionDialog() {
    // TODO: Implement manual connection dialog
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text('Manual connection feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
