// First screen on a fresh install: what the app does, then "Get started".
// There is no account: everything stays on this phone.
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme.dart';
import '../../widgets/brand.dart';
import 'profile_setup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final features = const [
      ('🔔', 'Smart reminders', 'Get nudged 30, 7 and 1 day before anything expires'),
      ('🚗', 'Everything in one place', 'Insurance, PUC, recharges, passports, EMIs, subscriptions'),
      ('🔒', 'Private by design', 'No account, no cloud. Your data never leaves this phone'),
    ];

    return Scaffold(
      body: SoftBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            children: [
              const Center(child: BrandLogo(size: 112))
                  .animate()
                  .scale(begin: const Offset(0.6, 0.6), duration: 500.ms, curve: Curves.easeOutBack)
                  .fadeIn(),
              const SizedBox(height: 20),
              const Center(child: BrandWordmark()).animate().fadeIn(delay: 150.ms).slideY(begin: 0.3),
              const SizedBox(height: 8),
              Text(
                'Never pay a late fee again.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ).animate().fadeIn(delay: 250.ms),
              const SizedBox(height: 28),
              for (final (i, f) in features.indexed)
                _FeatureRow(emoji: f.$1, title: f.$2, body: f.$3)
                    .animate()
                    .fadeIn(delay: (350 + i * 120).ms)
                    .slideX(begin: 0.15),
              const SizedBox(height: 40),
              GradientButton(
                label: 'Get started',
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                onPressed: () =>
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileSetupScreen())),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.4),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.emoji, required this.title, required this.body});
  final String emoji;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Brand.indigo.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Text(body, style: Theme.of(context).textTheme.bodySmall),
            ]),
          ),
        ]),
      );
}
