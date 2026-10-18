import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
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

    if (mounted) setState(() => _isSaving = false);

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

  // ---------- map ----------

  Future<void> _openMap() async {
    final url = widget.ticket.mapsUrl;
    if (url == null) return;

    try {
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) _mapError();
    } catch (_) {
      _mapError();
    }
  }

  void _mapError() {
    Get.snackbar(
      'Could not open map',
      'No app or browser was available to open Google Maps.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  // ---------- copy ----------

  Future<void> _copy(String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    Get.snackbar(
      'Copied',
      '$label copied to clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  // ---------- photo ----------

  Widget _imageLoading() {
    return Container(
      color: AppTheme.backgroundLight,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _imageError() {
    return Container(
      color: AppTheme.backgroundLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image_outlined, color: AppTheme.textMuted, size: 32),
          const SizedBox(height: 6),
          Text(
            'Could not load photo',
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  void _showFullImage(String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(ctx).size.height * 0.8,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) =>
                      progress == null ? child : const CircularProgressIndicator(strokeWidth: 2),
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Photo from student',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMedium,
              ),
            ),
            const Spacer(),
            Text(
              'Tap to enlarge',
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSubtle),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showFullImage(url),
          borderRadius: BorderRadius.circular(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: double.infinity,
              height: 220,
              child: Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                progress == null ? child : _imageLoading(),
                errorBuilder: (_, __, ___) => _imageError(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    final t = widget.ticket;
    final createdDateStr = DateFormat('MMMM d, yyyy • h:mm a').format(t.createdAt);
    final reg = t.registrationNo;

    // Metadata rows; empty optional ones are skipped.
    final metaRows = <Widget>[
      _buildMetaRow(Icons.category_outlined, 'Category', t.category),
      _buildMetaRow(Icons.location_on_outlined, 'Location', t.location),
      if (t.address.isNotEmpty)
        _buildMetaRow(Icons.map_outlined, 'Address', t.address),
      _buildMetaRow(Icons.school_outlined, 'Reported By', t.studentName),
      _buildMetaRow(
        Icons.badge_outlined,
        'Registration No',
        reg,
        copyLabel: reg.isEmpty ? null : 'Registration number',
      ),
      _buildMetaRow(
        Icons.email_outlined,
        'Student Email',
        t.studentEmail,
        copyLabel: t.studentEmail.isEmpty ? null : 'Email',
      ),
      _buildMetaRow(Icons.calendar_today_outlined, 'Submitted', createdDateStr),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
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
                          t.ticketNumber,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PriorityBadge(priority: t.priority),
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
                t.title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
        
              // Description
              if (t.description.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Text(
                    t.description,
                    style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMedium),
                  ),
                ),
                const SizedBox(height: 16),
              ],
        
              // Photo uploaded by the student
              if (t.hasImage) ...[
                _buildPhotoSection(t.imageUrl!),
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
                    for (int i = 0; i < metaRows.length; i++) ...[
                      if (i > 0) const Divider(height: 16, color: AppTheme.borderLight),
                      metaRows[i],
                    ],
                  ],
                ),
              ),
        
              // View on map
              if (t.hasCoordinates) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openMap,
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: Text(
                      'View on Google Maps',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
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
        
              // Action Buttons (Wrap so narrow phones never overflow)
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 8,
                spacing: 12,
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
                    mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }

  /// One label/value row. If [copyLabel] is given, a copy button is shown.
  Widget _buildMetaRow(
      IconData icon,
      String label,
      String value, {
        String? copyLabel,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: AppTheme.textMuted),
        ),
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
          child: SelectableText(
            value.isEmpty ? 'N/A' : value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
        ),
        if (copyLabel != null && value.isNotEmpty)
          InkWell(
            onTap: () => _copy(copyLabel, value),
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.copy_rounded, size: 16, color: AppTheme.textMuted),
            ),
          ),
      ],
    );
  }
}