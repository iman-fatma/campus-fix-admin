import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';
import '../../core/responsive.dart';
import '../../controllers/admin_shell_controller.dart';
import '../../controllers/students_controller.dart';
import '../../controllers/tickets_controller.dart';
import '../../models/student_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/empty_state_view.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final StudentsController studentsController = Get.find<StudentsController>();
  final TicketsController ticketsController = Get.find<TicketsController>();
  final AdminShellController shellController = Get.find<AdminShellController>();

  final TextEditingController _searchController = TextEditingController();

  final List<String> _departments = [
    'All',
    'Computer Science',
    'Software Engineering',
    'Information Technology',
    'Artificial Intelligence',
    'Cyber Security',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      studentsController.searchQuery.value = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddStudentDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final idCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String dept = 'Computer Science';
    int sem = 7;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Register Student in System',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: nameCtrl,
                      label: 'Student Full Name *',
                      hint: 'e.g. Iman Fatima',
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: idCtrl,
                      label: 'Student / Roll ID *',
                      hint: 'e.g. COSC231101093',
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: emailCtrl,
                      label: 'Campus Email *',
                      hint: 'e.g. imanfatima@kfueit.edu.pk',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Department',
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: dept,
                                items: _departments
                                    .where((d) => d != 'All')
                                    .map((d) => DropdownMenuItem(value: d, child: Text(d, style: GoogleFonts.inter(fontSize: 12))))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setDialogState(() => dept = v);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Semester',
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<int>(
                                initialValue: sem,
                                items: [1, 2, 3, 4, 5, 6, 7, 8]
                                    .map((s) => DropdownMenuItem(value: s, child: Text('$s')))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setDialogState(() => sem = v);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButton(
                          text: 'Cancel',
                          variant: ButtonVariant.outline,
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                        const SizedBox(width: 12),
                        CustomButton(
                          text: 'Add Student',
                          isLoading: isLoading,
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            setDialogState(() => isLoading = true);

                            final newStudent = StudentModel(
                              id: 'std-${DateTime.now().millisecondsSinceEpoch}',
                              name: nameCtrl.text.trim(),
                              studentId: idCtrl.text.trim(),
                              email: emailCtrl.text.trim().toLowerCase(),
                              department: dept,
                              semester: sem,
                              role: 'student',
                              createdAt: DateTime.now(),
                            );

                            await studentsController.addStudent(newStudent);
                            Navigator.of(ctx).pop();
                            Get.snackbar(
                              'Student Added',
                              '${newStudent.name} successfully registered in system.',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Obx(() {
        final students = studentsController.filteredStudents;
        final selectedDept = studentsController.selectedDeptFilter.value;

        return Padding(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search & Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by student name, roll number, or department...',
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
                        const SizedBox(width: 14),
                        CustomButton(
                          text: isMobile ? 'Add' : 'Add Student',
                          icon: Icons.person_add_alt_1_rounded,
                          onPressed: _showAddStudentDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Department Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _departments.map((dept) {
                          final isSelected = selectedDept.toLowerCase() == dept.toLowerCase();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(dept),
                              selected: isSelected,
                              onSelected: (val) {
                                if (val) studentsController.selectedDeptFilter.value = dept;
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
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Registered Students (${students.length})',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),

              // Student Grid / List
              Expanded(
                child: students.isEmpty
                    ? EmptyStateView(
                        icon: Icons.group_off_rounded,
                        title: 'No Students Found',
                        message: 'No student accounts match the current filter or search query.',
                        buttonText: 'Reset Search',
                        onButtonPressed: () {
                          _searchController.clear();
                          studentsController.selectedDeptFilter.value = 'All';
                        },
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isMobile ? 1 : (isDesktop ? 3 : 2),
                          mainAxisExtent: 145,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: students.length,
                        itemBuilder: (ctx, index) {
                          final student = students[index];
                          final ticketCount = ticketsController.allTickets
                              .where((t) => t.studentId == student.studentId || t.studentEmail == student.email)
                              .length;

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.1),
                                      child: Text(
                                        student.initials,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryNavy,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student.name,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AppTheme.textDark,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            student.studentId,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: AppTheme.accentTeal,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${student.department} • Sem ${student.semester}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppTheme.textMuted,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        // Filter tickets by student
                                        ticketsController.searchQuery.value = student.studentId;
                                        shellController.setIndex(1);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '$ticketCount issues',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryNavy,
                                          ),
                                        ),
                                      ),
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
