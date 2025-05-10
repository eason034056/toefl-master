import 'package:flutter/material.dart';
import 'stats_card.dart';
import 'word_card.dart';
import '../../models/word.dart';
import '../../services/spaced_review_service.dart';
import '../../services/word_service.dart';
import 'word_list_screen.dart';
import 'dart:math';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  late List<Word> _words;
  late List<Word> _todayReviewWords;
  late List<Word> _todayLearnedWords;
  final double _swipeThreshold = 100.0;
  double _dragOffset = 0.0;
  final WordService _wordService = WordService();

  @override
  void initState() {
    super.initState();
    _words = _getDemoWords();
    _todayReviewWords = _words.where((word) => SpacedReviewService.shouldReviewToday(word)).toList();
    _todayLearnedWords = [];
  }

  List<Word> _getDemoWords() {
    final allWords = [
      Word(
        id: '1',
        word: 'chic',
        phonetic: '/ʃiːk/',
        audioUrl: 'https://example.com/audio/chic.mp3',
        meanings: [
          WordMeaning(
            partOfSpeech: 'adj.',
            definition: '時髦的；有格調的',
            example: 'She always looks chic in black.',
            exampleTranslation: '她穿黑色總是看起來很時髦。',
          ),
          WordMeaning(
            partOfSpeech: 'n.',
            definition: '別致的人；時髦的人',
            example: 'The chic of Paris.',
            exampleTranslation: '巴黎的時尚人士。',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        reviewCount: 0,
        masteryLevel: 0.0,
        learningStage: 0,
        isFavorite: true,
      ),
      Word(
        id: '2',
        word: 'ephemeral',
        phonetic: '/ɪˈfem(ə)rəl/',
        audioUrl: 'https://example.com/audio/ephemeral.mp3',
        meanings: [
          WordMeaning(
            partOfSpeech: 'adj.',
            definition: '短暫的；瞬息的',
            example: 'Ephemeral pleasures of life',
            exampleTranslation: '生命中轉瞬即逝的快樂',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        reviewCount: 0,
        masteryLevel: 0.0,
        learningStage: 0,
        isFavorite: true,
      ),
      Word(
        id: '3',
        word: 'serendipity',
        phonetic: '/ˌserənˈdɪpəti/',
        audioUrl: 'https://example.com/audio/serendipity.mp3',
        meanings: [
          WordMeaning(
            partOfSpeech: 'n.',
            definition: '意外發現美好事物的能力；幸運',
            example: 'Finding this book was pure serendipity.',
            exampleTranslation: '找到這本書純屬幸運。',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        reviewCount: 0,
        masteryLevel: 0.0,
        learningStage: 0,
        isFavorite: true,
      ),
      Word(
        id: '4',
        word: 'ubiquitous',
        phonetic: '/juːˈbɪkwɪtəs/',
        audioUrl: 'https://example.com/audio/ubiquitous.mp3',
        meanings: [
          WordMeaning(
            partOfSpeech: 'adj.',
            definition: '無所不在的；普遍存在的',
            example: 'Mobile phones are ubiquitous in modern life.',
            exampleTranslation: '手機在現代生活中無處不在。',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        reviewCount: 0,
        masteryLevel: 0.0,
        learningStage: 0,
        isFavorite: true,
      ),
      Word(
        id: '5',
        word: 'mellifluous',
        phonetic: '/məˈlɪfluəs/',
        audioUrl: 'https://example.com/audio/mellifluous.mp3',
        meanings: [
          WordMeaning(
            partOfSpeech: 'adj.',
            definition: '(聲音)甜美的；悅耳的',
            example: 'Her mellifluous voice was perfect for radio.',
            exampleTranslation: '她甜美的聲音非常適合做廣播。',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        reviewCount: 0,
        masteryLevel: 0.0,
        learningStage: 0,
        isFavorite: true,
      ),
    ];
    // 只留下有收藏的單字
    return allWords.where((word) => word.isFavorite).toList();
  }

  void _onSwipe(DragEndDetails details, Word word) {
    if (details.primaryVelocity == null) return;

    if (details.primaryVelocity! > _swipeThreshold) {
      // 右滑：標記為已熟練
      setState(() {
        final wordIndex = _words.indexWhere((w) => w.id == word.id);
        if (wordIndex != -1) {
          final updatedWord = SpacedReviewService.updateWordAfterReview(
            word: word,
            isCorrect: true,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 頂部標題和按鈕保持不變...
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
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // 新增單字功能
                    },
                  ),
                ],
              ),

              // 統計數據區域
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WordListScreen(words: _words),
                          ),
                        );
                        if (result == true) {
                          setState(() {
                            _words = _getDemoWords();
                            _todayReviewWords = _words.where((word) => SpacedReviewService.shouldReviewToday(word)).toList();
                            print(_words);
                          });
                        }
                      },
                      child: StatsCard(
                        title: "Total",
                        count: _words.length,
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
                              setState(() {
                                _dragOffset = 0.0;
                              });
                            },
                            onHorizontalDragUpdate: (details) {
                              if (i == _todayReviewWords.length - 1) {
                                setState(() {
                                  _dragOffset += details.delta.dx;
                                });
                              }
                            },
                            onHorizontalDragEnd: (details) {
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
                                              setState(() {
                                                _dragOffset = 0.0;
                                              });
                                            },
                                            onHorizontalDragUpdate: (details) {
                                              setState(() {
                                                _dragOffset += details.delta.dx;
                                              });
                                            },
                                            onHorizontalDragEnd: (details) {
                                              _onSwipe(details, _todayReviewWords[i]);
                                              setState(() {
                                                _dragOffset = 0.0;
                                              });
                                            },
                                            child: WordCard(
                                              word: _todayReviewWords[i],
                                              dragOffset: _dragOffset,
                                              swipeThreshold: _swipeThreshold,
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
                                            ),
                                          )
                                        : WordCard(
                                            word: _todayReviewWords[i],
                                            dragOffset: null,
                                            swipeThreshold: _swipeThreshold,
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
