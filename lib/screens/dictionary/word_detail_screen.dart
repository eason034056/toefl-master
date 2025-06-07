import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/word.dart';
import '../../models/word_collection.dart';
import '../../providers/user_provider.dart';
import '../../services/spaced_review_service.dart';

class WordDetailScreen extends StatefulWidget {
  final Word word;
  final List<WordCollection> collections;
  final Function(Word) onWordUpdated;
  final Function(List<WordCollection>, Map<String, UserWordProgress>) onCollectionsUpdated;

  const WordDetailScreen({
    super.key,
    required this.word,
    required this.collections,
    required this.onWordUpdated,
    required this.onCollectionsUpdated,
  });

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  late Word _word;
  bool _isFavorite = false;
  late UserProvider _userProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userProvider = Provider.of<UserProvider>(context);
    _checkFavoriteStatus();
  }

  @override
  void initState() {
    super.initState();
    _word = widget.word;
    print('=== WordDetailScreen initState ===');
    print('Word: ${_word.word}');
    print('Collections count: ${widget.collections.length}');
  }

  @override
  void dispose() {
    print('=== WordDetailScreen dispose ===');
    print('Word: ${_word.word}');
    super.dispose();
  }

  void _checkFavoriteStatus() {
    final user = _userProvider.user;
    if (user != null) {
      setState(() {
        _isFavorite = user.savedCollections.any((collection) => collection.words.any((word) => word.id == _word.id));
      });
    }
  }

  void _toggleFavorite() async {
    print('=== Toggle Favorite in WordDetail ===');
    final user = _userProvider.user;
    if (user == null) {
      print('Error: User is null');
      return;
    }

    try {
      print('User ID: ${user.id}');
      print('Current saved collections: ${user.savedCollections.length}');
      print('Current word progress count: ${user.wordProgress.length}');
      print('Current updatedAt: ${user.updatedAt}');

      // 1. 準備更新的資料
      final updatedCollections = List<WordCollection>.from(user.savedCollections);
      final updatedWordProgress = Map<String, UserWordProgress>.from(user.wordProgress);

      // 2. 更新收藏狀態
      if (_isFavorite) {
        // 移除收藏
        // 從個人收藏單字集中移除單字
        final personalCollection = updatedCollections.firstWhere(
          (collection) => collection.id == 'user_favorites_${user.id}',
          orElse: () => WordCollection(
            id: 'user_favorites_${user.id}',
            name: '個人收藏',
            description: '我收藏的單字',
            words: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        if (personalCollection.words.any((word) => word.id == _word.id)) {
          final updatedWords = personalCollection.words.where((word) => word.id != _word.id).toList();
          final updatedCollection = personalCollection.copyWith(
            words: updatedWords,
            updatedAt: DateTime.now(),
          );

          final index = updatedCollections.indexWhere((c) => c.id == 'user_favorites_${user.id}');
          if (index != -1) {
            updatedCollections[index] = updatedCollection;
          }
        }

        // 移除相關單字的學習進度
        updatedWordProgress.remove(_word.id);
        print('Removed word from personal collection and word progress');
      } else {
        // 新增收藏
        // 找到或創建個人收藏單字集
        var personalCollection = updatedCollections.firstWhere(
          (collection) => collection.id == 'user_favorites_${user.id}',
          orElse: () => WordCollection(
            id: 'user_favorites_${user.id}',
            name: '個人收藏',
            description: '我收藏的單字',
            words: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        // 如果單字不在個人收藏中，則添加
        if (!personalCollection.words.any((word) => word.id == _word.id)) {
          final updatedWords = List<Word>.from(personalCollection.words)..add(_word);
          personalCollection = personalCollection.copyWith(
            words: updatedWords,
            updatedAt: DateTime.now(),
          );

          // 更新或添加個人收藏單字集
          final index = updatedCollections.indexWhere((c) => c.id == 'user_favorites_${user.id}');
          if (index != -1) {
            updatedCollections[index] = personalCollection;
          } else {
            updatedCollections.add(personalCollection);
          }

          // 為單字創建學習進度
          final now = DateTime.now();
          final progress = SpacedReviewService.assignInitialReviewDate(
            UserWordProgress(
              userId: user.id,
              wordId: _word.id,
              createdAt: now,
              updatedAt: now,
            ),
            0,
            1,
            5,
          );
          updatedWordProgress[_word.id] = progress;
          print('Added word to personal collection and initialized word progress');
        }
      }

      // 3. 更新本地狀態
      setState(() {
        _isFavorite = !_isFavorite;
      });

      // 4. 更新 Firestore
      final updatedUser = user.copyWith(
        savedCollections: updatedCollections,
        wordProgress: updatedWordProgress,
        updatedAt: DateTime.now(),
      );
      await _userProvider.updateUser(updatedUser);
      print('✅ Firestore updated successfully');

      // 5. 通知父組件
      print('Notifying parent widget');
      widget.onCollectionsUpdated(updatedCollections, updatedWordProgress);
      print('=== End Toggle Favorite in WordDetail ===');
    } catch (e) {
      print('❌ Error toggling favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新收藏失敗：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_word.word),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            print('=== WordDetailScreen back button pressed ===');
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: Colors.amber,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 圖片區域
            if (_word.imageUrl != null)
              LayoutBuilder(builder: (context, constraints) {
                return Image.network(
                  _word.imageUrl!,
                  width: constraints.maxWidth,
                  height: constraints.maxWidth,
                  fit: BoxFit.cover,
                );
              }),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 單字和音標
                  Row(
                    children: [
                      Text(
                        _word.word,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        _word.phonetic,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () {
                          // 播放發音功能
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 所有詞性與解釋
                  ..._word.meanings.map((meaning) => Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 詞性和解釋
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  meaning.partOfSpeech,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '• ${meaning.definition}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            if (meaning.example != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      meaning.example!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    if (meaning.exampleTranslation != null)
                                      Text(
                                        meaning.exampleTranslation!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
