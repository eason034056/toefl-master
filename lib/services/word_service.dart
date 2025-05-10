import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/word.dart';

class WordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'words';

  Future<void> updateWord(Word word) async {
    try {
      print('WordService: Updating word with ID: ${word.id}');
      print('WordService: Word data: ${word.toJson()}');

      // 檢查 word.id 是否為空
      if (word.id.isEmpty) {
        throw Exception('Word ID cannot be empty');
      }

      // 檢查文件是否存在
      final docRef = _firestore.collection(_collection).doc(word.id);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        print('WordService: Document does not exist, creating new document');
        await docRef.set(word.toJson());
      } else {
        print('WordService: Document exists, updating...');
        await docRef.update(word.toJson());
      }

      print('WordService: Word updated successfully');
    } catch (e) {
      print('WordService: Error updating word: $e');
      throw Exception('Failed to update word: $e');
    }
  }

  Future<Word?> getWord(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('Word ID cannot be empty');
      }

      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Word.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('WordService: Error getting word: $e');
      throw Exception('Failed to get word: $e');
    }
  }
}
