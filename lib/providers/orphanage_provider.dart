import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/hivemodels.dart';

class OrphanageProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Orphanage? _orphanage;

  List<Requirement> _requirements = [];

  Orphanage? get orphanage => _orphanage;

  List<Requirement> get requirements =>
      _requirements;

  Future<void> loadOrphanage(
    String userId,
  ) async {
    try {
      _orphanage = null;
      _requirements = [];

      notifyListeners();

      final document = await _firestore
          .collection('orphanages')
          .doc(userId)
          .get();

      if (!document.exists) {
        return;
      }

      final data = document.data();

      if (data == null) {
        return;
      }

      _orphanage = Orphanage(
        id: document.id,
        userId:
            data['userId']?.toString() ?? userId,
        name: data['name']?.toString() ?? '',
        address:
            data['address']?.toString() ?? '',
        description:
            data['description']?.toString() ?? '',
        image: data['image']?.toString() ?? '',
        verified: data['verified'] == true,
        district:
            data['district']?.toString() ?? '',
        category:
            data['category']?.toString() ?? '',
      );

      await loadRequirements(
        _orphanage!.id,
      );

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Load orphanage error: $e',
      );

      _orphanage = null;
      _requirements = [];

      notifyListeners();
    }
  }

  Future<void> loadRequirements(
    String orphanageId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('requirements')
          .where(
            'orphanageId',
            isEqualTo: orphanageId,
          )
          .get();

      _requirements = snapshot.docs.map(
        (document) {
          final data = document.data();

          return Requirement(
            id: document.id,
            orphanageId:
                data['orphanageId']
                        ?.toString() ??
                    '',
            item:
                data['item']?.toString() ?? '',
            category:
                data['category']?.toString() ??
                    '',
            quantity:
                (data['quantity'] as num?)
                        ?.toInt() ??
                    0,
            priority:
                data['priority']?.toString() ??
                    'Medium',
            status:
                data['status']?.toString() ??
                    'Active',
          );
        },
      ).toList();

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Load requirements error: $e',
      );

      _requirements = [];

      notifyListeners();
    }
  }

  Future<void> loadAllRequirements() async {
    try {
      final snapshot = await _firestore
          .collection('requirements')
          .where(
            'status',
            isEqualTo: 'Active',
          )
          .get();

      _requirements = snapshot.docs.map(
        (document) {
          final data = document.data();

          return Requirement(
            id: document.id,
            orphanageId:
                data['orphanageId']
                        ?.toString() ??
                    '',
            item:
                data['item']?.toString() ?? '',
            category:
                data['category']?.toString() ??
                    '',
            quantity:
                (data['quantity'] as num?)
                        ?.toInt() ??
                    0,
            priority:
                data['priority']?.toString() ??
                    'Medium',
            status:
                data['status']?.toString() ??
                    'Active',
          );
        },
      ).toList();

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Load all requirements error: $e',
      );

      _requirements = [];

      notifyListeners();
    }
  }

  Future<void> addRequirement({
    required String item,
    required String category,
    required int quantity,
    required String priority,
  }) async {
    if (_orphanage == null) {
      throw Exception(
        'Orphanage profile not found',
      );
    }

    try {
      final document = _firestore
          .collection('requirements')
          .doc();

      final requirement =
          Requirement(
        id: document.id,
        orphanageId: _orphanage!.id,
        item: item,
        category: category,
        quantity: quantity,
        priority: priority,
        status: 'Active',
      );

      await document.set({
        'id': document.id,
        'orphanageId':
            _orphanage!.id,
        'item': item,
        'category': category,
        'quantity': quantity,
        'priority': priority,
        'status': 'Active',
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      _requirements.add(
        requirement,
      );

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Add requirement error: $e',
      );

      throw Exception(
        'Unable to add requirement',
      );
    }
  }

  Future<void> updateRequirement({
    required String requirementId,
    required String item,
    required String category,
    required int quantity,
    required String priority,
  }) async {
    try {
      await _firestore
          .collection('requirements')
          .doc(requirementId)
          .update({
        'item': item,
        'category': category,
        'quantity': quantity,
        'priority': priority,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      final index =
          _requirements.indexWhere(
        (requirement) =>
            requirement.id ==
            requirementId,
      );

      if (index != -1) {
        final oldRequirement =
            _requirements[index];

        _requirements[index] =
            Requirement(
          id: oldRequirement.id,
          orphanageId:
              oldRequirement.orphanageId,
          item: item,
          category: category,
          quantity: quantity,
          priority: priority,
          status:
              oldRequirement.status,
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Update requirement error: $e',
      );

      throw Exception(
        'Unable to update requirement',
      );
    }
  }

  Future<void> deleteRequirement(
    String requirementId,
  ) async {
    try {
      await _firestore
          .collection('requirements')
          .doc(requirementId)
          .delete();

      _requirements.removeWhere(
        (requirement) =>
            requirement.id ==
            requirementId,
      );

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Delete requirement error: $e',
      );

      throw Exception(
        'Unable to delete requirement',
      );
    }
  }

  Future<void> updateRequirementStatus({
    required String requirementId,
    required String status,
  }) async {
    try {
      await _firestore
          .collection('requirements')
          .doc(requirementId)
          .update({
        'status': status,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      final index =
          _requirements.indexWhere(
        (requirement) =>
            requirement.id ==
            requirementId,
      );

      if (index != -1) {
        final oldRequirement =
            _requirements[index];

        _requirements[index] =
            Requirement(
          id: oldRequirement.id,
          orphanageId:
              oldRequirement.orphanageId,
          item: oldRequirement.item,
          category:
              oldRequirement.category,
          quantity:
              oldRequirement.quantity,
          priority:
              oldRequirement.priority,
          status: status,
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Update requirement status error: $e',
      );

      throw Exception(
        'Unable to update requirement status',
      );
    }
  }

  Future<void> updateOrphanage({
    required String name,
    required String address,
    required String description,
  }) async {
    if (_orphanage == null) {
      throw Exception(
        'Orphanage profile not found',
      );
    }

    try {
      await _firestore
          .collection('orphanages')
          .doc(_orphanage!.id)
          .update({
        'name': name,
        'address': address,
        'description': description,
      });

      _orphanage!.name = name;
      _orphanage!.address = address;
      _orphanage!.description =
          description;

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Update orphanage error: $e',
      );

      throw Exception(
        'Unable to update orphanage',
      );
    }
  }
}