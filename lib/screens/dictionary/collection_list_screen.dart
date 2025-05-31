import 'package:flutter/material.dart';
import '../../models/word_collection.dart';
import '../../models/user.dart';
import '../../models/word.dart';
import '../../providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'word_list_screen.dart';

class CollectionListScreen extends StatefulWidget {
  final List<WordCollection> collections;
  final Function(List<WordCollection>) onCollectionsUpdated;
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

    print('Current user saved collections: ${user.savedCollections.length}');
    print('Collection to toggle: ${collection.name} (${collection.id})');

    // 檢查是否已經收藏
    final isCurrentlyFavorite = user.savedCollections.any((c) => c.id == collection.id);
    print('Is currently favorite: $isCurrentlyFavorite');

    // 創建新的收藏列表
    final updatedCollections = List<WordCollection>.from(user.savedCollections);

    if (isCurrentlyFavorite) {
      print('Removing collection from favorites');
      updatedCollections.removeWhere((c) => c.id == collection.id);
    } else {
      print('Adding collection to favorites');
      updatedCollections.add(collection);
    }

    print('Updated collections count: ${updatedCollections.length}');

    // 更新用戶資料
    final updatedUser = user.copyWith(
      savedCollections: updatedCollections,
    );

    print('Updating user provider');
    // 更新 Provider
    userProvider.updateUser(updatedUser);

    print('Notifying parent widget');
    // 通知父組件更新
    widget.onCollectionsUpdated(updatedCollections);
    print('=== End Toggle Favorite Debug ===');
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
                                widget.onCollectionsUpdated(_collections);
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
