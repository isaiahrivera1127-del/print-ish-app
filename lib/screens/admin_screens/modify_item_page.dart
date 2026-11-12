import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/app_spacing.dart';
import '../../models/printer.dart';
import '../../services/printer_service.dart';

class ModifyItemPage extends StatefulWidget {
  const ModifyItemPage({super.key});

  @override
  State<ModifyItemPage> createState() => _ModifyItemPageState();
}

class _ModifyItemPageState extends State<ModifyItemPage> {
  late Future<List<Printer>> printersFuture;

  @override
  void initState() {
    super.initState();
    printersFuture = PrinterService().getPrinters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Modify Items'),
        centerTitle: true,
        backgroundColor: AppColors.admin,
        foregroundColor: AppColors.textWhite,
        actions: [
          IconButton(
            onPressed: () {
              // Add printer functionality will go here.
            },
            icon: const Icon(Icons.add),
            tooltip: 'Add Printer',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: FutureBuilder<List<Printer>>(
          future: printersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Unable to load printers. Please try again later.',
                  style: TextStyle(color: AppColors.textBlack),
                ),
              );
            }

            final printers = snapshot.data ?? [];

            if (printers.isEmpty) {
              return const Center(
                child: Text('No printers found.'),
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${printer.price.toStringAsFixed(2)}',
                        ),
                        IconButton(
                          onPressed: () {
                            // Delete functionality will go here.
                          },
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          tooltip: 'Delete Printer',
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}