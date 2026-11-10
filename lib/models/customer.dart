import 'order.dart';
import 'printer.dart';

class Customer {
  final String? id;
  final String email;
  final String password;
  final List<Order> orders;

  Customer({
    this.id,
    required this.email,
    required this.password,
    this.orders = const [],
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String?,
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
    };
  }

  void checkoutPage() {
    // TODO: implement checkoutPage
  }

  List<Printer> filterCategory(String category) {
    // TODO: implement filterCategory
    return [];
  }

  void previousOrder(String orderNumber) {
    // TODO: implement previousOrder
  }
}
