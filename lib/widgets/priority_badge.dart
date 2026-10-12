import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;
  final double fontSize;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    IconData icon;

    switch (priority.toLowerCase()) {
      case 'urgent':
        bg = AppTheme.priorityUrgentBg;
        text = AppTheme.priorityUrgentText;
        icon = Icons.warning_amber_rounded;
        break;
      case 'high':
        bg = AppTheme.priorityHighBg;
        text = AppTheme.priorityHighText;
        icon = Icons.arrow_upward_rounded;
        break;
      case 'medium':
        bg = AppTheme.priorityMedBg;
        text = AppTheme.priorityMedText;
        icon = Icons.remove_rounded;
        break;
      case 'low':
      default:
        bg = AppTheme.priorityLowBg;
        text = AppTheme.priorityLowText;
        icon = Icons.arrow_downward_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: text.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 1, color: text),
          const SizedBox(width: 4),
          Text(
            priority,
            style: GoogleFonts.inter(
              color: text,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
