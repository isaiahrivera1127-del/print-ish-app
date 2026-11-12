import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart.dart';

class CheckoutPage extends StatefulWidget {
  final ShopCart cart;

  const CheckoutPage({
    super.key,
    required this.cart,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String paymentMethod = 'Credit Card';

  @override
  void initState() {
    super.initState();
    // Auto-fill signed-in user email
    final user = Supabase.instance.client.auth.currentUser;
    if (user?.email != null) {
      _emailController.text = user!.email!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    try {
      final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      final customerEmail = _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : (user?.email ?? 'guest@printish.com');

      Map<String, dynamic>? order;

      final Map<String, dynamic> insertData = {
        'order_number': orderNumber,
        'name': _nameController.text.trim(),
        'email': customerEmail,
        'customer_email': customerEmail,
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zip': _zipController.text.trim(),
        'payment_method': paymentMethod,
        'price': widget.cart.getTotal(),
        'total_price': widget.cart.getTotal(),
        'created_at': DateTime.now().toIso8601String(),
      };

      try {
        order = await supabase
            .from('orders')
            .insert(insertData)
            .select()
            .single();
      } catch (_) {
        // Fallback without duplicate keys if schema is strict
        order = await supabase
            .from('orders')
            .insert({
              'order_number': orderNumber,
              'name': _nameController.text.trim(),
              'email': customerEmail,
              'price': widget.cart.getTotal(),
              'address': _addressController.text.trim(),
              'city': _cityController.text.trim(),
              'state': _stateController.text.trim(),
              'zip': _zipController.text.trim(),
              'payment_method': paymentMethod,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();
      }

      if (order['id'] != null) {
        final orderId = order['id'];

        for (final item in widget.cart.currentOrder) {
          try {
            await supabase.from('order_items').insert({
              'order_id': orderId,
              'printer_id': item.printer.printerID,
              'quantity': item.quantity,
              'price': item.printer.price,
            });
          } catch (e) {
            debugPrint('Order items insert error: $e');
          }
        }
      }

      widget.cart.clear();
      _nameController.clear();
      _addressController.clear();
      _cityController.clear();
      _stateController.clear();
      _zipController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
          ),
        );
        Navigator.popUntil(
          context,
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing order: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value.trim())) {
                    return 'Name can only contain letters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Email TextFormField - Pre-filled with signed in user's email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                readOnly: user != null,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(),
                  helperText: user != null
                      ? 'Signed in as ${user.email}'
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  final emailRegex = RegExp(
                    r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Shipping Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Address is required';
                  }
                  bool hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
                  bool hasNumber = RegExp(r'[0-9]').hasMatch(value);
                  if (!hasLetter || !hasNumber) {
                    return 'Address must contain letters and numbers';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'City is required';
                  }
                  if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value.trim())) {
                    return 'City can only contain letters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'State is required';
                  }
                  if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value.trim())) {
                    return 'State can only contain letters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _zipController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ZIP Code',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ZIP Code is required';
                  }
                  if (!RegExp(r'^\d{5}$').hasMatch(value)) {
                    return 'Enter a valid 5-digit ZIP Code';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Credit Card',
                    child: Text('Credit Card'),
                  ),
                  DropdownMenuItem(
                    value: 'Debit Card',
                    child: Text('Debit Card'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value!;
                  });
                },
              ),

              const SizedBox(height: 30),

              Text(
                'Total: \$${widget.cart.getTotal().toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: placeOrder,
                child: const Text('Place Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
