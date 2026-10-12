import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_shell_controller.dart';
import '../controllers/announcements_controller.dart';
import '../controllers/students_controller.dart';
import '../controllers/tickets_controller.dart';
import '../core/responsive.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_top_nav.dart';
import 'announcements/announcements_screen.dart';
import 'dashboard/admin_dashboard_screen.dart';
import 'settings/admin_settings_screen.dart';
import 'students/students_screen.dart';
import 'tickets/tickets_screen.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  static const _titles = [
    'Dashboard',
    'Tickets / Issues',
    'Students & Users',
    'Announcements',
    'Admin Settings',
  ];

  late final AdminShellController _shellController;

  @override
  void initState() {
    super.initState();
    _shellController = Get.put(AdminShellController());
    Get.put(TicketsController());
    Get.put(StudentsController());
    Get.put(AnnouncementsController());
  }

  @override
  void dispose() {
    Get.delete<AnnouncementsController>();
    Get.delete<StudentsController>();
    Get.delete<TicketsController>();
    Get.delete<AdminShellController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final screens = [
      const AdminDashboardScreen(),
      const TicketsScreen(),
      const StudentsScreen(),
      const AnnouncementsScreen(),
      const AdminSettingsScreen(),
    ];

    if (isMobile) {
      return Obx(() {
        final index = _shellController.selectedIndex.value;
        return Scaffold(
          key: _shellController.scaffoldKey,
          appBar: AdminTopNav(title: _titles[index]),
          drawer: Drawer(
            width: 280,
            child: AdminSidebar(isDrawer: true),
          ),
          body: IndexedStack(index: index, children: screens),
        );
      });
    }

    return Obx(() {
      final index = _shellController.selectedIndex.value;
      return Scaffold(
        body: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _shellController.isSidebarExpanded.value ? 260 : 72,
              child: const AdminSidebar(),
            ),
            Expanded(
              child: Column(
                children: [
                  AdminTopNav(title: _titles[index]),
                  Expanded(
                    child: IndexedStack(index: index, children: screens),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
