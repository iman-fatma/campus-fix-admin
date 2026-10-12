import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';
import '../../core/responsive.dart';
import '../../controllers/tickets_controller.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/new_ticket_dialog.dart';
import '../../widgets/ticket_detail_sheet.dart';
import '../../widgets/ticket_item_card.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  final TicketsController ticketsController = Get.find<TicketsController>();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _statuses = [
    'All',
    'Open',
    'Assigned',
    'In Progress',
    'Resolved',
    'Rejected'
  ];

  final List<String> _priorities = ['All', 'Low', 'Medium', 'High', 'Urgent'];

  final List<String> _categories = [
    'All',
    'HVAC / Air Conditioning',
    'Electrical & Lighting',
    'Plumbing & Restroom',
    'Furniture & Classroom',
    'Network & WiFi',
    'Other Facility Issue',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ticketsController.searchQuery.value = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    ticketsController.searchQuery.value = '';
    ticketsController.selectedStatusFilter.value = 'All';
    ticketsController.selectedPriorityFilter.value = 'All';
    ticketsController.selectedCategoryFilter.value = 'All';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => NewTicketDialog.show(context),
              backgroundColor: AppTheme.primaryNavy,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Obx(() {
        final filteredTickets = ticketsController.filteredTickets;
        final selectedStatus = ticketsController.selectedStatusFilter.value;
        final selectedPriority = ticketsController.selectedPriorityFilter.value;
        final selectedCategory = ticketsController.selectedCategoryFilter.value;

        return Padding(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search & Filter Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  children: [
                    // Search Bar and Filters Row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by ticket #, issue, location, or student...',
                              prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () => _searchController.clear(),
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                        if (!isMobile) ...[
                          const SizedBox(width: 14),
                          // Priority Dropdown
                          SizedBox(
                            width: 150,
                            child: DropdownButtonFormField<String>(
                              value: selectedPriority,
                              items: _priorities
                                  .map((p) => DropdownMenuItem(
                                        value: p,
                                        child: Text(
                                          p == 'All' ? 'All Priorities' : p,
                                          style: GoogleFonts.inter(fontSize: 13),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) ticketsController.selectedPriorityFilter.value = val;
                              },
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Category Dropdown
                          SizedBox(
                            width: 180,
                            child: DropdownButtonFormField<String>(
                              value: selectedCategory,
                              items: _categories
                                  .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(
                                          c == 'All' ? 'All Categories' : c.split(' ').first,
                                          style: GoogleFonts.inter(fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) ticketsController.selectedCategoryFilter.value = val;
                              },
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Status Filter Chips Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ..._statuses.map((status) {
                            final isSelected = selectedStatus.toLowerCase() == status.toLowerCase();
                            int count = 0;
                            if (status == 'All') {
                              count = ticketsController.totalCount;
                            } else if (status == 'Open') {
                              count = ticketsController.openCount;
                            } else if (status == 'Assigned') {
                              count = ticketsController.assignedCount;
                            } else if (status == 'In Progress') {
                              count = ticketsController.inProgressCount;
                            } else if (status == 'Resolved') {
                              count = ticketsController.resolvedCount;
                            } else {
                              count = ticketsController.allTickets
                                  .where((t) => t.status.toLowerCase() == status.toLowerCase())
                                  .length;
                            }

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text('$status ($count)'),
                                selected: isSelected,
                                onSelected: (val) {
                                  if (val) ticketsController.selectedStatusFilter.value = status;
                                },
                                selectedColor: AppTheme.primaryNavy,
                                backgroundColor: AppTheme.backgroundLight,
                                labelStyle: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppTheme.textMedium,
                                ),
                                showCheckmark: false,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected ? AppTheme.primaryNavy : AppTheme.borderLight,
                                  ),
                                ),
                              ),
                            );
                          }),
                          if (selectedStatus != 'All' ||
                              selectedPriority != 'All' ||
                              selectedCategory != 'All' ||
                              _searchController.text.isNotEmpty)
                            TextButton.icon(
                              onPressed: _clearFilters,
                              icon: const Icon(Icons.filter_alt_off, size: 16),
                              label: const Text('Reset', style: TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Total matching count header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${filteredTickets.length} tickets',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  if (ticketsController.isLoading.value)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Tickets List / Grid
              Expanded(
                child: filteredTickets.isEmpty
                    ? EmptyStateView(
                        icon: Icons.search_off_rounded,
                        title: 'No Tickets Found',
                        message: 'Try changing your search query or filters.',
                        buttonText: 'Reset Filters',
                        onButtonPressed: _clearFilters,
                      )
                    : ListView.separated(
                        itemCount: filteredTickets.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, index) {
                          final ticket = filteredTickets[index];
                          return TicketItemCard(
                            ticket: ticket,
                            onTap: () => TicketDetailSheet.show(context, ticket),
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
