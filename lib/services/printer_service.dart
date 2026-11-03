import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/printer.dart';

class PrinterService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Printer>> getPrinters() async {
    try {
      final data = await supabase
          .from('printers')
          .select();

      return (data as List).map((row) => Printer.fromMap(row)).toList();
    } catch (e) {
      print('Error fetching printers: $e');
      rethrow;
    }
  }
}
