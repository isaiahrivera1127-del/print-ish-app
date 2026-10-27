
import 'cart_item.dart';
import 'printer.dart';

class ShopCart {
  final List<CartItem> currentOrder = [];

  void addItem(Printer printer, int quantity) {
    currentOrder.add(
      CartItem(
        printer: printer,
        quantity: quantity,
      ),
    );
  }

  void removeItem(int printerID) {
    currentOrder.removeWhere(
          (item) => item.printer.printerID == printerID,
    );
  }

  void updateQuantity(int printerID, int quantity) {
    for (final item in currentOrder) {
      if (item.printer.printerID == printerID) {
        item.updateQuantity(quantity);
        return;
      }
    }
  }

  double getTotal() {
    double total = 0;

    for (final item in currentOrder) {
      total += item.getSubtotal();
    }

    return total;
  }

  void clear() {
    currentOrder.clear();
  }
}
