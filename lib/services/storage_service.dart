import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../utils/logger.dart';

// Provider for storage service
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Upload a file to Firebase Storage
  Future<String?> uploadFile({
    required File file,
    required String userId,
    required String folder,
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
      
      if (folder.isEmpty) {
        AppLogger.error('Folder is empty', null, null);
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
      
      // Create reference to the file location
      final fileRef = _storage.ref().child('$folder/$userId/$fileName');
      
      // Start upload with metadata
      final metadata = SettableMetadata(
        contentType: 'image/${fileExtension.replaceAll('.', '')}',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      
      // Execute upload with progress logging
      final uploadTask = fileRef.putFile(file, metadata);
      
      // Log progress (useful for debugging)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        AppLogger.info('Upload progress: ${progress.toStringAsFixed(2)}%', null);
      });
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      AppLogger.info('File uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e, stack) {
      AppLogger.error('Error uploading file', e, stack);
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
      folder: 'profile_images',
    );
  }
  
  // Delete a file from Firebase Storage
  Future<bool> deleteFile(String fileUrl) async {
    try {
      // Get reference from URL
      final ref = _storage.refFromURL(fileUrl);
      
      // Delete the file
      await ref.delete();
      
      AppLogger.info('File deleted successfully: $fileUrl');
      return true;
    } catch (e, stack) {
      AppLogger.error('Error deleting file', e, stack);
      return false;
    }
  }
}