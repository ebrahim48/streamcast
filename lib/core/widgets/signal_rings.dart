import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// The expanding orange "signal" rings behind the wordmark.
///
/// A Dart port of the reference `signal-ring` / `signal-glow` CSS: [ringCount]
/// circles ride one controller, each offset by an equal slice of the cycle, so
/// a new ring departs the centre as the previous one fades out at the edge.
///
/// ```dart
/// SignalRings(size: 420, child: ScWordmark(size: WordmarkSize.lg, glow: true))
/// ```
class SignalRings extends StatefulWidget {
  const SignalRings({
    super.key,
    this.size = 420,
    this.ringCount = 3,
    this.duration = const Duration(milliseconds: 2700),
    this.color = AppColors.accentSignal,
    this.beginScale = 0.42,
    this.endScale = 1.0,
    this.showGlow = true,
    this.backdrop,
    this.child,
  });

  /// Diameter of the largest ring, in logical pixels.
  final double size;

  final int ringCount;
  final Duration duration;
  final Color color;

  /// Scale a ring starts at (fully opaque) and ends at (fully faded).
  final double beginScale;
  final double endScale;

  /// Paints the soft radial halo under the rings.
  final bool showGlow;

  /// Optional artwork layered beneath the rings — e.g. the circular splash PNG.
  final Widget? backdrop;

  /// Content centred inside the rings.
  final Widget? child;

  @override
  State<SignalRings> createState() => _SignalRingsState();
}

class _SignalRingsState extends State<SignalRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

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
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.backdrop != null)
            Positioned.fill(child: Center(child: widget.backdrop!)),
          if (widget.showGlow)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.color.withValues(alpha: 0.22),
                      widget.color.withValues(alpha: 0.06),
                      AppColors.transparent,
                    ],
                    stops: const [0.0, 0.45, 0.85],
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _RingPainter(
                    progress: _controller.value,
                    ringCount: widget.ringCount,
                    color: widget.color,
                    beginScale: widget.beginScale,
                    endScale: widget.endScale,
                  ),
                ),
              ),
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.ringCount,
    required this.color,
    required this.beginScale,
    required this.endScale,
  });

  final double progress;
  final int ringCount;
  final Color color;
  final double beginScale;
  final double endScale;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;

    for (var i = 0; i < ringCount; i++) {
      // Stagger each ring by an equal slice of the cycle, wrapping at 1.0.
      final t = (progress + i / ringCount) % 1.0;
      final eased = Curves.easeOut.transform(t);

      final radius = maxRadius * (beginScale + (endScale - beginScale) * eased);

      // Fade in briefly, then out — so a ring never pops at the centre.
      final opacity = t < 0.12 ? t / 0.12 : (1.0 - (t - 0.12) / 0.88);
      if (opacity <= 0) continue;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0) * 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.ringCount != ringCount ||
      old.color != color;
}
