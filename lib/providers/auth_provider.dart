import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 认证状态模型
class AuthState {
  const AuthState({
    required this.loaded,
    this.currentUser,
    required this.accountCount,
    required this.lockOnStartup,
    required this.sessionLocked,
  });

  /// 是否已完成初始化（从本地读取）
  final bool loaded;

  /// 当前登录账号名；null 表示游客
  final String? currentUser;

  /// 已注册账号数量
  final int accountCount;

  /// 是否开启「启动需解锁」（可选保护，默认关闭，不影响直接进入主界面）
  final bool lockOnStartup;

  /// 当前会话是否被锁定（需登录解锁）
  final bool sessionLocked;

  /// 是否处于游客状态
  bool get isGuest => currentUser == null;

  /// 当前数据归属空间：游客为 guest，登录后为账号名
  String get owner => currentUser ?? 'guest';

  AuthState copyWith({
    bool? loaded,
    String? Function()? currentUser,
    int? accountCount,
    bool? lockOnStartup,
    bool? sessionLocked,
  }) {
    return AuthState(
      loaded: loaded ?? this.loaded,
      currentUser: currentUser != null ? currentUser() : this.currentUser,
      accountCount: accountCount ?? this.accountCount,
      lockOnStartup: lockOnStartup ?? this.lockOnStartup,
      sessionLocked: sessionLocked ?? this.sessionLocked,
    );
  }
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  static const _keyAccounts = 'accounts';
  static const _keyCurrentUser = 'current_user';
  static const _keyLockOnStartup = 'lock_on_startup';

  final _storage = const FlutterSecureStorage();

  @override
  Future<AuthState> build() async {
    return _loadState();
  }

  Future<AuthState> _loadState() async {
    final currentUser = await _storage.read(key: _keyCurrentUser);
    final lockRaw = await _storage.read(key: _keyLockOnStartup);
    final lockOnStartup = lockRaw == 'true';
    final accounts = await _loadAccounts();

    final state = AuthState(
      loaded: true,
      currentUser: currentUser,
      accountCount: accounts.length,
      lockOnStartup: lockOnStartup,
      // 开启启动锁时，冷启动需解锁
      sessionLocked: lockOnStartup && currentUser != null,
    );
    return state;
  }

  Future<Map<String, String>> _loadAccounts() async {
    final raw = await _storage.read(key: _keyAccounts);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded.map((k, v) => MapEntry(k, v.toString()));
      }
    } catch (_) {}
    return {};
  }

  Future<void> _saveAccounts(Map<String, String> accounts) async {
    await _storage.write(key: _keyAccounts, value: jsonEncode(accounts));
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  /// 注册新账号（用户名不可重复）
  Future<String?> register(String username, String password) async {
    final name = username.trim();
    if (name.isEmpty) return '用户名不能为空';
    if (password.length < 4) return '密码至少 4 位';

    final accounts = await _loadAccounts();
    if (accounts.containsKey(name)) return '该用户名已被注册';

    accounts[name] = _hashPassword(password);
    await _saveAccounts(accounts);

    await _storage.write(key: _keyCurrentUser, value: name);
    state = AsyncData(
      state.value!.copyWith(
        currentUser: () => name,
        accountCount: accounts.length,
        sessionLocked: false,
      ),
    );
    return null;
  }

  /// 账号密码登录
  Future<String?> login(String username, String password) async {
    final name = username.trim();
    final accounts = await _loadAccounts();
    final hash = accounts[name];
    if (hash == null) return '该账号不存在';

    if (hash != _hashPassword(password)) return '密码错误';

    await _storage.write(key: _keyCurrentUser, value: name);
    state = AsyncData(
      state.value!.copyWith(currentUser: () => name, sessionLocked: false),
    );
    return null;
  }

  /// 退出登录，回到游客空间
  Future<void> logout() async {
    await _storage.delete(key: _keyCurrentUser);
    state = AsyncData(
      state.value!.copyWith(currentUser: () => null, sessionLocked: false),
    );
  }

  /// 开启/关闭「启动需解锁」
  Future<void> setLockOnStartup(bool enabled) async {
    await _storage.write(key: _keyLockOnStartup, value: enabled.toString());
    state = AsyncData(state.value!.copyWith(lockOnStartup: enabled));
  }

  /// 会话锁（下次进入需解锁）
  Future<void> lock() async {
    state = AsyncData(state.value!.copyWith(sessionLocked: true));
  }

  /// 会话解锁
  void unlock() {
    state = AsyncData(state.value!.copyWith(sessionLocked: false));
  }

  /// 修改当前账号密码
  Future<String?> changePassword(String oldPassword, String newPassword) async {
    final name = state.value?.currentUser;
    if (name == null) return '请先登录';
    if (newPassword.length < 4) return '新密码至少 4 位';

    final accounts = await _loadAccounts();
    final hash = accounts[name];
    if (hash == null) return '账号不存在';
    if (hash != _hashPassword(oldPassword)) return '原密码错误';

    accounts[name] = _hashPassword(newPassword);
    await _saveAccounts(accounts);
    return null;
  }

  /// 返回所有已注册用户名
  Future<List<String>> getUsernames() async {
    final accounts = await _loadAccounts();
    return accounts.keys.toList();
  }

  /// 切换到指定账号（需校验密码），返回错误信息，null 表示成功
  Future<String?> switchAccount(String username, String password) async {
    final name = username.trim();
    final accounts = await _loadAccounts();
    final hash = accounts[name];
    if (hash == null) return '该账号不存在';
    if (hash != _hashPassword(password)) return '密码错误';

    await _storage.write(key: _keyCurrentUser, value: name);
    state = AsyncData(
      state.value!.copyWith(currentUser: () => name, sessionLocked: false),
    );
    return null;
  }

  /// 删除账号及其本地数据（需密码校验，且不能删除当前已登录账号）
  Future<String?> deleteAccount(String username, String password) async {
    final name = username.trim();
    if (name == state.value?.currentUser) return '请先退出当前账号后再删除';

    final accounts = await _loadAccounts();
    final hash = accounts[name];
    if (hash == null) return '该账号不存在';
    if (hash != _hashPassword(password)) return '密码错误';

    accounts.remove(name);
    await _saveAccounts(accounts);

    state = AsyncData(state.value!.copyWith(accountCount: accounts.length));
    return null;
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
