import 'package:flutter/material.dart';
import '../../models/word.dart';
import '../../models/word_collection.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'word_detail_screen.dart';
import 'package:intl/intl.dart'; // 新增日期格式化套件

class WordListScreen extends StatefulWidget {
  final List<Word> words;
  final String? title;
  final List<WordCollection> collections;
  final Function(Word) onWordUpdated;
  final Function(List<WordCollection>) onCollectionsUpdated;

  const WordListScreen({
    super.key,
    required this.words,
    required this.collections,
    required this.onWordUpdated,
    required this.onCollectionsUpdated,
    this.title,
  });

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  late List<Word> _words;
  late User _user;
  final DateFormat _dateFormat = DateFormat('yyyy/MM/dd'); // 設定日期格式

  @override
  void initState() {
    super.initState();
    _words = List.from(widget.words); // 複製一份，避免直接改到外部資料
    _user = Provider.of<UserProvider>(context, listen: false).user!;
  }

  // 取得單字的學習進度
  UserWordProgress? _getWordProgress(Word word) {
    return _user.wordProgress[word.id];
  }

  // 格式化日期顯示
  String _formatDate(DateTime? date) {
    if (date == null) return '尚未複習';
    return _dateFormat.format(date);
  }

  void _onWordUpdated(Word updatedWord) {
    setState(() {
      final index = _words.indexWhere((w) => w.id == updatedWord.id);
      if (index != -1) {
        _words[index] = updatedWord;
      }
    });
    widget.onWordUpdated(updatedWord);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'All Words'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _words.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final word = _words[index];
          final progress = _getWordProgress(word);
          return ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  word.word,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    value: progress?.masteryLevel ?? 0.0,
                    backgroundColor: Colors.grey[200],
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(word.phonetic),
                const SizedBox(height: 4),
                // 顯示所有詞性和解釋
                ...word.meanings
                    .map((meaning) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  meaning.partOfSpeech,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      meaning.definition,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '上次複習：${_formatDate(progress?.lastReviewDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '下次複習：${_formatDate(progress?.nextReviewDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WordDetailScreen(
                    word: word,
                    collections: widget.collections,
                    onWordUpdated: _onWordUpdated,
                    onCollectionsUpdated: widget.onCollectionsUpdated,
                  ),
                ),
              );
              if (result is Word) {
                _onWordUpdated(result);
              }
            },
          );
        },
      ),
    );
  }
}
