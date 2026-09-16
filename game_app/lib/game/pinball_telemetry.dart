class PinballTelemetryEvent {
  final String name;
  final int value;

  const PinballTelemetryEvent(this.name, this.value);
}

class PinballTelemetry {
  final List<PinballTelemetryEvent> events = <PinballTelemetryEvent>[];

  void record(String name, {int value = 1}) {
    events.add(PinballTelemetryEvent(name, value));
  }

  int count(String name) => events.where((event) => event.name == name).length;

  int totalValue(String name) => events
      .where((event) => event.name == name)
      .fold(0, (total, event) => total + event.value);

  void clear() => events.clear();
}

class PinballPerformance {
  static const double targetFrameSeconds = 1 / 60;

  int frames = 0;
  int slowFrames = 0;
  double totalFrameSeconds = 0;
  double maxFrameSeconds = 0;

  double get averageFrameSeconds =>
      frames == 0 ? 0 : totalFrameSeconds / frames;

  void sample(double frameSeconds) {
    final safeFrameSeconds = frameSeconds.isFinite
        ? frameSeconds.clamp(0.0, 1.0).toDouble()
        : 1.0;
    frames++;
    totalFrameSeconds += safeFrameSeconds;
    if (safeFrameSeconds > maxFrameSeconds) {
      maxFrameSeconds = safeFrameSeconds;
    }
    if (safeFrameSeconds > targetFrameSeconds * 1.5) {
      slowFrames++;
    }
  }
}
