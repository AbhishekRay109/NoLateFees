// "Tell us about you": name (required), email and phone, kept on this phone.
// Also used for "Edit profile".
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_services.dart';
import '../../core/format.dart';
import '../../widgets/brand.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key, this.editing = false});

  /// Opened from Settings: pop back instead of entering the app.
  final bool editing;

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  bool _loaded = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ref.read(repoProvider).profile();
    if (!mounted) return;
    setState(() {
      _name.text = p.displayName ?? '';
      _email.text = p.email ?? '';
      _phone.text = p.phone == null ? '' : formatPhone(p.phone!);
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final phone = _phone.text.trim().isEmpty ? null : normalizePhone(_phone.text);
    await ref.read(servicesProvider).saveProfile(name: _name.text, email: _email.text, phone: phone);
    if (!mounted) return;
    // Onboarding done: the app root swaps to the home screen underneath.
    Navigator.of(context).popUntil((r) => r.isFirst);
    if (widget.editing) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.editing ? 'Edit profile' : 'About you')),
      body: SoftBackground(
        child: SafeArea(
          child: !_loaded
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _form,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Center(
                        child: ValueListenableBuilder(
                          valueListenable: _name,
                          builder: (_, v, _) => UserAvatar(initials: initialsOf(v.text), radius: 44),
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 16),
                      if (!widget.editing)
                        Text(
                          'So reminders feel like yours. Only your name is needed.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge,
                        ),
                      const SizedBox(height: 24),
                      TextFormField(
                        key: const Key('nameField'),
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.name],
                        decoration: const InputDecoration(labelText: 'Your name', prefixIcon: Icon(Icons.person_outline)),
                        validator: (v) => (v ?? '').trim().isEmpty ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('emailField'),
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                            labelText: 'Email (optional)', prefixIcon: Icon(Icons.alternate_email)),
                        validator: (v) =>
                            (v ?? '').trim().isEmpty || isValidEmail(v!) ? null : 'That email doesn\'t look right',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('profilePhoneField'),
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                            labelText: 'Phone (optional)', prefixIcon: Icon(Icons.phone_iphone)),
                        validator: (v) =>
                            (v ?? '').trim().isEmpty || normalizePhone(v!) != null ? null : 'Enter a valid mobile number',
                      ),
                      const SizedBox(height: 32),
                      GradientButton(
                        label: widget.editing ? 'Save' : 'Let\'s go',
                        busy: _busy,
                        icon: widget.editing ? null : const Icon(Icons.arrow_forward, color: Colors.white),
                        onPressed: _save,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
