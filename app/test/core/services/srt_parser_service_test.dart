import 'package:flutter_test/flutter_test.dart';
import 'package:lingo_nexus/core/services/srt_parser_service.dart';

const _sampleSrt = '''
1
00:00:01,000 --> 00:00:04,000
Hello world

2
00:00:05,000 --> 00:00:08,500
This is a test
''';

void main() {
  late SrtParserService parser;

  setUp(() {
    parser = SrtParserService();
  });

  group('SrtParserService.parse', () {
    test('returns correct number of items', () {
      final items = parser.parse(_sampleSrt);
      expect(items.length, 2);
    });

    test('parses start time of first block correctly', () {
      final items = parser.parse(_sampleSrt);
      expect(items[0].startTime, const Duration(seconds: 1));
    });

    test('parses end time of first block correctly', () {
      final items = parser.parse(_sampleSrt);
      expect(items[0].endTime, const Duration(seconds: 4));
    });

    test('parses start time of second block', () {
      final items = parser.parse(_sampleSrt);
      expect(items[1].startTime, const Duration(seconds: 5));
    });

    test('parses end time of second block with milliseconds', () {
      final items = parser.parse(_sampleSrt);
      expect(items[1].endTime, const Duration(milliseconds: 8500));
    });

    test('parses sentence text of first block', () {
      final items = parser.parse(_sampleSrt);
      expect(items[0].sentence, 'Hello world');
    });

    test('parses sentence text of second block', () {
      final items = parser.parse(_sampleSrt);
      expect(items[1].sentence, 'This is a test');
    });

    test('strips italic HTML tags from subtitle text', () {
      const srtWithHtml = '''
1
00:00:01,000 --> 00:00:04,000
<i>Hello world</i>
''';
      final items = parser.parse(srtWithHtml);
      expect(items[0].sentence, 'Hello world');
    });

    test('joins multi-line subtitle into single sentence', () {
      const srtMultiLine = '''
1
00:00:01,000 --> 00:00:04,000
Line one
Line two
''';
      final items = parser.parse(srtMultiLine);
      expect(items[0].sentence, 'Line one Line two');
    });

    test('returns empty list for empty string input', () {
      expect(parser.parse(''), isEmpty);
    });

    test('accepts dot separator in timecode WebVTT-style', () {
      const vttStyle = '''
1
00:00:01.000 --> 00:00:04.000
VTT style
''';
      final items = parser.parse(vttStyle);
      expect(items.length, 1);
      expect(items[0].sentence, 'VTT style');
    });

    test('parses hours correctly for timecodes above one hour', () {
      const longSrt = '''
1
01:30:00,000 --> 01:30:05,000
Long video subtitle
''';
      final items = parser.parse(longSrt);
      expect(items[0].startTime, const Duration(hours: 1, minutes: 30));
      expect(items[0].endTime, const Duration(hours: 1, minutes: 30, seconds: 5));
    });

    test('skips blocks where text is empty after HTML stripping', () {
      const srtEmpty = '''
1
00:00:01,000 --> 00:00:04,000
<i></i>

2
00:00:05,000 --> 00:00:08,000
Valid text
''';
      final items = parser.parse(srtEmpty);
      expect(items.length, 1);
      expect(items[0].sentence, 'Valid text');
    });
  });

  group('SrtParserService.extractPlainText', () {
    test('extracts all sentences joined by single space', () {
      final text = parser.extractPlainText(_sampleSrt);
      expect(text, 'Hello world This is a test');
    });

    test('returns empty string for empty SRT input', () {
      expect(parser.extractPlainText(''), '');
    });

    test('returns single sentence when only one block', () {
      const singleBlock = '''
1
00:00:01,000 --> 00:00:04,000
Only sentence
''';
      expect(parser.extractPlainText(singleBlock), 'Only sentence');
    });
  });
}
