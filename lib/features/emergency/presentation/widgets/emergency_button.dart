import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'seismic_wave_painter.dart';

/// The main 'I'm OK' emergency button with press-and-hold interaction and visual progress arc
class EmergencyButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSent;
  final String label;

  const EmergencyButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.isSent = false,
    this.label = "I'm OK",
  });

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _holdController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // 2 seconds hold duration
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          HapticFeedback.heavyImpact();
          widget.onPressed();
          _holdController.reset();
        }
      });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _holdController.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (!widget.isLoading && !widget.isSent) {
      _holdController.forward();
      HapticFeedback.mediumImpact();
    }
  }

  void _onTapUp(_) {
    if (_holdController.status != AnimationStatus.completed) {
      _holdController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Background and glow colors matching Emergency Mode
    const Color buttonColor = Color(0xFF0066CC);
    const Color glowColor = Color(0xFF0066CC);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () {
        if (_holdController.status != AnimationStatus.completed) {
          _holdController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _holdController]),
        builder: (context, _) {
          final scale = 1.0 +
              (_holdController.value * 0.08); // Slight scale up while holding

          return Transform.scale(
            scale: scale,
            child: SeismicWaveWidget(
              color: glowColor,
              size: 260,
              isActive: !widget.isSent && !widget.isLoading,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Hold Progress Arc Indicator
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: _holdController.value,
                      strokeWidth: 6,
                      color: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),

                  // Main Circular Button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 176,
                    height: 176,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          buttonColor,
                          buttonColor.withValues(alpha: 0.85),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withValues(
                              alpha: 0.25 + _pulseController.value * 0.15),
                          blurRadius: 25 + _pulseController.value * 15,
                          spreadRadius: 3 + _pulseController.value * 4,
                        ),
                      ],
                    ),
                    child: widget.isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.label,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
