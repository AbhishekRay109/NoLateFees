// Phone number → 6-digit SMS code. Android often reads the SMS by itself.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_services.dart';
import '../../data/auth/auth_service.dart';
import '../../widgets/brand.dart';
import 'welcome_screen.dart';

const resendSeconds = 30;

class PhoneSignInScreen extends ConsumerStatefulWidget {
  const PhoneSignInScreen({super.key, this.signInOnly = false});
  final bool signInOnly;

  @override
  ConsumerState<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends ConsumerState<PhoneSignInScreen> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  String? _e164;
  CodeSent? _sent;
  bool _busy = false;
  String? _error;
  int _wait = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  AuthService get _auth => ref.read(servicesProvider).auth!;

  void _startTimer() {
    _timer?.cancel();
    setState(() => _wait = resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _wait--);
      if (_wait <= 0) t.cancel();
    });
  }

  Future<void> _send({bool resend = false}) async {
    final e164 = normalizePhone(_phone.text);
    if (e164 == null) {
      setState(() => _error = 'Enter a valid mobile number, e.g. 98765 43210.');
      return;
    }
    await _run(() async {
      final result = await _auth.sendPhoneCode(e164, resendToken: resend ? _sent?.resendToken : null);
      _e164 = e164;
      switch (result) {
        case AutoVerified(:final user):
          await _done(user);
        case CodeSent():
          setState(() => _sent = result);
          _startTimer();
      }
    });
  }

  Future<void> _verify() async {
    final code = _code.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _error = 'Enter the 6-digit code from the SMS.');
      return;
    }
    await _run(() async => _done(await _auth.confirmPhoneCode(_sent!.verificationId, code)));
  }

  Future<void> _done(AppUser user) async {
    if (mounted) await afterSignIn(context, ref, user, signInOnly: widget.signInOnly);
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Something went wrong. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sent = _sent;
    return Scaffold(
      appBar: AppBar(title: Text(sent == null ? 'Your phone number' : 'Enter the code')),
      body: SoftBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                sent == null
                    ? 'We\'ll text you a 6-digit code to sign in. Standard SMS rates may apply.'
                    : 'We sent a code to ${formatPhone(_e164!)}.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              if (sent == null)
                TextField(
                  key: const Key('phoneField'),
                  controller: _phone,
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-]'))],
                  decoration: const InputDecoration(
                    labelText: 'Mobile number',
                    prefixIcon: Icon(Icons.phone_iphone),
                    helperText: 'Indian numbers can skip +91',
                  ),
                  onSubmitted: (_) => _send(),
                ).animate().fadeIn().slideY(begin: 0.2)
              else
                TextField(
                  key: const Key('codeField'),
                  controller: _code,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, letterSpacing: 12, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(hintText: '••••••'),
                  onChanged: (v) {
                    if (v.length == 6 && !_busy) _verify();
                  },
                  onSubmitted: (_) => _verify(),
                ).animate().fadeIn().slideX(begin: 0.2),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                ),
              const SizedBox(height: 24),
              GradientButton(
                label: sent == null ? 'Send code' : 'Verify',
                busy: _busy,
                onPressed: sent == null ? _send : _verify,
              ),
              if (sent != null) ...[
                const SizedBox(height: 8),
                Wrap(alignment: WrapAlignment.spaceBetween, children: [
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              _sent = null;
                              _code.clear();
                              _error = null;
                            }),
                    child: const Text('Change number'),
                  ),
                  TextButton(
                    onPressed: _busy || _wait > 0 ? null : () => _send(resend: true),
                    child: Text(_wait > 0 ? 'Resend in ${_wait}s' : 'Resend code'),
                  ),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
