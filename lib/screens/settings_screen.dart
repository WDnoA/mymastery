import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../providers/auth_provider.dart';
import '../providers/asset_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _version = '${info.version}(${info.buildNumber})');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载设置失败: $e')),
      data: (settings) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: '显示与外观',
            children: [_buildThemeTile(context, settings)],
          ),
          const SizedBox(height: 16),
          _buildSecuritySection(context),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '数值与单位',
            children: [
              _buildCurrencyTile(context, settings),
              _buildDecimalTile(context, settings),
              _buildSwitchTile(
                context,
                icon: Icons.format_list_numbered,
                iconColor: Colors.green,
                title: '使用千位分隔符',
                subtitle: '金额显示如 ¥1,234.56',
                value: settings.useSeparator,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).setUseSeparator(v),
              ),
              _buildSegmentedTile(
                context,
                icon: Icons.timer_outlined,
                iconColor: Colors.blue,
                title: '时长显示格式',
                value: settings.durationFormat,
                options: const ['天数', '日期'],
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).setDurationFormat(v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '数据管理',
            children: [
              _buildNavTile(
                context,
                icon: Icons.category_outlined,
                iconColor: Colors.orange,
                title: '分类管理',
                subtitle: '管理资产分类',
                onTap: () => context.push('/settings/categories'),
              ),
              _buildNavTile(
                context,
                icon: Icons.backup_outlined,
                iconColor: Colors.green,
                title: '备份与恢复',
                subtitle: '导出或导入数据',
                onTap: () => context.push('/settings/backup'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '关于',
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: const Text('版本信息'),
                subtitle: Text(_version.isEmpty ? '加载中...' : _version),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '安全与隐私',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SecurityCard(),
      ],
    );
  }

  Widget _buildThemeTile(BuildContext context, AppSettings settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.palette_outlined, color: Colors.purple),
          const SizedBox(width: 16),
          Expanded(
            child: Text('主题模式', style: Theme.of(context).textTheme.bodyLarge),
          ),
          SegmentedButton<AppThemeMode>(
            segments: const [
              ButtonSegment(
                value: AppThemeMode.system,
                icon: Icon(Icons.brightness_auto, size: 18),
              ),
              ButtonSegment(
                value: AppThemeMode.light,
                icon: Icon(Icons.brightness_5, size: 18),
              ),
              ButtonSegment(
                value: AppThemeMode.dark,
                icon: Icon(Icons.brightness_4, size: 18),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (v) =>
                ref.read(settingsProvider.notifier).setThemeMode(v.first),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyTile(BuildContext context, AppSettings settings) {
    final currencies = ['CNY', 'USD', 'EUR', 'JPY', 'GBP'];
    return ListTile(
      leading: const Icon(Icons.attach_money, color: Colors.amber),
      title: const Text('货币单位'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            settings.currency,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => _showCurrencyPicker(context, settings, currencies),
    );
  }

  void _showCurrencyPicker(
    BuildContext context,
    AppSettings settings,
    List<String> currencies,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '选择货币单位',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            ...currencies.map(
              (c) => ListTile(
                title: Text(c),
                trailing: c == settings.currency
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).setCurrency(c);
                  Navigator.pop(ctx);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDecimalTile(BuildContext context, AppSettings settings) {
    final options = [0, 1, 2, 3, 4];
    return ListTile(
      leading: const Icon(Icons.format_shapes, color: Colors.blue),
      title: const Text('小数点设置'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '保留 ${settings.decimalPlaces} 位',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => _showDecimalPicker(context, settings, options),
    );
  }

  void _showDecimalPicker(
    BuildContext context,
    AppSettings settings,
    List<int> options,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '小数位数',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            ...options.map(
              (n) => ListTile(
                title: Text('保留 $n 位'),
                trailing: n == settings.decimalPlaces
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).setDecimalPlaces(n);
                  Navigator.pop(ctx);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSegmentedTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ),
          SegmentedButton<String>(
            segments: options
                .map((o) => ButtonSegment<String>(value: o, label: Text(o)))
                .toList(),
            selected: {value},
            onSelectionChanged: (v) => onChanged(v.first),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class SecurityCard extends ConsumerWidget {
  const SecurityCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);

    return authAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => const Card(
        child: Padding(padding: EdgeInsets.all(16), child: Text('加载失败')),
      ),
      data: (auth) {
        final isGuest = auth.isGuest;
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // 账号状态（登录/注册）
              ListTile(
                leading: Icon(
                  isGuest ? Icons.account_circle_outlined : Icons.person,
                  color: isGuest ? Colors.grey : Colors.blue,
                ),
                title: Text(isGuest ? '未登录（游客模式）' : '当前账号：${auth.currentUser}'),
                subtitle: Text(isGuest ? '数据保存在游客空间' : '数据独立保存，仅本人可查看'),
                trailing: isGuest
                    ? TextButton(
                        onPressed: () => context.push('/login'),
                        child: const Text('登录'),
                      )
                    : null,
                onTap: isGuest
                    ? () => context.push('/login')
                    : () => handleAccountTap(context, ref, auth),
              ),
              // 登录后：修改密码
              if (!isGuest) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.key_outlined, color: Colors.orange),
                  title: const Text('修改密码'),
                  subtitle: const Text('定期更换密码更安全'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/change-password'),
                ),
              ],
              // 账号管理（切换 / 删除）（所有账号）
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.swap_horiz, color: Colors.teal),
                title: const Text('切换账号'),
                subtitle: const Text('在其他已注册账号间切换'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showAccountsSheet(context, ref),
              ),
              // 忘记密码
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.brown),
                title: const Text('忘记密码'),
                subtitle: const Text('本地账号密码无法找回'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showForgotPasswordDialog(context),
              ),
              const Divider(height: 1),
              // 启动需解锁开关
              SwitchListTile(
                secondary: const Icon(
                  Icons.lock_outline,
                  color: Colors.blueGrey,
                ),
                title: const Text('启动需解锁'),
                subtitle: const Text('开启后打开 App 需登录账号方可进入'),
                value: auth.lockOnStartup,
                onChanged: (v) async {
                  await ref.read(authProvider.notifier).setLockOnStartup(v);
                },
              ),
              // 登出
              if (!isGuest) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    '退出登录',
                    style: TextStyle(color: Colors.red),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.red),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('确认退出'),
                        content: Text('退出后将回到游客空间，是否继续？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('退出'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ref.read(authProvider.notifier).logout();
                    }
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// 点击当前账号行：未登录进登录页，已登录进入切换账号面板
  void handleAccountTap(BuildContext context, WidgetRef ref, AuthState auth) {
    if (auth.isGuest) {
      context.push('/login');
    } else {
      showAccountsSheet(context, ref);
    }
  }

  /// 底部弹出所有已注册账号，可切换或删除
  Future<void> showAccountsSheet(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(authProvider.notifier);
    final currentAuth = ref.read(authProvider).value;
    final usernames = await notifier.getUsernames();

    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '账号管理',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            if (usernames.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('暂无已注册账号，请先注册'),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: usernames.map((name) {
                    final isCurrent = name == currentAuth?.currentUser;
                    return ListTile(
                      leading: Icon(
                        isCurrent ? Icons.person : Icons.person_outline,
                        color: isCurrent ? Colors.blue : Colors.grey,
                      ),
                      title: Text(name),
                      subtitle: Text(isCurrent ? '当前账号' : '点击切换'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCurrent)
                            const Icon(Icons.check, color: Colors.green)
                          else ...[
                            IconButton(
                              icon: const Icon(
                                Icons.swap_horiz,
                                color: Colors.teal,
                              ),
                              tooltip: '切换到此账号',
                              onPressed: () async {
                                Navigator.pop(ctx);
                                await _verifyPasswordAndSwitch(
                                  context,
                                  ref,
                                  name,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              tooltip: '删除账号',
                              onPressed: () async {
                                Navigator.pop(ctx);
                                await _verifyPasswordAndDelete(
                                  context,
                                  ref,
                                  name,
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// 输入密码校验后切换到此账号
  Future<void> _verifyPasswordAndSwitch(
    BuildContext context,
    WidgetRef ref,
    String username,
  ) async {
    final password = await _promptPassword(
      context,
      '切换账号',
      '请输入 $username 的密码',
    );
    if (password == null || !context.mounted) return;

    final err = await ref
        .read(authProvider.notifier)
        .switchAccount(username, password);
    if (err != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('切换失败：$err')));
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('已切换到 $username')));
    }
  }

  /// 输入密码校验后删除账号（连同其本地数据）
  Future<void> _verifyPasswordAndDelete(
    BuildContext context,
    WidgetRef ref,
    String username,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除账号'),
        content: Text('将删除账号「$username」及其在本机的全部资产数据，此操作不可恢复。是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final password = await _promptPassword(
      context,
      '删除账号',
      '请输入 $username 的密码以确认',
    );
    if (password == null || !context.mounted) return;

    final err = await ref
        .read(authProvider.notifier)
        .deleteAccount(username, password);
    if (err != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('删除失败：$err')));
      }
      return;
    }
    // 删除账号的本地数据
    await ref.read(databaseProvider).deleteDataByOwner(username);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('已删除账号 $username')));
    }
  }

  /// 弹密码输入对话框，返回输入值；取消返回 null
  Future<String?> _promptPassword(
    BuildContext context,
    String title,
    String hint,
  ) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: InputDecoration(labelText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  /// 忘记密码说明弹窗
  void showForgotPasswordDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('忘记密码'),
        content: const Text(
          '本 App 为纯本地存储，密码不会上传服务器，也无法找回。\n\n'
          '若忘记密码，可通过「切换账号 → 删除」删除该账号并重新注册，'
          '但该账号下的全部资产数据将一并删除，请谨慎操作。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}
