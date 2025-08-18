import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class JoinPartnerDialog extends StatefulWidget {
  final Function(String) onJoinWithCode;

  const JoinPartnerDialog({
    super.key,
    required this.onJoinWithCode,
  });

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
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
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
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      AppTheme.secondaryBlue.withValues(alpha: 0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppTheme.secondaryBlue.withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondaryBlue.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    _buildContent(),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryBlue.withValues(alpha: 0.1),
            AppTheme.accentMint.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.secondaryBlue, AppTheme.accentMint],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.group_add,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join Partner',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                ),
                Text(
                  'Connect using invitation code',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstructionSection(),
            const SizedBox(height: 24),
            _buildCodeInput(),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorMessage(),
            ],
            const SizedBox(height: 24),
            _buildAlternativeOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppTheme.secondaryBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'How to Join',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInstructionStep(
          '1',
          'Ask your partner to send you an invitation',
          Icons.email_outlined,
        ),
        const SizedBox(height: 8),
        _buildInstructionStep(
          '2',
          'Copy the invitation code from their message',
          Icons.content_copy,
        ),
        const SizedBox(height: 8),
        _buildInstructionStep(
          '3',
          'Paste the code below to connect',
          Icons.link,
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildInstructionStep(String number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.secondaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: AppTheme.secondaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          icon,
          size: 16,
          color: AppTheme.mediumGrey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppTheme.mediumGrey,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          'Enter the 6-digit code from your partner\'s invitation.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.mediumGrey,
          ),
        ),
        const SizedBox(height: 16),
        Row(
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
                  hintText: 'ABC123',
                  hintStyle: TextStyle(
                    color: AppTheme.lightGrey,
                    letterSpacing: 4,
                  ),
                  prefixIcon: Icon(
                    Icons.vpn_key,
                    color: AppTheme.secondaryBlue,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppTheme.lightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppTheme.secondaryBlue, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
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
            const SizedBox(width: 12),
            IconButton(
              onPressed: _pasteFromClipboard,
              icon: Icon(
                Icons.content_paste,
                color: AppTheme.secondaryBlue,
              ),
              tooltip: 'Paste from clipboard',
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.secondaryBlue.withValues(alpha: 0.1),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ).animate().shake();
  }

  Widget _buildAlternativeOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppTheme.lightGrey,
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: TextStyle(
                  color: AppTheme.mediumGrey,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppTheme.lightGrey,
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildAlternativeOption(
          'Request New Invitation',
          'Ask your partner to send a new invitation',
          Icons.refresh,
          () {
            Navigator.pop(context);
            _showRequestInvitationDialog();
          },
        ),
        const SizedBox(height: 8),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.lightGrey,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.mediumGrey,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.darkGrey,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.mediumGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.lightGrey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (_isLoading || _codeController.text.length != 6) 
            ? null 
            : _handleJoin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.secondaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
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
                children: [
                  const Icon(Icons.link, size: 18),
                  const SizedBox(width: 8),
                  const Text(
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
    );
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null) {
        final text = data!.text!.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
        if (text.length >= 6) {
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
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call
        
        // Validate code format (in real implementation, this would be server-side)
        final code = _codeController.text.trim();
        if (code.length != 6 || !RegExp(r'^[A-Z0-9]{6}$').hasMatch(code)) {
          throw Exception('Invalid code format');
        }

        widget.onJoinWithCode(code);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Successfully connected with partner!'),
                ],
              ),
              backgroundColor: AppTheme.accentMint,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid invitation code. Please check and try again.';
        });
      }
    }
  }

  void _showRequestInvitationDialog() {
    // TODO: Implement request invitation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request invitation feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showManualConnectionDialog() {
    // TODO: Implement manual connection dialog
    ScaffoldMessenger.of(context).showSnackBar(
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
