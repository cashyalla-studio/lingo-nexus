class MinimalPairSet {
  final String language;
  final String phonemeA;
  final String phonemeB;
  final String description; // Korean description of the phoneme pair
  final List<MinimalPair> pairs;

  const MinimalPairSet({
    required this.language,
    required this.phonemeA,
    required this.phonemeB,
    required this.description,
    required this.pairs,
  });
}

class MinimalPair {
  final String wordA;
  final String wordB;
  final String? exampleSentenceA;
  final String? exampleSentenceB;

  const MinimalPair({
    required this.wordA,
    required this.wordB,
    this.exampleSentenceA,
    this.exampleSentenceB,
  });
}

class MinimalPairData {
  static const List<MinimalPairSet> english = [
    MinimalPairSet(
      language: 'English',
      phonemeA: '/r/',
      phonemeB: '/l/',
      description: '한국어와 일본어 화자가 가장 어려워하는 구별입니다. /r/은 혀를 말고, /l/은 혀끝을 윗니 뒤에 댑니다.',
      pairs: [
        MinimalPair(wordA: 'right', wordB: 'light', exampleSentenceA: 'Turn right here.', exampleSentenceB: 'Turn on the light.'),
        MinimalPair(wordA: 'road', wordB: 'load', exampleSentenceA: 'The road is long.', exampleSentenceB: 'The load is heavy.'),
        MinimalPair(wordA: 'rice', wordB: 'lice', exampleSentenceA: 'I eat rice daily.', exampleSentenceB: 'Lice are tiny insects.'),
        MinimalPair(wordA: 'read', wordB: 'lead', exampleSentenceA: 'I read every day.', exampleSentenceB: 'She took the lead.'),
        MinimalPair(wordA: 'pray', wordB: 'play', exampleSentenceA: 'We pray together.', exampleSentenceB: 'Children love to play.'),
      ],
    ),
    MinimalPairSet(
      language: 'English',
      phonemeA: '/iː/',
      phonemeB: '/ɪ/',
      description: '긴 /iː/ (sheep)와 짧은 /ɪ/ (ship)의 차이입니다. 한국어에는 이 구별이 없어 어렵습니다.',
      pairs: [
        MinimalPair(wordA: 'sheep', wordB: 'ship', exampleSentenceA: 'The sheep is white.', exampleSentenceB: 'The ship is large.'),
        MinimalPair(wordA: 'feel', wordB: 'fill', exampleSentenceA: 'I feel happy.', exampleSentenceB: 'Fill the glass.'),
        MinimalPair(wordA: 'meal', wordB: 'mill', exampleSentenceA: 'A delicious meal.', exampleSentenceB: 'An old mill.'),
        MinimalPair(wordA: 'heat', wordB: 'hit', exampleSentenceA: 'The heat is intense.', exampleSentenceB: 'He hit the ball.'),
        MinimalPair(wordA: 'seat', wordB: 'sit', exampleSentenceA: 'Take a seat.', exampleSentenceB: 'Please sit down.'),
      ],
    ),
    MinimalPairSet(
      language: 'English',
      phonemeA: '/θ/',
      phonemeB: '/s/',
      description: '치간음 /θ/ (think)는 혀를 윗니와 아랫니 사이에 살짝 넣고 발음합니다. 많은 언어에 없는 소리입니다.',
      pairs: [
        MinimalPair(wordA: 'think', wordB: 'sink', exampleSentenceA: 'I think so.', exampleSentenceB: 'Kitchen sink.'),
        MinimalPair(wordA: 'three', wordB: 'free', exampleSentenceA: 'I have three cats.', exampleSentenceB: 'I am free today.'),
        MinimalPair(wordA: 'thank', wordB: 'sank', exampleSentenceA: 'Thank you very much.', exampleSentenceB: 'The ship sank.'),
        MinimalPair(wordA: 'thin', wordB: 'sin', exampleSentenceA: 'Ice is thin.', exampleSentenceB: 'Forgive my sin.'),
        MinimalPair(wordA: 'math', wordB: 'mass', exampleSentenceA: 'I love math.', exampleSentenceB: 'A mass of people.'),
      ],
    ),
    MinimalPairSet(
      language: 'English',
      phonemeA: '/æ/',
      phonemeB: '/ʌ/',
      description: '/æ/ (cat)는 입을 크게 벌려 발음하고, /ʌ/ (cut)는 입을 덜 벌립니다. 한국어의 \'아\'와 \'어\'의 중간쯤입니다.',
      pairs: [
        MinimalPair(wordA: 'cat', wordB: 'cut', exampleSentenceA: 'My cat is cute.', exampleSentenceB: 'I got a cut.'),
        MinimalPair(wordA: 'had', wordB: 'hud', exampleSentenceA: 'I had lunch.', exampleSentenceB: 'Hudson river.'),
        MinimalPair(wordA: 'bat', wordB: 'but', exampleSentenceA: 'A baseball bat.', exampleSentenceB: 'But I disagree.'),
        MinimalPair(wordA: 'bad', wordB: 'bud', exampleSentenceA: 'That is bad.', exampleSentenceB: 'A flower bud.'),
        MinimalPair(wordA: 'ran', wordB: 'run', exampleSentenceA: 'She ran fast.', exampleSentenceB: 'Let\'s run together.'),
      ],
    ),
  ];

  static const List<MinimalPairSet> japanese = [
    MinimalPairSet(
      language: 'Japanese',
      phonemeA: 'は行',
      phonemeB: 'パ行',
      description: '\'は\'(ha)와 \'ぱ\'(pa)를 구별하는 연습입니다. 한국어 화자에게 ぱ행의 기식음이 어렵습니다.',
      pairs: [
        MinimalPair(wordA: 'はな (hana)', wordB: 'ぱな (pana)', exampleSentenceA: '花が咲いた。', exampleSentenceB: 'パナマ (Panama)'),
        MinimalPair(wordA: 'ひと (hito)', wordB: 'ぴと', exampleSentenceA: '人がいる。', exampleSentenceB: 'ピトケアン島'),
        MinimalPair(wordA: 'ほん (hon)', wordB: 'ぽん (pon)', exampleSentenceA: '本を読む。', exampleSentenceB: 'ポンポン'),
      ],
    ),
    MinimalPairSet(
      language: 'Japanese',
      phonemeA: '長音 (ちょうおん)',
      phonemeB: '短音',
      description: '일본어의 장단음 구별입니다. おばさん(아주머니) vs おばあさん(할머니)처럼 의미가 완전히 달라집니다.',
      pairs: [
        MinimalPair(wordA: 'おばさん', wordB: 'おばあさん', exampleSentenceA: 'おばさんが来た。', exampleSentenceB: 'おばあさんが来た。'),
        MinimalPair(wordA: 'ビル (biru)', wordB: 'ビール (biiru)', exampleSentenceA: '高いビル。', exampleSentenceB: 'ビールを飲む。'),
        MinimalPair(wordA: 'いえ (ie)', wordB: 'いいえ (iie)', exampleSentenceA: '私の家。', exampleSentenceB: 'いいえ、違います。'),
      ],
    ),
  ];

  static const List<MinimalPairSet> spanish = [
    MinimalPairSet(
      language: 'Spanish',
      phonemeA: '/b/',
      phonemeB: '/v/',
      description: '스페인어에서 b와 v는 같은 소리(/b/)로 발음됩니다. 영어 화자가 스페인어를 배울 때 이 점을 알아야 합니다.',
      pairs: [
        MinimalPair(wordA: 'baca (roof rack)', wordB: 'vaca (cow)', exampleSentenceA: 'La baca del coche.', exampleSentenceB: 'La vaca come hierba.'),
        MinimalPair(wordA: 'bienes (goods)', wordB: 'vienes (you come)', exampleSentenceA: 'Mis bienes.', exampleSentenceB: '¿Vienes mañana?'),
        MinimalPair(wordA: 'tubo (pipe)', wordB: 'tuvo (had)', exampleSentenceA: 'Un tubo de metal.', exampleSentenceB: 'Ella lo tuvo.'),
      ],
    ),
    MinimalPairSet(
      language: 'Spanish',
      phonemeA: '/r/ (simple)',
      phonemeB: '/rr/ (trill)',
      description: '단일 r (para)와 이중 rr (parra)의 구별입니다. rr은 혀를 더 강하게 진동시킵니다.',
      pairs: [
        MinimalPair(wordA: 'pero (but)', wordB: 'perro (dog)', exampleSentenceA: 'Pero no sé.', exampleSentenceB: 'El perro ladra.'),
        MinimalPair(wordA: 'caro (expensive)', wordB: 'carro (car)', exampleSentenceA: 'Es muy caro.', exampleSentenceB: 'Mi carro nuevo.'),
        MinimalPair(wordA: 'para (for)', wordB: 'parra (grapevine)', exampleSentenceA: 'Para ti.', exampleSentenceB: 'Una parra grande.'),
      ],
    ),
  ];

  static List<MinimalPairSet> getAllForLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'english': return english;
      case 'japanese': return japanese;
      case 'spanish': return spanish;
      default: return english;
    }
  }

  static const List<String> supportedLanguages = ['English', 'Japanese', 'Spanish'];
}
