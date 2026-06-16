import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:churchs_mng/core/di/injector.dart';
import 'package:churchs_mng/main.dart';

void main() {
  setupInjector();

  testWidgets('Tela inicial pública é exibida sem login (RF-002)', (WidgetTester tester) async {
    await initializeDateFormatting('pt_BR');
    await tester.pumpWidget(const ChurchsMngApp());
    await tester.pumpAndSettle();

    expect(find.text('IBBE Connect'), findsWidgets);
    expect(find.text('Avisos e Eventos'), findsOneWidget);
  });
}
