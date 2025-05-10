import 'package:flutter/material.dart';
import '../../models/word.dart';
import 'word_detail_screen.dart';

class WordListScreen extends StatefulWidget {
  final List<Word> words;
  final String? title;

  const WordListScreen({
    super.key,
    required this.words,
    this.title,
  });

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  late List<Word> _words;

  @override
  void initState() {
    super.initState();
    _words = List.from(widget.words); // 複製一份，避免直接改到外部資料
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
          return ListTile(
            title: Text(
              word.word,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(word.phonetic),
                Text(
                  word.meanings.first.definition,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: CircularProgressIndicator(
              value: word.masteryLevel,
              backgroundColor: Colors.grey[200],
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WordDetailScreen(
                    word: word,
                  ),
                ),
              );
              // 如果 result 是 Word 物件且 isFavorite 為 false，移除
              if (result is Word && !result.isFavorite) {
                setState(() {
                  _words.removeWhere((w) => w.id == result.id);
                });
                // 回傳有變動的訊號給上一層
                Navigator.pop(context, true);
              }
            },
          );
        },
      ),
    );
  }
}
