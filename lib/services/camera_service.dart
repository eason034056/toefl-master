import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraService {
  // 創建 ImagePicker 實例，這就像是一個可以操作相機和相簿的遙控器
  final ImagePicker _picker = ImagePicker();

  // 拍照的方法
  Future<File?> takePhoto() async {
    try {
      // 開啟相機並等待使用者拍照
      // 這就像是按下相機的快門鍵
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera, // 指定使用相機，而不是相簿
        imageQuality: 80, // 設定照片品質（0-100），這裡設80來平衡品質和檔案大小
      );

      // 如果使用者沒有拍照（按了取消），就回傳 null
      if (photo == null) return null;

      // 將拍到的照片轉換成 File 格式
      return File(photo.path);
    } catch (e) {
      // 如果拍照過程發生錯誤，印出錯誤訊息
      print('Error taking photo: $e');
      return null;
    }
  }

  // 從相簿選擇照片的方法
  Future<File?> pickFromGallery() async {
    try {
      // 開啟相簿讓使用者選擇照片
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, // 指定使用相簿
        imageQuality: 80,
      );

      // 如果使用者沒有選擇照片，就回傳 null
      if (image == null) return null;

      // 將選擇的照片轉換成 File 格式
      return File(image.path);
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }
}
