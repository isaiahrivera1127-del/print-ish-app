import 'package:flutter/material.dart';

class LookupOrderPage extends StatelessWidget {
  const LookupOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lookup Order'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Search & Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Enter an order number or customer email to view order history and details.'),
          ],
        ),
      ),
    );
  }
}
