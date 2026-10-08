import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/hivemodels.dart';

class DonationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  List<Donation> _donations = [];

  List<Donation> get donations => _donations;

  Donation _donationFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>>
        document,
  ) {
    final data = document.data();

    final rawDate = data['date'];

    DateTime date = DateTime.now();

    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    }

    return Donation(
      id: document.id,
      donorId:
          data['donorId']?.toString() ?? '',
      orphanageId:
          data['orphanageId']?.toString() ?? '',
      requirementId:
          data['requirementId']?.toString() ?? '',
      item: data['item']?.toString() ?? '',
      quantity:
          (data['quantity'] as num?)?.toInt() ?? 0,
      date: date,
      status:
          data['status']?.toString() ?? 'Pending',
    );
  }

  Future<Requirement?> _getRequirement(
    String requirementId,
  ) async {
    final document = await _firestore
        .collection('requirements')
        .doc(requirementId)
        .get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null) {
      return null;
    }

    return Requirement(
      id: document.id,
      orphanageId:
          data['orphanageId']?.toString() ?? '',
      item: data['item']?.toString() ?? '',
      category:
          data['category']?.toString() ?? '',
      quantity:
          (data['quantity'] as num?)?.toInt() ?? 0,
      priority:
          data['priority']?.toString() ?? 'Medium',
      status:
          data['status']?.toString() ?? 'Active',
    );
  }

  Future<void> loadAllDonations() async {
    try {
      final snapshot = await _firestore
          .collection('donations')
          .get();

      _donations = snapshot.docs
          .map(_donationFromDocument)
          .toList();

      _donations.sort(
        (a, b) => b.date.compareTo(a.date),
      );

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Load all donations error: $e',
      );

      _donations = [];
      notifyListeners();
    }
  }

  Future<void> loadDonations(
    String orphanageId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('donations')
          .where(
            'orphanageId',
            isEqualTo: orphanageId,
          )
          .get();

      _donations = snapshot.docs
          .map(_donationFromDocument)
          .where(
            (donation) =>
                donation.status.toLowerCase() ==
                'confirmed',
          )
          .toList();

      _donations.sort(
        (a, b) => b.date.compareTo(a.date),
      );

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Load orphanage donations error: $e',
      );

      _donations = [];
      notifyListeners();
    }
  }

  Future<void> loadDonationsByDonor(
    String donorId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('donations')
          .where(
            'donorId',
            isEqualTo: donorId,
          )
          .get();

      _donations = snapshot.docs
          .map(_donationFromDocument)
          .toList();

      _donations.sort(
        (a, b) => b.date.compareTo(a.date),
      );

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Load donor donations error: $e',
      );

      _donations = [];
      notifyListeners();
    }
  }

  List<Donation> get pendingDonations {
    return _donations
        .where(
          (donation) =>
              donation.status.toLowerCase() ==
              'pending',
        )
        .toList();
  }

  List<Donation> get confirmedDonations {
    return _donations
        .where(
          (donation) =>
              donation.status.toLowerCase() ==
              'confirmed',
        )
        .toList();
  }

  List<Donation> get rejectedDonations {
    return _donations
        .where(
          (donation) =>
              donation.status.toLowerCase() ==
              'rejected',
        )
        .toList();
  }

  Future<void> addDonation({
    required String donorId,
    required String orphanageId,
    required String requirementId,
    required String item,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      throw Exception(
        'Donation quantity must be greater than zero',
      );
    }

    final requirement =
        await _getRequirement(requirementId);

    if (requirement == null) {
      throw Exception(
        'Requirement not found',
      );
    }

    if (requirement.orphanageId != orphanageId) {
      throw Exception('Requirement does not belong to this orphanage');
    }

    if (requirement.status.toLowerCase() !=
        'active') {
      throw Exception(
        'This requirement is no longer active',
      );
    }

    final confirmedQuantity =
        await _getQuantityFromFirestore(
      requirementId,
      'Confirmed',
    );

    final pendingQuantity =
        await _getQuantityFromFirestore(
      requirementId,
      'Pending',
    );

    final availableQuantity =
        requirement.quantity -
            confirmedQuantity -
            pendingQuantity;

    if (availableQuantity <= 0) {
      throw Exception(
        'This requirement is already fully covered',
      );
    }

    if (quantity > availableQuantity) {
      throw Exception(
        'Only $availableQuantity items are currently available to donate',
      );
    }

    final document = _firestore
        .collection('donations')
        .doc();

    final now = DateTime.now();

    final donation = Donation(
      id: document.id,
      donorId: donorId,
      orphanageId: orphanageId,
      requirementId: requirementId,
      item: item,
      quantity: quantity,
      date: now,
      status: 'Pending',
    );

    await document.set({
      'id': document.id,
      'donorId': donorId,
      'orphanageId': orphanageId,
      'requirementId': requirementId,
      'item': item,
      'quantity': quantity,
      'date': FieldValue.serverTimestamp(),
      'status': 'Pending',
    });

    _donations.add(donation);

    _donations.sort(
      (a, b) => b.date.compareTo(a.date),
    );

    notifyListeners();
  }

  Future<int> _getQuantityFromFirestore(
    String requirementId,
    String status,
  ) async {
    final snapshot = await _firestore
        .collection('donations')
        .where(
          'requirementId',
          isEqualTo: requirementId,
        )
        .get();

    return snapshot.docs
        .map(_donationFromDocument)
        .where(
          (donation) =>
              donation.status.toLowerCase() ==
              status.toLowerCase(),
        )
        .fold<int>(
          0,
          (total, donation) =>
              total + donation.quantity,
        );
  }

  Future<void> confirmDonation(String donationId) async {
    final donationRef = _firestore.collection('donations').doc(donationId);
    final initialDonation = await donationRef.get();
    if (!initialDonation.exists || initialDonation.data() == null) {
      throw Exception('Donation not found');
    }

    final initialData = initialDonation.data()!;
    if ((initialData['status']?.toString() ?? '').toLowerCase() != 'pending') {
      return;
    }

    final requirementId = initialData['requirementId']?.toString() ?? '';
    if (requirementId.isEmpty) {
      throw Exception('Donation has no requirement');
    }

    final requirementRef =
        _firestore.collection('requirements').doc(requirementId);

    // This query is outside the transaction. Suitable for a single-admin
    // classroom demonstration, but not a concurrency-safe stock reservation.
    final confirmedQuantity =
        await _getQuantityFromFirestore(requirementId, 'Confirmed');

    await _firestore.runTransaction((transaction) async {
      final donationSnapshot = await transaction.get(donationRef);
      final requirementSnapshot = await transaction.get(requirementRef);

      if (!donationSnapshot.exists || donationSnapshot.data() == null) {
        throw Exception('Donation not found');
      }
      if (!requirementSnapshot.exists || requirementSnapshot.data() == null) {
        throw Exception('Requirement not found');
      }

      final donationData = donationSnapshot.data()!;
      if ((donationData['status']?.toString() ?? '').toLowerCase() !=
          'pending') {
        throw Exception('This donation has already been processed');
      }
      if (donationData['requirementId']?.toString() != requirementId) {
        throw Exception('Donation requirement changed');
      }

      final quantity = (donationData['quantity'] as num?)?.toInt() ?? 0;
      final target =
          (requirementSnapshot.data()!['quantity'] as num?)?.toInt() ?? 0;
      if (quantity <= 0 || target <= 0 ||
          confirmedQuantity + quantity > target) {
        throw Exception('Donation exceeds the remaining requirement');
      }

      transaction.update(donationRef, {
        'status': 'Confirmed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (confirmedQuantity + quantity >= target) {
        transaction.update(requirementRef, {
          'status': 'Fulfilled',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });

    final index = _donations.indexWhere((d) => d.id == donationId);
    if (index != -1) {
      final old = _donations[index];
      _donations[index] = Donation(
        id: old.id,
        donorId: old.donorId,
        orphanageId: old.orphanageId,
        requirementId: old.requirementId,
        item: old.item,
        quantity: old.quantity,
        date: old.date,
        status: 'Confirmed',
      );
    }
    notifyListeners();
  }

  Future<void> rejectDonation(
    String donationId,
  ) async {
    final document = await _firestore
        .collection('donations')
        .doc(donationId)
        .get();

    if (!document.exists) {
      throw Exception(
        'Donation not found',
      );
    }

    final data = document.data();

    if (data == null) {
      throw Exception(
        'Donation not found',
      );
    }

    final status =
        data['status']?.toString() ?? '';

    if (status.toLowerCase() != 'pending') {
      return;
    }

    await _firestore
        .collection('donations')
        .doc(donationId)
        .update({
      'status': 'Rejected',
      'updatedAt':
          FieldValue.serverTimestamp(),
    });

    final index = _donations.indexWhere(
      (donation) =>
          donation.id == donationId,
    );

    if (index != -1) {
      final oldDonation =
          _donations[index];

      _donations[index] = Donation(
        id: oldDonation.id,
        donorId: oldDonation.donorId,
        orphanageId:
            oldDonation.orphanageId,
        requirementId:
            oldDonation.requirementId,
        item: oldDonation.item,
        quantity: oldDonation.quantity,
        date: oldDonation.date,
        status: 'Rejected',
      );
    }

    notifyListeners();
  }

  Future<void> deleteDonation(String donationId) async {
    final donationRef = _firestore.collection('donations').doc(donationId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(donationRef);
      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception('Donation not found');
      }
      final status = snapshot.data()!['status']?.toString().toLowerCase() ?? '';
      if (status == 'pending') {
        throw Exception('Please approve or reject pending donations first');
      }
      if (status == 'confirmed') {
        throw Exception('Confirmed donations cannot be removed because they count towards fulfilled requirements');
      }
      transaction.delete(donationRef);
    });
    _donations.removeWhere((donation) => donation.id == donationId);
    notifyListeners();
  }

  List<Donation> getDonationsForRequirement(
    String requirementId,
  ) {
    return _donations
        .where(
          (donation) =>
              donation.requirementId ==
              requirementId,
        )
        .toList();
  }

  int getConfirmedQuantity(
    String requirementId,
  ) {
    return _donations
        .where(
          (donation) =>
              donation.requirementId ==
                  requirementId &&
              donation.status.toLowerCase() ==
                  'confirmed',
        )
        .fold<int>(
          0,
          (total, donation) =>
              total + donation.quantity,
        );
  }

  int getPendingQuantity(
    String requirementId,
  ) {
    return _donations
        .where(
          (donation) =>
              donation.requirementId ==
                  requirementId &&
              donation.status.toLowerCase() ==
                  'pending',
        )
        .fold<int>(
          0,
          (total, donation) =>
              total + donation.quantity,
        );
  }

  int getRemainingQuantity(
    Requirement requirement,
  ) {
    final confirmedQuantity =
        getConfirmedQuantity(
      requirement.id,
    );

    final remaining =
        requirement.quantity -
            confirmedQuantity;

    return remaining < 0
        ? 0
        : remaining;
  }

  int getAvailableQuantity(
    Requirement requirement,
  ) {
    final confirmedQuantity =
        getConfirmedQuantity(
      requirement.id,
    );

    final pendingQuantity =
        getPendingQuantity(
      requirement.id,
    );

    final available =
        requirement.quantity -
            confirmedQuantity -
            pendingQuantity;

    return available < 0
        ? 0
        : available;
  }

  double getRequirementProgress(
    Requirement requirement,
  ) {
    if (requirement.quantity <= 0) {
      return 0;
    }

    final confirmedQuantity =
        getConfirmedQuantity(
      requirement.id,
    );

    return (confirmedQuantity /
            requirement.quantity)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  bool isRequirementFulfilled(
    Requirement requirement,
  ) {
    return getRemainingQuantity(
          requirement,
        ) ==
        0;
  }

  int get pendingCount =>
      pendingDonations.length;

  int get confirmedCount =>
      confirmedDonations.length;

  int get rejectedCount =>
      rejectedDonations.length;

  int get totalReceivedQuantity {
    return confirmedDonations.fold<int>(
      0,
      (total, donation) =>
          total + donation.quantity,
    );
  }
}