
import 'printer.dart';

class CartItem {
  final Printer printer;
  int quantity;

  CartItem({
    required this.printer,
    required this.quantity,
  });

  double getSubtotal() {
    return printer.price * quantity;
  }

  void updateQuantity(int quantity) {
    this.quantity = quantity;
  }
}
