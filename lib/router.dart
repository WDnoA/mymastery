import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/all_assets_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_edit_asset_screen.dart';
import 'screens/category_manager_screen.dart';
import 'screens/backup_restore_screen.dart';
import 'screens/login_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/user_agreement_screen.dart';

final _authRefreshProvider = Provider<AuthRefreshListenable>((ref) {
  return AuthRefreshListenable(ref);
});

class AuthRefreshListenable extends ChangeNotifier {
  final Ref _ref;

  AuthRefreshListenable(this._ref) {
    _ref.listen<AsyncValue<AuthState>>(authProvider, (_, _) {
      notifyListeners();
    });
  }
}

GoRouter createRouter(WidgetRef ref) {
  final refreshListenable = ref.watch(_authRefreshProvider);

  return GoRouter(
    refreshListenable: refreshListenable,
    initialLocation: '/',
    redirect: (context, state) {
      final auth = ref.read(authProvider).value;
      final isLoginPage = state.matchedLocation == '/login';

      // 未初始化完成，尚未锁定：放行，避免闪烁
      if (auth == null) return null;

      // 仅当「启动需解锁」且当前会话未解锁时，强制进入登录页
      final needsUnlock = auth.lockOnStartup && auth.sessionLocked;
      if (needsUnlock && !isLoginPage) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const OverviewScreen(),
          ),
          GoRoute(
            path: '/stats',
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: '/assets',
            builder: (context, state) => const AllAssetsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/assets/add',
        builder: (context, state) => const AddEditAssetScreen(),
      ),
      GoRoute(
        path: '/assets/:id/edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return AddEditAssetScreen(assetId: id);
        },
      ),
      GoRoute(
        path: '/settings/categories',
        builder: (context, state) => const CategoryManagerScreen(),
      ),
      GoRoute(
        path: '/settings/backup',
        builder: (context, state) => const BackupRestoreScreen(),
      ),
      GoRoute(
        path: '/settings/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/settings/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/settings/user-agreement',
        builder: (context, state) => const UserAgreementScreen(),
      ),
    ],
  );
}
