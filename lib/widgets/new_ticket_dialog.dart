import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';
import '../controllers/tickets_controller.dart';
import '../models/ticket_model.dart';
import 'custom_button.dart';
import 'custom_text_field.dart';

class NewTicketDialog extends StatefulWidget {
  const NewTicketDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: const NewTicketDialog(),
        ),
      ),
    );
  }

  @override
  State<NewTicketDialog> createState() => _NewTicketDialogState();
}

class _NewTicketDialogState extends State<NewTicketDialog> {
  final TicketsController ticketsController = Get.find<TicketsController>();
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _studentNameController = TextEditingController(
    text: 'Campus Admin Log',
  );
  final _studentIdController = TextEditingController(text: 'ADMIN-FACILITY');
  final _studentEmailController = TextEditingController(
    text: 'admin@campusfix.test',
  );
  final _assignedToController = TextEditingController();

  String _selectedCategory = 'HVAC / Air Conditioning';
  String _selectedPriority = 'Medium';
  bool _isLoading = false;

  final List<String> _categories = [
    'HVAC / Air Conditioning',
    'Electrical & Lighting',
    'Plumbing & Restroom',
    'Furniture & Classroom',
    'Network & WiFi',
    'Cleanliness & Sanitation',
    'Other Facility Issue',
  ];

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Urgent'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _studentNameController.dispose();
    _studentIdController.dispose();
    _studentEmailController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final docId =
        'CF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final newTicket = TicketModel(
      id: docId,
      ticketNumber: '#$docId',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      location: _locationController.text.trim(),
      status: 'Open',
      priority: _selectedPriority,
      studentId: _studentIdController.text.trim(),
      studentName: _studentNameController.text.trim(),
      studentEmail: _studentEmailController.text.trim(),
      assignedTo: _assignedToController.text.trim(),
      createdAt: DateTime.now(),
    );

    final success = await ticketsController.createTicket(newTicket);
    setState(() => _isLoading = false);

    if (success) {
      Get.back();
      Get.snackbar(
        'Ticket Created',
        'Ticket #${newTicket.ticketNumber} successfully logged in system.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.primaryNavy,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Log New Maintenance Ticket',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppTheme.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _titleController,
                label: 'Issue Title *',
                hint: 'e.g. Water leak in Chemistry Lab 3',
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 14),

              // Category & Priority
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMedium,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          items: _categories
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(
                                    cat,
                                    style: GoogleFonts.inter(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null)
                              setState(() => _selectedCategory = val);
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Priority',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMedium,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedPriority,
                          items: _priorities
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(
                                    p,
                                    style: GoogleFonts.inter(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null)
                              setState(() => _selectedPriority = val);
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _locationController,
                label: 'Location / Room *',
                hint: 'e.g. Block A, Room 102, Ground Floor',
                prefixIcon: Icons.location_on_outlined,
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Location is required'
                    : null,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _descController,
                label: 'Detailed Description',
                hint: 'Describe the problem in detail...',
                maxLines: 3,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _assignedToController,
                label: 'Assign Technician (Optional)',
                hint: 'e.g. Engr. Tariq, HVAC Team',
                prefixIcon: Icons.engineering_outlined,
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'Cancel',
                    variant: ButtonVariant.outline,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    text: 'Create Ticket',
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
