import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      appBar: AppBar(
        title: const Text('Admin Print-ish'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.deepOrange,
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
    );
  }
}
