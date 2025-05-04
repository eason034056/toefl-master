import 'package:flutter/material.dart';
import '../../../models/reading_passage.dart';
import 'reading_passage_screen.dart';

class ReadingListScreen extends StatelessWidget {
  const ReadingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 返回按鈕
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. 頁面標題
                const Text(
                  '閱讀練習\nReading',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '選擇一個題組開始練習',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // 3. 題組列表
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _mockPassages.length,
                  itemBuilder: (context, index) {
                    final passage = _mockPassages[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReadingPassageScreen(
                                passage: passage,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // 左側內容
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      passage.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '約 ${passage.wordCount} 字｜${passage.questions.length} 題',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 右側完成狀態
                              if (passage.isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '已完成',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 模擬數據
  static final List<ReadingPassage> _mockPassages = [
    ReadingPassage(
      id: '1',
      title: 'Passage 1: Animal Migration',
      content: '''
Animal migration is one of nature's most remarkable phenomena. Every year, millions of animals embark on incredible journeys across vast distances, driven by the changing seasons and the need for survival. These migrations are not random wanderings but carefully timed movements that often follow the same routes year after year.

Birds are perhaps the most well-known migrators, with some species traveling thousands of miles between their breeding and wintering grounds. The Arctic Tern holds the record for the longest migration, flying from the Arctic to the Antarctic and back each year, a round trip of about 44,000 miles.

But migration isn't limited to birds. Mammals, fish, insects, and even reptiles undertake seasonal journeys. The wildebeest migration in Africa involves over 1.5 million animals moving across the Serengeti plains in search of fresh grass and water. Meanwhile, beneath the ocean's surface, whales travel between cold feeding grounds and warm breeding waters.

What makes these journeys even more fascinating is how animals navigate. They use a variety of methods, including the position of the sun, patterns of stars, Earth's magnetic field, and even their sense of smell. Some species, like sea turtles, can detect both the angle and intensity of Earth's magnetic field, allowing them to determine both latitude and longitude.

Climate change and human activities pose significant challenges to migrating animals. Changes in temperature affect the timing of migrations and the availability of food sources. Urban development, agriculture, and other human activities can disrupt traditional migration routes and destroy crucial stopover sites.
''',
      wordCount: 700,
      questions: [
        ReadingQuestion(
          id: 'q1',
          question: 'What is the main purpose of animal migration?',
          options: [
            'To explore new territories',
            'To escape predators',
            'To survive changing seasons',
            'To find mates',
          ],
          correctAnswer: 2,
          explanation: '文章第一段提到動物遷徙是為了因應季節變化和生存需求（"driven by the changing seasons and the need for survival"）。',
        ),
        ReadingQuestion(
          id: 'q2',
          question: 'Which animal holds the record for the longest migration distance?',
          options: [
            'Wildebeest',
            'Arctic Tern',
            'Sea Turtle',
            'Whale',
          ],
          correctAnswer: 1,
          explanation: '文章第二段明確指出北極燕鷗（Arctic Tern）擁有最長的遷徙距離，每年往返約44,000英里。',
        ),
        ReadingQuestion(
          id: 'q3',
          question: 'According to the passage, how do animals navigate during migration?',
          options: [
            'Only by following other animals',
            'Using the sun, stars, magnetic field and smell',
            'By memorizing landmarks',
            'Using their instincts alone',
          ],
          correctAnswer: 1,
          explanation:
              '文章第四段提到動物使用多種導航方法，包括太陽位置、星星模式、地球磁場和嗅覺（"They use a variety of methods, including the position of the sun, patterns of stars, Earth\'s magnetic field, and even their sense of smell"）。',
        ),
        ReadingQuestion(
          id: 'q4',
          question: 'What is mentioned as a challenge to migrating animals?',
          options: [
            'Lack of food sources',
            'Natural predators',
            'Climate change and human activities',
            'Disease outbreaks',
          ],
          correctAnswer: 2,
          explanation: '文章最後一段指出氣候變遷和人類活動對遷徙動物構成重大挑戰（"Climate change and human activities pose significant challenges to migrating animals"）。',
        ),
        ReadingQuestion(
          id: 'q5',
          question: 'How many wildebeest participate in the migration across the Serengeti plains?',
          options: [
            'Over 500,000',
            'Over 1 million',
            'Over 1.5 million',
            'Over 2 million',
          ],
          correctAnswer: 2,
          explanation: '文章第三段提到超過150萬隻角馬參與塞倫蓋提平原的遷徙（"The wildebeest migration in Africa involves over 1.5 million animals"）。',
        ),
        ReadingQuestion(
          id: 'q6',
          question: 'What special ability do sea turtles have according to the passage?',
          options: [
            'They can communicate with other turtles over long distances',
            'They can detect both angle and intensity of Earth\'s magnetic field',
            'They can swim faster than most marine animals',
            'They can hold their breath for several hours',
          ],
          correctAnswer: 1,
          explanation: '文章第四段提到海龜能夠同時檢測地球磁場的角度和強度（"sea turtles, can detect both the angle and intensity of Earth\'s magnetic field"）。',
        ),
        ReadingQuestion(
          id: 'q7',
          question: 'What is described as a consequence of climate change on animal migration?',
          options: [
            'Changes in migration timing and food availability',
            'Increased predator populations',
            'More competition between species',
            'Higher mortality rates',
          ],
          correctAnswer: 0,
          explanation: '文章最後一段提到氣候變遷影響遷徙時間和食物來源的供應（"Changes in temperature affect the timing of migrations and the availability of food sources"）。',
        ),
        ReadingQuestion(
          id: 'q8',
          question: 'Which of the following is NOT mentioned as a type of migrating animal in the passage?',
          options: [
            'Birds',
            'Amphibians',
            'Fish',
            'Insects',
          ],
          correctAnswer: 1,
          explanation: '文章第三段列舉了哺乳動物、魚類、昆蟲和爬行動物，但沒有提到兩棲動物。',
        ),
        ReadingQuestion(
          id: 'q9',
          question: 'Why do whales migrate according to the passage?',
          options: [
            'To escape predators',
            'To find new feeding grounds',
            'To move between feeding and breeding waters',
            'To follow their prey',
          ],
          correctAnswer: 2,
          explanation: '文章第三段提到鯨魚在冷水覓食區和溫暖繁殖水域之間遷徙（"whales travel between cold feeding grounds and warm breeding waters"）。',
        ),
        ReadingQuestion(
          id: 'q10',
          question: 'Which of the following statements about animal migration are true? (Select all that apply)',
          options: [
            'Migration routes are carefully timed and consistent',
            'Animals use multiple navigation methods',
            'Climate change affects migration patterns',
            'Migration is essential for survival',
          ],
          correctAnswer: [0, 1, 2, 3], // 所有選項都是正確的
          explanation: '文章提到：\n1. 遷徙路線是精確計時且固定的\n2. 動物使用多種導航方法\n3. 氣候變遷影響遷徙模式\n4. 遷徙對生存至關重要',
          isMultipleChoice: true, // 標記為多選題
        ),
      ],
      isCompleted: true,
    ),
    ReadingPassage(
      id: '2',
      title: 'Passage 2: The James Webb Space Telescope',
      content: '''
The James Webb Space Telescope (JWST) represents one of humanity's greatest achievements in space exploration...
''',
      wordCount: 850,
      questions: [
        ReadingQuestion(
          id: 'q1',
          question: 'What makes the James Webb Space Telescope different from the Hubble Space Telescope?',
          options: [
            'It is smaller in size',
            'It observes primarily in infrared light',
            'It orbits closer to Earth',
            'It uses a single mirror',
          ],
          correctAnswer: 1,
          explanation: '文章第二段提到，與主要觀測可見光和紫外線的哈伯望遠鏡不同，韋伯望遠鏡主要觀測紅外線。',
        ),
        ReadingQuestion(
          id: 'q2',
          question: 'How far from Earth is the JWST positioned?',
          options: [
            'In low Earth orbit',
            'At Lagrange point L2, 1.5 million kilometers away',
            'At the edge of the solar system',
            'In geosynchronous orbit',
          ],
          correctAnswer: 1,
          explanation: '文章提到韋伯望遠鏡位於拉格朗日點L2，距離地球約150萬公里。',
        ),
        ReadingQuestion(
          id: 'q3',
          question: 'What is the main scientific goal of the JWST?',
          options: [
            'To study black holes',
            'To search for alien life',
            'To observe the early universe',
            'To monitor Earth\'s climate',
          ],
          correctAnswer: 2,
          explanation: '文章強調韋伯望遠鏡的主要目標是觀察早期宇宙。',
        ),
        ReadingQuestion(
          id: 'q4',
          question: 'What is special about the JWST\'s mirror design?',
          options: [
            'It\'s made of a single piece of glass',
            'It consists of 18 hexagonal segments',
            'It\'s the smallest space telescope mirror',
            'It\'s fixed and cannot move',
          ],
          correctAnswer: 1,
          explanation: '文章描述韋伯望遠鏡的主鏡由18片六角形鏡片組成。',
        ),
        ReadingQuestion(
          id: 'q5',
          question: 'Why does the JWST need to be kept extremely cold?',
          options: [
            'To protect its electronics',
            'To observe infrared light effectively',
            'To preserve its fuel',
            'To maintain its orbit',
          ],
          correctAnswer: 1,
          explanation: '文章解釋為了有效觀測紅外線，望遠鏡需要保持在極低溫。',
        ),
        ReadingQuestion(
          id: 'q6',
          question: 'What type of objects will the JWST primarily study?',
          options: [
            'Nearby planets',
            'Distant galaxies and exoplanets',
            'Asteroids and comets',
            'The Sun and solar flares',
          ],
          correctAnswer: 1,
          explanation: '文章指出韋伯望遠鏡主要研究遙遠的星系和系外行星。',
        ),
        ReadingQuestion(
          id: 'q7',
          question: 'How long is the JWST expected to operate?',
          options: [
            '5-10 years',
            '10-20 years',
            '20-30 years',
            'Indefinitely',
          ],
          correctAnswer: 0,
          explanation: '文章提到韋伯望遠鏡的預期壽命為5-10年。',
        ),
        ReadingQuestion(
          id: 'q8',
          question: 'What is the significance of the JWST\'s sunshield?',
          options: [
            'It generates solar power',
            'It protects from space debris',
            'It keeps the telescope cold',
            'It aids in communication',
          ],
          correctAnswer: 2,
          explanation: '文章說明遮陽板的主要功能是保持望遠鏡的低溫。',
        ),
        ReadingQuestion(
          id: 'q9',
          question: 'How does the JWST\'s size compare to Hubble?',
          options: [
            'It\'s the same size',
            'It\'s much smaller',
            'It\'s much larger',
            'Size comparison is not mentioned',
          ],
          correctAnswer: 2,
          explanation: '文章比較指出韋伯望遠鏡比哈伯望遠鏡大得多。',
        ),
        ReadingQuestion(
          id: 'q10',
          question: 'What makes the JWST\'s deployment location unique?',
          options: [
            'It\'s the closest to Earth',
            'It\'s at a gravitationally stable point',
            'It\'s in the asteroid belt',
            'It\'s beyond Mars\' orbit',
          ],
          correctAnswer: 1,
          explanation: '文章提到韋伯望遠鏡位於重力穩定的拉格朗日點L2。',
        ),
      ],
      isCompleted: false,
    ),
  ];
}
