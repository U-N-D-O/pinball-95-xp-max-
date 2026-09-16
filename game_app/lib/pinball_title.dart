import 'package:flutter/material.dart';

class PinballTitlePanel extends StatefulWidget {
  final VoidCallback onStart;
  final int highScore;

  const PinballTitlePanel({
    required this.onStart,
    this.highScore = 0,
    super.key,
  });

  @override
  State<PinballTitlePanel> createState() => _PinballTitlePanelState();
}

class _PinballTitlePanelState extends State<PinballTitlePanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _attractPulse;

  @override
  void initState() {
    super.initState();
    _attractPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.35,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _attractPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xEE07101C),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PINBALL',
                style: TextStyle(
                  color: Color(0xFFFFC928),
                  fontFamily: 'monospace',
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const Text(
                'NEO 95',
                style: TextStyle(
                  color: Color(0xFFD4473F),
                  fontFamily: 'monospace',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                color: const Color(0xFF172A3C),
                child: const Text(
                  'CANINE ARCADE SYSTEM',
                  style: TextStyle(
                    color: Color(0xFF7BE2B2),
                    fontFamily: 'monospace',
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Text(
                'HIGH SCORE ${widget.highScore.toString().padLeft(7, '0')}',
                style: const TextStyle(
                  color: Color(0xFFFFF1A8),
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: widget.onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF317BD0),
                  foregroundColor: const Color(0xFFFFF1A8),
                  minimumSize: const Size(210, 54),
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text(
                  'START GAME',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: _attractPulse,
                builder: (context, child) =>
                    Opacity(opacity: _attractPulse.value, child: child),
                child: const Text(
                  'INSERT PAW TO START',
                  style: TextStyle(
                    color: Color(0xFFFFF1A8),
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Z / LEFT PAW       RIGHT PAW   RIGHT / /',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7B93A1),
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'SPACE TO LAUNCH   /   P TO PAUSE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7B93A1),
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
