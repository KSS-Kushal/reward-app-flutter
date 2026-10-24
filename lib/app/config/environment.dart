/// Build flavours supported by the app.
///
/// Selected at build time with `--dart-define=ENV=<name>`.
enum Environment {
  development,
  staging,
  production;

  static Environment fromName(String name) {
    return Environment.values.firstWhere(
      (env) => env.name == name.toLowerCase(),
      orElse: () => Environment.development,
    );
  }

  /// The environment this binary was compiled for.
  static final Environment current = fromName(
    const String.fromEnvironment('ENV', defaultValue: 'development'),
  );

  bool get isDevelopment => this == Environment.development;
  bool get isStaging => this == Environment.staging;
  bool get isProduction => this == Environment.production;
}
