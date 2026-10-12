import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../models/ticket_model.dart';
import '../controllers/tickets_controller.dart';
import 'custom_button.dart';
import 'priority_badge.dart';
import 'status_badge.dart';

class TicketDetailSheet extends StatefulWidget {
  final TicketModel ticket;

  const TicketDetailSheet({super.key, required this.ticket});

  static Future<void> show(BuildContext context, TicketModel ticket) {
    final isMobile = ResponsiveHelper.isMobile(context);

    if (isMobile) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => TicketDetailSheet(ticket: ticket),
      );
    } else {
      return showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: TicketDetailSheet(ticket: ticket),
          ),
        ),
      );
    }
  }

  @override
  State<TicketDetailSheet> createState() => _TicketDetailSheetState();
}

class _TicketDetailSheetState extends State<TicketDetailSheet> {
  final TicketsController ticketsController = Get.find<TicketsController>();

  late String _selectedStatus;
  late TextEditingController _technicianController;
  late TextEditingController _remarksController;
  bool _isSaving = false;

  final List<String> _statuses = [
    'Open',
    'Assigned',
    'In Progress',
    'Resolved',
    'Rejected'
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.ticket.status;
    _technicianController = TextEditingController(text: widget.ticket.assignedTo);
    _remarksController = TextEditingController(text: widget.ticket.remarks);
  }

  @override
  void dispose() {
    _technicianController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    final success = await ticketsController.updateTicketStatus(
      ticketId: widget.ticket.id,
      newStatus: _selectedStatus,
      assignedTo: _technicianController.text.trim(),
      remarks: _remarksController.text.trim(),
    );

    setState(() => _isSaving = false);

    if (success) {
      Get.back();
      Get.snackbar(
        'Ticket Updated',
        'Ticket ${widget.ticket.ticketNumber} marked as "$_selectedStatus".',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.primaryNavy,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Ticket', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete ticket ${widget.ticket.ticketNumber}? This action cannot be undone.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.rejectedText),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ticketsController.deleteTicket(widget.ticket.id);
      Get.back();
      Get.snackbar(
        'Deleted',
        'Ticket ${widget.ticket.ticketNumber} removed from database.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdDateStr = DateFormat('MMMM d, yyyy • h:mm a').format(widget.ticket.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.ticket.ticketNumber,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PriorityBadge(priority: widget.ticket.priority),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              widget.ticket.title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            if (widget.ticket.description.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Text(
                  widget.ticket.description,
                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMedium),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Metadata Grid
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                children: [
                  _buildMetaRow(Icons.category_outlined, 'Category', widget.ticket.category),
                  const Divider(height: 16, color: AppTheme.borderLight),
                  _buildMetaRow(Icons.location_on_outlined, 'Location', widget.ticket.location),
                  const Divider(height: 16, color: AppTheme.borderLight),
                  _buildMetaRow(
                    Icons.school_outlined,
                    'Reported By',
                    '${widget.ticket.studentName} (${widget.ticket.studentId})',
                  ),
                  const Divider(height: 16, color: AppTheme.borderLight),
                  _buildMetaRow(Icons.email_outlined, 'Student Email', widget.ticket.studentEmail),
                  const Divider(height: 16, color: AppTheme.borderLight),
                  _buildMetaRow(Icons.calendar_today_outlined, 'Submitted', createdDateStr),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Update Status Section
            Text(
              'Change Ticket Status',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statuses.map((status) {
                final isSelected = _selectedStatus.toLowerCase() == status.toLowerCase();
                return ChoiceChip(
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedStatus = status);
                  },
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textMedium,
                  ),
                  selectedColor: AppTheme.primaryNavy,
                  backgroundColor: AppTheme.backgroundLight,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryNavy : AppTheme.borderLight,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Assign Technician
            Text(
              'Assign Technician / Maintenance Staff',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMedium,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _technicianController,
              decoration: const InputDecoration(
                hintText: 'e.g. Engr. Tariq, Electrician Bashir, Carpentry Team',
                prefixIcon: Icon(Icons.engineering_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 14),

            // Remarks / Resolution note
            Text(
              'Resolution Note / Admin Remarks',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMedium,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _remarksController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Enter maintenance details, replacement parts, or status comments...',
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_outline, color: AppTheme.rejectedText, size: 20),
                  label: Text(
                    'Delete',
                    style: GoogleFonts.inter(color: AppTheme.rejectedText, fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  children: [
                    CustomButton(
                      text: 'Cancel',
                      variant: ButtonVariant.outline,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    CustomButton(
                      text: 'Save Changes',
                      isLoading: _isSaving,
                      onPressed: _saveChanges,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textMuted),
        const SizedBox(width: 8),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? 'N/A' : value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
