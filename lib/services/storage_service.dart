import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../utils/logger.dart';
import 'providers.dart';

// Provider for storage service
final storageServiceProvider = Provider<StorageService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return StorageService(supabaseClient);
});

class StorageService {
  final SupabaseClient _supabaseClient;

  StorageService(this._supabaseClient);

  // Upload a file to Supabase Storage
  Future<String?> uploadFile({
    required File file,
    required String userId,
    required String bucketName,
  }) async {
    try {
      // Validate inputs
      if (!file.existsSync()) {
        AppLogger.error('File does not exist: ${file.path}', null, null);
        return null;
      }

      if (userId.isEmpty) {
        AppLogger.error('User ID is empty', null, null);
        return null;
      }

      if (bucketName.isEmpty) {
        AppLogger.error('Bucket name is empty', null, null);
        return null;
      }

      // Check file size (limit to 5MB for profile images)
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        AppLogger.error('File size exceeds 5MB limit: ${fileSize / 1024 / 1024}MB', null, null);
        return null;
      }

      // Create a unique filename using UUID
      final uuid = const Uuid().v4();
      final fileExtension = path.extension(file.path);
      final fileName = '$uuid$fileExtension';

      // Define the path within the bucket
      final String filePathInBucket = '$userId/$fileName';

      // Determine content type
      String contentType = 'application/octet-stream'; // Default
      if (fileExtension.isNotEmpty) {
        final ext = fileExtension.toLowerCase().replaceAll('.', '');
        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
          contentType = 'image/$ext';
        }
        // Add more content types as needed
      }

      // Upload the file
      await _supabaseClient.storage
          .from(bucketName)
          .uploadBinary(
            filePathInBucket,
            await file.readAsBytes(),
            fileOptions: FileOptions(contentType: contentType, upsert: false),
          );

      // Get public URL
      final String downloadUrl = _supabaseClient.storage
          .from(bucketName)
          .getPublicUrl(filePathInBucket);

      AppLogger.info('File uploaded successfully to Supabase: $downloadUrl');
      return downloadUrl;
    } catch (e, stack) {
      AppLogger.error('Error uploading file to Supabase', e, stack);
      if (e is StorageException) {
        AppLogger.error('Supabase Storage Exception: ${e.message}', e, stack);
      }
      return null;
    }
  }

  // Upload a profile image
  Future<String?> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    return uploadFile(
      file: imageFile,
      userId: userId,
      bucketName: 'profile_images',
    );
  }

  // Delete a file from Supabase Storage
  Future<bool> deleteFile(String fileUrl) async {
    try {
      final uri = Uri.parse(fileUrl);
      // Expected Supabase URL structure: /storage/v1/object/public/bucket_name/file_path...
      // Example: https://projectid.supabase.co/storage/v1/object/public/profile_images/user_id/image.jpg
      final pathSegments = uri.pathSegments;

      if (pathSegments.length < 5 || pathSegments[3] != 'public') {
        AppLogger.error('Invalid Supabase file URL format for deletion: $fileUrl', null, null);
        return false;
      }

      final bucketName = pathSegments[4];
      final filePathInBucket = pathSegments.sublist(5).join('/');

      if (bucketName.isEmpty || filePathInBucket.isEmpty) {
        AppLogger.error('Could not parse bucket or file path from URL: $fileUrl', null, null);
        return false;
      }

      await _supabaseClient.storage
          .from(bucketName)
          .remove([filePathInBucket]);

      AppLogger.info('File deleted successfully from Supabase: $fileUrl (Path: $filePathInBucket in bucket $bucketName)');
      return true;
    } catch (e, stack) {
      AppLogger.error('Error deleting file from Supabase', e, stack);
      if (e is StorageException) {
        AppLogger.error('Supabase Storage Exception: ${e.message}', e, stack);
      }
      return false;
    }
  }
}