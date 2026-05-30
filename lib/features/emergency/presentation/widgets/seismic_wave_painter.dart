import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Custom painter for the seismic wave background animation
class SeismicWavePainter extends CustomPainter {
  final double animationValue;
  final Color waveColor;
  final int waveCount;

  SeismicWavePainter({
    required this.animationValue,
    this.waveColor = AppColors.primary,
    this.waveCount = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < waveCount; i++) {
      final progress = (animationValue + i / waveCount) % 1.0;
      final opacity = (1 - progress) * 0.4;
      final radius = progress * size.width * 0.6;

      paint.color = waveColor.withValues(alpha: opacity);

      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SeismicWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Seismic wave animation widget
class SeismicWaveWidget extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Color color;
  final double size;

  const SeismicWaveWidget({
    super.key,
    required this.child,
    this.isActive = true,
    this.color = AppColors.primary,
    this.size = 200,
  });

  @override
  State<SeismicWaveWidget> createState() => _SeismicWaveWidgetState();
}

class _SeismicWaveWidgetState extends State<SeismicWaveWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SeismicWaveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: SeismicWavePainter(
                  animationValue: _controller.value,
                  waveColor: widget.color,
                ),
              ),
              widget.child,
            ],
          );
        },
      ),
    );
  }
}
