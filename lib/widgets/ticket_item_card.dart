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

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final dateStr = DateFormat('MMM d, h:mm a').format(ticket.createdAt);

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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
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
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ticket.category,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PriorityBadge(priority: ticket.priority),
                  const SizedBox(width: 8),
                  StatusBadge(status: ticket.status),
                ],
              ),
              const SizedBox(height: 10),

              // Title
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
              const SizedBox(height: 6),

              // Description preview
              if (ticket.description.isNotEmpty) ...[
                Text(
                  ticket.description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textMedium,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
              ],

              // Location, Student info & Date
              Wrap(
                spacing: 16,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 15, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        ticket.location,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_outline, size: 15, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${ticket.studentName} (${ticket.studentId})',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  if (ticket.assignedTo.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.engineering_outlined, size: 15, color: AppTheme.accentTeal),
                        const SizedBox(width: 4),
                        Text(
                          ticket.assignedTo,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentTeal,
                          ),
                        ),
                      ],
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppTheme.textSubtle),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textSubtle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
