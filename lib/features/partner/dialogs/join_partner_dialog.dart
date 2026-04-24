import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/partner_invitation_dialog.dart';
import '../services/partner_service.dart';
import '../screens/qr_join_screen.dart';

class JoinPartnerDialog extends StatefulWidget {
  final String? initialCode;
  final Future<void> Function(String) onJoinWithCode;

  const JoinPartnerDialog({
    super.key,
    this.initialCode,
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
  late TabController _tabController;

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _manualEmailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _requestSent = false;
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
                              color: const Color(
                                0xFF9B59B6,
                              ).withValues(alpha: 0.2),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF9B59B6,
                                ).withValues(alpha: 0.2),
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
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    0,
                                  ),
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
            showDialog(
      barrierColor: Colors.transparent,
              context: context,
              builder: (_) => PartnerInvitationDialog(partnerService: PartnerService()),
            );
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryRose.withValues(alpha: 0.1),
              AppTheme.primaryRose.withValues(alpha: 0.05),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.group_add, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryRose,
                    ),
                  ),
                ],
              ),
            ),
            _buildHeaderCollapseControl(),
          ],
        ),
      ),
    ).animate().slideY(begin: -0.3, end: 0, duration: 400.ms);
  }

  Widget _buildHeaderCollapseControl() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).cardColor
              : Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFB58AAE).withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.55
                  : 0.35,
            ),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.transparent,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 22,
          color: const Color(0xFFB07ACB),
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
          color: const Color(0xFFB58AAE).withValues(alpha: 0.35),
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
          unselectedLabelColor: const Color(0xFF6F6673),
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: const [
            Tab(
              height: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Icons.link, size: 20),
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
          const SizedBox(height: 12),
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
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight * 0.72,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.link,
                              size: 72,
                              color: const Color(0xFFB07ACB),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Connect with Code',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Use a 6-character code to Synchronize',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: const Color(0xFF9B59B6)),
                            ),
                            const SizedBox(height: 12),
                            _buildCodeInput(),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              _buildErrorMessage(),
                            ],
                            const SizedBox(height: 16),
                            _buildJoinButton(),
                            const SizedBox(height: 14),
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
          constraints: BoxConstraints(minHeight: constraints.maxHeight * 0.72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 72,
                  color: const Color(0xFFB07ACB),
                ),
                const SizedBox(height: 10),
                Text(
                  'Scan Partner QR Code',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use your camera to scan instantly',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: const Color(0xFF9B59B6)),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _showRequestInvitationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).cardColor,
                    foregroundColor: AppTheme.primaryRose,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: const Color(0xFF9B59B6).withValues(alpha: 0.55),
                        width: 1.4,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.qr_code_scanner, size: 18),
                      SizedBox(width: 8),
                      Text('Open Scanner'),
                    ],
                  ),
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
          constraints: BoxConstraints(minHeight: constraints.maxHeight * 0.72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.alternate_email,
                  size: 72,
                  color: const Color(0xFFB07ACB),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manual Connection',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Synchronize using your partner\'s Email',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: const Color(0xFF9B59B6)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  autofocus: false,
                  controller: _manualEmailController,
                  textAlign: TextAlign.start,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.emailAddress,
                  onFieldSubmitted: (_) => _handleManualJoin(),
                  autocorrect: false,
                  onChanged: (_) => setState(() {}),
                  inputFormatters: [LengthLimitingTextInputFormatter(80)],
                  decoration: InputDecoration(
                    hintText: 'partner@example.com',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppTheme.primaryRose,
                    ),
                    hintStyle: TextStyle(
                      color: const Color(0xFFD2BEDB),
                      letterSpacing: 0,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: _manualEmailController.text.isEmpty
                            ? Theme.of(context).dividerColor
                            : (_isValidManualEmail()
                                  ? Colors.green
                                  : AppTheme.primaryRose),
                        width: 1.4,
                      ),
                    ),
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
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).cardColor.withOpacity(0.92)
                        : const Color(0xFFF9EEF3),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _requestSent
                      ? 'Your partner will be notified when connected'
                      : 'Enter a valid partner Email to enable request',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        _requestSent
                        ? Colors.green
                        : Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor:
                          _errorMessage ==
                              'Request sent successfully. Waiting for your partner.'
                          ? Colors.green
                          : ((_isLoading || !_isValidManualEmail())
                                ? Colors.grey.shade400
                                : AppTheme.primaryRose),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    onPressed:
                        (_isLoading ||
                            !_isValidManualEmail() ||
                            _errorMessage ==
                                'Request sent successfully. Waiting for your partner.')
                        ? null
                        : _handleManualJoin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 260),
                            child: Row(
                              key: ValueKey(
                                _errorMessage ==
                                    'Request sent successfully. Waiting for your partner.',
                              ),
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _errorMessage ==
                                        'Request sent successfully. Waiting for your partner.'
                                    ? const Icon(Icons.check, size: 20)
                                    : const Icon(Icons.send, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  _errorMessage ==
                                          'Request sent successfully. Waiting for your partner.'
                                      ? 'Request Sent'
                                      : 'Send Request',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
        Row(
          children: [
            Expanded(
              child: TextFormField(
                autofocus: false,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleJoin(),
                controller: _codeController,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0,
                ),
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                enableSuggestions: false,
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                  LengthLimitingTextInputFormatter(6),
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
                    padding: const EdgeInsets.only(left: 12, right: 6),
                    child: Icon(
                      Icons.vpn_key,
                      size: 18,
                      color: AppTheme.primaryRose,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: const Color(0xFFD2BEDB),
                      width: 1.4,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: const Color(0xFFD2BEDB),
                      width: 1.4,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: const Color(0xFFB07ACB),
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
                      : const Color(0xFFF3EFF8),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 20,
                  ),
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
            const SizedBox(width: 8),
            IconButton(
              iconSize: 20,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              onPressed: _pasteFromClipboard,
              icon: Icon(Icons.content_paste, color: const Color(0xFF9B59B6)),
              tooltip: 'Paste from clipboard',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).dividerColor.withValues(alpha: 0.2),
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
        onPressed: (_isLoading || _codeController.text.trim().length != 6)
            ? null
            : _handleJoin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryRose,
          disabledBackgroundColor: AppTheme.primaryRose.withValues(alpha: 0.38),
          foregroundColor: Colors.white,
          disabledForegroundColor: const Color(0xFFB78FA6),
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link, size: 20),
                  SizedBox(width: 10),
                  Text(
                    _errorMessage == 'Connected successfully.'
                        ? 'Connected'
                        : 'Connect with Partner',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
    FocusScope.of(context).unfocus();

    final code = _codeController.text.trim();

    if (code.length != 6) {
      setState(() {
        _errorMessage = 'Enter a valid 6-character code.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    setState(() {
      _isLoading = false;
      _errorMessage = 'Invalid or expired partner code.';
    });
  }

  bool _isValidManualEmail() {
    final email = _manualEmailController.text.trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  void _showRequestInvitationDialog() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const QrJoinScreen()));
  }

  void _handleManualJoin() async {
    FocusScope.of(context).unfocus();

    final email = _manualEmailController.text.trim();

    if (email.isEmpty ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() {
        _errorMessage = 'Enter a valid E-Mail address.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await PartnerService().sendPartnerInvitation(
      inviteeEmail: email,
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _isLoading = false;
        _requestSent = true;
        _errorMessage = 'Request sent successfully. Waiting for your partner.';
      });

      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to send invitation.';
      });
    }
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
