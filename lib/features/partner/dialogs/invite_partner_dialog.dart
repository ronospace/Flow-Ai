import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import 'join_partner_dialog.dart';

class InvitePartnerDialog extends StatefulWidget {
  final Function(String, String?) onSendInvite;

  const InvitePartnerDialog({super.key, required this.onSendInvite});

  @override
  State<InvitePartnerDialog> createState() => _InvitePartnerDialogState();
}

class _InvitePartnerDialogState extends State<InvitePartnerDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  int _currentStep = 0;

  final List<String> _predefinedMessages = [
    "Hi! I'd love to share my cycle journey with you for mutual support. Would you like to connect on Flow Ai? 💕",
    "Hey! I'm using Flow Ai to track my cycle and would love to have you as my support partner. Want to join me? 🌸",
    "Hi there! I think it would be amazing if we could support each other through our cycle journeys. Care to connect? ❤️",
  ];

  @override
  void initState() {
    super.initState();

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
    _tabController = TabController(length: 2, vsync: this);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _tabController.dispose();
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
              child: Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 420,
                    maxHeight: 680,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).cardColor,
                          Theme.of(context).cardColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppTheme.primaryRose.withValues(alpha: 0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRose.withValues(alpha: 0.2),
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
                            child: Form(
                              key: _formKey,
                              child: _buildCurrentStep(),
                            ),
                          ),
                        ),
                        _buildFooter(),
                        _buildBottomHandle(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return GestureDetector(
      onPanEnd: (d) {
        if (d.velocity.pixelsPerSecond.dx < -80) {
          Navigator.pop(context);
          Future.delayed(const Duration(milliseconds: 160), () {
            showDialog(context: context, builder: (_) => JoinPartnerDialog(onJoinWithCode: (_) async {}));
          });
        }
      },
      child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryRose.withValues(alpha: 0.1),
            AppTheme.primaryPurple.withValues(alpha: 0.05),
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
                colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.person_add, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invite Partner',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  'Share your journey together',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
        ],
      ),
    )).animate().slideY(begin: -0.3, end: 0);
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildMessageStep();
      default:
        return _buildEmailStep();
    }
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildStepIndicator(),
        const SizedBox(height: 24),
        Text(
          'Enter Partner\'s Email',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ll send them an invitation to connect with you on Flow Ai.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'partner@example.com',
            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryRose),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: const Color(0xFFD6B8C8), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.primaryRose, width: 2),
            ),
            filled: true,
            fillColor: AppTheme.primaryPurple.withOpacity(0.08),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an email address';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildPrivacyNote(),
        const SizedBox(height: 24),
      ],
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildMessageStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildStepIndicator(),
        const SizedBox(height: 24),
        Text(
          'Personal Message',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add a personal touch to your invitation (optional).',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: 24),
        Text(
          'Quick Templates',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        ..._predefinedMessages.asMap().entries.map((entry) {
          final index = entry.key;
          final message = entry.value;
          return _buildMessageTemplate(message, index);
        }),
        const SizedBox(height: 20),
        Text(
          'Custom Message',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _messageController,
          maxLines: 4,
          maxLength: 300,
          decoration: InputDecoration(
            hintText: 'Write your personal invitation message...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: const Color(0xFFD6B8C8), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.primaryRose, width: 2),
            ),
            filled: true,
            fillColor: AppTheme.primaryRose.withOpacity(0.08),
          ),
        ),
        const SizedBox(height: 24),
      ],
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildMessageTemplate(String message, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _messageController.text = message),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: _messageController.text == message
                  ? AppTheme.primaryRose
                  : Theme.of(context).dividerColor,
              width: _messageController.text == message ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: _messageController.text == message
                ? AppTheme.primaryRose.withValues(alpha: 0.05)
                : Theme.of(context).cardColor,
          ),
          child: Row(
            children: [
              Icon(
                _messageController.text == message
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: _messageController.text == message
                    ? AppTheme.primaryRose
                    : Theme.of(context).dividerColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: SizedBox(
        height: 56,
        child: TabBar(
          controller: _tabController,
          onTap: (index) => setState(() => _currentStep = index),
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(2),
          labelPadding: EdgeInsets.zero,
          labelColor: Colors.white,
          unselectedLabelColor: Theme.of(context).hintColor,
          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: const [
            Tab(icon: Icon(Icons.email, size: 20), text: 'Email'),
            Tab(icon: Icon(Icons.message_outlined, size: 20), text: 'Message'),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentMint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentMint.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: AppTheme.accentMint, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your partner will need to accept the invitation before you can share any cycle data.',
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() => _currentStep = _currentStep - 1);
                    },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, size: 16, color: Theme.of(context).hintColor),
                  const SizedBox(width: 8),
                  Text('Back', style: TextStyle(color: Theme.of(context).hintColor)),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRose,
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
                        Text(
                          _currentStep == 0 ? 'Next' : 'Send Invitation',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentStep == 0 ? Icons.arrow_forward : Icons.send,
                          size: 20,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBottomHandle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  void _handleNext() async {
    if (_currentStep == 0) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _currentStep = 1);
      }
    } else {
      await _sendInvitation();
    }
  }

  Future<void> _sendInvitation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Call the callback - parent will handle PartnerService call
      widget.onSendInvite(
        _emailController.text.trim(),
        _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Text('Failed to create invitation: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
