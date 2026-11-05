/// Build-time configuration.
///
/// Pass the API URL when building/running:
///   flutter run --dart-define=API_BASE_URL=https://api.akobrah.ly/api/v1
///
/// The default targets a Laravel server on the host machine from the Android emulator.
class AppConfig {
  const AppConfig._();

  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000/api/v1');

  static const customerServicePhone = '0925441206';
}
