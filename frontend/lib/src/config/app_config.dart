class AppConfig {
  static const backendBaseUrl = String.fromEnvironment(
    'VITASYNC_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:9000',
  );
}
