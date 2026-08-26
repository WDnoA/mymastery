import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('隐私政策')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '隐私政策',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '最后更新日期：2026年8月24日',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            _buildSection(context, '1. 信息收集', [
              '本应用（"资产"）是一款纯本地个人资产管理工具，不会收集、上传或共享您的任何个人数据。',
              '',
              '所有数据（包括资产信息、分类、账号密码等）均存储在您的设备本地，不会发送到任何服务器。',
            ]),
            _buildSection(context, '2. 数据存储', [
              '• 资产数据：使用 SQLite 数据库存储在设备本地',
              '• 账号密码：使用 SHA-256 加密后存储在设备安全存储区',
              '• 设置信息：使用 SharedPreferences 存储在设备本地',
              '',
              '我们建议您定期使用"备份与恢复"功能导出数据，以防设备丢失或损坏。',
            ]),
            _buildSection(context, '3. 权限使用', [
              '本应用仅请求以下必要权限：',
              '',
              '• 存储权限：用于备份数据的导入/导出',
              '',
              '我们不会请求与核心功能无关的权限。',
            ]),
            _buildSection(context, '4. 第三方服务', [
              '本应用不使用任何第三方分析、广告或追踪服务。',
              '',
              '所有功能均由应用自身实现，不依赖外部服务。',
            ]),
            _buildSection(context, '5. 数据安全', [
              '• 密码使用 SHA-256 算法加密存储',
              '• 支持多账号数据隔离',
              '• 可选启用"启动需解锁"保护数据',
              '',
              '请注意：由于数据完全存储在本地，如果您忘记密码，我们将无法帮您恢复。',
            ]),
            _buildSection(context, '6. 儿童隐私', [
              '本应用不面向 13 岁以下儿童，也不会故意收集儿童个人信息。',
            ]),
            _buildSection(context, '7. 政策更新', [
              '我们可能会不时更新本隐私政策。更新后的政策将在应用内发布，重大变更会通过应用内通知告知。',
            ]),
            _buildSection(context, '8. 联系我们', [
              '如果您对本隐私政策有任何疑问，请通过以下方式联系我们：',
              '',
              '• 应用内反馈：设置 → 反馈与支持',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<String> content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...content.map(
            (line) => Text(
              line,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
