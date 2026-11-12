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
      body: const Center(
        child: Text('Printer form goes here'),
      ),
    );
  }
}