import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/cards/app_card.dart';

class SocialAuthButton extends StatelessWidget {
  final String label;
  final bool isGoogle;
  final VoidCallback onPressed;

  const SocialAuthButton({
    super.key,
    required this.label,
    required this.isGoogle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onPressed,
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isGoogle)
              CustomPaint(
                size: const Size(20, 20),
                painter: GoogleLogoPainter(),
              )
            else
              const Icon(
                Icons.apple,
                color: Colors.black,
                size: 24,
              ),
            AppSpacing.gapWMd,
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double strokeWidth = w * 0.22;

    final Paint paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Paint paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Paint paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Paint paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Rect rect = Rect.fromLTWH(
        strokeWidth / 2, strokeWidth / 2, w - strokeWidth, h - strokeWidth);

    canvas.drawArc(rect, -135 * 3.14159 / 180, 115 * 3.14159 / 180, false, paintRed);
    canvas.drawArc(rect, -225 * 3.14159 / 180, 90 * 3.14159 / 180, false, paintYellow);
    canvas.drawArc(rect, 45 * 3.14159 / 180, 90 * 3.14159 / 180, false, paintGreen);
    canvas.drawArc(rect, -45 * 3.14159 / 180, 90 * 3.14159 / 180, false, paintBlue);

    final Paint paintBlueFill = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(w / 2, h / 2 - strokeWidth / 2, w / 2 - strokeWidth / 4, strokeWidth),
      paintBlueFill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
