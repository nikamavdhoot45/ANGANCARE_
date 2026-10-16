import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return instance;
  }

  // =========================
  // USERS
  // =========================

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return {
      'id': doc.id,
      ...doc.data()!,
    };
  }

  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    required String role,
    String? centerId,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': role,
      'centerId': centerId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================
  // CHILDREN
  // =========================

  Future<String> insertChild(
      Map<String, dynamic> child,
      ) async {
    final data = Map<String, dynamic>.from(child);

    data['createdAt'] = FieldValue.serverTimestamp();

    final doc =
    await _firestore.collection('children').add(data);

    return doc.id;
  }

  Future<List<Map<String, dynamic>>> getChildren() async {
    final snapshot = await _firestore
        .collection('children')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  Future<Map<String, dynamic>?> getChild(
      String id,
      ) async {
    final doc =
    await _firestore.collection('children').doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return {
      'id': doc.id,
      ...doc.data()!,
    };
  }

  Future<void> updateChild(
      String id,
      Map<String, dynamic> child,
      ) async {
    final data = Map<String, dynamic>.from(child);

    data['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore
        .collection('children')
        .doc(id)
        .update(data);
  }

  Future<void> deleteChild(
      String id,
      ) async {
    final childRef =
    _firestore.collection('children').doc(id);

    await _deleteSubcollection(
      childRef.collection('growthRecords'),
    );

    await _deleteSubcollection(
      childRef.collection('nutritionRecords'),
    );

    await _deleteSubcollection(
      childRef.collection('vaccinationRecords'),
    );

    await _deleteSubcollection(
      childRef.collection('healthRecords'),
    );

    await childRef.delete();
  }

  Future<void> _deleteSubcollection(
      CollectionReference collection,
      ) async {
    final snapshot = await collection.get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // =========================
  // GROWTH RECORDS
  // =========================

  Future<String> insertGrowthRecord(
      String childId,
      Map<String, dynamic> record,
      ) async {
    final data = Map<String, dynamic>.from(record);

    data['createdAt'] = FieldValue.serverTimestamp();

    final doc = await _firestore
        .collection('children')
        .doc(childId)
        .collection('growthRecords')
        .add(data);

    return doc.id;
  }

  Future<List<Map<String, dynamic>>> getGrowthRecords(
      String childId,
      ) async {
    final snapshot = await _firestore
        .collection('children')
        .doc(childId)
        .collection('growthRecords')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  // =========================
  // NUTRITION RECORDS
  // =========================

  Future<String> insertNutritionRecord(
      String childId,
      Map<String, dynamic> record,
      ) async {
    final data = Map<String, dynamic>.from(record);

    data['createdAt'] = FieldValue.serverTimestamp();

    final doc = await _firestore
        .collection('children')
        .doc(childId)
        .collection('nutritionRecords')
        .add(data);

    return doc.id;
  }

  Future<List<Map<String, dynamic>>> getNutritionRecords(
      String childId,
      ) async {
    final snapshot = await _firestore
        .collection('children')
        .doc(childId)
        .collection('nutritionRecords')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  // =========================
  // VACCINATION RECORDS
  // =========================

  Future<String> insertVaccinationRecord(
      String childId,
      Map<String, dynamic> record,
      ) async {
    final data = Map<String, dynamic>.from(record);

    data['createdAt'] = FieldValue.serverTimestamp();

    final doc = await _firestore
        .collection('children')
        .doc(childId)
        .collection('vaccinationRecords')
        .add(data);

    return doc.id;
  }

  Future<List<Map<String, dynamic>>> getVaccinationRecords(
      String childId,
      ) async {
    final snapshot = await _firestore
        .collection('children')
        .doc(childId)
        .collection('vaccinationRecords')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  // =========================
  // HEALTH RECORDS
  // =========================

  Future<String> insertHealthRecord(
      String childId,
      Map<String, dynamic> record,
      ) async {
    final data = Map<String, dynamic>.from(record);

    data['createdAt'] = FieldValue.serverTimestamp();

    final doc = await _firestore
        .collection('children')
        .doc(childId)
        .collection('healthRecords')
        .add(data);

    return doc.id;
  }

  Future<List<Map<String, dynamic>>> getHealthRecords(
      String childId,
      ) async {
    final snapshot = await _firestore
        .collection('children')
        .doc(childId)
        .collection('healthRecords')
        .orderBy('checkupDate', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  // =========================
  // DASHBOARD COUNTS
  // =========================

  Future<int> getTotalChildren() async {
    final snapshot =
    await _firestore.collection('children').count().get();

    return snapshot.count ?? 0;
  }

  Future<int> getNormalChildren() async {
    final snapshot = await _firestore
        .collection('children')
        .where('growthStatus', isEqualTo: 'Normal')
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  Future<int> getModerateChildren() async {
    final snapshot = await _firestore
        .collection('children')
        .where('growthStatus', isEqualTo: 'Moderate')
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  Future<int> getSevereChildren() async {
    final snapshot = await _firestore
        .collection('children')
        .where('growthStatus', isEqualTo: 'Severe')
        .count()
        .get();

    return snapshot.count ?? 0;
  }
}