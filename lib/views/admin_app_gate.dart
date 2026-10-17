import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/admin_auth_controller.dart';
import '../core/app_theme.dart';
import 'admin_shell_screen.dart';
import 'auth/admin_login_screen.dart';

class AdminAppGate extends StatelessWidget {
  const AdminAppGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AdminAuthController>();

    return Obx(() {
      if (authController.isCheckingAuth.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (authController.currentAdmin.value != null) {
        return const AdminShellScreen();
      }

      // Signed in, but the email is not verified yet.
      if (authController.needsEmailVerification.value) {
        return _VerifyEmailView(authController: authController);
      }

      if (authController.authorizationError.value.isNotEmpty) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.gpp_bad_outlined,
                      size: 48,
                      color: AppTheme.rejectedText,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authController.authorizationError.value,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: authController.retryAuthorization,
                      child: const Text('Try again'),
                    ),
                    TextButton(
                      onPressed: authController.signOut,
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      return const AdminLoginScreen();
    });
  }
}

/// Shown when a user is signed in but has not verified their email.
class _VerifyEmailView extends StatelessWidget {
  final AdminAuthController authController;

  const _VerifyEmailView({required this.authController});

  Future<void> _onContinue() async {
    final verified = await authController.checkEmailVerified();
    if (!verified) {
      Get.snackbar(
        'Not verified yet',
        'Open the link in your email first, then tap this button again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        maxWidth: 460,
      );
    }
  }

  Future<void> _onResend() async {
    final sent = await authController.resendVerificationEmail();
    Get.snackbar(
      sent ? 'Email sent' : 'Could not send',
      sent
          ? 'Check your inbox (and spam folder) for the new link.'
          : authController.errorMessage.value,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      maxWidth: 460,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 64,
                  color: AppTheme.accentTeal,
                ),
                const SizedBox(height: 16),
                Text(
                  'Verify your email',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final email = authController.firebaseUser.value?.email ?? '';
                  return Text(
                    'We sent a verification link to $email. Open it, then '
                        'come back and tap the button below to continue.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                      height: 1.5,
                    ),
                  );
                }),
                const SizedBox(height: 24),
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authController.isVerifying.value
                        ? null
                        : _onContinue,
                    child: authController.isVerifying.value
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text("I've verified my email"),
                  ),
                )),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _onResend,
                  child: const Text('Resend verification email'),
                ),
                TextButton(
                  onPressed: authController.signOut,
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}