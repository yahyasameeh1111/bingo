import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/firebase_constants.dart';
import '../models/household.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  String? _currentSessionMarker;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  bool get isAuthenticated =>
      currentUser != null &&
      currentUser!.email != null &&
      currentUser!.email!.toLowerCase().endsWith(FirebaseConstants.householdAuthDomain);

  bool get isSignedIn => isAuthenticated;
  String? get currentUid => currentUser?.uid;

  String? get currentHouseholdId {
    final user = currentUser;
    if (user == null) return null;
    return FirebaseConstants.householdIdFromEmail(user.email);
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges().map((user) {
      if (user != null &&
          user.email != null &&
          user.email!.toLowerCase().endsWith(FirebaseConstants.householdAuthDomain)) {
        return user;
      }
      return null;
    });
  }

  Future<UserCredential> signInWithHouseholdId({
    required String householdId,
    required String password,
  }) async {
    final cleanId = householdId.trim().toUpperCase();
    final email = FirebaseConstants.emailForHouseholdId(cleanId);

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        _currentSessionMarker = const Uuid().v4();
        await _recordHouseholdLogin(cleanId, user.uid, _currentSessionMarker!);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  Future<UserCredential> registerHousehold({
    required String householdId,
    required String password,
  }) async {
    final cleanId = householdId.trim().toUpperCase();
    final email = FirebaseConstants.emailForHouseholdId(cleanId);

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<void> signOut() async {
    final hid = currentHouseholdId;
    if (hid != null) {
      try {
        await _firestore.collection(FirebaseConstants.colHouseholds).doc(hid).set({
          'online': false,
          'lastSeen': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }
    _currentSessionMarker = null;
    await _auth.signOut();
  }

  Future<void> _recordHouseholdLogin(String householdId, String uid, String marker) async {
    final now = DateTime.now().toIso8601String();
    final ref = _firestore.collection(FirebaseConstants.colHouseholds).doc(householdId);
    final snap = await ref.get();

    final data = <String, dynamic>{
      'online': true,
      'lastSeen': now,
      'lastLogin': marker,
      'uid': uid,
    };

    if (!snap.exists) {
      data['id'] = householdId;
      data['status'] = 'active';
      data['isVerified'] = false;
      data['emailVerified'] = false;
      await ref.set(data);
    } else {
      await ref.set(data, SetOptions(merge: true));
    }
  }

  Future<Household?> fetchCurrentHouseholdProfile() async {
    final hid = currentHouseholdId;
    if (hid == null) return null;

    final doc = await _firestore.collection(FirebaseConstants.colHouseholds).doc(hid).get();
    if (!doc.exists || doc.data() == null) return null;
    return Household.fromFirestore(doc.id, doc.data()!);
  }

  Exception _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Household ID not found. Check your ID or contact admin.');
      case 'wrong-password':
      case 'invalid-credential':
        return Exception('Incorrect password. Please try again.');
      case 'user-disabled':
        return Exception('This household account has been disabled by admin.');
      case 'network-request-failed':
        return Exception('No internet connection. Please check your network.');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later.');
      default:
        return Exception(e.message ?? 'Authentication error occurred.');
    }
  }
}
