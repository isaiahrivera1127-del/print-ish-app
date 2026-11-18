
import 'package:flutter/material.dart';

class EditFieldDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  final String labelText;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const EditFieldDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
  });

  static Future<String?> show({
    required BuildContext context,
    required String title,
    required String initialValue,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => EditFieldDialog(
        title: title,
        initialValue: initialValue,
        labelText: labelText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  @override
  State<EditFieldDialog> createState() => _EditFieldDialogState();
}

class _EditFieldDialogState extends State<EditFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: widget.initialValue,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(context, controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: widget.labelText,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
