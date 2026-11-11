import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/printer.dart';
import '../constants/colors.dart';
import '../constants/app_spacing.dart';
import '../widgets/back_button.dart';
import '../models/cart.dart';
import 'login_page.dart';

class PrinterDetails extends StatelessWidget {
  final Printer printer;
  final ShopCart cart;

  const PrinterDetails({
    super.key,
    required this.printer,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Printer Details'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.print,
                size: 120,
                color: AppColors.quaternary,
              ),
            ),

            const SizedBox(height: AppSpacing.large),

            Text(
              '${printer.brand} ${printer.model}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),

            const SizedBox(height: AppSpacing.small),

            Text(
              printer.category,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.quaternary,
              ),
            ),

            const SizedBox(height: AppSpacing.medium),

            Text(
              '\$${printer.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),

            const SizedBox(height: AppSpacing.large),

            const Text(
              'Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),

            const SizedBox(height: AppSpacing.small),

            Text(
              printer.specs,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textWhite,
              ),
            ),

            const SizedBox(height: AppSpacing.small),

            Text(
              printer.inStock ? 'Available' : 'Currently Unavailable',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),

            const SizedBox(height: AppSpacing.large),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final user = Supabase.instance.client.auth.currentUser;
                  if (user != null) {
                    cart.addItem(printer, 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Added to cart'),
                      ),
                    );
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Login before adding to cart'),
                      ),
                    );
                  }
                  },
                
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tertiary,
                  foregroundColor: AppColors.textBlack,
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
