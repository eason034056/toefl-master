import 'package:flutter/material.dart';
import '../../models/word.dart';

class WordDetailScreen extends StatefulWidget {
  final Word word;

  const WordDetailScreen({
    super.key,
    required this.word,
  });

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.word.isFavorite; // 一開始用 Word 的收藏狀態
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.word.word),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 圖片區域
            if (widget.word.imageUrl != null)
              Image.network(
                widget.word.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 單字和音標
                  Row(
                    children: [
                      Text(
                        widget.word.word,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            isFavorite = !isFavorite; // 切換狀態
                            if (!isFavorite) {
                              // 用 copyWith 產生新的 Word 物件
                              final updatedWord = widget.word.copyWith(isFavorite: false);
                              Navigator.pop(context, updatedWord); // 把新物件傳回去
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        widget.word.phonetic,
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
                  ...widget.word.meanings.map((meaning) => Padding(
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
