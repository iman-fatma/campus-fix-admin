import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/ticket_model.dart';

class TicketsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<TicketModel> allTickets = <TicketModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Filters and Search
  final RxString searchQuery = ''.obs;
  final RxString selectedStatusFilter = 'All'.obs;
  final RxString selectedPriorityFilter = 'All'.obs;
  final RxString selectedCategoryFilter = 'All'.obs;

  StreamSubscription? _ticketsSubscription;

  @override
  void onInit() {
    super.onInit();
    bindTicketsStream();
  }

  @override
  void onClose() {
    _ticketsSubscription?.cancel();
    super.onClose();
  }

  void bindTicketsStream() {
    isLoading.value = true;
    _ticketsSubscription?.cancel();

    _ticketsSubscription = _firestore
        .collection('tickets')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        final list = snapshot.docs
            .map((doc) => TicketModel.fromMap(doc.data(), doc.id))
            .toList();

        allTickets.value = list;
        isLoading.value = false;
      },
      onError: (error) {
        debugPrint('Tickets snapshot error: $error');
        errorMessage.value = 'Failed to load tickets: $error';
        isLoading.value = false;
      },
    );
  }

  List<TicketModel> get filteredTickets {
    return allTickets.where((t) {
      // 1. Status Filter
      if (selectedStatusFilter.value != 'All' &&
          t.status.toLowerCase() != selectedStatusFilter.value.toLowerCase()) {
        return false;
      }

      // 2. Priority Filter
      if (selectedPriorityFilter.value != 'All' &&
          t.priority.toLowerCase() != selectedPriorityFilter.value.toLowerCase()) {
        return false;
      }

      // 3. Category Filter
      if (selectedCategoryFilter.value != 'All' &&
          !t.category.toLowerCase().contains(selectedCategoryFilter.value.toLowerCase())) {
        return false;
      }

      // 4. Search Filter
      final q = searchQuery.value.trim().toLowerCase();
      if (q.isNotEmpty) {
        final matchesTicketNumber = t.ticketNumber.toLowerCase().contains(q);
        final matchesTitle = t.title.toLowerCase().contains(q);
        final matchesDesc = t.description.toLowerCase().contains(q);
        final matchesLocation = t.location.toLowerCase().contains(q);
        final matchesStudent = t.studentName.toLowerCase().contains(q) ||
            t.studentId.toLowerCase().contains(q);

        return matchesTicketNumber ||
            matchesTitle ||
            matchesDesc ||
            matchesLocation ||
            matchesStudent;
      }

      return true;
    }).toList();
  }

  // Quick Stats Getters
  int get totalCount => allTickets.length;
  int get openCount => allTickets.where((t) => t.status.toLowerCase() == 'open').length;
  int get assignedCount => allTickets.where((t) => t.status.toLowerCase() == 'assigned').length;
  int get inProgressCount => allTickets.where((t) => t.status.toLowerCase() == 'in progress').length;
  int get resolvedCount => allTickets.where((t) => t.status.toLowerCase() == 'resolved').length;
  int get urgentCount => allTickets.where((t) => t.priority.toLowerCase() == 'urgent').length;

  /// Update status and optional technician or remarks
  Future<bool> updateTicketStatus({
    required String ticketId,
    required String newStatus,
    String? assignedTo,
    String? remarks,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'status': newStatus,
        'updatedAt': Timestamp.now(),
      };

      if (assignedTo != null) {
        updateData['assignedTo'] = assignedTo;
      }
      if (remarks != null && remarks.isNotEmpty) {
        updateData['remarks'] = remarks;
      }

      await _firestore.collection('tickets').doc(ticketId).update(updateData);
      return true;
    } catch (e) {
      debugPrint('Error updating ticket: $e');
      Get.snackbar(
        'Update Error',
        'Could not update ticket: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Create new maintenance ticket
  Future<bool> createTicket(TicketModel ticket) async {
    try {
      await _firestore.collection('tickets').doc(ticket.id).set(ticket.toMap());
      return true;
    } catch (e) {
      debugPrint('Error creating ticket: $e');
      return false;
    }
  }

  /// Delete a ticket
  Future<bool> deleteTicket(String ticketId) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting ticket: $e');
      return false;
    }
  }

}
