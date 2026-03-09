import 'package:flutter/material.dart';
import 'pitch_accent_data.dart';

/// 일본어 피치 악센트를 시각적으로 표시하는 위젯
/// 각 모라(mora)위에 H/L 그래프를 선으로 연결해 표시합니다.
class PitchAccentWidget extends StatelessWidget {
  final PitchEntry entry;
  final String word;
  final double fontSize;
  final Color accentColor;

  const PitchAccentWidget({
    super.key,
    required this.entry,
    required this.word,
    this.fontSize = 28,
    this.accentColor = const Color(0xFF00FFD1),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final morae = entry.reading.split(''); // Split by character (mora approximation)
    final pattern = entry.pattern;

    // Pad pattern if shorter than morae
    final paddedPattern = List<PitchType>.generate(
      morae.length,
      (i) => i < pattern.length ? pattern[i] : pattern.last,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pitch graph
        CustomPaint(
          size: Size(morae.length * (fontSize + 8), 60),
          painter: _PitchGraphPainter(
            pattern: paddedPattern,
            moraCount: morae.length,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 4),
        // Mora characters
        Row(
          mainAxisSize: MainAxisSize.min,
          children: morae.asMap().entries.map((e) {
            final isHigh = paddedPattern[e.key] == PitchType.high;
            return SizedBox(
              width: fontSize + 8,
              child: Column(
                children: [
                  Text(
                    e.value,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: isHigh ? accentColor : theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isHigh
                          ? accentColor
                          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // H/L labels
        Row(
          mainAxisSize: MainAxisSize.min,
          children: paddedPattern.map((p) => SizedBox(
            width: fontSize + 8,
            child: Text(
              p == PitchType.high ? 'H' : 'L',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: p == PitchType.high
                    ? accentColor
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class _PitchGraphPainter extends CustomPainter {
  final List<PitchType> pattern;
  final int moraCount;
  final Color color;

  const _PitchGraphPainter({
    required this.pattern,
    required this.moraCount,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (moraCount == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final moraWidth = size.width / moraCount;
    const highY = 10.0;
    const lowY = 45.0;

    final points = List<Offset>.generate(moraCount, (i) {
      final x = moraWidth * i + moraWidth / 2;
      final y = pattern[i] == PitchType.high ? highY : lowY;
      return Offset(x, y);
    });

    // Draw lines connecting dots
    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }
    canvas.drawPath(path, paint);

    // Draw dots
    for (final point in points) {
      canvas.drawCircle(point, 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PitchGraphPainter oldDelegate) {
    if (oldDelegate.moraCount != moraCount || oldDelegate.color != color) return true;
    if (oldDelegate.pattern.length != pattern.length) return true;
    for (int i = 0; i < pattern.length; i++) {
      if (oldDelegate.pattern[i] != pattern[i]) return true;
    }
    return false;
  }
}
