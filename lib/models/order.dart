import 'cart_item.dart';

class Order {
  final String orderNumber;
  final String customerEmail;
  final double totalPrice;
  final DateTime orderDate;
  final List<CartItem> items;

  // Getter for email alias
  String get email => customerEmail;

  Order({
    required this.orderNumber,
    required this.customerEmail,
    required this.totalPrice,
    required this.orderDate,
    this.items = const [],
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderNumber: map['order_number'] as String? ??
          map['order_id'] as String? ??
          map['id']?.toString() ??
          '',
      customerEmail: map['customer_email'] as String? ??
          map['email'] as String? ??
          map['user_email'] as String? ??
          '',
      totalPrice: (map['total_price'] as num?)?.toDouble() ??
          (map['total'] as num?)?.toDouble() ??
          (map['price'] as num?)?.toDouble() ??
          (map['amount'] as num?)?.toDouble() ??
          0.0,
      orderDate: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : (map['date'] != null
              ? DateTime.parse(map['date'] as String)
              : DateTime.now()),
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
