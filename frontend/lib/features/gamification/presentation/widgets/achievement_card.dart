import 'package:flutter/material.dart';

import '../../domain/entities/achievement.dart';

class AchievementCard extends StatelessWidget {
  const AchievementCard({
    required this.achievement,
    this.onTap,
    super.key,
  });

  final Achievement achievement;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: achievement.isEarned ? 4 : 1,
      color: achievement.isEarned
          ? theme.colorScheme.primaryContainer
          : theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildIcon(theme),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          achievement.description,
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (achievement.isEarned)
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                ],
              ),
              if (!achievement.isEarned) ...[
                const SizedBox(height: 12),
                _buildProgressBar(theme),
                const SizedBox(height: 4),
                Text(
                  '${achievement.progress}/${achievement.conditionValue}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
              if (achievement.rewardPoints > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${achievement.rewardPoints} баллов',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    final iconData = _getIconData(achievement.icon);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: achievement.isEarned
            ? theme.primaryColor.withOpacity(0.2)
            : theme.colorScheme.surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 32,
        color: achievement.isEarned
            ? theme.primaryColor
            : theme.textTheme.bodySmall?.color,
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: achievement.progressPercent / 100,
        minHeight: 8,
        backgroundColor: theme.colorScheme.surfaceVariant,
        valueColor: AlwaysStoppedAnimation<Color>(
          theme.primaryColor,
        ),
      ),
    );
  }

  IconData _getIconData(String icon) {
    switch (icon.toLowerCase()) {
      case 'star':
        return Icons.star;
      case 'flame':
      case 'fire':
        return Icons.local_fire_department;
      case 'trophy':
        return Icons.emoji_events;
      case 'medal':
        return Icons.military_tech;
      case 'gem':
        return Icons.diamond;
      case 'crown':
        return Icons.workspace_premium;
      default:
        return Icons.emoji_events;
    }
  }
}
