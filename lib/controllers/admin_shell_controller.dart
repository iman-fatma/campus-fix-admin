import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminShellController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxBool isSidebarExpanded = true.obs;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void setIndex(int index) {
    selectedIndex.value = index;
    // Close drawer on mobile if open
    if (scaffoldKey.currentState?.isDrawerOpen ?? false) {
      scaffoldKey.currentState?.closeDrawer();
    }
  }

  void toggleSidebar() {
    isSidebarExpanded.value = !isSidebarExpanded.value;
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
  }
}
