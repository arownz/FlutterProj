import 'package:flutter/material.dart';
import 'hover_effect_card.dart';

class InteractiveFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final Color baseColor;
  final Color iconColor;
  final Color hoverColor;
  final bool isLocked;
  final VoidCallback? onLockTap;

  const InteractiveFeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.baseColor,
    this.iconColor = Colors.black87,
    required this.hoverColor,
    this.isLocked = false,
    this.onLockTap,
  });

  @override
  Widget build(BuildContext context) {
    return HoverEffectCard(
      onTap: isLocked ? (onLockTap ?? onTap) : onTap,
      baseColor: baseColor,
      hoverColor: hoverColor,
      scale: 1.03,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: baseColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (isLocked)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lock, color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: isLocked 
                ? TextButton.icon(
                    onPressed: onLockTap ?? onTap,
                    icon: const Icon(Icons.login),
                    label: const Text('Login to Access'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  )
                : TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Access'),
                    style: TextButton.styleFrom(
                      foregroundColor: iconColor,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
