import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/app_spacing.dart';
import '../../services/printer_service.dart';

class AddPrinterPage extends StatefulWidget {
  const AddPrinterPage({super.key});

  @override
  State<AddPrinterPage> createState() => _AddPrinterPageState();
}

class _AddPrinterPageState extends State<AddPrinterPage> {
  final _formKey = GlobalKey<FormState>();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _typeController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();

  bool isAvailable = true;
  bool isSaving = false;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _typeController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _submitPrinter() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await PrinterService().addPrinter(
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        printerType: _typeController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        isAvailable: isAvailable,
        stock: int.parse(_stockController.text.trim()),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Printer added successfully!'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to add printer. Try again later.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Printer'),
        centerTitle: true,
        backgroundColor: AppColors.admin,
        foregroundColor: AppColors.textWhite,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.medium),
          children: [
            // Brand
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Brand',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Brand is required';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.medium),

            // Model
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Model is required';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.medium),

            // Printer Type
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Printer Type',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Printer type is required';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.medium),

            // Price
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final price = double.tryParse(value ?? '');

                if (price == null || price < 0) {
                  return 'Enter a valid nonnegative price';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.medium),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.medium),

            // Stock
            TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stock Quantity',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final stock = int.tryParse(value ?? '');

                if (stock == null || stock < 0) {
                  return 'Enter a valid nonnegative whole number';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.medium),

            // Availability
            SwitchListTile(
              title: const Text('Available for purchase'),
              value: isAvailable,
              activeTrackColor: AppColors.tertiary,
              onChanged: (value) {
                setState(() {
                  isAvailable = value;
                });
              },
            ),

            const SizedBox(height: AppSpacing.large),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : _submitPrinter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tertiary,
                  foregroundColor: AppColors.textBlack,
                  padding: const EdgeInsets.all(AppSpacing.medium),
                ),
                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text(
                  'Add Printer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}