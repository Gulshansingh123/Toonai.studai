import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class PremiumScreen extends StatelessWidget {
  final bool embedded;
  const PremiumScreen({super.key, this.embedded = false});

  // TODO(billing): wire to Google Play Billing Library. Query available
  // subscription products, launch purchase flow, verify purchase token
  // server-side, then call AppState.unlockPremium() on confirmed entitlement.
  void _mockPurchase(BuildContext context) {
    context.read<AppState>().unlockPremium();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Premium unlocked! (mock purchase flow)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final content = ListView(
      padding: EdgeInsets.fromLTRB(20, embedded ? 16 : 12, 20, 24),
      children: [
        if (embedded)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('Premium', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          ),
        const BrandBanner(
          title: 'Go Premium',
          subtitle: 'No ads, unlimited generations, 1080p export, and the full character, voice & template library.',
        ),
        const SizedBox(height: 20),
        if (state.isPremium)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
            child: const Row(
              children: [
                Icon(Icons.workspace_premium_rounded, color: AppColors.success),
                SizedBox(width: 10),
                Expanded(child: Text('You are a Premium member. Enjoy unlimited creativity!')),
              ],
            ),
          )
        else ...[
          _PlanCard(
            title: 'Monthly',
            price: '₹199 / month',
            features: const ['Unlimited generations', 'No ads', '1080p export', 'All voices & templates'],
            onTap: () => _mockPurchase(context),
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: 'Yearly (Best Value)',
            price: '₹1,499 / year',
            highlighted: true,
            features: const ['Everything in Monthly', 'Save 35%', 'Early access to new characters'],
            onTap: () => _mockPurchase(context),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(onPressed: () {}, child: const Text('Restore Purchases')),
          ),
        ],
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),
        const Text('Feature Comparison', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        const _CompareRow(feature: 'Video generations / month', free: '3', premium: 'Unlimited'),
        const _CompareRow(feature: 'Export resolution', free: '720p', premium: '1080p'),
        const _CompareRow(feature: 'Ads', free: 'Yes', premium: 'None'),
        const _CompareRow(feature: 'Characters & voices', free: 'Core set', premium: 'Full library'),
        const _CompareRow(feature: 'Templates', free: 'Limited', premium: 'All templates'),
      ],
    );

    if (embedded) return content;
    return Scaffold(appBar: AppBar(title: const Text('Premium')), body: content);
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> features;
  final bool highlighted;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title, required this.price, required this.features,
    required this.onTap, this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.brand : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: highlighted ? AppColors.brand : Colors.black12),
        boxShadow: highlighted ? [BoxShadow(color: AppColors.brand.withOpacity(0.3), blurRadius: 16)] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 16,
                  color: highlighted ? Colors.white : Colors.black87)),
              Text(price, style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 15,
                  color: highlighted ? Colors.white : AppColors.brand)),
            ],
          ),
          const SizedBox(height: 10),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_rounded, size: 16, color: highlighted ? Colors.white : AppColors.brand),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(f, style: TextStyle(
                          fontSize: 12.5, color: highlighted ? Colors.white : Colors.black87)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: highlighted
                ? ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.brand),
                    child: const Text('Choose Plan'),
                  )
                : OutlinedButton(onPressed: onTap, child: const Text('Choose Plan')),
          ),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String feature;
  final String free;
  final String premium;
  const _CompareRow({required this.feature, required this.free, required this.premium});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(feature, style: const TextStyle(fontSize: 12.5))),
          Expanded(flex: 2, child: Text(free, style: const TextStyle(fontSize: 12.5, color: Colors.black45))),
          Expanded(flex: 2, child: Text(premium, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.brand))),
        ],
      ),
    );
  }
}
