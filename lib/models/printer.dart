
class Printer {
  final int printerID;
  final String category;
  final double price;
  final String specs;
  final int stock;
  final bool inStock;

  Printer({
    required this.printerID,
    required this.category,
    required this.price,
    required this.specs,
    required this.stock,
    required this.inStock,
  });

  factory Printer.fromMap(Map<String, dynamic> map) {
    return Printer(
      printerID: (map['id'] as num).toInt(),
      category: map['printer_type'] as String,
      price: (map['price'] as num).toDouble(),
      specs: map['description'] as String,
      stock: (map['stock'] as num).toInt(),
      inStock: map['is_available'] as bool,
    );
  }
}
