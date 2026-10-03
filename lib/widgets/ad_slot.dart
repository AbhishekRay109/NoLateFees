// The one place an ad can appear: a slim strip above the bottom navigation on
// the Home and All Items tabs. It takes no space until an ad has loaded and
// stays out of forms, sign-in and settings.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_services.dart';

class AdSlot extends ConsumerWidget {
  const AdSlot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(servicesProvider).ads;
    if (ads == null) return const SizedBox.shrink();
    return ValueListenableBuilder<bool>(
      valueListenable: ads.ready,
      builder: (context, ready, _) {
        if (!ready) return const SizedBox.shrink();
        final theme = Theme.of(context);
        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: Container(
            key: const Key('adSlot'),
            width: double.infinity,
            color: theme.navigationBarTheme.backgroundColor,
            alignment: Alignment.center,
            child: LayoutBuilder(builder: (context, c) => ads.buildBanner(c.maxWidth)),
          ),
        );
      },
    );
  }
}
