import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/app_spacing.dart';
import '../../models/printer.dart';
import '../../services/printer_service.dart';
import 'add_printer_page.dart';

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

  Future<void> _deletePrinter(Printer printer) async {
    // First confirmation
    final firstConfirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Printer?'),
          content: Text(
            'Are you sure you want to delete '
                '${printer.brand} ${printer.model}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (firstConfirmation != true || !mounted) return;

    // Second confirmation
    final secondConfirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are You Absolutely Sure?'),
          content: const Text(
            'This action cannot be undone. '
                'The printer will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete Permanently'),
            ),
          ],
        );
      },
    );

    if (secondConfirmation != true || !mounted) return;

    // Perform deletion
    try {
      await PrinterService().deletePrinter(printer.printerID);

      if (!mounted) return;

      setState(() {
        printersFuture = PrinterService().getPrinters();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Printer deleted successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to delete printer. Please try again.'),
        ),
      );
    }
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
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPrinterPage(),
                ),
              );

              if (result == true && mounted) {
                setState(() {
                  printersFuture = PrinterService().getPrinters();
                });
              }
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
                            _deletePrinter(printer);
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