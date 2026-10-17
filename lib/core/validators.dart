class Validators {
  static const int minPasswordLength = 8;

  static final RegExp _upper = RegExp(r'[A-Z]');
  static final RegExp _digit = RegExp(r'[0-9]');
  static final RegExp _special = RegExp(r'[^A-Za-z0-9\s]');
  static final RegExp _usernameRe = RegExp(r'^[a-z0-9_.]+$');

  // ---- Password rules (each one is reused by the live checklist) ----------
  static bool hasMinLength(String v) => v.length >= minPasswordLength;
  static bool hasUpper(String v) => _upper.hasMatch(v);
  static bool hasDigit(String v) => _digit.hasMatch(v);
  static bool hasSpecial(String v) => _special.hasMatch(v);

  static String? password(String? v) {
    final p = v ?? '';
    if (p.isEmpty) return 'Password is required';
    if (!hasMinLength(p)) {
      return 'Use at least $minPasswordLength characters';
    }
    if (!hasUpper(p)) return 'Add at least one capital letter';
    if (!hasDigit(p)) return 'Add at least one number';
    if (!hasSpecial(p)) return 'Add at least one special character';
    return null;
  }

  // ---- Username ----------------------------------------------------------
  /// Usernames are stored lowercase so "Iman" and "iman" are the same name.
  static String normalizeUsername(String v) => v.trim().toLowerCase();

  static String? usernameFormat(String? v) {
    final u = normalizeUsername(v ?? '');
    if (u.isEmpty) return 'Username is required';
    if (u.length < 3) return 'At least 3 characters';
    if (u.length > 20) return 'At most 20 characters';
    if (!_usernameRe.hasMatch(u)) {
      return 'Only letters, numbers, "_" and "."';
    }
    return null;
  }

  // ---- Email -------------------------------------------------------------
  static String? email(String? v, {String? requiredDomain}) {
    final e = (v ?? '').trim().toLowerCase();
    if (e.isEmpty) return 'Email is required';
    if (!e.contains('@') || e.startsWith('@') || e.endsWith('@')) {
      return 'Enter a valid email';
    }
    if (requiredDomain != null && !e.endsWith('@$requiredDomain')) {
      return 'Use your university email (@$requiredDomain)';
    }
    return null;
  }
}