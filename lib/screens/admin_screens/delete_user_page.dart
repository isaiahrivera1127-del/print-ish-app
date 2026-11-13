import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/app_spacing.dart';
import '../../models/customer.dart';

class DeleteUserPage extends StatefulWidget {
  const DeleteUserPage({super.key});

  @override
  State<DeleteUserPage> createState() => _DeleteUserPageState();
}

class _DeleteUserPageState extends State<DeleteUserPage> {
  final TextEditingController _searchController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;

  String _searchQuery = '';
  bool _isLoading = false;
  List<Customer> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchRegisteredUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch registered users from Supabase
  Future<void> _fetchRegisteredUsers() async {
    setState(() => _isLoading = true);

    try {
      List<dynamic> data = [];

      // Try fetching from 'profiles', 'customers', or 'users' tables
      try {
        final res = await _supabase.from('profiles').select();
        data = res as List<dynamic>;
      } catch (_) {
        try {
          final res = await _supabase.from('customers').select();
          data = res as List<dynamic>;
        } catch (_) {
          try {
            final res = await _supabase.from('users').select();
            data = res as List<dynamic>;
          } catch (e) {
            debugPrint('Error querying user tables: $e');
          }
        }
      }

      setState(() {
        _users = data
            .map((item) => Customer.fromMap(item as Map<String, dynamic>))
            .where((u) => u.email.isNotEmpty)
            .toList();
      });
    } catch (e) {
      debugPrint('Error fetching users from Supabase: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- Delete User Account ---
  Future<void> _deleteUser(Customer user) async {
    setState(() => _isLoading = true);

    try {
      // Attempt delete by ID or Email
      if (user.id != null && user.id!.isNotEmpty) {
        await _supabase.from('profiles').delete().eq('id', user.id!);
      } else {
        await _supabase.from('profiles').delete().eq('email', user.email);
      }

      setState(() {
        _users.removeWhere((u) => u.email == user.email);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account for ${user.email} deleted successfully.'),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting user: $e'),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Delete Confirmation Dialog
  void _confirmDeleteUser(Customer user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirm Deletion'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete the account for ${user.email}?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteUser(user);
            },
            child: const Text('Delete User'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _users.where((user) {
      final isAdminAccount = user.isAdmin ||
          user.role == 'admin' ||
          user.email.toLowerCase().startsWith('admin');

      return !isAdminAccount &&
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete User Accounts'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh User List',
            onPressed: _fetchRegisteredUsers,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registered User Accounts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Search and manage customer accounts in your database',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.medium),

            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by user email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
            const SizedBox(height: AppSpacing.medium),

            // User List View
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline_rounded,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'No registered users found'
                                    : 'No users matching "$_searchQuery"',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.deepOrange.shade100,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                title: Text(
                                  user.email,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Role: Registered Customer',
                                  style: TextStyle(fontSize: 12),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Delete User',
                                  onPressed: () => _confirmDeleteUser(user),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
