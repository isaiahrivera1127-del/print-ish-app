
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://sisfpvzjrclalrcdbqyl.supabase.co',
    publishableKey: 'sb_publishable_jPzaTRQiKMVaFNR4vO5MKg_DlYXip2L',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('Printer Application'),
        ),
      ),
    );
  }
}
