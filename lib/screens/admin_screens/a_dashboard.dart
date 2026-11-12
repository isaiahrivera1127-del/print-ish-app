import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/app_spacing.dart';
import '../../constants/colors.dart';
import 'delete_user_page.dart';
import '../login_page.dart';
import 'lookup_order_page.dart';
import 'modify_item_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Print-ish'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          StreamBuilder<AuthState>(
            stream: Supabase.instance.client.auth.onAuthStateChange,
            builder: (context, snapshot) {
              final user = Supabase.instance.client.auth.currentUser;
              return IconButton(
                icon: Icon(user != null ? Icons.person : Icons.login),
                tooltip: user != null ? 'Admin Account' : 'Sign out',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Control Panel',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            const Text(
              'Manage products, users, and orders',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.medium),

            // Menu Cards
            Expanded(
              child: ListView(
                children: [
                  _buildMenuButton(
                    context,
                    icon: Icons.edit_note_rounded,
                    title: 'Modify Item',
                    subtitle: 'Edit product pricing, specs, and stock availability',
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ModifyItemPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.small),
                  _buildMenuButton(
                    context,
                    icon: Icons.person_remove_rounded,
                    title: 'Delete User',
                    subtitle: 'Search and delete registered customer accounts',
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeleteUserPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.small),
                  _buildMenuButton(
                    context,
                    icon: Icons.receipt_long_rounded,
                    title: 'Lookup Order',
                    subtitle: 'Search order details by order number or customer',
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LookupOrderPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.small,
        ),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          radius: 26,
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        onTap: onTap,
      ),
    );
  }
}
