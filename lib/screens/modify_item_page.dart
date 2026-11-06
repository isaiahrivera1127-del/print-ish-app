import 'package:flutter/material.dart';

class ModifyItemPage extends StatelessWidget {
  const ModifyItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modify Item'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modify Product Inventory',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Select a printer or product from inventory to modify specs, price, or availability.'),
          ],
        ),
      ),
    );
  }
}
