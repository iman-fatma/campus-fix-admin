import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';
import '../../core/validators.dart';
import '../../controllers/admin_auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

enum _UsernameStatus { idle, invalid, checking, available, taken, error }

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final AdminAuthController authController = Get.find<AdminAuthController>();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitted = false;

  // Username availability state
  Timer? _debounce;
  _UsernameStatus _usernameStatus = _UsernameStatus.idle;
  String _usernameMessage = '';
  String _lastKey = '';

  @override
  void initState() {
    super.initState();
    authController.errorMessage.value = '';
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Username availability: debounce, then ask Firestore
  // ---------------------------------------------------------------------------
  void _onUsernameChanged() {
    final key = Validators.normalizeUsername(_usernameController.text);

    // The listener also fires on cursor moves; ignore if the text is the same.
    if (key == _lastKey) return;
    _lastKey = key;

    _debounce?.cancel();

    if (key.isEmpty) {
      setState(() {
        _usernameStatus = _UsernameStatus.idle;
        _usernameMessage = '';
      });
      return;
    }

    final formatError = Validators.usernameFormat(key);
    if (formatError != null) {
      setState(() {
        _usernameStatus = _UsernameStatus.invalid;
        _usernameMessage = formatError;
      });
      return;
    }

    setState(() {
      _usernameStatus = _UsernameStatus.checking;
      _usernameMessage = 'Checking availability...';
    });

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final available = await authController.isUsernameAvailable(key);
      if (!mounted) return;

      // The user kept typing while we waited: this answer is stale.
      if (Validators.normalizeUsername(_usernameController.text) != key) return;

      setState(() {
        if (available == null) {
          _usernameStatus = _UsernameStatus.error;
          _usernameMessage = 'Could not check. Check your connection.';
        } else if (available) {
          _usernameStatus = _UsernameStatus.available;
          _usernameMessage = '"$key" is available';
        } else {
          _usernameStatus = _UsernameStatus.taken;
          _usernameMessage = '"$key" is already taken';
        }
      });
    });
  }

  Widget? _usernameSuffix() {
    switch (_usernameStatus) {
      case _UsernameStatus.checking:
        return const Padding(
          padding: EdgeInsets.all(14),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case _UsernameStatus.available:
        return const Icon(Icons.check_circle, color: AppTheme.accentTeal);
      case _UsernameStatus.taken:
      case _UsernameStatus.invalid:
      case _UsernameStatus.error:
        return const Icon(Icons.error_outline, color: AppTheme.rejectedText);
      case _UsernameStatus.idle:
        return null;
    }
  }

  Color _usernameMessageColor() {
    switch (_usernameStatus) {
      case _UsernameStatus.available:
        return AppTheme.accentTeal;
      case _UsernameStatus.taken:
      case _UsernameStatus.invalid:
      case _UsernameStatus.error:
        return AppTheme.rejectedText;
      default:
        return AppTheme.textMuted;
    }
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await authController.registerAdminRequest(
      name: _nameController.text.trim(),
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (ok && mounted) {
      setState(() => _submitted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textDark,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: _submitted ? _buildSuccess() : _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.mark_email_read_outlined,
            size: 64, color: AppTheme.accentTeal),
        const SizedBox(height: 16),
        Text(
          'Check your email',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a verification link to ${_emailController.text.trim()}. '
              'Open it to verify your email. Your request has also been sent to '
              'the project owner. You can sign in once it is approved.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
              fontSize: 13, color: AppTheme.textMuted, height: 1.5),
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'Back to Sign In',
          width: double.infinity,
          icon: Icons.arrow_back_rounded,
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request Admin Access',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create an account with your university email. A project owner '
                'will review and approve it.',
            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 24),

          // Error banner
          Obx(() {
            final error = authController.errorMessage.value;
            if (error.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.rejectedBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppTheme.rejectedText.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppTheme.rejectedText, size: 20),
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

          // Full name
          CustomTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Your full name',
            prefixIcon: Icons.person_outline,
            validator: (v) =>
            v == null || v.trim().length < 3 ? 'Enter your full name' : null,
          ),
          const SizedBox(height: 16),

          // Username with live availability check
          CustomTextField(
            controller: _usernameController,
            label: 'Username',
            hint: 'e.g. iman.admin',
            prefixIcon: Icons.alternate_email,
            suffixIcon: _usernameSuffix(),
            validator: (_) {
              final format = Validators.usernameFormat(_usernameController.text);
              if (format != null) return format;
              if (_usernameStatus == _UsernameStatus.taken) {
                return 'That username is already taken';
              }
              if (_usernameStatus != _UsernameStatus.available) {
                return 'Wait for the availability check to finish';
              }
              return null;
            },
          ),
          if (_usernameMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                _usernameMessage,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: _usernameMessageColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Email (university domain only)
          CustomTextField(
            controller: _emailController,
            label: 'University Email',
            hint: 'you@${AdminAuthController.uniDomain}',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => Validators.email(
              v,
              requiredDomain: AdminAuthController.uniDomain,
            ),
          ),
          const SizedBox(height: 16),

          // Password
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
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: Validators.password,
          ),
          const SizedBox(height: 10),
          _PasswordChecklist(controller: _passwordController),
          const SizedBox(height: 16),

          // Confirm password
          CustomTextField(
            controller: _confirmController,
            label: 'Confirm Password',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureConfirm,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: AppTheme.textMuted,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            validator: (v) =>
            v != _passwordController.text ? 'Passwords do not match' : null,
          ),
          const SizedBox(height: 24),

          Obx(() => CustomButton(
            text: 'Submit Request',
            width: double.infinity,
            isLoading: authController.isLoading.value,
            icon: Icons.person_add_alt_1_rounded,
            onPressed: _submit,
          )),
          const SizedBox(height: 16),

          Center(
            child: TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Already approved? Sign in',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryNavy,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Live checklist under the password field. A TextEditingController is a
/// ValueListenable, so ValueListenableBuilder rebuilds ONLY this widget on
/// every keystroke, with no setState in the parent.
class _PasswordChecklist extends StatelessWidget {
  final TextEditingController controller;

  const _PasswordChecklist({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final p = value.text;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rule('At least ${Validators.minPasswordLength} characters',
                Validators.hasMinLength(p)),
            _rule('One capital letter', Validators.hasUpper(p)),
            _rule('One number', Validators.hasDigit(p)),
            _rule('One special character (! @ # \$ ...)',
                Validators.hasSpecial(p)),
          ],
        );
      },
    );
  }

  Widget _rule(String text, bool ok) {
    final color = ok ? AppTheme.accentTeal : AppTheme.textMuted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}