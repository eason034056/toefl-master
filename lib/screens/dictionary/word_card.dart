import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'word_detail_screen.dart';
import '../../models/word.dart';
import '../../models/word_collection.dart';

class WordCard extends StatefulWidget {
  final Word word;
  final double? dragOffset;
  final double swipeThreshold;
  final List<WordCollection> collections;
  final Function(Word) onWordUpdated;
  final Function(List<WordCollection>, Map<String, UserWordProgress>) onCollectionsUpdated;
  final Function(bool)? onGeneratingChanged;

  const WordCard({
    super.key,
    required this.word,
    required this.collections,
    this.dragOffset,
    this.swipeThreshold = 100.0,
    required this.onWordUpdated,
    required this.onCollectionsUpdated,
    this.onGeneratingChanged,
  });

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // OpenAI.apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  }

  Future<String?> _checkExistingImage() async {
    try {
      final storage = FirebaseStorage.instance;
      final wordImagesRef = storage.ref().child('word_images');

      // 列出所有以該單字開頭的圖片
      final result = await wordImagesRef.listAll();

      // 尋找以該單字開頭的圖片
      for (var item in result.items) {
        if (item.name.startsWith('${widget.word.word}_')) {
          // 找到圖片，返回下載 URL
          return await item.getDownloadURL();
        }
      }

      // 沒有找到圖片
      return null;
    } catch (e) {
      print('Error checking existing image: $e');
      return null;
    }
  }

  Future<void> _generateImage() async {
    if (_isGenerating) return;

    print('Generate Image button clicked for word: ${widget.word.word}');

    setState(() {
      _isGenerating = true;
    });

    // 通知父組件正在生成圖片
    widget.onGeneratingChanged?.call(true);

    try {
      // 先檢查是否已有圖片
      final existingImageUrl = await _checkExistingImage();
      if (existingImageUrl != null) {
        print('Found existing image: $existingImageUrl');

        final updatedWord = widget.word.copyWith(
          imageUrl: existingImageUrl,
        );

        try {
          await widget.onWordUpdated(updatedWord);
          print('Word updated successfully with existing image');
          return;
        } catch (e) {
          print('Error updating word with existing image: $e');
          throw Exception('Failed to update word with existing image: $e');
        }
      }

      // 如果沒有現有圖片，則生成新圖片
      print('No existing image found, generating new image...');
      final url = Uri.parse('http://localhost:8000/generate-image');
      final headers = {
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        "prompt":
            '''Create a aspect ratio 1:1 4-panel comic strip (2x2 layout) in black-and-white Notion style that explains the meaning of the English word "${widget.word.word}" through a simple visual story.
The illustration should use minimalist lines, simple characters, and clean backgrounds.
Each panel should contain a speech bubble or short caption in English that helps explain the word naturally through context.
The tone should be clear, light, and slightly humorous, designed to help students understand and remember the word.
All text must be in English.
Keep the entire layout clean, focused, and easy to follow.''',
        "word": widget.word.word
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['image_url'];
        print('Generated image URL: $imageUrl');

        final updatedWord = widget.word.copyWith(
          imageUrl: imageUrl,
        );

        print('Updating word in Firestore...');
        print('Word ID: ${updatedWord.id}');
        print('Word data: ${updatedWord.toJson()}');

        try {
          await widget.onWordUpdated(updatedWord);
          print('Word updated successfully in Firestore');
        } catch (e) {
          print('Error updating word in Firestore: $e');
          throw Exception('Failed to update word in Firestore: $e');
        }
      } else {
        throw Exception('Failed to generate image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in _generateImage: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating image: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
      // 通知父組件圖片生成完成
      widget.onGeneratingChanged?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double swipeProgress = (widget.dragOffset ?? 0) / widget.swipeThreshold;
    final bool isSwipingRight = widget.dragOffset != null && widget.dragOffset! > 0;
    final bool isSwipingLeft = widget.dragOffset != null && widget.dragOffset! < 0;

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
              word: widget.word,
              collections: widget.collections,
              onWordUpdated: widget.onWordUpdated,
              onCollectionsUpdated: widget.onCollectionsUpdated,
            ),
          ),
        );
      },
      child: Container(
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
                child: widget.word.imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(
                          widget.word.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildGenerateImageButton();
                          },
                        ),
                      )
                    : _buildGenerateImageButton(),
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
                    widget.word.word,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        widget.word.phonetic,
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
                  ...widget.word.meanings.map((meaning) => Row(
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
    );
  }

  Widget _buildGenerateImageButton() {
    return Center(
      child: TextButton(
        onPressed: _isGenerating ? null : _generateImage,
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.grey),
          ),
        ),
        child: _isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'Generate Image',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
