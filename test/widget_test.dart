import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mymastery/app.dart';

void main() {
  testWidgets('App 启动不崩溃', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    // 等待初始帧渲染完成即可，不等待异步数据加载
    await tester.pump();
  });
}
