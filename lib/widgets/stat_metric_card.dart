import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';

class StatMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 180;
        final cardRadius = BorderRadius.circular(16);
        return Material(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: cardRadius,
            side: const BorderSide(color: AppTheme.borderLight),
          ),
          child: InkWell(
            onTap: onTap,
            mouseCursor: onTap == null
                ? MouseCursor.defer
                : SystemMouseCursors.click,
            borderRadius: cardRadius,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: cardRadius,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.035),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(isCompact ? 12 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textMuted,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.all(isCompact ? 7 : 9),
                              decoration: BoxDecoration(
                                color: iconBgColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                icon,
                                size: isCompact ? 18 : 20,
                                color: iconColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            value,
                            style: GoogleFonts.inter(
                              fontSize: isCompact ? 28 : 32,
                              height: 1,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  subtitle!,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    height: 1.3,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textMuted,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (onTap != null) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: iconColor,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
