import 'package:flutter/material.dart';

/// Placeholder — replace with the exact Figma design once that screen is shared.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _items = [
    (title: 'Account', icon: Icons.person_outline),
    (title: 'Notifications', icon: Icons.notifications_none),
    (title: 'Subscription', icon: Icons.workspace_premium_outlined),
    (title: 'Support', icon: Icons.help_outline),
    (title: 'About Warmup', icon: Icons.info_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
            const SizedBox(height: 24),
            for (final item in _items)
              Card(
                child: ListTile(
                  leading: Icon(item.icon),
                  title: Text(item.title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
          ],
        ),
      ),
    );
  }
}
