import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Minimal key/value persistence, swappable in tests.
abstract interface class KeyValueStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

/// Keychain (iOS) / encrypted storage (Android) — used for the auth token.
class SecureKeyValueStore implements KeyValueStore {
  const SecureKeyValueStore();

  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class MemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

final keyValueStoreProvider = Provider<KeyValueStore>((ref) => const SecureKeyValueStore());

/// Holds the Sanctum token in memory (for the HTTP interceptor) and persists it.
class SessionStore {
  SessionStore(this._store);

  static const _tokenKey = 'auth_token';

  final KeyValueStore _store;
  String? _token;

  String? get token => _token;

  Future<String?> load() async => _token = await _store.read(_tokenKey);

  Future<void> save(String token) async {
    _token = token;
    await _store.write(_tokenKey, token);
  }

  Future<void> clear() async {
    _token = null;
    await _store.delete(_tokenKey);
  }
}

final sessionStoreProvider = Provider<SessionStore>((ref) => SessionStore(ref.watch(keyValueStoreProvider)));
