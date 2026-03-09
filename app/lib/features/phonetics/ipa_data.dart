/// 영어 주요 단어의 IPA 발음기호 데이터 (CMU Dict 기반)
class IpaData {
  static const Map<String, String> english = {
    // A
    'apple': 'ˈæp.əl', 'about': 'əˈbaʊt', 'above': 'əˈbʌv', 'act': 'ækt',
    'age': 'eɪdʒ', 'air': 'ɛr', 'all': 'ɔːl', 'also': 'ˈɔːl.soʊ',
    'always': 'ˈɔːl.weɪz', 'am': 'æm', 'and': 'ænd', 'any': 'ˈen.i',
    'are': 'ɑːr', 'ask': 'æsk', 'at': 'æt', 'away': 'əˈweɪ',
    // B
    'back': 'bæk', 'bad': 'bæd', 'ball': 'bɔːl', 'be': 'biː',
    'because': 'bɪˈkɔːz', 'bed': 'bɛd', 'before': 'bɪˈfɔːr',
    'best': 'bɛst', 'better': 'ˈbɛt.ər', 'big': 'bɪɡ', 'black': 'blæk',
    'blue': 'bluː', 'book': 'bʊk', 'boy': 'bɔɪ', 'bring': 'brɪŋ',
    'but': 'bʌt', 'buy': 'baɪ', 'by': 'baɪ',
    // C
    'call': 'kɔːl', 'came': 'keɪm', 'can': 'kæn', 'car': 'kɑːr',
    'cat': 'kæt', 'change': 'tʃeɪndʒ', 'child': 'tʃaɪld', 'city': 'ˈsɪt.i',
    'close': 'kloʊz', 'cold': 'koʊld', 'come': 'kʌm', 'could': 'kʊd',
    'cut': 'kʌt',
    // D
    'day': 'deɪ', 'different': 'ˈdɪf.ər.ənt', 'do': 'duː', 'dog': 'dɔɡ',
    'down': 'daʊn', 'drink': 'drɪŋk',
    // E
    'each': 'iːtʃ', 'early': 'ˈɜːr.li', 'eat': 'iːt', 'end': 'ɛnd',
    'even': 'ˈiː.vən', 'ever': 'ˈɛv.ər', 'every': 'ˈɛv.ri',
    // F
    'face': 'feɪs', 'fact': 'fækt', 'fall': 'fɔːl', 'far': 'fɑːr',
    'feel': 'fiːl', 'feet': 'fiːt', 'few': 'fjuː', 'find': 'faɪnd',
    'first': 'fɜːrst', 'food': 'fuːd', 'for': 'fɔːr', 'form': 'fɔːrm',
    'found': 'faʊnd', 'free': 'friː', 'from': 'frʌm', 'full': 'fʊl',
    // G
    'gave': 'ɡeɪv', 'get': 'ɡɛt', 'girl': 'ɡɜːrl', 'give': 'ɡɪv',
    'go': 'ɡoʊ', 'good': 'ɡʊd', 'got': 'ɡɒt', 'great': 'ɡreɪt',
    'green': 'ɡriːn', 'grow': 'ɡroʊ',
    // H
    'had': 'hæd', 'hand': 'hænd', 'hard': 'hɑːrd', 'has': 'hæz',
    'have': 'hæv', 'he': 'hiː', 'head': 'hɛd', 'hear': 'hɪr',
    'heat': 'hiːt', 'help': 'hɛlp', 'her': 'hɜːr', 'here': 'hɪr',
    'him': 'hɪm', 'his': 'hɪz', 'hit': 'hɪt', 'hold': 'hoʊld',
    'home': 'hoʊm', 'hot': 'hɒt', 'house': 'haʊs', 'how': 'haʊ',
    // I
    'if': 'ɪf', 'in': 'ɪn', 'into': 'ˈɪn.tuː', 'is': 'ɪz', 'it': 'ɪt',
    // J
    'job': 'dʒɒb', 'just': 'dʒʌst',
    // K
    'keep': 'kiːp', 'kind': 'kaɪnd', 'know': 'noʊ',
    // L
    'land': 'lænd', 'large': 'lɑːrdʒ', 'last': 'læst', 'late': 'leɪt',
    'lead': 'liːd', 'learn': 'lɜːrn', 'left': 'lɛft', 'let': 'lɛt',
    'life': 'laɪf', 'light': 'laɪt', 'like': 'laɪk', 'line': 'laɪn',
    'lice': 'laɪs', 'load': 'loʊd', 'long': 'lɔːŋ', 'look': 'lʊk',
    // M
    'made': 'meɪd', 'make': 'meɪk', 'man': 'mæn', 'many': 'ˈmɛn.i',
    'may': 'meɪ', 'mean': 'miːn', 'meal': 'miːl', 'mill': 'mɪl',
    'more': 'mɔːr', 'most': 'moʊst', 'move': 'muːv', 'much': 'mʌtʃ',
    'must': 'mʌst', 'my': 'maɪ',
    // N
    'name': 'neɪm', 'need': 'niːd', 'never': 'ˈnɛv.ər', 'new': 'njuː',
    'next': 'nɛkst', 'night': 'naɪt', 'no': 'noʊ', 'not': 'nɒt',
    'now': 'naʊ',
    // O
    'of': 'ɒv', 'off': 'ɒf', 'old': 'oʊld', 'on': 'ɒn', 'one': 'wʌn',
    'only': 'ˈoʊn.li', 'open': 'ˈoʊ.pən', 'or': 'ɔːr', 'other': 'ˈʌð.ər',
    'our': 'aʊr', 'out': 'aʊt', 'over': 'ˈoʊ.vər', 'own': 'oʊn',
    // P
    'part': 'pɑːrt', 'people': 'ˈpiː.pəl', 'place': 'pleɪs', 'plant': 'plænt',
    'play': 'pleɪ', 'point': 'pɔɪnt', 'pray': 'preɪ', 'put': 'pʊt',
    // Q
    'question': 'ˈkwɛs.tʃən',
    // R
    'ran': 'ræn', 'read': 'riːd', 'real': 'riːl', 'rice': 'raɪs',
    'right': 'raɪt', 'road': 'roʊd', 'room': 'ruːm', 'run': 'rʌn',
    // S
    'said': 'sɛd', 'same': 'seɪm', 'saw': 'sɔː', 'say': 'seɪ',
    'school': 'skuːl', 'sea': 'siː', 'seat': 'siːt', 'see': 'siː',
    'seem': 'siːm', 'set': 'sɛt', 'she': 'ʃiː', 'sheep': 'ʃiːp',
    'ship': 'ʃɪp', 'show': 'ʃoʊ', 'sin': 'sɪn', 'sink': 'sɪŋk',
    'sit': 'sɪt', 'small': 'smɔːl', 'so': 'soʊ', 'some': 'sʌm',
    'song': 'sɔːŋ', 'soon': 'suːn', 'sound': 'saʊnd', 'start': 'stɑːrt',
    'still': 'stɪl', 'stop': 'stɒp', 'such': 'sʌtʃ', 'sure': 'ʃʊr',
    // T
    'take': 'teɪk', 'talk': 'tɔːk', 'tell': 'tɛl', 'than': 'ðæn',
    'thank': 'θæŋk', 'that': 'ðæt', 'the': 'ðə', 'their': 'ðɛr',
    'them': 'ðɛm', 'then': 'ðɛn', 'there': 'ðɛr', 'think': 'θɪŋk',
    'thin': 'θɪn', 'three': 'θriː', 'time': 'taɪm', 'to': 'tuː',
    'told': 'toʊld', 'too': 'tuː', 'took': 'tʊk', 'town': 'taʊn',
    'try': 'traɪ', 'turn': 'tɜːrn', 'two': 'tuː',
    // U
    'under': 'ˈʌn.dər', 'up': 'ʌp', 'us': 'ʌs', 'use': 'juːz',
    // V
    'very': 'ˈvɛr.i',
    // W
    'walk': 'wɔːk', 'want': 'wɒnt', 'was': 'wɒz', 'water': 'ˈwɔː.tər',
    'way': 'weɪ', 'we': 'wiː', 'well': 'wɛl', 'went': 'wɛnt',
    'were': 'wɜːr', 'what': 'wɒt', 'when': 'wɛn', 'where': 'wɛr',
    'which': 'wɪtʃ', 'while': 'waɪl', 'who': 'huː', 'why': 'waɪ',
    'will': 'wɪl', 'with': 'wɪð', 'word': 'wɜːrd', 'work': 'wɜːrk',
    'world': 'wɜːrld', 'would': 'wʊd', 'write': 'raɪt',
    // Y
    'year': 'jɪr', 'yes': 'jɛs', 'you': 'juː', 'your': 'jʊr',
    // Z
    'zero': 'ˈzɪr.oʊ',
  };

  /// 단어로 IPA 발음기호 조회
  static String? lookup(String word) {
    return english[word.toLowerCase().trim()];
  }

  /// 발음 연습용 카테고리별 단어 목록
  static const Map<String, List<String>> categories = {
    '기초 모음': ['apple', 'eat', 'up', 'book', 'blue', 'all', 'air'],
    '자주 틀리는 자음': ['think', 'three', 'thank', 'thin', 'this', 'that', 'the'],
    '장단 모음 구별': ['sheep', 'ship', 'feel', 'fill', 'seat', 'sit', 'heat', 'hit', 'meal', 'mill'],
    'R vs L': ['right', 'light', 'road', 'load', 'rice', 'lice', 'read', 'lead', 'pray', 'play'],
    '일상 필수 단어': ['water', 'work', 'world', 'year', 'people', 'think', 'place', 'great'],
    '고급 어휘': ['question', 'different', 'because', 'every', 'always', 'never', 'other'],
  };

  static const Map<String, String> spanish = {
    'agua': 'ˈa.ɣwa', 'bien': 'bjen', 'casa': 'ˈka.sa', 'ciudad': 'sjuˈðað',
    'comer': 'koˈmer', 'con': 'kon', 'dar': 'dar', 'decir': 'deˈθir',
    'día': 'ˈdi.a', 'donde': 'ˈdon.de', 'estar': 'esˈtar', 'gracias': 'ˈɡra.θjas',
    'grande': 'ˈɡran.de', 'hablar': 'aˈβlar', 'hacer': 'aˈθer', 'hola': 'ˈo.la',
    'libro': 'ˈli.βro', 'llegar': 'ʎeˈɣar', 'más': 'mas', 'mucho': 'ˈmu.tʃo',
    'muy': 'mwi', 'noche': 'ˈno.tʃe', 'nuevo': 'ˈnwe.βo', 'paella': 'paˈeʎa',
    'pero': 'ˈpe.ro', 'perro': 'ˈpe.ro', 'puede': 'ˈpwe.ðe', 'que': 'ke',
    'querer': 'keˈrer', 'saber': 'saˈβer', 'ser': 'ser', 'si': 'si',
    'también': 'tamˈbjen', 'tener': 'teˈner', 'tiempo': 'ˈtjem.po', 'todo': 'ˈto.ðo',
    'trabajar': 'tɾaβaˈxar', 'ver': 'ber', 'venir': 'beˈnir', 'vida': 'ˈbi.ða',
    'año': 'ˈa.ɲo', 'español': 'espaˈɲol', 'mañana': 'maˈɲa.na', 'niño': 'ˈni.ɲo',
  };

  static const Map<String, List<String>> spanishCategories = {
    '기초 인사': ['hola', 'gracias', 'bien', 'mucho', 'muy'],
    '동사': ['ser', 'estar', 'tener', 'hacer', 'ver', 'dar', 'venir', 'hablar', 'comer'],
    'ñ 발음': ['año', 'español', 'mañana', 'niño'],
    'R vs RR 구별': ['pero', 'perro'],
    '명사': ['casa', 'libro', 'agua', 'día', 'noche', 'tiempo', 'vida'],
  };
}
