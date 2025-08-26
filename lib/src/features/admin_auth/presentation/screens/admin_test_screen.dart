import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k53app/src/core/services/supabase_service.dart';

class AdminTestScreen extends ConsumerStatefulWidget {
  const AdminTestScreen({super.key});

  @override
  ConsumerState<AdminTestScreen> createState() => _AdminTestScreenState();
}

class _AdminTestScreenState extends ConsumerState<AdminTestScreen> {
  String _status = 'Checking admin access...';
  String? _userRole;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    try {
      final user = SupabaseService.auth.currentUser;
      if (user == null) {
        setState(() => _status = 'No user logged in');
        return;
      }

      _userId = user.id;
      
      final profile = await SupabaseService.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single()
          .catchError((e) {
        setState(() => _status = 'Error fetching profile: $e');
        return null;
      });

      if (profile == null) {
        setState(() => _status = 'No profile found for user');
        return;
      }

      _userRole = profile['role'] as String?;
      
      if (_userRole == 'admin' || _userRole == 'qa_reviewer') {
        setState(() => _status = '✅ Admin access granted! Role: $_userRole');
      } else {
        setState(() => _status = '❌ Access denied. User role: $_userRole');
      }
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  Future<void> _setAsAdmin() async {
    try {
      final user = SupabaseService.auth.currentUser;
      if (user == null) return;

      await SupabaseService.client
          .from('profiles')
          .update({'role': 'admin'})
          .eq('id', user.id);

      setState(() {
        _userRole = 'admin';
        _status = '✅ User role updated to admin!';
      });
    } catch (e) {
      setState(() => _status = 'Error updating role: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Access Test'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/login'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings, size: 64, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Admin Access Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(_status, textAlign: TextAlign.center),
                    if (_userId != null) Text('User ID: $_userId'),
                    if (_userRole != null) Text('Role: $_userRole'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_userRole != 'admin')
              ElevatedButton(
                onPressed: _setAsAdmin,
                child: const Text('Set as Admin (Debug)'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/admin/dashboard'),
              child: const Text('Try Access Dashboard'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.go('/admin/login'),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}