import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const sampleRate = 22050;

class Tone {
  final double start;
  final double duration;
  final double startFrequency;
  final double endFrequency;
  final double volume;
  final String waveform;
  final int seed;

  const Tone(
    this.start,
    this.duration,
    this.startFrequency,
    this.endFrequency,
    this.volume,
    this.waveform, [
    this.seed = 1,
  ]);
}

void main() {
  final output = Directory('assets/audio/sfx')..createSync(recursive: true);
  final sounds = <String, List<Tone>>{
    'flipper': [const Tone(0, 0.045, 170, 85, 0.55, 'square')],
    'launch': [const Tone(0, 0.24, 180, 760, 0.48, 'square')],
    'bumper': [
      const Tone(0, 0.16, 95, 55, 0.62, 'square'),
      const Tone(0.015, 0.12, 420, 220, 0.2, 'noise', 3),
    ],
    'target': [const Tone(0, 0.12, 620, 980, 0.42, 'square')],
    'chew_toy': [const Tone(0, 0.16, 260, 190, 0.42, 'triangle')],
    'paw_mission': [
      const Tone(0, 0.08, 420, 520, 0.36, 'square'),
      const Tone(0.075, 0.1, 620, 800, 0.4, 'square'),
    ],
    'doghouse_bonus': [
      const Tone(0, 0.1, 440, 540, 0.38, 'square'),
      const Tone(0.1, 0.1, 660, 760, 0.38, 'square'),
      const Tone(0.2, 0.18, 880, 1100, 0.42, 'square'),
    ],
    'hydrant': [const Tone(0, 0.14, 300, 540, 0.34, 'square')],
    'water_bonus': [
      const Tone(0, 0.1, 520, 720, 0.35, 'triangle'),
      const Tone(0.1, 0.14, 760, 1080, 0.38, 'triangle'),
    ],
    'drain': [
      const Tone(0, 0.24, 420, 75, 0.5, 'square'),
      const Tone(0, 0.24, 130, 55, 0.2, 'noise', 7),
    ],
    'game_over': [
      const Tone(0, 0.2, 300, 220, 0.48, 'square'),
      const Tone(0.21, 0.28, 220, 95, 0.52, 'square'),
    ],
    'restart': [const Tone(0, 0.16, 260, 600, 0.4, 'square')],
  };

  for (final entry in sounds.entries) {
    final samples = _render(entry.value);
    File('${output.path}/${entry.key}.wav').writeAsBytesSync(_wav(samples));
  }
}

List<double> _render(List<Tone> tones) {
  final duration = tones.fold<double>(
    0,
    (maxDuration, tone) => math.max(maxDuration, tone.start + tone.duration),
  );
  final samples = List<double>.filled((duration * sampleRate).ceil(), 0);

  for (final tone in tones) {
    var phase = 0.0;
    for (var index = 0; index < samples.length; index++) {
      final time = index / sampleRate;
      final local = time - tone.start;
      if (local < 0 || local >= tone.duration) {
        continue;
      }

      final progress = local / tone.duration;
      final frequency =
          tone.startFrequency +
          ((tone.endFrequency - tone.startFrequency) * progress);
      phase = (phase + (frequency / sampleRate)) % 1.0;
      final wave = switch (tone.waveform) {
        'triangle' => 1 - (4 * (phase - 0.5).abs()),
        'noise' => _noise(index + tone.seed),
        _ => phase < 0.5 ? 1.0 : -1.0,
      };
      final envelope =
          math.min(progress * 24, 1) * math.min((1 - progress) * 18, 1);
      samples[index] += wave * tone.volume * envelope;
    }
  }

  // Master each cue as a group so stacked tones stay punchy without hard
  // digital clipping when converted to 8-bit PCM.
  final peak = samples.fold<double>(
    0,
    (current, sample) => math.max(current, sample.abs()),
  );
  if (peak == 0) {
    return samples;
  }
  final gain = 0.9 / peak;
  return samples.map((sample) => sample * gain).toList();
}

double _noise(int value) {
  var x = value * 1103515245 + 12345;
  x = (x ^ (x >> 11)) & 0x7fffffff;
  return (x / 0x3fffffff) - 1;
}

List<int> _wav(List<double> samples) {
  final data = BytesBuilder();
  final header = ByteData(44);
  final dataLength = samples.length;
  header.setUint32(0, 0x52494646, Endian.big);
  header.setUint32(4, 36 + dataLength, Endian.little);
  header.setUint32(8, 0x57415645, Endian.big);
  header.setUint32(12, 0x666d7420, Endian.big);
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little);
  header.setUint16(22, 1, Endian.little);
  header.setUint32(24, sampleRate, Endian.little);
  header.setUint32(28, sampleRate, Endian.little);
  header.setUint16(32, 1, Endian.little);
  header.setUint16(34, 8, Endian.little);
  header.setUint32(36, 0x64617461, Endian.big);
  header.setUint32(40, dataLength, Endian.little);
  data.add(header.buffer.asUint8List());
  data.add(
    Uint8List.fromList(
      samples
          .map((sample) => ((sample.clamp(-1.0, 1.0) + 1) * 127.5).round())
          .toList(),
    ),
  );
  return data.takeBytes();
}
