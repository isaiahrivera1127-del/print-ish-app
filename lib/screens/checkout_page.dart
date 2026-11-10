import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
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

  String paymentMethod = 'Credit Card';

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
    final supabase = Supabase.instance.client;

if (_nameController.text.isEmpty ||
    _emailController.text.isEmpty ||
    _addressController.text.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Please complete all required fields'),
    ),
  );
  return;
}


    final order = await supabase
        .from('orders')
        .insert({
          'order_number': 'ORD-${DateTime.now().millisecondsSinceEpoch.toString()}',
          'name': _nameController.text,
          'email': _emailController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'zip': _zipController.text,
          'payment_method': paymentMethod,
          'price': widget.cart.getTotal(),
        })
        .select()
        .single();


    final orderId = order['id'];

    for (final item in widget.cart.currentOrder) {
      await supabase.from('order_items').insert({
        'order_id': orderId,
        'printer_id': item.printer.printerID,
        'quantity': item.quantity,
        'price': item.printer.price,
      });
    }

    widget.cart.clear();
    _nameController.clear();
    _emailController.clear();
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
  } 





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
              ),
            ),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),

            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Street Address',
              ),
            ),

            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City',
              ),
            ),

            TextField(
              controller: _stateController,
              decoration: const InputDecoration(
                labelText: 'State',
              ),
            ),

            TextField(
              controller: _zipController,
              decoration: const InputDecoration(
                labelText: 'ZIP Code',
              ),
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
    );
  }
}