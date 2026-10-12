import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/student_model.dart';

class StudentsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<StudentModel> allStudents = <StudentModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedDeptFilter = 'All'.obs;

  StreamSubscription? _studentsSubscription;

  @override
  void onInit() {
    super.onInit();
    bindStudentsStream();
  }

  @override
  void onClose() {
    _studentsSubscription?.cancel();
    super.onClose();
  }

  void bindStudentsStream() {
    isLoading.value = true;
    _studentsSubscription?.cancel();

    _studentsSubscription = _firestore
        .collection('students')
        .snapshots()
        .listen(
      (snapshot) {
        final list = snapshot.docs
            .map((doc) => StudentModel.fromMap(doc.data(), doc.id))
            .toList();

        allStudents.value = list;
        isLoading.value = false;
      },
      onError: (error) {
        debugPrint('Students stream error: $error');
        errorMessage.value = 'Failed to load students: $error';
        isLoading.value = false;
      },
    );
  }

  List<StudentModel> get filteredStudents {
    return allStudents.where((s) {
      if (selectedDeptFilter.value != 'All' &&
          !s.department.toLowerCase().contains(selectedDeptFilter.value.toLowerCase())) {
        return false;
      }

      final q = searchQuery.value.trim().toLowerCase();
      if (q.isNotEmpty) {
        final matchesName = s.name.toLowerCase().contains(q);
        final matchesId = s.studentId.toLowerCase().contains(q);
        final matchesEmail = s.email.toLowerCase().contains(q);
        final matchesDept = s.department.toLowerCase().contains(q);

        return matchesName || matchesId || matchesEmail || matchesDept;
      }

      return true;
    }).toList();
  }

  // Quick Stats
  int get totalStudentsCount => allStudents.length;

  /// Add student to Firestore
  Future<bool> addStudent(StudentModel student) async {
    try {
      await _firestore.collection('students').doc(student.id).set(student.toMap());
      return true;
    } catch (e) {
      debugPrint('Error adding student: $e');
      return false;
    }
  }

  /// Update student details
  Future<bool> updateStudent(StudentModel student) async {
    try {
      await _firestore.collection('students').doc(student.id).update(student.toMap());
      return true;
    } catch (e) {
      debugPrint('Error updating student: $e');
      return false;
    }
  }

  /// Delete student
  Future<bool> deleteStudent(String studentId) async {
    try {
      await _firestore.collection('students').doc(studentId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting student: $e');
      return false;
    }
  }
}
