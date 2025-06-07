import 'package:flutter/material.dart';
import '../../models/word_collection.dart';
import '../../models/user.dart';
import '../../models/word.dart';
import '../../providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'word_list_screen.dart';
import '../../services/user_service.dart';
import '../../services/spaced_review_service.dart';

class CollectionListScreen extends StatefulWidget {
  final List<WordCollection> collections;
  final Function(List<WordCollection>, Map<String, UserWordProgress>) onCollectionsUpdated;
  final bool isSystemCollection;

  const CollectionListScreen({
    super.key,
    required this.collections,
    required this.onCollectionsUpdated,
    required this.isSystemCollection,
  });

  @override
  State<CollectionListScreen> createState() => _CollectionListScreenState();
}

class _CollectionListScreenState extends State<CollectionListScreen> {
  late List<WordCollection> _collections;

  @override
  void initState() {
    super.initState();
    _collections = List.from(widget.collections);
    print('CollectionListScreen initialized with ${_collections.length} collections');
  }

  Future<void> _toggleFavorite(WordCollection collection) async {
    print('=== Toggle Favorite Debug ===');
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) {
      print('Error: User is null');
      return;
    }

    try {
      print('=== User Data Before Toggle ===');
      print('User ID: ${user.id}');
      print('Current saved collections: ${user.savedCollections.length}');
      print('Current word progress count: ${user.wordProgress.length}');
      print('Current updatedAt: ${user.updatedAt}');
      print('Word progress details:');
      user.wordProgress.forEach((wordId, progress) {
        print('  - Word $wordId: lastReview=${progress.lastReviewDate}, nextReview=${progress.nextReviewDate}');
      });
      print('Collection to toggle: ${collection.id} - ${collection.name}');
      print('Collection words count: ${collection.words.length}');

      // 1. 準備更新的資料
      final isCurrentlyFavorite = user.savedCollections.any((c) => c.id == collection.id);
      final updatedCollections = List<WordCollection>.from(user.savedCollections);
      final updatedWordProgress = Map<String, UserWordProgress>.from(user.wordProgress);

      print('Is currently favorite: $isCurrentlyFavorite');

      // 2. 更新收藏列表
      if (isCurrentlyFavorite) {
        updatedCollections.removeWhere((c) => c.id == collection.id);
        // 移除相關單字的學習進度
        for (var word in collection.words) {
          updatedWordProgress.remove(word.id);
        }
        print('Removed collection and its word progress');
      } else {
        updatedCollections.add(collection);

        // 3. 如果是新增收藏，為每個單字創建學習進度
        final now = DateTime.now();
        for (var i = 0; i < collection.words.length; i++) {
          final word = collection.words[i];
          if (!updatedWordProgress.containsKey(word.id)) {
            final progress = SpacedReviewService.assignInitialReviewDate(
              UserWordProgress(
                userId: user.id,
                wordId: word.id,
                createdAt: now,
                updatedAt: now,
              ),
              i,
              collection.words.length,
              5,
            );
            updatedWordProgress[word.id] = progress;
          }
        }
        print('Added collection and initialized word progress');
      }

      // 4. 創建完整的更新用戶資料（只用於本地狀態）
      final updatedUser = user.copyWith(
        savedCollections: updatedCollections,
        wordProgress: updatedWordProgress,
        updatedAt: DateTime.now(),
      );

      print('=== User Data After Local Update ===');
      print('Updated saved collections: ${updatedUser.savedCollections.length}');
      print('Updated word progress count: ${updatedUser.wordProgress.length}');
      print('Updated updatedAt: ${updatedUser.updatedAt}');
      print('Updated word progress details:');
      updatedUser.wordProgress.forEach((wordId, progress) {
        print('  - Word $wordId: lastReview=${progress.lastReviewDate}, nextReview=${progress.nextReviewDate}');
      });
      print('Updated collections IDs: ${updatedUser.savedCollections.map((c) => c.id).join(', ')}');

      // 5. 更新本地 Provider 狀態
      await userProvider.setUser(updatedUser);
      print('✅ Local user data updated successfully');

      // 6. 通知父組件更新（傳遞 collections 和 wordProgress）
      widget.onCollectionsUpdated(updatedCollections, updatedWordProgress);
      print('=== End Toggle Favorite Debug ===');
    } catch (e) {
      print('❌ Error updating collections: $e');
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
        title: Text(widget.isSystemCollection ? '系統單字集' : '我的收藏'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          if (user == null) {
            print('Error: User is null in build method');
            return const SizedBox.shrink();
          }

          print('Building list with ${_collections.length} collections');
          print('User has ${user.savedCollections.length} saved collections');

          return ListView.builder(
            itemCount: _collections.length,
            itemBuilder: (context, index) {
              final collection = _collections[index];
              final isFavorite = user.savedCollections.any((c) => c.id == collection.id);
              print('Collection ${collection.name}: isFavorite = $isFavorite');

              return ListTile(
                title: Text(collection.name),
                subtitle: Text(collection.description),
                trailing: widget.isSystemCollection
                    ? IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () => _toggleFavorite(collection),
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WordListScreen(
                        words: collection.words,
                        collections: _collections,
                        onWordUpdated: (updatedWord) {
                          setState(() {
                            final collectionIndex = _collections.indexWhere((c) => c.id == collection.id);
                            if (collectionIndex != -1) {
                              final wordIndex = _collections[collectionIndex].words.indexWhere((w) => w.id == updatedWord.id);
                              if (wordIndex != -1) {
                                final updatedWords = List<Word>.from(_collections[collectionIndex].words);
                                updatedWords[wordIndex] = updatedWord;
                                _collections[collectionIndex] = _collections[collectionIndex].copyWith(words: updatedWords);
                                widget.onCollectionsUpdated(_collections, user.wordProgress);
                              }
                            }
                          });
                        },
                        onCollectionsUpdated: widget.onCollectionsUpdated,
                        title: collection.name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
