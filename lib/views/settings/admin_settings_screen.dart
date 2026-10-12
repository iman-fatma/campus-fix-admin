import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';
import '../../core/responsive.dart';
import '../../controllers/admin_auth_controller.dart';
import '../../widgets/custom_button.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AdminAuthController>();
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Obx(() {
        final admin = authController.currentAdmin.value;
        final lastLoginStr = admin?.lastLogin != null
            ? DateFormat('MMMM d, yyyy • h:mm a').format(admin!.lastLogin!)
            : 'Today';

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Administrator Profile & Portal Settings',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage administrative permissions, security configurations, and database linkages.',
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 20),

                // Admin Profile Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppTheme.primaryNavy,
                            child: Text(
                              admin?.initials ?? 'AD',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      admin?.fullName ?? 'Campus Facilities Administrator',
                                      style: GoogleFonts.inter(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentTeal.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'ADMIN',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.accentTeal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  admin?.email ?? 'admin@campusfix.test',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppTheme.textMedium,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  admin?.department ?? 'Campus Facilities & Operations',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 28, color: AppTheme.borderLight),

                      _buildInfoRow('Security Role', 'Campus Facility Super Administrator'),
                      _buildInfoRow('Access Scope', 'Full Read & Write (Firestore, Tickets, Students, Notices)'),
                      _buildInfoRow('Admin UID', admin?.uid ?? 'N/A'),
                      _buildInfoRow('Last Active Session', lastLoginStr),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Firebase Environment Linkage Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cloud_done_rounded, color: AppTheme.accentTeal, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Firebase Cloud Connection',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildInfoRow('Firebase Project ID', 'campus-fix-9565f (Attached to Campus Fix App)'),
                      _buildInfoRow('Firestore Collections', 'users, students, tickets, announcements, admins'),
                      _buildInfoRow('Connection Status', 'Synchronized & Streaming Live'),
                      const SizedBox(height: 14),

                      OutlinedButton.icon(
                        onPressed: () async {
                          final email = admin?.email ?? '';
                          if (email.isEmpty) return;

                          final sent = await authController.sendPasswordReset(
                            email,
                          );
                          Get.snackbar(
                            sent ? 'Password Reset Link Sent' : 'Password Reset Failed',
                            sent
                                ? 'Check your inbox at $email to reset the admin password.'
                                : authController.errorMessage.value,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        icon: const Icon(Icons.lock_reset, size: 18),
                        label: const Text('Send Password Reset Email'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textMedium,
                          side: const BorderSide(color: AppTheme.borderLight),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Out Button
                CustomButton(
                  text: 'Sign Out of Administrator Session',
                  icon: Icons.logout_rounded,
                  variant: ButtonVariant.danger,
                  width: double.infinity,
                  onPressed: () => authController.signOut(),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
