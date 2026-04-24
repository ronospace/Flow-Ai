import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

enum InviteInputMode { idle, email, message }

class PartnerInvitationEmailTab extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController messageController;
  final FocusNode emailFocus;
  final FocusNode messageFocus;
  final GlobalKey<FormState> formKey;
  final InviteInputMode inviteInputMode;
  final bool isLoading;
  final bool isSent;
  final String? successMessage;
  final VoidCallback onSubmit;
  final VoidCallback onEmailTap;
  final VoidCallback onMessageTap;

  const PartnerInvitationEmailTab({
    super.key,
    required this.emailController,
    required this.messageController,
    required this.emailFocus,
    required this.messageFocus,
    required this.formKey,
    required this.inviteInputMode,
    required this.isLoading,
    required this.isSent,
    required this.successMessage,
    required this.onSubmit,
    required this.onEmailTap,
    required this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget emailField() {
      return TextFormField(
        key: const ValueKey('invite_email_field'),
        controller: emailController,
        focusNode: emailFocus,
        showCursor: true,
        cursorColor: const Color(0xFFFF6FAE),
        textInputAction: TextInputAction.done,
        onTap: onEmailTap,
        onEditingComplete: () => emailFocus.unfocus(),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          hintText: "Partner's Email",
          prefixIcon: Icon(
            Icons.email_outlined,
            size: 20,
            color: AppTheme.primaryRose,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          filled: true,
          fillColor: AppTheme.primaryRose.withValues(alpha: 0.16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(
              color: AppTheme.primaryRose.withValues(alpha: 0.14),
              width: 1.2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(
              color: AppTheme.primaryRose.withValues(alpha: 0.18),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: AppTheme.primaryRose, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: Colors.redAccent, width: 1.4),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: Colors.redAccent, width: 1.8),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter an email address';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
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
      );
    }

    Widget messageField() {
      return TextFormField(
        key: const ValueKey('invite_message_field'),
        controller: messageController,
        focusNode: messageFocus,
        showCursor: true,
        cursorColor: const Color(0xFFFF6FAE),
        maxLines: 3,
        textInputAction: emailController.text.trim().isEmpty
            ? TextInputAction.done
            : TextInputAction.send,
        onTap: onMessageTap,
        onFieldSubmitted: (_) {
          if (emailController.text.trim().isEmpty) {
            messageFocus.unfocus();
          } else {
            onSubmit();
          }
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          hintText: 'Personal Message (Optional)',
          prefixIcon: Icon(
            Icons.message_outlined,
            size: 20,
            color: AppTheme.primaryRose,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          suffixIcon: IconButton(
            onPressed: (isLoading || isSent) ? null : onSubmit,
            icon: Icon(Icons.send, size: 20, color: AppTheme.primaryRose),
          ),
          filled: true,
          fillColor: AppTheme.primaryPurple.withValues(alpha: 0.16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(
              color: AppTheme.primaryRose.withValues(alpha: 0.14),
              width: 1.2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(
              color: AppTheme.primaryRose.withValues(alpha: 0.18),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: AppTheme.primaryRose, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: Colors.redAccent, width: 1.4),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: Colors.redAccent, width: 1.8),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).viewInsets.bottom > 0 ? 4 : 24,
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (successMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.pink),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              successMessage!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: -0.3),

                  const SizedBox(height: 12),

                  if (inviteInputMode != InviteInputMode.message) emailField(),
                  if (inviteInputMode == InviteInputMode.idle)
                    const SizedBox(height: 12),
                  if (inviteInputMode != InviteInputMode.email) messageField(),

                  if (inviteInputMode == InviteInputMode.idle) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (isLoading || isSent) ? null : onSubmit,
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                isSent ? Icons.check : Icons.send,
                                size: 20,
                                color: Colors.white,
                              ),
                        label: Text(
                          isLoading
                              ? 'Sending...'
                              : (isSent ? 'Sent ✓' : 'Send Invitation'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSent
                              ? AppTheme.primaryRose.withOpacity(0.35)
                              : AppTheme.primaryRose,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    ).animate().fadeIn(delay: 300.ms);
  }
}
