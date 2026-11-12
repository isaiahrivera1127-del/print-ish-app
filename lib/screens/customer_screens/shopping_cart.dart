import 'package:flutter/material.dart';
import 'checkout_page.dart';
import '../../models/cart.dart';

class ShoppingCartPage extends StatefulWidget {
  final ShopCart cart;

  const ShoppingCartPage({
    super.key,
    required this.cart,
  });

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: widget.cart.currentOrder.isEmpty
          ? const Center(
              child: Text('Your cart is empty'),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cart.currentOrder.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart.currentOrder[index];

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text('${item.printer.brand} ${item.printer.model}'),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Price: \$${item.printer.price.toStringAsFixed(2)}'),
                              Text('Quantity: ${item.quantity}'),
                              Text(
                                  'Subtotal: \$${item.getSubtotal().toStringAsFixed(2)}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                if (item.quantity > 1) {
                                  widget.cart.updateQuantity(
                                   item.printer.printerID,
                                    item.quantity - 1,
                                     );
                                    } else {
                                widget.cart.removeItem(
                                  item.printer.printerID,
                                     );
                                }
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Total: \$${widget.cart.getTotal().toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                     ElevatedButton(
                        onPressed: () {
                             Navigator.push(
                               context,
                              MaterialPageRoute(
                      builder: (context) => CheckoutPage(
                   cart: widget.cart,
                                              ),
                                            ),
                                         );
                                    },
                 child: const Text('Checkout'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}