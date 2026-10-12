import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'open':
        bg = AppTheme.openBg;
        textColor = AppTheme.openText;
        break;
      case 'assigned':
        bg = AppTheme.assignedBg;
        textColor = AppTheme.assignedText;
        break;
      case 'in progress':
        bg = AppTheme.inProgressBg;
        textColor = AppTheme.inProgressText;
        break;
      case 'resolved':
        bg = AppTheme.resolvedBg;
        textColor = AppTheme.resolvedText;
        break;
      case 'rejected':
      case 'cancelled':
        bg = AppTheme.rejectedBg;
        textColor = AppTheme.rejectedText;
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textColor.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: GoogleFonts.inter(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
