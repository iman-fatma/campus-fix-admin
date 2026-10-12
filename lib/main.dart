import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/admin_auth_controller.dart';
import 'core/app_theme.dart';
import 'firebase_options.dart';
import 'views/admin_app_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? firebaseError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Get.put(AdminAuthController(), permanent: true);
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization failed: $error\n$stackTrace');
    firebaseError = error.toString();
  }

  runApp(CampusFixAdminApp(firebaseError: firebaseError));
}

class CampusFixAdminApp extends StatelessWidget {
  final String? firebaseError;

  const CampusFixAdminApp({super.key, this.firebaseError});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CampusFix Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: firebaseError == null
          ? const AdminAppGate()
          : FirebaseUnavailableScreen(message: firebaseError!),
    );
  }
}

class FirebaseUnavailableScreen extends StatelessWidget {
  final String message;

  const FirebaseUnavailableScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Could not connect to Firebase',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                SelectableText(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
