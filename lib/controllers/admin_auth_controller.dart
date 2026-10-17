import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/validators.dart';
import '../models/admin_user_model.dart';

/// Thrown inside the registration transaction when someone else
/// claimed the username first (race condition).
class UsernameTakenException implements Exception {
  const UsernameTakenException();
}

class AdminAuthController extends GetxController {
  AdminAuthController({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Only emails from this domain may register as admin.
  static const String uniDomain = 'kfueit.edu.pk';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<AdminUserModel?> currentAdmin = Rx<AdminUserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isCheckingAuth = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString authorizationError = ''.obs;

  /// True when someone is signed in but has not verified their email yet.
  /// The gate shows the "Verify your email" screen while this is true.
  final RxBool needsEmailVerification = false.obs;

  /// True while the "I've verified" button is checking with Firebase.
  final RxBool isVerifying = false.obs;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _adminSubscription;
  int _authorizationAttempt = 0;

  /// True while registerAdmin is running. Creating a Firebase user signs
  /// them in automatically, which would trigger _handleAuthChanged BEFORE
  /// the admins/{uid} document exists and wrongly show "not authorized".
  /// This flag makes the listener stay out of the way until we are done.
  bool _isRegistering = false;

  @override
  void onInit() {
    super.onInit();
    _authSubscription = _auth.authStateChanges().listen(
      _handleAuthChanged,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Firebase auth state stream failed: $error');
        currentAdmin.value = null;
        authorizationError.value =
        'Could not verify your sign-in with Firebase. Check your connection and try again.';
        isCheckingAuth.value = false;
      },
    );
  }

  @override
  void onClose() {
    unawaited(_authSubscription?.cancel());
    unawaited(_adminSubscription?.cancel());
    super.onClose();
  }

  Future<void> _handleAuthChanged(User? user) async {
    // Ignore the temporary sign-in that happens during registration.
    if (_isRegistering) return;

    final attempt = ++_authorizationAttempt;
    firebaseUser.value = user;
    isCheckingAuth.value = true;

    if (user == null) {
      unawaited(_adminSubscription?.cancel());
      _adminSubscription = null;
      currentAdmin.value = null;
      needsEmailVerification.value = false;
      isCheckingAuth.value = false;
      return;
    }
    authorizationError.value = '';

    // Admin access requires a verified email. We do NOT sign the user out:
    // the gate shows a "Verify your email" screen with resend / continue.
    if (!user.emailVerified) {
      unawaited(_adminSubscription?.cancel());
      _adminSubscription = null;
      currentAdmin.value = null;
      needsEmailVerification.value = true;
      isCheckingAuth.value = false;
      return;
    }
    needsEmailVerification.value = false;

    try {
      final admin = await _verifyAndFetchAdmin(user);
      if (attempt != _authorizationAttempt) return;

      if (admin == null) {
        currentAdmin.value = null;
        authorizationError.value =
        'This account is not authorized to access the CampusFix admin portal.';
        await _auth.signOut();
        return;
      }

      currentAdmin.value = admin;
      _watchAdminAuthorization(user, attempt);
    } catch (error, stackTrace) {
      debugPrint('Could not verify admin access: $error\n$stackTrace');
      if (attempt == _authorizationAttempt) {
        currentAdmin.value = null;
        authorizationError.value =
        'Could not verify administrator access. Check your connection and Firestore permissions, then try again.';
      }
    } finally {
      if (attempt == _authorizationAttempt) {
        isCheckingAuth.value = false;
      }
    }
  }

  Future<AdminUserModel?> _verifyAndFetchAdmin(User user) async {
    final doc = await _firestore.collection('admins').doc(user.uid).get();
    return _adminFromSnapshot(user, doc);
  }

  AdminUserModel? _adminFromSnapshot(
      User user,
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();
    if (!doc.exists || data == null) return null;

    final role = (data['role'] ?? '').toString().trim().toLowerCase();
    const allowedRoles = {'admin', 'administrator', 'facility_manager'};
    if (!allowedRoles.contains(role) ||
        data['active'] == false ||
        data['isActive'] == false) {
      return null;
    }

    return AdminUserModel.fromMap({
      ...data,
      'email': data['email'] ?? user.email ?? '',
      'fullName': data['fullName'] ?? user.displayName ?? 'Facility Admin',
    }, user.uid);
  }

  void _watchAdminAuthorization(User user, int attempt) {
    unawaited(_adminSubscription?.cancel());
    _adminSubscription = _firestore
        .collection('admins')
        .doc(user.uid)
        .snapshots()
        .listen(
          (snapshot) async {
        if (attempt != _authorizationAttempt) return;
        final admin = _adminFromSnapshot(user, snapshot);
        if (admin == null) {
          currentAdmin.value = null;
          authorizationError.value =
          'Administrator access has been revoked or disabled.';
          await signOut();
          return;
        }
        currentAdmin.value = admin;
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Admin membership stream failed: $error\n$stackTrace');
        if (attempt == _authorizationAttempt) {
          currentAdmin.value = null;
          authorizationError.value =
          'Could not verify administrator access. Check your Firestore permissions and connection.';
        }
      },
    );
  }

  Future<bool> signIn({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    authorizationError.value = '';

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      authorizationError.value = '';

      final prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setString('saved_admin_email', email.trim().toLowerCase());
      } else {
        await prefs.remove('saved_admin_email');
      }
      return true;
    } on FirebaseAuthException catch (error) {
      errorMessage.value = switch (error.code) {
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' => 'Invalid administrator email or password.',
        'invalid-email' => 'Please provide a valid email address.',
        'user-disabled' => 'This administrator account has been disabled.',
        'too-many-requests' =>
        'Too many failed login attempts. Please try again later.',
        _ => error.message ?? 'Sign-in failed. Please check your credentials.',
      };
      return false;
    } catch (error, stackTrace) {
      debugPrint('Administrator sign-in failed: $error\n$stackTrace');
      errorMessage.value = 'Sign-in failed. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Email verification
  // ---------------------------------------------------------------------------

  /// Sends a fresh verification email to the signed-in user.
  Future<bool> resendVerificationEmail() async {
    errorMessage.value = '';
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      await user.sendEmailVerification();
      return true;
    } on FirebaseAuthException catch (error) {
      errorMessage.value = error.code == 'too-many-requests'
          ? 'Too many requests. Wait a few minutes before trying again.'
          : (error.message ?? 'Could not send the verification email.');
      return false;
    } catch (error, stackTrace) {
      debugPrint('Resend verification failed: $error\n$stackTrace');
      errorMessage.value = 'Could not send the verification email.';
      return false;
    }
  }

  /// Called by the "I've verified my email" button. Reloads the user from
  /// Firebase, refreshes the ID token (so Firestore rules see
  /// email_verified == true), then re-runs the admin check.
  /// Returns true if the email is now verified.
  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    isVerifying.value = true;
    try {
      await user.reload();
      final fresh = _auth.currentUser;
      if (fresh == null || !fresh.emailVerified) return false;

      await fresh.getIdToken(true);
      await _handleAuthChanged(fresh);
      return true;
    } catch (error, stackTrace) {
      debugPrint('Email verification check failed: $error\n$stackTrace');
      errorMessage.value = 'Could not check verification. Try again.';
      return false;
    } finally {
      isVerifying.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Registration
  // ---------------------------------------------------------------------------

  /// Returns true if free, false if taken, null if the check itself failed
  /// (offline, permission error...). The screen maps null to an error message.
  Future<bool?> isUsernameAvailable(String username) async {
    try {
      final key = Validators.normalizeUsername(username);
      final doc = await _firestore.collection('usernames').doc(key).get();
      return !doc.exists;
    } catch (error, stackTrace) {
      debugPrint('Username availability check failed: $error\n$stackTrace');
      return null;
    }
  }

  /// Creates the Firebase account, claims the username, and saves
  /// admins/{uid} with role 'admin' in ONE transaction. Firestore rules
  /// verify the invite code, so the client cannot fake it. On success the
  /// user stays signed in; the gate then asks them to verify their email
  /// before showing the admin panel.
  Future<bool> registerAdmin({
    required String name,
    required String username,
    required String email,
    required String password,
    required String inviteCode,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    _isRegistering = true;

    final cleanEmail = email.trim().toLowerCase();
    final key = Validators.normalizeUsername(username);
    User? createdUser;

    try {
      // Re-check the domain here too: UI validation alone is not security.
      if (!cleanEmail.endsWith('@$uniDomain')) {
        errorMessage.value = 'Please use your @$uniDomain email address.';
        return false;
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      createdUser = credential.user;
      if (createdUser == null) {
        errorMessage.value = 'Could not create the account. Try again.';
        return false;
      }
      final user = createdUser;

      await user.updateDisplayName(name.trim());

      // Claim the username and save the admin role atomically:
      // either both writes happen or neither does.
      await _firestore.runTransaction((tx) async {
        final usernameRef = _firestore.collection('usernames').doc(key);
        final existing = await tx.get(usernameRef);
        if (existing.exists) throw const UsernameTakenException();

        tx.set(usernameRef, {
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        tx.set(_firestore.collection('admins').doc(user.uid), {
          'uid': user.uid,
          'fullName': name.trim(),
          'username': key,
          'email': cleanEmail,
          'role': 'admin',
          'active': true,
          'inviteCode': inviteCode.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      // A failed verification email should not fail the whole registration:
      // the verify screen has a "Resend" button.
      try {
        await user.sendEmailVerification();
      } catch (error) {
        debugPrint('Could not send verification email: $error');
      }

      // Registration is complete and admins/{uid} exists. Re-enable the
      // listener and run the check manually, because the auth-state event
      // already fired (and was ignored) earlier. Because the email is not
      // verified yet, this ends on the "Verify your email" screen.
      _isRegistering = false;
      await _handleAuthChanged(_auth.currentUser);
      return true;
    } on UsernameTakenException {
      await _rollbackUser(createdUser);
      errorMessage.value = 'That username was just taken. Pick another one.';
      return false;
    } on FirebaseAuthException catch (error) {
      await _rollbackUser(createdUser);
      errorMessage.value = switch (error.code) {
        'email-already-in-use' =>
        'An account with this email already exists.',
        'invalid-email' => 'Please provide a valid email address.',
        'weak-password' => 'That password is too weak.',
        'operation-not-allowed' =>
        'Email/password sign-up is not enabled in Firebase.',
        'network-request-failed' =>
        'No connection. Check your internet and try again.',
        _ => error.message ?? 'Registration failed. Please try again.',
      };
      return false;
    } on FirebaseException catch (error) {
      // Firestore rejected the write. With these rules, the usual cause is a
      // wrong invite code.
      await _rollbackUser(createdUser);
      errorMessage.value = error.code == 'permission-denied'
          ? 'Invalid invite code. Ask a project owner for the correct one.'
          : (error.message ?? 'Registration failed. Please try again.');
      return false;
    } catch (error, stackTrace) {
      debugPrint('Admin registration failed: $error\n$stackTrace');
      await _rollbackUser(createdUser);
      errorMessage.value = 'Registration failed. Please try again.';
      return false;
    } finally {
      _isRegistering = false;
      isLoading.value = false;
    }
  }

  /// If something failed after the Auth user was created, delete that user so
  /// they can retry with the same email instead of hitting "email in use".
  Future<void> _rollbackUser(User? user) async {
    if (user == null) return;
    try {
      await user.delete();
    } catch (error) {
      debugPrint('Could not roll back user: $error');
      await _auth.signOut();
    }
  }

  Future<void> retryAuthorization() async {
    final user = _auth.currentUser;
    if (user == null) {
      authorizationError.value = '';
      isCheckingAuth.value = false;
      return;
    }
    await _handleAuthChanged(user);
  }

  Future<bool> sendPasswordReset(String email) async {
    errorMessage.value = '';
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
      return true;
    } on FirebaseAuthException catch (error) {
      errorMessage.value =
          error.message ?? 'Could not send a password reset email.';
      return false;
    } catch (error, stackTrace) {
      debugPrint('Password reset request failed: $error\n$stackTrace');
      errorMessage.value = 'Could not send a password reset email.';
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      currentAdmin.value = null;
      needsEmailVerification.value = false;
      authorizationError.value = '';
    } catch (error, stackTrace) {
      debugPrint('Administrator sign-out failed: $error\n$stackTrace');
      errorMessage.value = 'Could not sign out. Please try again.';
    }
  }
}