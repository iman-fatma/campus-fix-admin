import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/announcement_model.dart';

class AnnouncementsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<AnnouncementModel> announcements = <AnnouncementModel>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    bindAnnouncements();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void bindAnnouncements() {
    isLoading.value = true;
    _subscription?.cancel();

    _subscription = _firestore
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        final list = snapshot.docs
            .map((doc) => AnnouncementModel.fromMap(doc.data(), doc.id))
            .toList();

        announcements.value = list;
        isLoading.value = false;
      },
      onError: (error) {
        debugPrint('Announcements error: $error');
        isLoading.value = false;
      },
    );
  }

  Future<bool> createAnnouncement(AnnouncementModel model) async {
    try {
      await _firestore.collection('announcements').doc(model.id).set(model.toMap());
      return true;
    } catch (e) {
      debugPrint('Error creating announcement: $e');
      return false;
    }
  }

  Future<bool> deleteAnnouncement(String id) async {
    try {
      await _firestore.collection('announcements').doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting announcement: $e');
      return false;
    }
  }

  Future<bool> toggleActive(String id, bool currentState) async {
    try {
      await _firestore.collection('announcements').doc(id).update({
        'isActive': !currentState,
      });
      return true;
    } catch (e) {
      debugPrint('Error toggling active status: $e');
      return false;
    }
  }

}
