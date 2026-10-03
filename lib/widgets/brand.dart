// Small branded building blocks shared by the welcome flow and the dashboard.
import 'package:flutter/material.dart';

import '../core/theme.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 96});
  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset('assets/logo/logo.png', width: size, height: size, semanticLabel: 'NoLateFees logo'),
      );
}

/// "NoLateFees" with the brand gradient painted through the letters.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.fontSize = 34});
  final double fontSize;

  @override
  Widget build(BuildContext context) => ShaderMask(
        shaderCallback: (r) => Brand.gradient.createShader(r),
        child: Text(
          'NoLateFees',
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
        ),
      );
}

/// Full-screen soft gradient used behind the welcome flow.
class SoftBackground extends StatelessWidget {
  const SoftBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: dark ? Brand.darkSoftGradient : Brand.softGradient),
      child: child,
    );
  }
}

/// A button filled with the brand gradient that shrinks a little when pressed.
class GradientButton extends StatefulWidget {
  const GradientButton({super.key, required this.label, required this.onPressed, this.icon, this.busy = false});
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool busy;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.busy;
    return AnimatedScale(
      scale: _down ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      child: Opacity(
        opacity: enabled ? 1 : 0.6,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            height: 54,
            decoration: BoxDecoration(
              gradient: Brand.gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Brand.pink.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: enabled ? widget.onPressed : null,
              onHighlightChanged: (v) => setState(() => _down = v),
              child: Center(
                child: widget.busy
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Row(mainAxisSize: MainAxisSize.min, children: [
                        if (widget.icon != null) ...[widget.icon!, const SizedBox(width: 10)],
                        Flexible(
                          child: Text(widget.label,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Round avatar with the person's photo or initials on the brand gradient.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.initials, this.photoUrl, this.radius = 24});
  final String initials;
  final String? photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: Brand.gradient),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: url != null && url.startsWith('http')
          ? Image.network(url, fit: BoxFit.cover, width: radius * 2, height: radius * 2,
              errorBuilder: (_, _, _) => _letters())
          : _letters(),
    );
  }

  Widget _letters() => Text(initials,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: radius * 0.75));
}
