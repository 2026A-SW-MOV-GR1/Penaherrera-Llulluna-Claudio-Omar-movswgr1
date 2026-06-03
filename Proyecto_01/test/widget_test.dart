import 'package:flutter_test/flutter_test.dart';

import 'package:proyecto_01/main.dart';

void main() {
  testWidgets('La app principal carga y muestra las secciones base', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Red y Seguridad'), findsOneWidget);
    expect(find.text('REST API'), findsOneWidget);
    expect(find.text('Secretos'), findsOneWidget);
  });
}
