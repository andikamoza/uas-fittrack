import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_preference.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> savePreferenceToFirestore(UserPreference preference) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).set(preference.toMap(), SetOptions(merge: true));
  }

  Future<void> saveWorkoutLog(Map<String, dynamic> workoutData) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).collection('workout_logs').add(workoutData);
  }

  Future<UserPreference?> getUserPreferenceFromFirestore() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserPreference.fromMap(doc.data()!);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getWorkoutLogs() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await _firestore.collection('users').doc(uid).collection('workout_logs').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
