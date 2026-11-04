import 'cart_item.dart';

class Order {
  final String orderNumber;
  final String customerEmail;
  final double totalPrice;
  final DateTime orderDate;
  final List<CartItem> items;

  Order({
    required this.orderNumber,
    required this.customerEmail,
    required this.totalPrice,
    required this.orderDate,
    this.items = const [],
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderNumber: map['order_number'] as String? ?? '',
      customerEmail: map['customer_email'] as String? ?? '',
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0.0,
      orderDate: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order_number': orderNumber,
      'customer_email': customerEmail,
      'total_price': totalPrice,
      'created_at': orderDate.toIso8601String(),
    };
  }
}
