import 'package:flutter/material.dart';
import '../../models/word.dart';
import 'word_detail_screen.dart';

class WordListScreen extends StatelessWidget {
  final List<Word> words;
  final String? title;

  const WordListScreen({
    super.key,
    required this.words,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'All Words'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: words.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final word = words[index];
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
            onTap: () {
              // TODO: 導航到單字詳細頁面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WordDetailScreen(
                    word: word,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
