import 'package:flutter/material.dart';

class ReactionToLeaderButton extends StatelessWidget {
  final bool enabled;
  final bool alreadyReacted;
  final VoidCallback? onPressed;
  final int reactionCount;

  const ReactionToLeaderButton({
    required this.enabled,
    this.alreadyReacted = false,
    this.onPressed,
    this.reactionCount = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final label = alreadyReacted ? 'Вы уже поддержали лидера' : 'Поддержать лидера';
    final icon = alreadyReacted ? Icons.favorite : Icons.favorite_outline;

    return FilledButton.tonalIcon(
      onPressed: (enabled && !alreadyReacted) ? onPressed : null,
      icon: Badge(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, size: 10, color: Colors.white),
            const SizedBox(width: 2),
            Text('$reactionCount'),
          ],
        ),
        isLabelVisible: reactionCount > 0,
        child: Icon(icon),
      ),
      label: Text(label),
    );
  }
}