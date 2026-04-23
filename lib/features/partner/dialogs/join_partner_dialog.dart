import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/partner_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import 'invite_partner_dialog.dart';
import '../screens/qr_join_screen.dart';

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
  late TabController _tabController;

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _manualEmailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    if (widget.initialCode != null && widget.initialCode!.isNotEmpty) {
      _codeController.text = widget.initialCode!;
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _codeController.dispose();
    _manualEmailController.dispose();
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
                          width: double.infinity,
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
                              _buildTopTabs(),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
    return GestureDetector(
      onPanEnd: (d) {
        if (d.velocity.pixelsPerSecond.dx > 80) {
          Navigator.pop(context);
          Future.delayed(const Duration(milliseconds: 160), () {
            showDialog(context: context, builder: (_) => InvitePartnerDialog(onSendInvite: (_, __) {}));
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.group_add, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join Your Partner 💍',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  'Connect Your Love and Cycle Journey Together 💞',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
          _buildHeaderCollapseControl(),
        ],
      ),
    )).animate().slideY(begin: -0.3, end: 0);
  }





  


  

Widget _buildHeaderCollapseControl() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).cardColor : Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.55 : 0.35),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 22,
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }




  Widget _buildTopTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 14),
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
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(2),
          labelPadding: EdgeInsets.zero,
          tabAlignment: TabAlignment.fill,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: Theme.of(context).hintColor,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: const [
            Tab(
              height: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link, size: 20),
                  SizedBox(height: 4),
                  Text('Code'),
                ],
              ),
            ),
            Tab(
              height: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code, size: 20),
                  SizedBox(height: 4),
                  Text('QR Code'),
                ],
              ),
            ),
            Tab(
              height: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 20),
                  SizedBox(height: 4),
                  Text('Manual'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
        const SizedBox(height: 14),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
            children: [
              LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  primary: false,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                    Text(
                      'Use the code your partner sent to connect instantly.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCodeInput(),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _buildErrorMessage(),
                    ],
                    const SizedBox(height: 20),
                    _buildJoinButton(),
                    const SizedBox(height: 16),
                    _buildAlternativeOptions(),
                    const SizedBox(height: 16),
                  ],
                ),
                      ),
                    ),
                  ),
              ),
              _buildQrTab(),
              _buildManualTab(),
            ],
          ),
        ),
        ],
      ),
    );
  }



  Widget _buildQrTab() {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.qr_code_scanner, size: 72, color: AppTheme.primaryRose),
                const SizedBox(height: 16),
                Text(
                  'Scan Partner QR Code',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use your camera to scan instantly',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _showRequestInvitationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).cardColor,
                    foregroundColor: AppTheme.primaryRose,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppTheme.primaryRose.withValues(alpha: 0.55),
                        width: 1.4,
                      ),
                    ),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.qr_code_scanner, size: 18), SizedBox(width: 8), Text('Open Scanner')]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManualTab() {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.alternate_email, size: 72, color: AppTheme.primaryPurple),
                const SizedBox(height: 16),
                Text(
                  'Manual Connection',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect using your partner\'s email.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _manualEmailController,
                  textAlign: TextAlign.start,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.emailAddress,
                  onFieldSubmitted: (_) => _handleManualJoin(),
                  autocorrect: false,
                  onChanged: (_) => setState(() {}),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(80),
                  ],
                  decoration: InputDecoration(
                    hintText: 'partner@example.com',
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryPurple),
                    hintStyle: TextStyle(
                      color: Theme.of(context).dividerColor,
                      letterSpacing: 0,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: _manualEmailController.text.isEmpty ? Theme.of(context).dividerColor : (_isValidManualEmail() ? Colors.green : AppTheme.primaryRose), width: 1.4),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppTheme.primaryPurple, width: 2),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(_errorMessage == 'Request sent successfully. Waiting for your partner.' ? 'Your partner will be notified when connected.' : 'Enter a valid partner email to enable request.', style: TextStyle(fontSize: 12, color: _errorMessage == 'Request sent successfully. Waiting for your partner.' ? Colors.green : Theme.of(context).hintColor)),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: _errorMessage == 'Request sent successfully. Waiting for your partner.' ? Colors.green : ((_isLoading || !_isValidManualEmail()) ? Colors.grey.shade300 : AppTheme.primaryRose),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    onPressed: (_isLoading || !_isValidManualEmail() || _errorMessage == 'Request sent successfully. Waiting for your partner.') ? null : _handleManualJoin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : AnimatedSwitcher(duration: const Duration(milliseconds: 260), child: Row(key: ValueKey(_errorMessage == 'Request sent successfully. Waiting for your partner.'), mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [_errorMessage == 'Request sent successfully. Waiting for your partner.' ? const Icon(Icons.check, size: 20) : const Icon(Icons.send, size: 20), const SizedBox(width: 8), Text(_errorMessage == 'Request sent successfully. Waiting for your partner.' ? 'Request Sent' : 'Send Request', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))]),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Code',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the 6-character code to begin syncing together.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                autofocus: _codeController.text.isEmpty,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleJoin(),
                controller: _codeController,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                  LengthLimitingTextInputFormatter(6),
                  UpperCaseTextFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: 'Enter Code',
                  hintStyle: TextStyle(
                    color: Theme.of(context).dividerColor,
                    letterSpacing: 0,
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
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppTheme.primaryRose,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).cardColor.withOpacity(0.92)
                      : const Color(0xFFFFF4F7),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
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
                    _handleJoin();
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: _pasteFromClipboard,
              icon: Icon(Icons.content_paste, color: Theme.of(context).hintColor),
              tooltip: 'Paste from clipboard',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.2),
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


  Widget _buildJoinButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isLoading || _codeController.text.trim().length != 6) ? null : _handleJoin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryRose,
          disabledBackgroundColor: AppTheme.primaryRose.withValues(alpha: 0.22),
          foregroundColor: Colors.white,
          disabledForegroundColor: AppTheme.primaryRose.withValues(alpha: 0.55),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Connect with Partner',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
              children: [
            Expanded(child: Divider(color: Theme.of(context).dividerColor, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: TextStyle(color: Theme.of(context).hintColor, fontSize: 11),
              ),
            ),
            Expanded(child: Divider(color: Theme.of(context).dividerColor, thickness: 1)),
          ],
        ),
        const SizedBox(height: 24),
        _buildAlternativeOption(
          'Request New Invitation',
          'Ask your partner to send a new invitation',
          Icons.refresh,
          () {
            Navigator.pop(context);
            _showRequestInvitationDialog();
          },
        ),
        const SizedBox(height: 24),
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
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
              children: [
            Icon(icon, color: Theme.of(context).hintColor, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Theme.of(context).hintColor, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Theme.of(context).dividerColor, size: 16),
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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QrJoinScreen()),
    );
  }

  void _showManualConnectionDialog() {}

  void _handleManualJoin() async {
    final email = _manualEmailController.text.trim();

    if (email.isEmpty || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() {
        _errorMessage = 'Enter a valid email address.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _errorMessage = 'Request sent successfully. Waiting for your partner.';
      _isLoading = false;
    });

    final service = context.read<PartnerService>();
      final result = await service.sendPartnerInvitation(
        inviteeEmail: _manualEmailController.text.trim(),
      );
      setState(() => _isLoading = false);
      if (result != null && mounted) Navigator.of(context).pop(true);
  }

  bool _isValidManualEmail() {
    final email = _manualEmailController.text.trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
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
