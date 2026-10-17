import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../models/ticket_model.dart';
import 'priority_badge.dart';
import 'status_badge.dart';

class TicketItemCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;
  final Function(String newStatus)? onQuickStatusChange;

  const TicketItemCard({
    super.key,
    required this.ticket,
    required this.onTap,
    this.onQuickStatusChange,
  });

  /// Icon + single-line text that can never be wider than [maxWidth].
  Widget _info({
    required IconData icon,
    required String text,
    required double maxWidth,
    Color? color,
    double fontSize = 12,
    FontWeight? weight,
    double iconSize = 15,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color ?? AppTheme.textMuted),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: fontSize,
                color: color ?? AppTheme.textMuted,
                fontWeight: weight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumbnail(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 76,
        height: 76,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: AppTheme.backgroundLight,
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            color: AppTheme.backgroundLight,
            child: const Icon(
              Icons.broken_image_outlined,
              color: AppTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final dateStr = DateFormat('MMM d, h:mm a').format(ticket.createdAt);
    final thumb = ticket.thumbnailUrl;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 14 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderLight, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.015),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Ticket #, Category, Status & Priority
              // On mobile badges wrap to their own row to avoid overflow.
              if (isMobile) ...[
                Row(
                  children: [
                    _ticketNumberChip(),
                    const SizedBox(width: 8),
                    Expanded(child: _categoryText()),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    PriorityBadge(priority: ticket.priority),
                    StatusBadge(status: ticket.status),
                  ],
                ),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _ticketNumberChip(),
                    const SizedBox(width: 8),
                    Expanded(child: _categoryText()),
                    const SizedBox(width: 8),
                    PriorityBadge(priority: ticket.priority),
                    const SizedBox(width: 8),
                    StatusBadge(status: ticket.status),
                  ],
                ),
              const SizedBox(height: 10),

              // Title + description on the left, photo thumbnail on the right
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.title,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (ticket.description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            ticket.description,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.textMedium,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (thumb != null) ...[
                    const SizedBox(width: 12),
                    _thumbnail(thumb),
                  ],
                ],
              ),
              const SizedBox(height: 10),

              // Location, Student info, assignee & Date
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxW = constraints.maxWidth;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _info(
                        icon: Icons.location_on_outlined,
                        text: ticket.location,
                        maxWidth: maxW,
                        weight: FontWeight.w500,
                      ),
                      _info(
                        icon: Icons.person_outline,
                        text: ticket.studentLabel,
                        maxWidth: maxW,
                      ),
                      if (ticket.assignedTo.isNotEmpty)
                        _info(
                          icon: Icons.engineering_outlined,
                          text: ticket.assignedTo,
                          maxWidth: maxW,
                          color: AppTheme.accentTeal,
                          weight: FontWeight.w600,
                        ),
                      _info(
                        icon: Icons.access_time,
                        text: dateStr,
                        maxWidth: maxW,
                        color: AppTheme.textSubtle,
                        fontSize: 11,
                        iconSize: 14,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ticketNumberChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        ticket.ticketNumber,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryNavy,
        ),
      ),
    );
  }

  Widget _categoryText() {
    return Text(
      ticket.category,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppTheme.textMuted,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}