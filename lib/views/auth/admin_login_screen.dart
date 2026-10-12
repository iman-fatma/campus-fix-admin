import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_theme.dart';
import '../../core/responsive.dart';
import '../../controllers/admin_auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final AdminAuthController authController = Get.find<AdminAuthController>();
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_admin_email');
    if (!mounted) return;
    if (savedEmail != null && savedEmail.isNotEmpty) {
      _emailController.text = savedEmail;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await authController.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      rememberMe: _rememberMe,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Hero Panel
        Expanded(
          flex: 5,
          child: Container(
            color: AppTheme.sidebarBg,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Brand
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF0D9488)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.build_circle_outlined, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'CampusFix',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accentTeal.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ADMIN',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentTeal,
                        ),
                      ),
                    ),
                  ],
                ),

                // Center Hero Content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.security, color: Color(0xFF60A5FA), size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Restricted Administrative Access',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFE2E8F0),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Campus Facility\nManagement Console',
                      style: GoogleFonts.inter(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Real-time maintenance ticket tracking, technician assignment, student issue resolution, and campus broadcast alerts. Synchronized directly with Campus Fix.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF94A3B8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Feature points
                    _featurePoint(Icons.speed, 'Real-time synchronization with Firestore'),
                    const SizedBox(height: 12),
                    _featurePoint(Icons.shield_outlined, 'Strict role-based administrator security'),
                    const SizedBox(height: 12),
                    _featurePoint(Icons.devices, 'Full responsiveness for mobile and desktop screens'),
                  ],
                ),

                // Footer
                Text(
                  'Connected to Firebase Project: campus-fix-9565f',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right Form Panel
        Expanded(
          flex: 6,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: _buildLoginForm(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Brand Logo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10355B), Color(0xFF0D9488)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.build_circle_outlined, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              'CampusFix Admin',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              'Facility & Complaint Management',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 28),

            _buildLoginForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Sign In',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Please enter your authorized facility administrator credentials.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 24),

          // Error Message Alert
          Obx(() {
            final error = authController.errorMessage.value;
            if (error.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.rejectedBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.rejectedText.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.rejectedText, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      error,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.rejectedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Email Field
          CustomTextField(
            controller: _emailController,
            label: 'Administrator Email',
            hint: 'admin@campusfix.test',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password Field
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: AppTheme.textMuted,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
          ),
          const SizedBox(height: 14),

          // Remember Me & Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (val) => setState(() => _rememberMe = val ?? true),
                      activeColor: AppTheme.primaryNavy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Remember me',
                    style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMedium),
                  ),
                ],
              ),
              TextButton(
                onPressed: () async {
                  final email = _emailController.text.trim();
                  if (email.isEmpty) {
                    Get.snackbar('Notice', 'Enter your administrator email first.');
                    return;
                  }

                  final sent = await authController.sendPasswordReset(email);
                  if (sent) {
                    Get.snackbar(
                      'Sent',
                      'Password reset instructions sent to $email',
                    );
                  } else {
                    Get.snackbar('Password reset failed', authController.errorMessage.value);
                  }
                },
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Submit Button
          Obx(() => CustomButton(
                text: 'Sign In to Admin Console',
                width: double.infinity,
                isLoading: authController.isLoading.value,
                icon: Icons.login_rounded,
                onPressed: _submitLogin,
              )),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20, color: AppTheme.primaryNavy),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Admin accounts must be provisioned by a Firebase project owner.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featurePoint(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF60A5FA), size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: const Color(0xFFCBD5E1),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
