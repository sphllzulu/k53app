import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/supabase_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _soundEffectsEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildSwitchTile(
            title: 'Dark Mode',
            subtitle: 'Switch between light and dark theme',
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              // TODO: Implement theme switching
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dark mode ${value ? 'enabled' : 'disabled'}')),
              );
            },
            icon: Icons.dark_mode,
          ),

          const SizedBox(height: 16),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          _buildSwitchTile(
            title: 'Enable Notifications',
            subtitle: 'Receive study reminders and updates',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notifications ${value ? 'enabled' : 'disabled'}')),
              );
            },
            icon: Icons.notifications,
          ),

          const SizedBox(height: 16),

          // Sound & Vibration Section
          _buildSectionHeader('Sound & Vibration'),
          _buildSwitchTile(
            title: 'Sound Effects',
            subtitle: 'Enable sound feedback',
            value: _soundEffectsEnabled,
            onChanged: (value) {
              setState(() {
                _soundEffectsEnabled = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sound effects ${value ? 'enabled' : 'disabled'}')),
              );
            },
            icon: Icons.volume_up,
          ),
          _buildSwitchTile(
            title: 'Vibration',
            subtitle: 'Enable haptic feedback',
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() {
                _vibrationEnabled = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Vibration ${value ? 'enabled' : 'disabled'}')),
              );
            },
            icon: Icons.vibration,
          ),

          const SizedBox(height: 16),

          // Account Section
          _buildSectionHeader('Account'),
          _buildListTile(
            title: 'Sign Out',
            subtitle: 'Log out of your account',
            icon: Icons.logout,
            onTap: () async {
              final shouldSignOut = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              if (shouldSignOut == true) {
                await SupabaseService.signOut();
                context.go('/auth/login');
              }
            },
            trailing: null,
          ),

          const SizedBox(height: 16),

          // App Info Section
          _buildSectionHeader('About'),
          _buildListTile(
            title: 'Version',
            subtitle: '1.0.0',
            icon: Icons.info,
            onTap: () {},
            trailing: null,
          ),
          _buildListTile(
            title: 'Privacy Policy',
            subtitle: 'View our privacy practices',
            icon: Icons.privacy_tip,
            onTap: () {
              // TODO: Open privacy policy
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy policy coming soon!')),
              );
            },
            trailing: null,
          ),
          _buildListTile(
            title: 'Terms of Service',
            subtitle: 'View terms and conditions',
            icon: Icons.description,
            onTap: () {
              // TODO: Open terms of service
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms of service coming soon!')),
              );
            },
            trailing: null,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        onTap: () => onChanged(!value),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Widget? trailing,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}