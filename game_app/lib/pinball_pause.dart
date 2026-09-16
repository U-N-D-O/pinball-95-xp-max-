import 'package:flutter/material.dart';

class PinballPausePanel extends StatelessWidget {
  final VoidCallback onResume;

  const PinballPausePanel({required this.onResume, super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xCC07101C),
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF172A3C),
            border: Border.all(color: const Color(0xFF6A8CA1), width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME PAUSED',
                style: TextStyle(
                  color: Color(0xFFFFC928),
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onResume,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF317BD0),
                  foregroundColor: const Color(0xFFFFF1A8),
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text(
                  'RESUME',
                  style: TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
