import 'dart:math' as math;

import 'package:flame/components.dart';

class CameraShakeController extends Component {
  static const double maxIntensity = 0.35;

  final CameraComponent camera;
  late final Vector2 _restPosition = camera.viewfinder.position.clone();
  double _remaining = 0;
  double _duration = 0;
  double _intensity = 0;
  double _phase = 0;

  CameraShakeController({required this.camera});

  bool get isShaking => _remaining > 0;
  double get intensity => _intensity;

  void trigger({double duration = 0.12, double intensity = 0.12}) {
    _duration = math.max(_duration, duration);
    _remaining = math.max(_remaining, duration);
    _intensity = math.min(maxIntensity, math.max(_intensity, intensity));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_remaining <= 0) {
      camera.viewfinder.position.setFrom(_restPosition);
      _intensity = 0;
      return;
    }

    _remaining -= dt;
    _phase += dt * 75;
    final strength = (_remaining / _duration).clamp(0.0, 1.0);
    final offset = Vector2(
      math.sin(_phase) * _intensity * strength,
      math.cos(_phase * 1.37) * _intensity * strength,
    );
    camera.viewfinder.position.setFrom(_restPosition + offset);

    if (_remaining <= 0) {
      camera.viewfinder.position.setFrom(_restPosition);
      _intensity = 0;
    }
  }
}
