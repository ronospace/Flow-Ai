import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'partner_invitation_actions.dart';
import 'partner_invitation_qr_tab.dart';
import 'partner_invitation_link_tab.dart';
import 'partner_invitation_email_tab.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';
import '../services/partner_service.dart';

enum _InviteInputMode { idle, email, message }

class PartnerInvitationDialog extends StatefulWidget {
  final PartnerService partnerService;

  const PartnerInvitationDialog({super.key, required this.partnerService});

  @override
  State<PartnerInvitationDialog> createState() =>
      _PartnerInvitationDialogState();
}

class _PartnerInvitationDialogState extends State<PartnerInvitationDialog>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late AnimationController _dialogController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _emailFocus = FocusNode();
  final _messageFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isExecutingInvite = false;
  String? _successMessage;
  bool _isSent = false;

  PartnerInvitation? _generatedInvitation;
  _InviteInputMode _inviteInputMode = _InviteInputMode.idle;
  bool _wasKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _wasKeyboardVisible =
        WidgetsBinding
            .instance
            .platformDispatcher
            .views
            .first
            .viewInsets
            .bottom >
        0;
    void syncInviteInputMode() {
      if (!mounted) return;
      final nextMode = _emailFocus.hasFocus
          ? _InviteInputMode.email
          : _messageFocus.hasFocus
          ? _InviteInputMode.message
          : _InviteInputMode.idle;

      if (_inviteInputMode != nextMode) {
        setState(() => _inviteInputMode = nextMode);
      }
    }

    _emailFocus.addListener(syncInviteInputMode);
    _messageFocus.addListener(syncInviteInputMode);

    _tabController = TabController(length: 3, vsync: this);
    _dialogController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _dialogController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _dialogController,
      curve: Curves.easeIn,
    );

    _dialogController.forward();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final isKeyboardVisible =
        WidgetsBinding
            .instance
            .platformDispatcher
            .views
            .first
            .viewInsets
            .bottom >
        0;

    if (_wasKeyboardVisible &&
        !isKeyboardVisible &&
        mounted &&
        _inviteInputMode != _InviteInputMode.idle) {
      setState(() => _inviteInputMode = _InviteInputMode.idle);
    }

    _wasKeyboardVisible = isKeyboardVisible;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dialogController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _emailController.dispose();
    _messageController.dispose();
    _emailFocus.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: _dialogController,
      builder: (context, child) {
        final kb = MediaQuery.of(context).viewInsets.bottom;
        final keyboardOpen = kb > 0;

        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Dialog(
              insetPadding: keyboardOpen
                  ? const EdgeInsets.fromLTRB(16, 64, 16, 0)
                  : const EdgeInsets.fromLTRB(16, 64, 16, 40),
              backgroundColor: Colors.transparent,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final dialogHeight = keyboardOpen
                      ? constraints.maxHeight.clamp(320.0, 680.0).toDouble()
                      : (constraints.maxHeight * 0.78)
                            .clamp(320.0, 680.0)
                            .toDouble();

                  return Padding(
                    padding: EdgeInsets.only(
                      top: 56,
                      bottom: keyboardOpen ? 0 : 48,
                    ),
                    child: Align(
                      alignment: keyboardOpen
                          ? Alignment.topCenter
                          : Alignment.center,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 420,
                          maxHeight: dialogHeight,
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.transparent,
                                blurRadius: 0,
                                spreadRadius: 0,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Container(
                              color: Colors.transparent,
                              child: Column(
                                children: [
                                  _buildHeader(theme, localizations),
                                  _buildTabBar(theme, localizations),
                                  Expanded(
                                    child: TabBarView(
                                      controller: _tabController,
                                      physics: const BouncingScrollPhysics(
                                        parent: AlwaysScrollableScrollPhysics(),
                                      ),
                                      children: [
                                        PartnerInvitationEmailTab(
                                          emailController: _emailController,
                                          messageController: _messageController,
                                          emailFocus: _emailFocus,
                                          messageFocus: _messageFocus,
                                          formKey: _formKey,
                                          inviteInputMode: InviteInputMode
                                              .values[_inviteInputMode.index],
                                          isLoading: _isLoading,
                                          isSent: _isSent,
                                          successMessage: _successMessage,
                                          onSubmit: _openEmailInvite,
                                          onEmailTap: () {
                                            if (_inviteInputMode !=
                                                _InviteInputMode.email) {
                                              setState(
                                                () => _inviteInputMode =
                                                    _InviteInputMode.email,
                                              );
                                            }
                                          },
                                          onMessageTap: () {
                                            if (_inviteInputMode !=
                                                _InviteInputMode.message) {
                                              setState(
                                                () => _inviteInputMode =
                                                    _InviteInputMode.message,
                                              );
                                            }
                                          },
                                        ),
                                        PartnerInvitationQrTab(
                                          theme: theme,
                                          generatedInvitation:
                                              _generatedInvitation,
                                          isSent: _isSent,
                                          onGenerateCode: _generateCodeOnly,
                                          onSaveQr: _saveQRCode,
                                        ),
                                        PartnerInvitationLinkTab(
                                          generatedInvitation:
                                              _generatedInvitation,
                                          isSent: _isSent,
                                          onGenerateLink: _generateCodeOnly,
                                          onShareLink: _shareLink,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

  Widget _buildHeader(ThemeData theme, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryRose.withValues(alpha: 0.1),
            AppTheme.primaryPurple.withValues(alpha: 0.1),
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
              gradient: LinearGradient(
                colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.favorite,
              color: Colors.white.withValues(alpha: 0.03),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invite Your Partner',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                ),
                Text(
                  'Share Your Love And Cycle Journey Together 💖',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mediumGrey.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, color: AppTheme.mediumGrey),
          ),
        ],
      ),
    ).animate().slideY(begin: -0.3, end: 0, duration: 400.ms);
  }

  Widget _buildTabBar(ThemeData theme, AppLocalizations localizations) {
    return Container(
          margin: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: AppTheme.lightGrey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            height: 64,
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              splashBorderRadius: BorderRadius.circular(16),
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.mediumGrey,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              labelPadding: EdgeInsets.zero,
              tabAlignment: TabAlignment.fill,
              tabs: const [
                Tab(
                  icon: Icon(Icons.email, size: 22),
                  height: 64,
                  text: 'Email',
                ),
                Tab(
                  icon: Icon(Icons.qr_code, size: 22),
                  height: 64,
                  text: 'QR Code',
                ),
                Tab(
                  icon: Icon(Icons.share, size: 22),
                  height: 64,
                  text: 'Share Link',
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 120.ms)
        .scale(begin: const Offset(0.96, 0.96), curve: Curves.easeOutBack);
  }

  Future<void> _openEmailInvite() async {
    if (_isExecutingInvite || _isSent || _isLoading) return;
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    if (_successMessage != null) {
      setState(() => _successMessage = null);
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isExecutingInvite = true;
      _isLoading = true;
    });

    try {
      final result = await widget.partnerService.sendPartnerInvitation(
        inviteeEmail: email,
        personalMessage: message.isEmpty ? null : message,
      );

      if (!mounted) return;

      if (result == null) {
        _showErrorMessage("Failed to send invitation");
        return;
      }

      setState(() {
        _successMessage = "Invitation sent successfully ❤️";
        _isSent = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _successMessage = null);
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      _showErrorMessage("Error sending invitation: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isExecutingInvite = false;
        });
      } else {
        _isExecutingInvite = false;
      }
    }
  }

  Future<void> _generateCodeOnly() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _successMessage = null;
    });

    try {
      final invitation = await widget.partnerService.createPartnerInvitation();

      if (!mounted) return;

      setState(() {
        _generatedInvitation = invitation;
      });
    } catch (e) {
      _showErrorMessage("Error generating invitation: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _isExecutingInvite = false;
    }
  }

  void _shareLink() {
    if (_generatedInvitation != null) {
      PartnerInvitationActions.shareLink(_generatedInvitation!);
    }
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _saveQRCode() {
    setState(() => _successMessage = "QR saved successfully");
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _successMessage = null);
      }
    });
  }
}
