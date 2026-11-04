
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(Icons.arrow_back),
      color: AppColors.textWhite,
      tooltip: 'Go back',
    );
  }
}
