
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/app_spacing.dart';
import '../../models/printer.dart';
import '../../widgets/edit_field_dialog.dart';
import '../../services/printer_service.dart';

class AdminPrinterDetailsPage extends StatefulWidget {
  final Printer printer;

  const AdminPrinterDetailsPage({
    super.key,
    required this.printer,
  });

  @override
  State<AdminPrinterDetailsPage> createState() =>
      _AdminPrinterDetailsPageState();
}

class _AdminPrinterDetailsPageState
    extends State<AdminPrinterDetailsPage> {
  late String brand;
  late String model;
  late String printerType;
  late double price;
  late String description;
  late int stock;
  late bool isAvailable;

  @override
  void initState() {
    super.initState();
    brand = widget.printer.brand;
    model = widget.printer.model;
    printerType = widget.printer.category;
    price = widget.printer.price;
    description = widget.printer.specs;
    stock = widget.printer.stock;
    isAvailable = widget.printer.inStock;
  }


  Future<void> _editBrand() async {
    final newBrand = await EditFieldDialog.show(
      context: context,
      title: 'Edit Brand',
      initialValue: brand,
      labelText: 'Brand',
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Brand cannot be empty.';
        }
        return null;
      },
    );

    if (newBrand == null || !mounted) return;

    try {
      await PrinterService().updatePrinter(
        widget.printer.printerID,
        {'brand': newBrand},
      );

      if (!mounted) return;

      setState(() {
        brand = newBrand;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Brand updated successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update brand. Please try again.'),
        ),
      );
    }
  }



  Future<void> _editModel() async {
    final newModel = await EditFieldDialog.show(
      context: context,
      title: 'Edit Model',
      initialValue: model,
      labelText: 'Model',
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Model cannot be empty.';
        }
        return null;
      },
    );

    if (newModel == null || !mounted) return;

    try {
      await PrinterService().updatePrinter(
        widget.printer.printerID,
        {'model': newModel},
      );

      if (!mounted) return;

      setState(() {
        model = newModel;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Model updated successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update model. Please try again.'),
        ),
      );
    }
  }



  Future<void> _editPrinterType() async {
    final newPrinterType = await EditFieldDialog.show(
      context: context,
      title: 'Edit Printer Type',
      initialValue: printerType,
      labelText: 'Printer Type',
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Printer type cannot be empty.';
        }
        return null;
      },
    );

    if (newPrinterType == null || !mounted) return;

    try {
      await PrinterService().updatePrinter(
        widget.printer.printerID,
        {'printer_type': newPrinterType},
      );

      if (!mounted) return;

      setState(() {
        printerType = newPrinterType;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Printer type updated successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update printer type. Please try again.'),
        ),
      );
    }
  }



  Future<void> _editPrice() async {
    final newPrice = await EditFieldDialog.show(
      context: context,
      title: 'Edit Price',
      initialValue: price.toString(),
      labelText: 'Price',
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      validator: (value) {
        final parsedPrice = double.tryParse(value ?? '');

        if (parsedPrice == null) {
          return 'Enter a valid price.';
        }

        if (parsedPrice < 0) {
          return 'Price cannot be negative.';
        }

        return null;
      },
    );

    if (newPrice == null || !mounted) return;

    final parsedPrice = double.tryParse(newPrice);

    if (parsedPrice == null) return;

    try {
      await PrinterService().updatePrinter(
        widget.printer.printerID,
        {'price': parsedPrice},
      );

      if (!mounted) return;

      setState(() {
        price = parsedPrice;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Price updated successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update price. Please try again.'),
        ),
      );
    }
  }



  Future<void> _editDescription() async {
    final newDescription = await EditFieldDialog.show(
      context: context,
      title: 'Edit Description',
      initialValue: description,
      labelText: 'Description',
      maxLines: 5,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Description cannot be empty.';
        }
        return null;
      },
    );

    if (newDescription == null || !mounted) return;

    try {
      await PrinterService().updatePrinter(
        widget.printer.printerID,
        {'description': newDescription},
      );

      if (!mounted) return;

      setState(() {
        description = newDescription;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Description updated successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update description. Please try again.'),
        ),
      );
    }
  }



  Future<void> _editStock() async {
    final newStock = await EditFieldDialog.show(
      context: context,
      title: 'Edit Stock',
      initialValue: stock.toString(),
      labelText: 'Stock Quantity',
      keyboardType: TextInputType.number,
      validator: (value) {
        final parsedStock = int.tryParse(value ?? '');

        if (parsedStock == null) {
          return 'Enter a valid whole number.';
        }

        if (parsedStock < 0) {
          return 'Stock cannot be negative.';
        }

        return null;
      },
    );

    if (newStock == null || !mounted) return;

    final parsedStock = int.tryParse(newStock);

    if (parsedStock == null) return;

    try {
      await PrinterService().updatePrinter(
        widget.printer.printerID,
        {'stock': parsedStock},
      );

      if (!mounted) return;

      setState(() {
        stock = parsedStock;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock updated successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update stock. Please try again.'),
        ),
      );
    }
  }


  Future<void> _updateAvailability(bool newValue) async {
    try {
      await PrinterService().updatePrinter(
        widget.printer.printerID,
        {'is_available': newValue},
      );

      if (!mounted) return;

      setState(() {
        isAvailable = newValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Availability updated successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update availability. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Printer'),
        centerTitle: true,
        backgroundColor: AppColors.admin,
        foregroundColor: AppColors.textWhite,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: ListView(
          children: [
            Text(
              '$brand $model',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: AppSpacing.large),

            Row(
              children: [
                Expanded(
                  child: _detailRow('Brand', brand),
                ),
                IconButton(
                  onPressed: _editBrand,
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit brand',
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: _detailRow('Model', model),
                ),
                IconButton(
                  onPressed: _editModel,
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit model',
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: _detailRow('Printer Type', printerType),
                ),
                IconButton(
                  onPressed: _editPrinterType,
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit printer type',
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: _detailRow(
                    'Price',
                    '\$${price.toStringAsFixed(2)}',
                  ),
                ),
                IconButton(
                  onPressed: _editPrice,
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit price',
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: _detailRow('Description', description),
                ),
                IconButton(
                  onPressed: _editDescription,
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit description',
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: _detailRow('Stock', stock.toString()),
                ),
                IconButton(
                  onPressed: _editStock,
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit stock',
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: _detailRow(
                    'Availability',
                    isAvailable ? 'Available' : 'Unavailable',
                  ),
                ),
                Switch(
                  value: isAvailable,
                  onChanged: _updateAvailability,
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
