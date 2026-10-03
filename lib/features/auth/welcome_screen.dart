// First screen on a fresh install (and "Sign in" from Settings): Google,
// phone OTP, or carry on without an account.
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_services.dart';
import '../../core/theme.dart';
import '../../data/auth/auth_service.dart';
import '../../widgets/brand.dart';
import 'phone_sign_in_screen.dart';
import 'profile_setup_screen.dart';

/// Where to go once someone has signed in: straight back when they came from
/// Settings, otherwise on to the profile screen.
Future<void> afterSignIn(BuildContext context, WidgetRef ref, AppUser user, {required bool signInOnly}) async {
  await ref.read(servicesProvider).completeSignIn(user);
  if (!context.mounted) return;
  if (signInOnly) {
    Navigator.of(context).popUntil((r) => r.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed in. Your reminders are syncing.')));
  } else {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileSetupScreen()));
  }
}

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key, this.signInOnly = false});

  /// Opened from Settings by someone already using the app.
  final bool signInOnly;

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _google() async {
    final auth = ref.read(servicesProvider).auth!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = await auth.signInWithGoogle();
      if (mounted) await afterSignIn(context, ref, user, signInOnly: widget.signInOnly);
    } on AuthCancelled {
      // They closed the account picker; nothing to say.
    } on AuthFailure catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Google sign-in failed. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _phone() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => PhoneSignInScreen(signInOnly: widget.signInOnly)));

  void _skip() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileSetupScreen()));

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(servicesProvider);
    final auth = services.auth;
    final theme = Theme.of(context);

    final features = const [
      ('🔔', 'Smart reminders', 'Get nudged 30, 7 and 1 day before anything expires'),
      ('🚗', 'Everything in one place', 'Insurance, PUC, recharges, passports, EMIs, subscriptions'),
      ('☁️', 'Safe in the cloud', 'Sign in to back up and use it on a new phone'),
    ];

    return Scaffold(
      appBar: widget.signInOnly ? AppBar(title: const Text('Sign in')) : null,
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
              if (!widget.signInOnly)
                for (final (i, f) in features.indexed)
                  _FeatureRow(emoji: f.$1, title: f.$2, body: f.$3)
                      .animate()
                      .fadeIn(delay: (350 + i * 120).ms)
                      .slideX(begin: 0.15),
              const SizedBox(height: 28),
              if (auth != null) ...[
                if (auth.googleAvailable)
                  _GoogleButton(onPressed: _busy ? null : _google, busy: _busy)
                      .animate()
                      .fadeIn(delay: 700.ms)
                      .slideY(begin: 0.4),
                const SizedBox(height: 12),
                GradientButton(
                  label: 'Continue with phone number',
                  icon: const Icon(Icons.phone_iphone, color: Colors.white),
                  onPressed: _busy ? null : _phone,
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.4),
              ] else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      const Icon(Icons.cloud_off_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sign-in and cloud backup switch on once Firebase is connected to this build. '
                          'Everything else works offline right now.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ]),
                  ),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
                ),
              if (!widget.signInOnly) ...[
                const SizedBox(height: 12),
                if (auth == null)
                  GradientButton(label: 'Get started', onPressed: _skip)
                else
                  TextButton(
                    onPressed: _busy ? null : _skip,
                    child: const Text('Continue without an account'),
                  ),
              ],
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

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed, required this.busy});
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Theme.of(context).cardTheme.color,
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: busy
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
            : const Row(mainAxisSize: MainAxisSize.min, children: [
                Text('G', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF4285F4))),
                SizedBox(width: 12),
                Text('Continue with Google'),
              ]),
      );
}
