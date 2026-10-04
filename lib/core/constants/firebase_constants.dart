import 'package:firebase_core/firebase_core.dart';

class FirebaseConstants {
  static const String apiKey = 'AIzaSyDOdcbGkP8M19j9H9v_05aybTGQLaZR0No';
  static const String authDomain = 'bingoc.firebaseapp.com';
  static const String projectId = 'bingoc';
  static const String storageBucket = 'bingoc.firebasestorage.app';
  static const String messagingSenderId = '1033140815570';
  static const String appId = '1:1033140815570:web:352a2513ee259581124f0b';
  static const String measurementId = 'G-V80YJB14MS';

  static const FirebaseOptions firebaseOptions = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    authDomain: authDomain,
    storageBucket: storageBucket,
    measurementId: measurementId,
  );

  // Household internal auth email domain
  static const String householdAuthDomain = '@auth.bingo.app';

  // Google Apps Script endpoint for OTP / Gmail verification
  static const String googleVerificationWebApp =
      'https://script.google.com/macros/s/AKfycbz-S9_4b053oyIFZqx7mwhwfo_pTJA-kWcrNQ1HZARQ-wJhIB2N76BLZlAipaHpVbfL/exec';

  // Supabase Storage endpoints for profile media
  static const String supabaseUrl = 'https://tajdmvwmeqdiuwirxjec.supabase.co';
  static const String supabasePublishableKey =
      'sb_publishable_c-w_5-vhvFWMD0eLUMVVHw_wcjrIhYP';
  static const String supabaseProfileBucket = 'profile-photos';

  // Firestore Collections
  static const String colHouseholds = 'households';
  static const String colSchedule = 'schedule';
  static const String colWasteTypes = 'wasteTypes';
  static const String colNotifications = 'notifications';
  static const String colCollectionPoints = 'collectionPoints';
  static const String colReports = 'reports';
  static const String colCommunityPosts = 'communityPosts';
  static const String colCommunityFollows = 'communityFollows';
  static const String colCommunityProfiles = 'communityProfiles';
  static const String colCommunityNotifications = 'communityNotifications';
  static const String colActivityLogs = 'activityLogs';
  static const String colAppSettings = 'appSettings';

  // Helpers
  static String emailForHouseholdId(String id) {
    final clean = id.trim().toUpperCase();
    final sanitized = clean.replaceAll(RegExp(r'[^A-Z0-9._-]'), '-').toLowerCase();
    return '$sanitized$householdAuthDomain';
  }

  static String householdIdFromEmail(String? email) {
    if (email == null) return '';
    final lower = email.trim().toLowerCase();
    if (lower.endsWith(householdAuthDomain)) {
      return lower.substring(0, lower.length - householdAuthDomain.length).toUpperCase();
    }
    return '';
  }
}
