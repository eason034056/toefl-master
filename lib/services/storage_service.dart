import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class StorageService {
  // 建立 Firebase Storage 的實例
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 生成唯一ID的工具
  final Uuid _uuid = const Uuid();

  // 上傳照片的方法
  Future<String> uploadImage(File imageFile, {int maxRetries = 3}) async {
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String uniqueId = _uuid.v4();
        final String extension = path.extension(imageFile.path);
        String fileName = 'check_in_photos/$timestamp-$uniqueId$extension';

        // 檢查文件是否存在
        if (!await imageFile.exists()) {
          throw Exception('Image file does not exist');
        }

        // 檢查文件大小
        final fileSize = await imageFile.length();
        print('File size: ${fileSize / 1024} KB');
        if (fileSize > 5 * 1024 * 1024) {
          throw Exception('Image file too large (max 5MB)');
        }

        Reference ref = _storage.ref().child(fileName);
        print('Attempting to upload to path: $fileName');

        // 添加上傳進度監聽
        final uploadTask = ref.putFile(
          imageFile,
          SettableMetadata(
            contentType: 'image/${extension.replaceAll('.', '')}',
            customMetadata: {
              'uploaded_at': DateTime.now().toIso8601String(),
              'uuid': uniqueId,
              'retry_count': retryCount.toString(),
            },
          ),
        );

        // 監聽上傳狀態
        uploadTask.snapshotEvents.listen(
          (TaskSnapshot snapshot) {
            final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
            print('Upload progress: ${progress.toStringAsFixed(2)}%');
          },
          onError: (e) {
            print('Upload stream error: $e');
          },
        );

        // 等待上傳完成
        final snapshot = await uploadTask;
        print('Upload completed with state: ${snapshot.state}');

        // 獲取下載URL
        String downloadUrl = await ref.getDownloadURL();
        print('Successfully uploaded image. Download URL: $downloadUrl');
        return downloadUrl;
      } on FirebaseException catch (e) {
        retryCount++;
        print('Firebase error on attempt $retryCount:');
        print('Error code: ${e.code}');
        print('Error message: ${e.message}');
        print('Error details: ${e.stackTrace}');

        if (retryCount >= maxRetries) {
          throw Exception('Firebase upload failed after $maxRetries attempts: ${e.message}');
        }
        await Future.delayed(Duration(seconds: retryCount * 2));
      } catch (e) {
        retryCount++;
        print('General error on attempt $retryCount: $e');

        if (retryCount >= maxRetries) {
          throw Exception('Upload failed after $maxRetries attempts: $e');
        }
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
    throw Exception('Unexpected error in upload retry loop');
  }

  // 刪除照片的方法
  Future<void> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('Successfully deleted image: $imageUrl');
    } catch (e) {
      print('Error deleting image: $e');
      if (e is FirebaseException) {
        print('Firebase error code: ${e.code}');
        print('Firebase error message: ${e.message}');
      }
      throw Exception('Failed to delete image: ${e.toString()}');
    }
  }

  Future<void> testFirebaseConnection() async {
    try {
      // 只測試是否可以訪問 storage bucket
      final storageRef = _storage.ref();
      // 列出根目錄下的所有項目（即使是空的）
      await storageRef.listAll();
      print('Firebase Storage connected successfully');
      return;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        // 這是正常的，因為目錄可能是空的
        print('Firebase Storage connected successfully (empty bucket)');
        return;
      }
      print('Firebase connection error: $e');
      throw e;
    } catch (e) {
      print('Firebase connection error: $e');
      throw e;
    }
  }
}
