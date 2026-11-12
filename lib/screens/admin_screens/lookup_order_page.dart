import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/app_spacing.dart';
import '../../models/order.dart';

class LookupOrderPage extends StatefulWidget {
  const LookupOrderPage({super.key});

  @override
  State<LookupOrderPage> createState() => _LookupOrderPageState();
}

class _LookupOrderPageState extends State<LookupOrderPage> {
  final TextEditingController _searchController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;

  String _searchQuery = '';
  bool _isLoading = false;
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Fetch Orders from Supabase ---
  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);

    try {
      final response = await _supabase.from('orders').select();
      final List<dynamic> data = response as List<dynamic>;

      setState(() {
        _orders = data
            .map((item) => Order.fromMap(item as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      debugPrint('Error fetching orders from Supabase: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- Show Detailed Order Info ---
  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.receipt_long, color: Colors.deepOrange),
            const SizedBox(width: 8),
            Text('Order #${order.orderNumber}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            Text(order.email, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            Text(
              'Date Placed:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            Text(
              '${order.orderDate.month}.${order.orderDate.day.toString().padLeft(2, '0')}.${order.orderDate.year.toString().padLeft(2, '0')} ${order.orderDate.hour}:${order.orderDate.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Text(
              'Total Amount:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            Text(
              '\$${order.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _orders.where((order) {
      final query = _searchQuery.toLowerCase();
      return order.orderNumber.toLowerCase().contains(query) ||
          order.email.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lookup Orders'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Orders',
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Lookup',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Search orders by order number or customer email',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.medium),

            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search order # or email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
            const SizedBox(height: AppSpacing.medium),

            // Orders List View
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredOrders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'No orders found in database'
                                    : 'No orders matching "$_searchQuery"',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.deepOrange.shade100,
                                  child: const Icon(
                                    Icons.receipt,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                title: Text(
                                  'Order #${order.orderNumber}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(
                                  '${order.email}\n${order.orderDate.toString().split(' ')[0]}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                isThreeLine: true,
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${order.totalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                                onTap: () => _showOrderDetails(order),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
