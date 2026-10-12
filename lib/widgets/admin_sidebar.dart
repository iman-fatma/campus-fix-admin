import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';
import '../controllers/admin_auth_controller.dart';
import '../controllers/admin_shell_controller.dart';

class AdminSidebar extends StatelessWidget {
  final bool isDrawer;

  const AdminSidebar({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    final shellController = Get.find<AdminShellController>();
    final authController = Get.find<AdminAuthController>();

    return Obx(() {
      final selectedIndex = shellController.selectedIndex.value;
      final isExpanded = shellController.isSidebarExpanded.value || isDrawer;
      final admin = authController.currentAdmin.value;

      return Container(
        width: isDrawer ? 280 : (isExpanded ? 260 : 72),
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.sidebarBg,
          border: const Border(
            right: BorderSide(color: Color(0xFF1E293B), width: 1),
          ),
        ),
        child: Column(
          children: [
            // App Branding Header
            Container(
              height: 70,
              padding: EdgeInsets.symmetric(horizontal: isExpanded ? 20 : 12),
              alignment: Alignment.centerLeft,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF0D9488)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.build_circle_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  if (isExpanded) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CampusFix',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'ADMIN PORTAL',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.accentTeal,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Navigation Links
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 10,
                ),
                children: [
                  _navItem(
                    index: 0,
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    isSelected: selectedIndex == 0,
                    isExpanded: isExpanded,
                    onTap: () => shellController.setIndex(0),
                  ),
                  _navItem(
                    index: 1,
                    icon: Icons.confirmation_number_outlined,
                    activeIcon: Icons.confirmation_number_rounded,
                    title: 'Tickets / Issues',
                    isSelected: selectedIndex == 1,
                    isExpanded: isExpanded,
                    onTap: () => shellController.setIndex(1),
                  ),
                  _navItem(
                    index: 2,
                    icon: Icons.people_alt_outlined,
                    activeIcon: Icons.people_alt_rounded,
                    title: 'Students & Users',
                    isSelected: selectedIndex == 2,
                    isExpanded: isExpanded,
                    onTap: () => shellController.setIndex(2),
                  ),
                  _navItem(
                    index: 3,
                    icon: Icons.campaign_outlined,
                    activeIcon: Icons.campaign_rounded,
                    title: 'Announcements',
                    isSelected: selectedIndex == 3,
                    isExpanded: isExpanded,
                    onTap: () => shellController.setIndex(3),
                  ),
                  _navItem(
                    index: 4,
                    icon: Icons.admin_panel_settings_outlined,
                    activeIcon: Icons.admin_panel_settings_rounded,
                    title: 'Admin Settings',
                    isSelected: selectedIndex == 4,
                    isExpanded: isExpanded,
                    onTap: () => shellController.setIndex(4),
                  ),
                ],
              ),
            ),

            // Bottom Admin Profile & Logout
            Container(
              padding: EdgeInsets.all(isExpanded ? 14 : 8),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFF1E293B), width: 1),
                ),
              ),
              child: Column(
                children: [
                  if (isExpanded)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF132238),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppTheme.accentTeal,
                            child: Text(
                              admin?.initials ?? 'AD',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  admin?.fullName ?? 'Campus Admin',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Super Admin',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _confirmSignOut(context, authController),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: isExpanded
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          if (isExpanded) ...[
                            const SizedBox(width: 10),
                            Text(
                              'Sign Out',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required bool isSelected,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 12,
              horizontal: isExpanded ? 14 : 0,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF1E3A8A).withValues(alpha: 0.6)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                  size: 20,
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF94A3B8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF60A5FA),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(
    BuildContext context,
    AdminAuthController authController,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Sign Out',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to end your administrator session?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              authController.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.rejectedText,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
