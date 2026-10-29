
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/app_spacing.dart';
import '../models/printer.dart';
import '../services/printer_service.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Print-ish'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search printers...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.textWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.small,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.small),

                IconButton(
                  onPressed: (){},
                  icon: const Icon(Icons.filter_list),
                  color: AppColors.tertiary,
                  iconSize: 28,
                  tooltip: 'Filter printers',
                ),

                IconButton(
                  onPressed: (){},
                  icon: const Icon(Icons.shopping_cart),
                  color: AppColors.secondary,
                  iconSize: 28,
                  tooltip: 'Shopping cart',
                ),
              ],
            ),


            const SizedBox(height: AppSpacing.medium),

            Expanded(
              child: FutureBuilder<List<Printer>>(
                future: PrinterService().getPrinters(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final printers = snapshot.data ?? [];

                  if (printers.isEmpty) {
                    return const Center(
                      child: Text('No printers available'),
                    );
                  }

                  return ListView.builder(
                    itemCount: printers.length,
                    itemBuilder: (context, index) {
                      final printer = printers[index];

                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.print),
                          title: Text('${printer.brand} ${printer.model}'),
                          subtitle: Text(
                            '${printer.category}\n${printer.specs}',
                          ),
                          isThreeLine: true,
                          trailing: Text(
                            '\$${printer.price.toStringAsFixed(2)}',
                          ),
                        ),
                      );
                    },
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
