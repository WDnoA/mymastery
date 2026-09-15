/// 安全存储抽象层 - Stub 文件
/// 根据平台自动选择实现

import 'secure_storage_io.dart'
    if (dart.library.js_interop) 'secure_storage_web.dart'
    as impl;

class SecureStorage {
  Future<String?> read({required String key}) {
    return impl.read(key: key);
  }

  Future<void> write({required String key, required String value}) {
    return impl.write(key: key, value: value);
  }

  Future<void> delete({required String key}) {
    return impl.delete(key: key);
  }
}
