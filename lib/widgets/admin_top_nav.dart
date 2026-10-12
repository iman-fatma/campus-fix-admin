import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../controllers/admin_auth_controller.dart';
import '../controllers/admin_shell_controller.dart';
import 'new_announcement_dialog.dart';
import 'new_ticket_dialog.dart';

class AdminTopNav extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AdminTopNav({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(65);

  @override
  Widget build(BuildContext context) {
    final shellController = Get.find<AdminShellController>();
    final authController = Get.find<AdminAuthController>();
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Left: Menu toggle or Back
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppTheme.primaryNavy),
              onPressed: shellController.openDrawer,
            )
          else
            IconButton(
              icon: Obx(() => Icon(
                    shellController.isSidebarExpanded.value
                        ? Icons.menu_open_rounded
                        : Icons.menu_rounded,
                    color: AppTheme.textMedium,
                  )),
              onPressed: shellController.toggleSidebar,
              tooltip: 'Toggle Sidebar',
            ),
          const SizedBox(width: 8),

          // Title
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 17 : 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),

          const Spacer(),

          // Quick Action: + New Ticket
          if (!isMobile) ...[
            OutlinedButton.icon(
              onPressed: () => NewAnnouncementDialog.show(context),
              icon: const Icon(Icons.campaign_outlined, size: 18),
              label: Text(
                'New Notice',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textMedium,
                side: const BorderSide(color: AppTheme.borderLight),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => NewTicketDialog.show(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                'Log Ticket',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 16),
            const VerticalDivider(width: 1, indent: 16, endIndent: 16, color: AppTheme.borderLight),
            const SizedBox(width: 16),
          ],

          // Admin Profile Pill
          Obx(() {
            final admin = authController.currentAdmin.value;
            return PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'settings') {
                  shellController.setIndex(4);
                } else if (val == 'logout') {
                  authController.signOut();
                }
              },
              offset: const Offset(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppTheme.borderLight),
              ),
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admin?.fullName ?? 'Campus Admin',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        admin?.email ?? '',
                        style: GoogleFonts.inter(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, size: 18, color: AppTheme.textMedium),
                      const SizedBox(width: 10),
                      Text('Admin Profile', style: GoogleFonts.inter(fontSize: 13)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout, size: 18, color: AppTheme.rejectedText),
                      const SizedBox(width: 10),
                      Text(
                        'Sign Out',
                        style: GoogleFonts.inter(fontSize: 13, color: AppTheme.rejectedText),
                      ),
                    ],
                  ),
                ),
              ],
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: AppTheme.primaryNavy,
                    child: Text(
                      admin?.initials ?? 'AD',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          admin?.fullName ?? 'Admin',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          'Administrator',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.accentTeal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.keyboard_arrow_down, size: 18, color: AppTheme.textMuted),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
