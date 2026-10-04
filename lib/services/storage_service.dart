import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../core/constants/firebase_constants.dart';

class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadCommunityImage({
    required Uint8List bytes,
    required String mimeType,
    String? customPath,
  }) async {
    final filename = customPath ?? 'post_${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4().substring(0, 8)}.jpg';
    final ref = _storage.ref().child('community_images/$filename');

    final metadata = SettableMetadata(
      contentType: mimeType,
      cacheControl: 'public,max-age=86400',
    );

    final uploadTask = await ref.putData(bytes, metadata);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadProfilePhoto({
    required Uint8List bytes,
    required String householdId,
    String mimeType = 'image/jpeg',
  }) async {
    // 1. Try Supabase profile-photos bucket for full parity with existing web
    try {
      final sanitizedId = householdId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final path = 'household_$sanitizedId.jpg';
      final uploadUrl = Uri.parse(
        '${FirebaseConstants.supabaseUrl}/storage/v1/object/${FirebaseConstants.supabaseProfileBucket}/$path',
      );

      final response = await http.put(
        uploadUrl,
        headers: {
          'apikey': FirebaseConstants.supabasePublishableKey,
          'Authorization': 'Bearer ${FirebaseConstants.supabasePublishableKey}',
          'Content-Type': mimeType,
          'x-upsert': 'true',
          'cache-control': '3600',
        },
        body: bytes,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final publicUrl =
            '${FirebaseConstants.supabaseUrl}/storage/v1/object/public/${FirebaseConstants.supabaseProfileBucket}/$path?v=${DateTime.now().millisecondsSinceEpoch}';
        return publicUrl;
      }
    } catch (_) {
      // Fallback to Firebase Storage if Supabase is unavailable
    }

    // 2. Firebase Storage fallback
    final filename = 'profile_${householdId.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('profiles/$filename');
    final metadata = SettableMetadata(contentType: mimeType);
    final task = await ref.putData(bytes, metadata);
    return await task.ref.getDownloadURL();
  }
}
