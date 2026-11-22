import 'package:flutter_test/flutter_test.dart';
import 'package:print_ish_app/models/printer.dart';

void main() {
  test('Printer.fromMap correctly creates a Printer', () {
    final printer = Printer.fromMap({
      'id': 1,
      'brand': 'HP',
      'model': 'LaserJet Pro',
      'printer_type': 'Laser',
      'price': 249.99,
      'description': 'Office laser printer',
      'stock': 10,
      'is_available': true,
    });

    expect(printer.printerID, 1);
    expect(printer.brand, 'HP');
    expect(printer.model, 'LaserJet Pro');
    expect(printer.category, 'Laser');
    expect(printer.price, 249.99);
    expect(printer.specs, 'Office laser printer');
    expect(printer.stock, 10);
    expect(printer.inStock, true);
  });
}