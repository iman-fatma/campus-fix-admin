import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
