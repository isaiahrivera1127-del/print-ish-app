import 'customer.dart';

class Admin extends Customer {
  Admin({
    required super.email,
    required super.password,
    super.orders = const [],
  });

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
    );
  }
}