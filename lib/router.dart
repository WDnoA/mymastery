import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/all_assets_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_edit_asset_screen.dart';
import 'screens/category_manager_screen.dart';
import 'screens/backup_restore_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => HomeScreen(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const OverviewScreen()),
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
  ],
);
