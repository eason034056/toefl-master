import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/word.dart';
import '../../models/word_collection.dart';
import '../../providers/user_provider.dart';

class WordDetailScreen extends StatefulWidget {
  final Word word;
  final List<WordCollection> collections;
  final Function(Word) onWordUpdated;
  final Function(List<WordCollection>) onCollectionsUpdated;

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

  void _toggleFavorite() {
    print('=== Toggle Favorite in WordDetail ===');
    final user = _userProvider.user;
    if (user == null) {
      print('Error: User is null');
      return;
    }

    print('Current saved collections: ${user.savedCollections.length}');

    setState(() {
      _isFavorite = !_isFavorite;
    });

    // 更新用戶的收藏狀態
    final updatedCollections = List<WordCollection>.from(user.savedCollections);
    if (_isFavorite) {
      print('Adding word to favorites');
      // 找到或創建個人收藏單字集
      var personalCollection = updatedCollections.firstWhere(
        (collection) => collection.id == 'user_favorites',
        orElse: () => WordCollection(
          id: 'user_favorites',
          name: '個人收藏',
          description: '我收藏的單字',
          words: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (!personalCollection.words.any((word) => word.id == _word.id)) {
        final updatedWords = List<Word>.from(personalCollection.words)..add(_word);
        personalCollection = personalCollection.copyWith(
          words: updatedWords,
          updatedAt: DateTime.now(),
        );

        if (!updatedCollections.any((c) => c.id == 'user_favorites')) {
          updatedCollections.add(personalCollection);
        } else {
          final index = updatedCollections.indexWhere((c) => c.id == 'user_favorites');
          updatedCollections[index] = personalCollection;
        }
      }
    } else {
      print('Removing word from favorites');
      // 從所有收藏單字集中移除該單字
      for (var i = 0; i < updatedCollections.length; i++) {
        final collection = updatedCollections[i];
        if (collection.words.any((word) => word.id == _word.id)) {
          final updatedWords = collection.words.where((word) => word.id != _word.id).toList();
          updatedCollections[i] = collection.copyWith(
            words: updatedWords,
            updatedAt: DateTime.now(),
          );
        }
      }
    }

    print('Updated collections count: ${updatedCollections.length}');

    // 更新用戶資料
    final updatedUser = user.copyWith(
      savedCollections: updatedCollections,
    );

    print('Updating user provider');
    _userProvider.updateUser(updatedUser);

    print('Notifying parent widget');
    widget.onCollectionsUpdated(updatedCollections);
    print('=== End Toggle Favorite in WordDetail ===');
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
