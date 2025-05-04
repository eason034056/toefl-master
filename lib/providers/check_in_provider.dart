import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/camera_service.dart';
import '../services/storage_service.dart';
import '../models/check_in_status.dart';

class CheckInProvider extends ChangeNotifier {
  final CameraService _cameraService = CameraService();
  final StorageService _storageService = StorageService();
  CheckInStatus _status = CheckInStatus();
  File? _currentPhoto; // 儲存當前拍攝的照片

  // 獲取當前照片
  File? get currentPhoto => _currentPhoto;

  // 獲取當前狀態
  CheckInStatus get status => _status;

  // 檢查今天是否已打卡
  bool get isTodayCheckedIn {
    if (_status.lastCheckIn == null) return false;

    final now = DateTime.now();
    final lastCheck = _status.lastCheckIn!;
    return now.year == lastCheck.year && now.month == lastCheck.month && now.day == lastCheck.day;
  }

  // 添加上傳狀態
  bool _isUploading = false;
  String _uploadProgress = '';
  String? _errorMessage;

  bool get isUploading => _isUploading;
  String get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;

  // 重設狀態
  void _resetState() {
    _isUploading = false;
    _uploadProgress = '';
    _errorMessage = null;
    notifyListeners();
  }

  // 更新上傳進度
  void _updateProgress(String progress) {
    _uploadProgress = progress;
    notifyListeners();
  }

  Future<bool> _uploadPhotoAndCheckIn(File photo) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 檢查網絡連接
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw Exception('No internet connection');
      }

      // 上傳照片
      final photoUrl = await _storageService.uploadImage(
        photo,
        maxRetries: 3,
      );

      // 更新打卡狀態
      await checkIn(photoUrl);

      _resetState();
      return true;
    } catch (e) {
      print('Error in _uploadPhotoAndCheckIn: $e');
      _errorMessage = _getErrorMessage(e);
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('No internet connection')) {
      return '網路連接失敗，請檢查網路後重試';
    } else if (error.toString().contains('file too large')) {
      return '照片檔案太大，請選擇較小的照片';
    } else {
      return '上傳失敗，請稍後重試';
    }
  }

  // 修改原有的拍照方法
  Future<bool> takeCheckInPhoto() async {
    try {
      final photo = await _cameraService.takePhoto();
      if (photo == null) return false;

      _currentPhoto = photo;
      return await _uploadPhotoAndCheckIn(photo);
    } catch (e) {
      print('Error in takeCheckInPhoto: $e');
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // 修改原有的相簿選擇方法
  Future<bool> pickPhotoFromGallery() async {
    try {
      final photo = await _cameraService.pickFromGallery();
      if (photo == null) return false;

      _currentPhoto = photo;
      return await _uploadPhotoAndCheckIn(photo);
    } catch (e) {
      print('Error in pickPhotoFromGallery: $e');
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // 更新原有的 checkIn 方法
  Future<void> checkIn(String photoUrl) async {
    if (isTodayCheckedIn) return;

    final now = DateTime.now();

    // 建立新的打卡活動
    final newActivity = CheckInActivity(
      timestamp: now,
      photoUrl: photoUrl,
      userName: 'Alex Smith', // 之後可以從用戶資料獲取
      userAvatar: 'https://i.pinimg.com/474x/a1/27/73/a1277303ec49ee936b2ba11bb3a98a18.jpg',
    );

    // 複製原有的活動列表並添加新活動
    final newActivities = List<CheckInActivity>.from(_status.activities)..add(newActivity);

    // 更新打卡狀態
    _status = _status.copyWith(
      hasCheckedIn: true,
      lastCheckIn: now,
      streakCount: _calculateNewStreakCount(now),
      checkedInDates: List<DateTime>.from(_status.checkedInDates)..add(now),
      lastPhotoUrl: photoUrl,
      activities: newActivities, // 更新活動列表
    );

    notifyListeners();
  }

  int _calculateNewStreakCount(DateTime now) {
    if (_status.lastCheckIn == null) return 1;

    final yesterday = now.subtract(const Duration(days: 1));
    return _status.lastCheckIn!.year == yesterday.year && _status.lastCheckIn!.month == yesterday.month && _status.lastCheckIn!.day == yesterday.day
        ? _status.streakCount + 1
        : 1;
  }
}
