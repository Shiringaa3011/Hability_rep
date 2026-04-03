import 'package:flutter/material.dart';

class ReactionToLeaderButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onPressed;

  const ReactionToLeaderButton({
    required this.enabled,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: enabled ? onPressed : null,
      icon: const Icon(Icons.favorite_outline),
      label: const Text('Поддержать лидера'),
    );
  }
}
