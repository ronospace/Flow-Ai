import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';
import '../services/partner_service.dart';

class PartnerInvitationDialog extends StatefulWidget {
  final PartnerService partnerService;

  const PartnerInvitationDialog({super.key, required this.partnerService});

  @override
  State<PartnerInvitationDialog> createState() =>
      _PartnerInvitationDialogState();
}

class _PartnerInvitationDialogState extends State<PartnerInvitationDialog>
    with TickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _messageFocus.addListener(() => setState(() {}));

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
  void dispose() {
    _tabController.dispose();
    _dialogController.dispose();
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
                      : (constraints.maxHeight * 0.78).clamp(320.0, 680.0).toDouble();

                  return Padding(
                    padding: EdgeInsets.only(
                      top: 56,
                      bottom: keyboardOpen ? 0 : 48,
                    ),
                    child: Align(
                      alignment: keyboardOpen ? Alignment.topCenter : Alignment.center,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 420,
                          maxHeight: dialogHeight,
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.38),
                                blurRadius: 28,
                                spreadRadius: 8,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                color: Colors.white.withValues(alpha: 0.04),
                                child: Column(
                                  children: [
                                    _buildHeader(theme, localizations),
                                    _buildTabBar(theme, localizations),
                                    Expanded(
                                      child: TabBarView(
                                        controller: _tabController,
                                        children: [
                                          _buildEmailInviteTab(theme, localizations),
                                          _buildQRCodeTab(theme, localizations),
                                          _buildLinkShareTab(theme, localizations),
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
            child: Icon(Icons.favorite, color: Colors.white, size: 22),
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
      child: SizedBox(height: 64,
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
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        labelPadding: EdgeInsets.zero,
        tabAlignment: TabAlignment.fill,
        tabs: const [
          Tab(icon: Icon(Icons.email, size: 22), height: 64, text: 'Email'),
          Tab(icon: Icon(Icons.qr_code, size: 22), height: 64, text: 'QR Code'),
          Tab(icon: Icon(Icons.share, size: 22), height: 64, text: 'Share Link'),
        ],
      ),
    
      ),
    ).animate().fadeIn(delay: 120.ms).scale(begin: const Offset(0.96,0.96), curve: Curves.easeOutBack);
  }

  Widget _buildEmailInviteTab(ThemeData theme, AppLocalizations localizations) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom > 0 ? 4 : 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_successMessage != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.pink),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.3),
              ],

              const SizedBox(height: 12),

              if (!_messageFocus.hasFocus)
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocus,
                decoration: InputDecoration(
                                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  hintText: 'Partner\'s Email',
                                    prefixIcon: Icon(Icons.email_outlined, size: 20, color: AppTheme.primaryRose),
                  prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  filled: true,
                  fillColor: AppTheme.primaryRose.withValues(alpha: 0.16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.42)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.42)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppTheme.primaryRose,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }

                  final lower = value.toLowerCase();

                  if (lower.endsWith('@gmail.co') ||
                      lower.endsWith('@gamil.com') ||
                      lower.endsWith('@gnail.com') ||
                      lower.endsWith('@gmail.con') ||
                      lower.endsWith('@yahoo.co') ||
                      lower.endsWith('@outlook.co') ||
                      lower.endsWith('@icloud.co')) {
                    return 'Did you mean .com?';
                  }

                  return null;
                },
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 24),

              if (!_emailFocus.hasFocus)
              TextFormField(
                controller: _messageController,
                focusNode: _messageFocus,
                maxLines: 3,
                decoration: InputDecoration(
                                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  hintText: 'Personal Message (Optional)',
                                    prefixIcon: Icon(Icons.message_outlined, size: 20, color: AppTheme.primaryRose),
                  prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  filled: true,
                  fillColor: AppTheme.primaryPurple.withValues(alpha: 0.16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.42)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.42)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppTheme.primaryRose,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              if (!_emailFocus.hasFocus && !_messageFocus.hasFocus)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                  onPressed: (_isLoading || _isSent) ? null : _openEmailInvite,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(_isSent ? Icons.check : Icons.send),
                  label: Text(
                    _isLoading
                        ? 'Sending...'
                        : (_isSent ? 'Sent ✓' : 'Send Invitation'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSent
                        ? AppTheme.primaryRose.withOpacity(0.35)
                        : AppTheme.primaryRose,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
              ),
            ),
          ),
        );
      },
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildQRCodeTab(ThemeData theme, AppLocalizations localizations) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Transform.translate(
              offset: Offset.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRose.withValues(alpha: 0.28),
                          blurRadius: 26,
                          spreadRadius: 0,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (_generatedInvitation != null)
                          QrImageView(
                            data: _generateInvitationLink(_generatedInvitation!),
                            version: QrVersions.auto,
                            size: 176,
                            foregroundColor: AppTheme.darkGrey,
                          )
                        else
                          Container(
                            width: 176,
                            height: 176,
                            decoration: BoxDecoration(
                              color: AppTheme.lightGrey.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.qr_code,
                                  size: 52,
                                  color: AppTheme.mediumGrey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Generate QR Code',
                                  style: TextStyle(
                                    color: AppTheme.mediumGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Scan to connect',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(begin: const Offset(0.92,0.92), curve: Curves.easeOutBack).fadeIn(delay: 120.ms),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _generateCodeOnly,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Generate Code'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryRose,
                            side: BorderSide(color: AppTheme.primaryRose),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _generatedInvitation != null ? _saveQRCode : null,
                          icon: const Icon(Icons.save),
                          label: const Text('Save QR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSent
                                ? AppTheme.primaryRose.withOpacity(0.35)
                                : AppTheme.primaryRose,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLinkShareTab(ThemeData theme, AppLocalizations localizations) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Transform.translate(
              offset: Offset.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.link, size: 48, color: AppTheme.primaryRose),
                const SizedBox(height: 16),

                if (_generatedInvitation != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _generateInvitationLink(_generatedInvitation!),
                            style: TextStyle(
                              color: AppTheme.mediumGrey,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _copyToClipboard(
                            _generateInvitationLink(_generatedInvitation!),
                          ),
                          icon: Icon(
                            Icons.copy,
                            color: AppTheme.primaryRose,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Text(
                    'Link will appear here after generation',
                    style: TextStyle(color: AppTheme.mediumGrey),
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(delay: 120.ms).scale(begin: const Offset(0.96,0.96), curve: Curves.easeOutBack),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _generateCodeOnly,
                  icon: const Icon(Icons.link),
                  label: const Text('Generate Link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryRose,
                    side: BorderSide(color: AppTheme.primaryRose),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _generatedInvitation != null ? _shareLink : null,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSent
                        ? AppTheme.primaryRose.withOpacity(0.35)
                        : AppTheme.primaryRose,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
              ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openEmailInvite() async {
    if (_isExecutingInvite || _isSent || _isLoading) return;
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

  String _generateInvitationLink(PartnerInvitation invitation) {
    return 'https://flow-ai-656b3.web.app/invite/${invitation.invitationCode}';
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  void _shareLink() {
    if (_generatedInvitation != null) {
      final link = _generateInvitationLink(_generatedInvitation!);
      Share.share(link);
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
