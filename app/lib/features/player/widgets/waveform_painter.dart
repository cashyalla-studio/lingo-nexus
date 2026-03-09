import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveformPainter extends CustomPainter {
  final Color color;
  final double animationValue;

  WaveformPainter(this.color, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final midY = height / 2;

    // Simulate a dynamic, smooth spectrum analyzer curve
    for (double i = 0; i < width; i += 5) {
      // Create a complex organic wave using multiple sine/cosine functions
      final normalizedX = i / width;
      
      // Base frequency
      double yOffset = math.sin((normalizedX * math.pi * 4) + (animationValue * 2 * math.pi)) * (height * 0.2);
      
      // Add high frequency details
      yOffset += math.sin((normalizedX * math.pi * 12) - (animationValue * 3 * math.pi)) * (height * 0.1);
      
      // Envelope to taper edges (fade out at ends)
      final envelope = math.sin(normalizedX * math.pi);
      yOffset *= envelope;

      final x = i;
      final y = midY + yOffset;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Add a subtle glow behind the wave
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
