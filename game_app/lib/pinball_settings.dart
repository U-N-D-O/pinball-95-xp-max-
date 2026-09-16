import 'package:flutter/material.dart';

import 'game/pinball_audio.dart';
import 'game/pinball_haptics.dart';

class PinballSettingsPanel extends StatefulWidget {
  final PinballAudio audio;
  final PinballHaptics haptics;
  final VoidCallback onClose;

  const PinballSettingsPanel({
    required this.audio,
    required this.haptics,
    required this.onClose,
    super.key,
  });

  @override
  State<PinballSettingsPanel> createState() => _PinballSettingsPanelState();
}

class _PinballSettingsPanelState extends State<PinballSettingsPanel> {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xEE07101C),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF172A3C),
            border: Border.all(color: const Color(0xFF6A8CA1), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF0A2E2C),
                offset: Offset(6, 6),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'SYSTEM SETTINGS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFC928),
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              MergeSemantics(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MUTE AUDIO',
                      style: TextStyle(
                        color: Color(0xFFB8D0D2),
                        fontFamily: 'monospace',
                      ),
                    ),
                    Switch(
                      value: widget.audio.muted,
                      onChanged: (value) {
                        setState(() => widget.audio.muted = value);
                      },
                      activeThumbColor: const Color(0xFFFFC928),
                      activeTrackColor: const Color(0xFF7A4B20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              MergeSemantics(
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'HAPTIC FEEDBACK',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFFB8D0D2),
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Switch(
                      value: widget.haptics.enabled,
                      onChanged: (value) {
                        setState(() => widget.haptics.enabled = value);
                      },
                      activeThumbColor: const Color(0xFFFFC928),
                      activeTrackColor: const Color(0xFF7A4B20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'VOLUME ${(widget.audio.volume * 100).round().toString().padLeft(3, '0')}%',
                style: const TextStyle(
                  color: Color(0xFFB8D0D2),
                  fontFamily: 'monospace',
                ),
              ),
              Slider(
                value: widget.audio.volume,
                onChanged: (value) {
                  setState(() => widget.audio.setVolume(value));
                },
                activeColor: const Color(0xFF7BE2B2),
                inactiveColor: const Color(0xFF405A69),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: widget.onClose,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD4473F),
                  foregroundColor: const Color(0xFFFFF1A8),
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text(
                  'CLOSE',
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
