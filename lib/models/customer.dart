import 'order.dart';
import 'printer.dart';

class Customer {
  final String? id;
  final String email;
  final String password;
  final String role;
  final List<Order> orders;

  Customer({
    this.id,
    required this.email,
    required this.password,
    this.role = 'customer',
    this.orders = const [],
  });

  bool get isAdmin => role == 'admin';

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String?,
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
      role: map['role'] as String? ??
          (map['user_metadata'] != null && map['user_metadata'] is Map
              ? map['user_metadata']['role'] as String?
              : null) ??
          'customer',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'role': role,
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
