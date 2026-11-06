import 'package:flutter/material.dart';

class DeleteUserPage extends StatelessWidget {
  const DeleteUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete User'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Account Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Search or select a registered customer account to remove or revoke access.'),
          ],
        ),
      ),
    );
  }
}
