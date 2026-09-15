/// 安全存储 IO 实现 - 使用 flutter_secure_storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();

Future<String?> read({required String key}) {
  return _storage.read(key: key);
}

Future<void> write({required String key, required String value}) {
  return _storage.write(key: key, value: value);
}

Future<void> delete({required String key}) {
  return _storage.delete(key: key);
}
