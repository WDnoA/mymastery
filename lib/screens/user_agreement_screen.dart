import 'package:flutter/material.dart';

class UserAgreementScreen extends StatelessWidget {
  const UserAgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('用户协议')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '用户协议',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '最后更新日期：2026年8月24日',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            _buildSection(context, '1. 协议接受', [
              '欢迎使用"资产"个人资产管理应用（以下简称"本应用"）。',
              '',
              '通过使用本应用，您表示同意接受本协议的所有条款。如果您不同意本协议的任何内容，请勿使用本应用。',
            ]),
            _buildSection(context, '2. 服务说明', [
              '本应用是一款纯本地个人资产管理工具，提供以下功能：',
              '',
              '• 资产记录与管理',
              '• 资产分类与统计',
              '• 数据备份与恢复',
              '• 多账号数据隔离',
              '• 密码保护与生物识别',
              '',
              '所有功能均在设备本地运行，不依赖网络连接。',
            ]),
            _buildSection(context, '3. 用户责任', [
              '• 您应妥善保管您的账号密码，因密码泄露导致的损失由您自行承担',
              '• 您应定期备份重要数据，防止设备丢失或损坏导致数据丢失',
              '• 您应确保使用本应用的行为符合当地法律法规',
              '• 您不得利用本应用从事任何违法违规活动',
            ]),
            _buildSection(context, '4. 数据与隐私', [
              '• 所有数据存储在您的设备本地，我们不会收集或上传您的数据',
              '• 密码使用 SHA-256 加密存储，但我们仍建议您设置强密码',
              '• 如果您忘记密码，我们将无法帮您恢复，您可能需要删除账号重新注册',
              '',
              '详情请参阅《隐私政策》。',
            ]),
            _buildSection(context, '5. 知识产权', [
              '本应用的代码、界面设计、图标等知识产权归开发者所有。',
              '',
              '您仅获得本应用的使用权，不得对本应用进行反向工程、反编译或反汇编。',
            ]),
            _buildSection(context, '6. 免责声明', [
              '• 本应用按"现状"提供，不提供任何明示或暗示的保证',
              '• 因设备故障、系统升级、操作失误等导致的数据丢失，我们不承担责任',
              '• 因不可抗力导致的服务中断，我们不承担责任',
              '',
              '我们建议您定期备份重要数据。',
            ]),
            _buildSection(context, '7. 协议修改', [
              '我们保留随时修改本协议的权利。修改后的协议将在应用内发布，自发布之日起生效。',
              '',
              '如果您继续使用本应用，即表示您接受修改后的协议。',
            ]),
            _buildSection(context, '8. 联系我们', [
              '如果您对本协议有任何疑问，请通过以下方式联系我们：',
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
