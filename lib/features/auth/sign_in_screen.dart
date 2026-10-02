// Email one-time code sign-in (no passwords, no SMS cost).
// The Supabase "Magic Link" email template must include {{ .Token }}; see README.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app_services.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  GoTrueClient get _auth => ref.read(servicesProvider).supabase!.auth;

  Future<void> _sendCode() async {
    final email = _email.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    await _run(() async {
      await _auth.signInWithOtp(email: email);
      setState(() => _codeSent = true);
    });
  }

  Future<void> _verify() async {
    await _run(() async {
      await _auth.verifyOTP(email: _email.text.trim(), token: _code.text.trim(), type: OtpType.email);
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on AuthException catch (e) {
      setState(() => _error = e.statusCode == '429'
          ? 'Too many attempts. Wait a minute and try again.'
          : (_codeSent ? 'That code didn\'t work. Check it and try again.' : 'Could not send the code. Try again.'));
    } catch (_) {
      setState(() => _error = 'No connection. Check your internet and try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            _codeSent
                ? 'We sent a 6-digit code to ${_email.text.trim()}.'
                : 'Sign in to back up your reminders and use them on another phone. '
                    'Anything you added already will be uploaded.',
          ),
          const SizedBox(height: 24),
          if (!_codeSent)
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Email'),
              onSubmitted: (_) => _sendCode(),
            )
          else
            TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'Code'),
              onSubmitted: (_) => _verify(),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : (_codeSent ? _verify : _sendCode),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: Text(_codeSent ? 'Verify' : 'Send code'),
          ),
          if (_codeSent)
            TextButton(onPressed: _busy ? null : () => setState(() => _codeSent = false), child: const Text('Use a different email')),
        ],
      ),
    );
  }
}
