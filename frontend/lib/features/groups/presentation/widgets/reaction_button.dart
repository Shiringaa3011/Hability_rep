import 'package:flutter/material.dart';

class ReactionToLeaderButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onPressed;
  final int reactionCount;

  const ReactionToLeaderButton({
    required this.enabled,
    this.onPressed,
    this.reactionCount = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: enabled ? onPressed : null,
      icon: Badge(
        label: Text('$reactionCount'),
        child: const Icon(Icons.favorite_outline),
      ),
      label: const Text('Поддержать лидера'),
    );
  }
}