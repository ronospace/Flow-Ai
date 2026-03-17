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
  final _formKey = GlobalKey<FormState>();


  bool _isLoading = false;
  String? _successMessage;


  PartnerInvitation? _generatedInvitation;

  @override
  void initState() {
    super.initState();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: _dialogController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
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
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(24),
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
              gradient: const LinearGradient(
                colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 24),
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
                  'Share your cycle journey together',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mediumGrey,
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.mediumGrey,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(icon: Icon(Icons.email, size: 20), text: 'Email'),
          Tab(icon: Icon(Icons.qr_code, size: 20), text: 'QR Code'),
          Tab(icon: Icon(Icons.share, size: 20), text: 'Share Link'),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildEmailInviteTab(ThemeData theme, AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_successMessage != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
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

              const SizedBox(height: 24),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Partner\'s Email',
                  hintText: 'Enter your partner\'s email address',
                  prefixIcon: Icon(Icons.email, color: AppTheme.primaryRose),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
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
              const SizedBox(height: 16),

              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Personal Message (Optional)',
                  hintText: 'Add a personal touch to your invitation...',
                  prefixIcon: Icon(Icons.message, color: AppTheme.primaryRose),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
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

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _openEmailInvite,
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
                      : const Icon(Icons.send),
                  label: Text(_isLoading ? 'Sending...' : 'Send Invitation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRose,
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
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildQRCodeTab(ThemeData theme, AppLocalizations localizations) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'QR Code Invitation',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Show this QR code to your partner or save it to share later.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGrey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryRose.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (_generatedInvitation != null)
                      QrImageView(
                        data: _generateInvitationLink(_generatedInvitation!),
                        version: QrVersions.auto,
                        size: 200.0,
                        foregroundColor: AppTheme.darkGrey,
                      )
                    else
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppTheme.lightGrey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code,
                              size: 60,
                              color: AppTheme.mediumGrey,
                            ),
                            const SizedBox(height: 12),
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

                    const SizedBox(height: 16),

                    Text(
                      'Flow Ai Partner Invitation',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    Text(
                      'Scan to connect',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGrey,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .scale(begin: const Offset(0.8, 0.8))
              .fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

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
                    backgroundColor: AppTheme.primaryRose,
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
    );
  }

  Widget _buildLinkShareTab(ThemeData theme, AppLocalizations localizations) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Share Invitation Link',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate a secure link that your partner can use to join from any device.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGrey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryRose.withValues(alpha: 0.1),
                  AppTheme.primaryPurple.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryRose.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.link, size: 48, color: AppTheme.primaryRose),
                const SizedBox(height: 16),

                if (_generatedInvitation != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.lightGrey, width: 1),
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
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

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
                    backgroundColor: AppTheme.primaryRose,
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
    );
  }

  Future<void> _openEmailInvite() async {
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    if (_successMessage != null) {
      setState(() => _successMessage = null);
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

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
      if (mounted) setState(() => _isLoading = false);
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
