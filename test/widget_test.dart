import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:print_ish_app/main.dart';

void main() {
  testWidgets('App initializes MaterialApp cleanly', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Supabase.initialize(
      url: 'https://sisfpvzjrclalrcdbqyl.supabase.co',
      anonKey: 'sb_publishable_jPzaTRQiKMVaFNR4vO5MKg_DlYXip2L',
    );

    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
}
