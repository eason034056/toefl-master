import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stats_card.dart';
import 'word_card.dart';
import '../../models/word.dart';
import '../../models/word_collection.dart';
import '../../services/spaced_review_service.dart';
import '../../services/word_service.dart';
import 'word_list_screen.dart';
import 'collection_list_screen.dart';
import 'dart:math';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../providers/user_provider.dart';
import '../../data/mock_data.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  List<Word> _words = [];
  List<Word> _todayReviewWords = [];
  List<Word> _todayLearnedWords = [];
  List<WordCollection> _systemCollections = []; // 系統提供的單字集
  final double _swipeThreshold = 100.0;
  double _dragOffset = 0.0;
  final WordService _wordService = WordService();
  final UserService _userService = UserService();
  bool _isGeneratingImage = false;
  int _dailyNewWords = 5;

  @override
  void initState() {
    super.initState();
    _systemCollections = systemCollections; // 使用假資料中的系統單字集
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // 用 Provider 取得目前用戶 ID
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) return;

    setState(() {
      // 合併系統單字集和用戶收藏的單字集
      final allCollections = [..._systemCollections, ...user.savedCollections];
      _words = _getAllWordsFromCollections(allCollections);
      _updateTodayReviewWords();
      _todayLearnedWords = [];
    });
  }

  List<Word> _getAllWordsFromCollections(List<WordCollection> collections) {
    final Set<String> seenWordIds = {};
    final List<Word> allWords = [];

    for (final collection in collections) {
      for (final word in collection.words) {
        if (!seenWordIds.contains(word.id)) {
          seenWordIds.add(word.id);
          allWords.add(word);
        }
      }
    }

    return allWords;
  }

  void _updateTodayReviewWords() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 從所有單字中找出今天需要複習的單字
    _todayReviewWords = _words.where((word) {
      final progress = user.wordProgress[word.id];
      if (progress == null) return false;

      final nextReview = progress.nextReviewDate;
      if (nextReview == null) return false;

      final reviewDate = DateTime(
        nextReview.year,
        nextReview.month,
        nextReview.day,
      );

      return reviewDate.isAtSameMomentAs(today);
    }).toList();

    // 根據複習優先級排序
    _todayReviewWords.sort((a, b) {
      final progressA = user.wordProgress[a.id];
      final progressB = user.wordProgress[b.id];
      if (progressA == null || progressB == null) return 0;

      return SpacedReviewService.calculateReviewPriority(progressB).compareTo(SpacedReviewService.calculateReviewPriority(progressA));
    });
  }

  // 新增設定每日新單字數量的方法
  void _showDailyNewWordsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('設定每日新單字數量'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('目前設定：$_dailyNewWords 個單字/天'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (_dailyNewWords > 1) {
                      setState(() {
                        _dailyNewWords--;
                      });
                    }
                  },
                ),
                Text(
                  '$_dailyNewWords',
                  style: const TextStyle(fontSize: 20),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _dailyNewWords++;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 更新單字的複習時間
              setState(() {
                _words = _getAllWordsFromCollections(_systemCollections);
                _updateTodayReviewWords();
              });
              Navigator.pop(context);
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _onSwipe(DragEndDetails details, Word word) {
    if (_isGeneratingImage) return;

    if (details.primaryVelocity == null) return;

    if (details.primaryVelocity! > _swipeThreshold) {
      // 右滑：標記為已熟練
      setState(() {
        final wordIndex = _words.indexWhere((w) => w.id == word.id);
        if (wordIndex != -1) {
          final userId = Provider.of<UserProvider>(context, listen: false).user?.id ?? 'current_user_id';
          final progress = UserWordProgress(
            wordId: word.id,
            userId: userId,
            learningStage: 0,
            masteryLevel: 0.0,
            reviewCount: 0,
            lastReviewDate: DateTime.now(),
            nextReviewDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          final updatedProgress = SpacedReviewService.updateWordAfterReview(
            word: progress,
            isCorrect: true,
          );
          // 更新單字資訊
          final updatedWord = word.copyWith(
              // 這裡需要根據 UserWordProgress 的資訊更新 Word
              // 暫時保持原樣，因為 Word 類別目前沒有學習進度相關的欄位
              );
          _words[wordIndex] = updatedWord;
          if (!_todayLearnedWords.any((w) => w.id == updatedWord.id)) {
            _todayLearnedWords.add(updatedWord);
          }
        }
        _todayReviewWords.remove(word);
      });
    } else if (details.primaryVelocity! < -_swipeThreshold) {
      // 左滑：重新排入複習堆疊
      setState(() {
        _todayReviewWords.remove(word);
        _todayReviewWords.insert(0, word);
      });
    }
  }

  void _onWordUpdated(Word updatedWord) {
    setState(() {
      // 更新單字列表中的單字
      final wordIndex = _words.indexWhere((w) => w.id == updatedWord.id);
      if (wordIndex != -1) {
        _words[wordIndex] = updatedWord;
      }

      // 更新單字集中的單字
      for (var i = 0; i < _systemCollections.length; i++) {
        final collection = _systemCollections[i];
        final wordIndex = collection.words.indexWhere((w) => w.id == updatedWord.id);
        if (wordIndex != -1) {
          final updatedWords = List<Word>.from(collection.words);
          updatedWords[wordIndex] = updatedWord;
          _systemCollections[i] = collection.copyWith(words: updatedWords);
        }
      }

      // 更新今日複習單字
      _updateTodayReviewWords();
    });
  }

  void _onCollectionsUpdated(List<WordCollection> updatedCollections) async {
    print('=== Collection Update Callback in DictionaryScreen ===');
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) {
      print('Error: User is null when updating collections');
      return;
    }

    try {
      print('Current user collections: ${user.savedCollections.length}');
      print('Updated collections: ${updatedCollections.length}');

      // 更新用戶收藏的單字集
      await _userService.updateSavedCollections(user.id, updatedCollections);

      setState(() {
        // 更新 Provider 中的用戶數據
        final updatedUser = user.copyWith(
          savedCollections: updatedCollections,
        );
        userProvider.updateUser(updatedUser);

        // 重新計算所有單字
        _words = _getAllWordsFromCollections([..._systemCollections, ...updatedCollections]);
        _updateTodayReviewWords();

        print('Updated total words: ${_words.length}');
        print('Updated today review words: ${_todayReviewWords.length}');
      });
    } catch (e) {
      print('Error updating collections: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating collections: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    // 計算用戶收藏的單字總數，保持原有順序
    final totalSavedWords = user?.savedCollections.fold<int>(
          0,
          (sum, collection) => sum + collection.words.length,
        ) ??
        0;

    print('=== Building DictionaryScreen ===');
    print('User saved collections: ${user?.savedCollections.length ?? 0}');
    print('Total saved words: $totalSavedWords');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      "Vocabulary",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: _showDailyNewWordsDialog,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          print('=== Opening System Collections ===');
                          // 顯示所有系統提供的單字集
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CollectionListScreen(
                                collections: _systemCollections,
                                onCollectionsUpdated: (updatedCollections) {
                                  print('=== Collection Update Callback ===');
                                  print('Updated collections count: ${updatedCollections.length}');
                                  // 更新用戶收藏的單字集
                                  setState(() {
                                    if (user != null) {
                                      print('Updating user with new collections');
                                      final updatedUser = user.copyWith(
                                        savedCollections: updatedCollections,
                                      );
                                      userProvider.updateUser(updatedUser);
                                      print('User updated with ${updatedCollections.length} collections');
                                    } else {
                                      print('Error: User is null when updating collections');
                                    }
                                  });
                                },
                                isSystemCollection: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              // 統計數據區域
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 顯示用戶收藏的單字集
                        if (user != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CollectionListScreen(
                                collections: user.savedCollections,
                                onCollectionsUpdated: (updatedCollections) {
                                  setState(() {
                                    final updatedUser = user.copyWith(
                                      savedCollections: updatedCollections,
                                    );
                                    userProvider.updateUser(updatedUser);
                                  });
                                },
                                isSystemCollection: false,
                              ),
                            ),
                          );
                        }
                      },
                      child: StatsCard(
                        title: "Collections",
                        count: totalSavedWords,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WordListScreen(
                              words: _todayReviewWords,
                              collections: _systemCollections,
                              onWordUpdated: _onWordUpdated,
                              onCollectionsUpdated: _onCollectionsUpdated,
                              title: 'Today\'s Review',
                            ),
                          ),
                        );
                      },
                      child: StatsCard(
                        title: "Today",
                        count: _todayReviewWords.length,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WordListScreen(
                              words: _todayLearnedWords,
                              collections: _systemCollections,
                              onWordUpdated: _onWordUpdated,
                              onCollectionsUpdated: _onCollectionsUpdated,
                              title: 'Today\'s Learned',
                            ),
                          ),
                        );
                      },
                      child: StatsCard(
                        title: "Learned",
                        count: _todayLearnedWords.length,
                      ),
                    ),
                  ),
                ],
              ),

              // 單字卡堆疊區域
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 顯示最上面的3張卡片，反轉順序讓最上面的卡片最後渲染
                      for (int i = max(0, _todayReviewWords.length - 3); i < _todayReviewWords.length; i++)
                        Positioned(
                          top: (i - (_todayReviewWords.length - 3)) * 20.0,
                          child: GestureDetector(
                            onHorizontalDragStart: (details) {
                              if (_isGeneratingImage) return;
                              setState(() {
                                _dragOffset = 0.0;
                              });
                            },
                            onHorizontalDragUpdate: (details) {
                              if (_isGeneratingImage) return;
                              if (i == _todayReviewWords.length - 1) {
                                setState(() {
                                  _dragOffset += details.delta.dx;
                                });
                              }
                            },
                            onHorizontalDragEnd: (details) {
                              if (_isGeneratingImage) return;
                              if (i == _todayReviewWords.length - 1) {
                                _onSwipe(details, _todayReviewWords[i]);
                                setState(() {
                                  _dragOffset = 0.0;
                                });
                              }
                            },
                            child: Transform.scale(
                              scale: 1 - (_todayReviewWords.length - 1 - i) * 0.05,
                              child: Transform.rotate(
                                angle: i == _todayReviewWords.length - 1 ? (_dragOffset / 1000) : 0.0,
                                child: Opacity(
                                  opacity: i == _todayReviewWords.length - 1 ? 1.0 : 1 - (_todayReviewWords.length - 1 - i) * 0.2,
                                  child: Transform.translate(
                                    offset: i == _todayReviewWords.length - 1 ? Offset(_dragOffset, 0) : Offset.zero,
                                    child: i == _todayReviewWords.length - 1
                                        ? GestureDetector(
                                            onHorizontalDragStart: (details) {
                                              if (_isGeneratingImage) return;
                                              setState(() {
                                                _dragOffset = 0.0;
                                              });
                                            },
                                            onHorizontalDragUpdate: (details) {
                                              if (_isGeneratingImage) return;
                                              setState(() {
                                                _dragOffset += details.delta.dx;
                                              });
                                            },
                                            onHorizontalDragEnd: (details) {
                                              if (_isGeneratingImage) return;
                                              _onSwipe(details, _todayReviewWords[i]);
                                              setState(() {
                                                _dragOffset = 0.0;
                                              });
                                            },
                                            child: WordCard(
                                              word: _todayReviewWords[i],
                                              dragOffset: _dragOffset,
                                              swipeThreshold: _swipeThreshold,
                                              collections: _systemCollections,
                                              onWordUpdated: (updatedWord) async {
                                                try {
                                                  await _wordService.updateWord(updatedWord);
                                                  setState(() {
                                                    _todayReviewWords[i] = updatedWord;
                                                  });
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Error updating word: $e')),
                                                  );
                                                }
                                              },
                                              onCollectionsUpdated: _onCollectionsUpdated,
                                              onGeneratingChanged: (isGenerating) {
                                                setState(() {
                                                  _isGeneratingImage = isGenerating;
                                                });
                                              },
                                            ),
                                          )
                                        : WordCard(
                                            word: _todayReviewWords[i],
                                            dragOffset: null,
                                            swipeThreshold: _swipeThreshold,
                                            collections: _systemCollections,
                                            onWordUpdated: (updatedWord) async {
                                              try {
                                                await _wordService.updateWord(updatedWord);
                                                setState(() {
                                                  _todayReviewWords[i] = updatedWord;
                                                });
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Error updating word: $e')),
                                                );
                                              }
                                            },
                                            onCollectionsUpdated: _onCollectionsUpdated,
                                            onGeneratingChanged: (isGenerating) {
                                              setState(() {
                                                _isGeneratingImage = isGenerating;
                                              });
                                            },
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (_todayReviewWords.isEmpty)
                        const Center(
                          child: Text(
                            '今天的單字都複習完了！',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
