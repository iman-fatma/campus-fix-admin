import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';
import '../controllers/announcements_controller.dart';
import '../models/announcement_model.dart';
import 'custom_button.dart';
import 'custom_text_field.dart';

class NewAnnouncementDialog extends StatefulWidget {
  const NewAnnouncementDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: const NewAnnouncementDialog(),
        ),
      ),
    );
  }

  @override
  State<NewAnnouncementDialog> createState() => _NewAnnouncementDialogState();
}

class _NewAnnouncementDialogState extends State<NewAnnouncementDialog> {
  final AnnouncementsController controller = Get.find<AnnouncementsController>();
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController(text: 'Campus Facility Administration');
  String _category = 'Maintenance';
  bool _isLoading = false;

  final List<String> _categories = [
    'Maintenance',
    'Power Outage',
    'Water Supply',
    'Network Upgrade',
    'Inspection',
    'General Notice',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final id = 'ann-${DateTime.now().millisecondsSinceEpoch}';
    final model = AnnouncementModel(
      id: id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _category,
      createdBy: _authorController.text.trim(),
      createdAt: DateTime.now(),
    );

    final success = await controller.createAnnouncement(model);
    setState(() => _isLoading = false);

    if (success) {
      Get.back();
      Get.snackbar(
        'Notice Broadcasted',
        'Campus maintenance announcement is now active for students.',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Post Campus Maintenance Notice',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
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
              label: 'Notice Title *',
              hint: 'e.g. Scheduled Generator Maintenance',
              validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 14),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notice Category',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textMedium),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.inter(fontSize: 13)))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _category = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            CustomTextField(
              controller: _contentController,
              label: 'Notice Details *',
              hint: 'Provide timing, affected campus areas, and advisory instructions...',
              maxLines: 4,
              validator: (v) => v == null || v.trim().isEmpty ? 'Notice content is required' : null,
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
                  text: 'Broadcast Notice',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
