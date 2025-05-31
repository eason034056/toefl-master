import '../models/word.dart';
import '../models/word_collection.dart';

// 系統預設單字集
final List<WordCollection> systemCollections = [
  WordCollection(
    id: 'sys_toefl_core',
    name: 'TOEFL 核心單字',
    description: 'TOEFL 考試中最常出現的核心單字',
    words: [
      Word(
        id: 'w1',
        word: 'academic',
        phonetic: '/ˌækəˈdemɪk/',
        audioUrl: 'https://example.com/audio/academic.mp3',
        meanings: [
          WordMeaning(
            partOfSpeech: 'adj.',
            definition: '學術的；學院的',
            example: 'The academic year begins in September.',
            exampleTranslation: '學年從九月開始。',
          ),
        ],
      ),
      Word(
        id: 'w2',
        word: 'analyze',
        phonetic: '/ˈænəlaɪz/',
        audioUrl: 'https://example.com/audio/analyze.mp3',
        meanings: [
          WordMeaning(
            partOfSpeech: 'v.',
            definition: '分析；研究',
            example: 'Scientists analyze the data to find patterns.',
            exampleTranslation: '科學家分析數據以尋找模式。',
          ),
        ],
      ),
    ],
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  ),
  WordCollection(
    id: 'sys_toefl_reading',
    name: 'TOEFL 閱讀單字',
    description: 'TOEFL 閱讀部分常見單字',
    words: [
      Word(
        id: 'w3',
        word: 'comprehend',
        phonetic: '/ˌkɒmprɪˈhend/',
        audioUrl: 'https://example.com/audio/comprehend.mp3',
        meanings: [
          WordMeaning(
            partOfSpeech: 'v.',
            definition: '理解；領會',
            example: 'It is difficult to comprehend the complexity of the situation.',
            exampleTranslation: '很難理解情況的複雜性。',
          ),
        ],
      ),
    ],
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  ),
];
