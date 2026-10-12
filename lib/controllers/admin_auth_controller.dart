import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/admin_user_model.dart';

class AdminAuthController extends GetxController {
  AdminAuthController({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<AdminUserModel?> currentAdmin = Rx<AdminUserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isCheckingAuth = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString authorizationError = ''.obs;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _adminSubscription;
  int _authorizationAttempt = 0;

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
    final attempt = ++_authorizationAttempt;
    firebaseUser.value = user;
    isCheckingAuth.value = true;

    if (user == null) {
      unawaited(_adminSubscription?.cancel());
      _adminSubscription = null;
      currentAdmin.value = null;
      isCheckingAuth.value = false;
      return;
    }
    authorizationError.value = '';

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
      authorizationError.value = '';
    } catch (error, stackTrace) {
      debugPrint('Administrator sign-out failed: $error\n$stackTrace');
      errorMessage.value = 'Could not sign out. Please try again.';
    }
  }
}
