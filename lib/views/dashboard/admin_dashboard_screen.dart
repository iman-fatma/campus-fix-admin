import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';
import '../../core/responsive.dart';
import '../../controllers/admin_auth_controller.dart';
import '../../controllers/admin_shell_controller.dart';
import '../../controllers/announcements_controller.dart';
import '../../controllers/students_controller.dart';
import '../../controllers/tickets_controller.dart';
import '../../widgets/new_announcement_dialog.dart';
import '../../widgets/new_ticket_dialog.dart';
import '../../widgets/stat_metric_card.dart';
import '../../widgets/ticket_detail_sheet.dart';
import '../../widgets/ticket_item_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ticketsController = Get.find<TicketsController>();
    final studentsController = Get.find<StudentsController>();
    final announcementsController = Get.find<AnnouncementsController>();
    final authController = Get.find<AdminAuthController>();
    final shellController = Get.find<AdminShellController>();

    final isMobile = ResponsiveHelper.isMobile(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final currentDateStr = DateFormat(
      'EEEE, MMMM d, yyyy',
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Obx(() {
        final admin = authController.currentAdmin.value;
        final allTickets = ticketsController.allTickets;
        final urgentTickets = allTickets
            .where(
              (t) =>
                  t.priority.toLowerCase() == 'urgent' &&
                  t.status.toLowerCase() != 'resolved',
            )
            .toList();

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 18 : 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF10355B),
                      Color(0xFF0F2C59),
                      Color(0xFF1E3A8A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryNavy.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentDateStr.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF93C5FD),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Welcome back, ${admin?.fullName ?? "Facility Admin"} 👋',
                            style: GoogleFonts.inter(
                              fontSize: isMobile ? 20 : 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Here is the live maintenance overview and complaints status across KFUEIT.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFFCBD5E1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: () => NewTicketDialog.show(context),
                        icon: const Icon(Icons.add_task, size: 18),
                        label: const Text('Log Ticket'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryNavy,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Urgent Alert Banner (if any)
              if (urgentTickets.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFECDD3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF43F5E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${urgentTickets.length} Urgent Maintenance Issues Require Immediate Attention!',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF9F1239),
                              ),
                            ),
                            Text(
                              'Latest: ${urgentTickets.first.title} (${urgentTickets.first.location})',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFFBE123C),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ticketsController.selectedPriorityFilter.value =
                              'Urgent';
                          shellController.setIndex(1);
                        },
                        child: Text(
                          'View Urgent',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE11D48),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Metric Cards Grid
              _buildMetricsGrid(
                context,
                ticketsController,
                studentsController,
                shellController,
              ),
              const SizedBox(height: 28),

              // Main Dashboard Split Row (Desktop: Tickets on left, Analytics & Notices on right)
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _buildRecentTicketsSection(
                        context,
                        ticketsController,
                        shellController,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          _buildCategoryBreakdownCard(allTickets),
                          const SizedBox(height: 24),
                          _buildAnnouncementsCard(
                            context,
                            announcementsController,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _buildRecentTicketsSection(
                  context,
                  ticketsController,
                  shellController,
                ),
                const SizedBox(height: 24),
                _buildCategoryBreakdownCard(allTickets),
                const SizedBox(height: 24),
                _buildAnnouncementsCard(context, announcementsController),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMetricsGrid(
    BuildContext context,
    TicketsController ticketsCtrl,
    StudentsController studentsCtrl,
    AdminShellController shellController,
  ) {
    final cards = [
      StatMetricCard(
        title: 'Total Tickets',
        value: '${ticketsCtrl.totalCount}',
        icon: Icons.confirmation_number_outlined,
        iconColor: AppTheme.primaryNavy,
        iconBgColor: AppTheme.primaryNavy.withValues(alpha: 0.1),
        subtitle: 'All-time reported complaints',
        onTap: () {
          ticketsCtrl.searchQuery.value = '';
          ticketsCtrl.selectedStatusFilter.value = 'All';
          ticketsCtrl.selectedPriorityFilter.value = 'All';
          ticketsCtrl.selectedCategoryFilter.value = 'All';
          shellController.setIndex(1);
        },
      ),
      StatMetricCard(
        title: 'Open / Pending',
        value: '${ticketsCtrl.openCount}',
        icon: Icons.pending_actions_rounded,
        iconColor: const Color(0xFF2563EB),
        iconBgColor: const Color(0xFFEFF6FF),
        subtitle: 'Awaiting technician assignment',
        onTap: () {
          ticketsCtrl.selectedStatusFilter.value = 'Open';
          ticketsCtrl.selectedPriorityFilter.value = 'All';
          ticketsCtrl.selectedCategoryFilter.value = 'All';
          ticketsCtrl.searchQuery.value = '';
          shellController.setIndex(1);
        },
      ),
      StatMetricCard(
        title: 'In Progress',
        value: '${ticketsCtrl.inProgressCount}',
        icon: Icons.engineering_rounded,
        iconColor: const Color(0xFFD97706),
        iconBgColor: const Color(0xFFFEF3C7),
        subtitle: 'Under active repair',
        onTap: () {
          ticketsCtrl.selectedStatusFilter.value = 'In Progress';
          ticketsCtrl.selectedPriorityFilter.value = 'All';
          ticketsCtrl.selectedCategoryFilter.value = 'All';
          ticketsCtrl.searchQuery.value = '';
          shellController.setIndex(1);
        },
      ),
      StatMetricCard(
        title: 'Resolved',
        value: '${ticketsCtrl.resolvedCount}',
        icon: Icons.task_alt_rounded,
        iconColor: const Color(0xFF059669),
        iconBgColor: const Color(0xFFECFDF5),
        subtitle:
            '${ticketsCtrl.totalCount > 0 ? ((ticketsCtrl.resolvedCount / ticketsCtrl.totalCount) * 100).toInt() : 0}% resolution rate',
        onTap: () {
          ticketsCtrl.selectedStatusFilter.value = 'Resolved';
          ticketsCtrl.selectedPriorityFilter.value = 'All';
          ticketsCtrl.selectedCategoryFilter.value = 'All';
          ticketsCtrl.searchQuery.value = '';
          shellController.setIndex(1);
        },
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 1100 ? 2 : 4;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            mainAxisExtent: 160,
          ),
          itemCount: cards.length,
          itemBuilder: (ctx, i) => cards[i],
        );
      },
    );
  }

  Widget _buildRecentTicketsSection(
    BuildContext context,
    TicketsController controller,
    AdminShellController shellController,
  ) {
    final recent = controller.allTickets.take(6).toList();

    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      color: AppTheme.primaryNavy,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Recent Complaints & Tickets',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => shellController.setIndex(1),
                child: Row(
                  children: [
                    Text(
                      'View All (${controller.totalCount})',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppTheme.primaryNavy,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No maintenance tickets logged yet.',
                  style: GoogleFonts.inter(color: AppTheme.textMuted),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final ticket = recent[idx];
                return TicketItemCard(
                  ticket: ticket,
                  onTap: () => TicketDetailSheet.show(context, ticket),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownCard(List dynamicTickets) {
    // Tally by category
    final Map<String, int> categories = {};
    for (var t in dynamicTickets) {
      final cat = (t.category as String).split(' ').first;
      categories[cat] = (categories[cat] ?? 0) + 1;
    }

    final total = dynamicTickets.isEmpty ? 1 : dynamicTickets.length;

    return Container(
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
              const Icon(
                Icons.pie_chart_outline_rounded,
                color: AppTheme.accentTeal,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Issues by Category',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (categories.isEmpty)
            Text(
              'No categorical data available yet.',
              style: GoogleFonts.inter(color: AppTheme.textMuted),
            )
          else
            ...categories.entries.map((entry) {
              final pct = (entry.value / total);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMedium,
                          ),
                        ),
                        Text(
                          '${entry.value} (${(pct * 100).toInt()}%)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: AppTheme.backgroundLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsCard(
    BuildContext context,
    AnnouncementsController controller,
  ) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.campaign_outlined,
                    color: AppTheme.primaryNavy,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Campus Notices',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppTheme.primaryNavy,
                  size: 20,
                ),
                onPressed: () => NewAnnouncementDialog.show(context),
                tooltip: 'Post Notice',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (controller.announcements.isEmpty)
            Text(
              'No active campus announcements.',
              style: GoogleFonts.inter(color: AppTheme.textMuted),
            )
          else
            ...controller.announcements.take(2).map((notice) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentTeal.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            notice.category,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentTeal,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('MMM d').format(notice.createdAt),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.textSubtle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notice.title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notice.content,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textMedium,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
