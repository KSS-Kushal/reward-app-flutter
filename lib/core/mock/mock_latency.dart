/// Simulated network latency for mock data sources, so loading states are
/// exercised during development. Tests set [value] to [Duration.zero].
abstract final class MockLatency {
  static Duration value = const Duration(milliseconds: 700);

  static Future<void> simulate([Duration? override]) {
    final duration = override ?? value;
    if (duration == Duration.zero) return Future<void>.value();
    return Future<void>.delayed(duration);
  }
}
