import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';
import '../../core/responsive.dart';
import '../../controllers/announcements_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/new_announcement_dialog.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnnouncementsController>();
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Obx(() {
        final list = controller.announcements;

        return Padding(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Campus Maintenance Notices & Advisories',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Broadcast scheduled outages, repair notices, and urgent facility alerts directly to all students on the Campus Fix mobile app.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    CustomButton(
                      text: isMobile ? 'Post' : 'Broadcast Notice',
                      icon: Icons.campaign_rounded,
                      onPressed: () => NewAnnouncementDialog.show(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Broadcasted Notices (${list.length})',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),

              // Notices List
              Expanded(
                child: list.isEmpty
                    ? EmptyStateView(
                        icon: Icons.notifications_off_outlined,
                        title: 'No Active Notices',
                        message: 'No campus maintenance notices currently broadcasted.',
                        buttonText: 'Broadcast First Notice',
                        onButtonPressed: () => NewAnnouncementDialog.show(context),
                      )
                    : ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, index) {
                          final item = list[index];
                          final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(item.createdAt);

                          return Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: item.isActive ? AppTheme.borderLight : Colors.grey.shade200,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: item.isActive
                                            ? AppTheme.accentTeal.withValues(alpha: 0.12)
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.category,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: item.isActive ? AppTheme.accentTeal : Colors.grey,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (item.isActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.resolvedBg,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'ACTIVE BROADCAST',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.resolvedText,
                                          ),
                                        ),
                                      ),
                                    const Spacer(),
                                    Text(
                                      dateStr,
                                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSubtle),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                Text(
                                  item.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: item.isActive ? AppTheme.textDark : Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                Text(
                                  item.content,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: item.isActive ? AppTheme.textMedium : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Issued by: ${item.createdBy}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          item.isActive ? 'Visible to students' : 'Hidden',
                                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
                                        ),
                                        const SizedBox(width: 6),
                                        Switch(
                                          value: item.isActive,
                                          onChanged: (val) => controller.toggleActive(item.id, item.isActive),
                                          activeTrackColor: AppTheme.primaryNavy,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: AppTheme.rejectedText, size: 20),
                                          onPressed: () => controller.deleteAnnouncement(item.id),
                                          tooltip: 'Delete Notice',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
