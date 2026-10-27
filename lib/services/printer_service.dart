
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/printer.dart';

class PrinterService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Printer>> getPrinters() async {
    final data = await supabase
        .from('printers')
        .select();

    return data.map((row) => Printer.fromMap(row)).toList();
  }
}
