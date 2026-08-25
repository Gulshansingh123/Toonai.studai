import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  final bool embedded;
  const SettingsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final content = ListView(
      padding: EdgeInsets.fromLTRB(20, embedded ? 16 : 12, 20, 24),
      children: [
        if (embedded)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('Settings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          ),
        _SettingsSection(title: 'App', children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.translate_rounded, color: AppColors.brand),
            title: const Text('Language'),
            subtitle: Text(state.isHindi ? 'हिंदी (Hindi)' : 'English'),
            trailing: Switch(
              value: state.isHindi,
              activeThumbColor: AppColors.brand,
              onChanged: (_) => context.read<AppState>().toggleLanguage(),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.notifications_outlined, color: AppColors.brand),
            title: const Text('Notifications'),
            subtitle: const Text('Render-complete alerts, tips & offers'),
            trailing: Switch(value: true, activeThumbColor: AppColors.brand, onChanged: (_) {}),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.storage_outlined, color: AppColors.brand),
            title: const Text('Clear Cache'),
            subtitle: const Text('Free up space used by drafts & previews'),
            onTap: () {},
          ),
        ]),
        _SettingsSection(title: 'Account', children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.workspace_premium_outlined, color: AppColors.brand),
            title: const Text('Subscription'),
            subtitle: Text(state.isPremium ? 'Premium active' : 'Free plan'),
            onTap: () {},
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.restore_rounded, color: AppColors.brand),
            title: const Text('Restore Purchases'),
            onTap: () {},
          ),
        ]),
        _SettingsSection(title: 'Legal & Safety', children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.shield_outlined, color: AppColors.brand),
            title: const Text('Content & Photo Upload Policy'),
            onTap: () {},
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.brand),
            title: const Text('Privacy Policy'),
            onTap: () {},
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.help_outline_rounded, color: AppColors.brand),
            title: const Text('Help & Support'),
            onTap: () {},
          ),
        ]),
        const SizedBox(height: 12),
        const Center(
          child: Text('ToonAI Studio v1.0.0', style: TextStyle(fontSize: 11, color: Colors.black38)),
        ),
      ],
    );

    if (embedded) return content;
    return Scaffold(appBar: AppBar(title: const Text('Settings')), body: content);
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.black45)),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }
}
