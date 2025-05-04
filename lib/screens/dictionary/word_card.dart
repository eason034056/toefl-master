import 'package:flutter/material.dart';
import 'word_detail_screen.dart';
import '../../models/word.dart';

class WordCard extends StatelessWidget {
  final Word word;
  final double? dragOffset;
  final double swipeThreshold;

  const WordCard({
    super.key,
    required this.word,
    this.dragOffset,
    this.swipeThreshold = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    final double swipeProgress = (dragOffset ?? 0) / swipeThreshold;
    final bool isSwipingRight = dragOffset != null && dragOffset! > 0;
    final bool isSwipingLeft = dragOffset != null && dragOffset! < 0;

    final Color overlayColor = isSwipingRight
        ? Colors.green.withOpacity(swipeProgress.abs().clamp(0.0, 1.0))
        : isSwipingLeft
            ? Colors.grey.withOpacity(swipeProgress.abs().clamp(0.0, 1.0))
            : Colors.transparent;

    final String? statusText = isSwipingRight && swipeProgress > 0.5
        ? 'Learned'
        : isSwipingLeft && swipeProgress.abs() > 0.5
            ? 'Still Learning'
            : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WordDetailScreen(
              word: word,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 圖片區域（1:1 比例）
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      color: Colors.grey[100],
                    ),
                    child: word.imageUrl != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: Image.network(
                              word.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: TextButton(
                              onPressed: () {
                                // 生成圖片的功能
                              },
                              style: TextButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                              child: const Text(
                                'Generate Image',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),

                // 單字主體區域
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 單字和音標區
                      Text(
                        word.word,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            word.phonetic,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.volume_up, size: 20),
                            onPressed: () {
                              // 播放發音功能
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // 所有詞性和解釋
                      ...word.meanings.map((meaning) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 詞性標籤
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  meaning.partOfSpeech,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // 解釋
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  ' ${meaning.definition}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (dragOffset != null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: overlayColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          if (statusText != null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
