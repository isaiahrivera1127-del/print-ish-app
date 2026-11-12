import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/printer.dart';

class PrinterService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Printer>> getPrinters() async {
      final data = await supabase
          .from('printers')
          .select();

      return (data as List).map((row) => Printer.fromMap(row)).toList();
    }

  Future<void> addPrinter({
    required String brand,
    required String model,
    required String printerType,
    required double price,
    required String description,
    required bool isAvailable,
    required int stock,
  }) async {
    await supabase.from('printers').insert({
      'brand': brand,
      'model': model,
      'printer_type': printerType,
      'price': price,
      'description': description,
      'is_available': isAvailable,
      'stock': stock,
    });
  }

  Future<void> deletePrinter(int printerID) async {
    final deletedRows = await supabase
        .from('printers')
        .delete()
        .eq('id', printerID)
        .select('id');

    if (deletedRows.isEmpty) {
      throw Exception('No printer was deleted.');
    }
  }

  }

