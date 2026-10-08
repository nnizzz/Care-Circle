import 'package:care_circle/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// ADMIN STAT CARD
// ============================================================

class AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.darkTeal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ThemeColors.primaryTeal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADMIN ACTION CARD
// ============================================================

class AdminActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const AdminActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: ThemeColors.darkTeal,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: ThemeColors.accentCyan,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ADMIN COUNT CARD
// ============================================================

class AdminCountCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;

  const AdminCountCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeColors.darkTeal,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: ThemeColors.accentCyan,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADMIN FILTER CHIP
// ============================================================

class AdminFilterChip extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const AdminFilterChip({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(
          title,
          style: GoogleFonts.poppins(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 12,
          ),
        ),
        selected: selected,
        selectedColor: ThemeColors.primaryTeal,
        backgroundColor: ThemeColors.darkTeal,
        side: BorderSide.none,
        onSelected: (_) {
          onTap();
        },
      ),
    );
  }
}

// ============================================================
// ADMIN STATUS BADGE
// ============================================================

class AdminStatusBadge extends StatelessWidget {
  final String status;

  const AdminStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'verified':
      case 'completed':
      case 'confirmed':
      case 'active':
        backgroundColor = Colors.green.withOpacity(0.15);
        textColor = Colors.greenAccent;
        break;

      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orangeAccent;
        break;

      case 'rejected':
      case 'cancelled':
        backgroundColor = Colors.red.withOpacity(0.15);
        textColor = Colors.redAccent;
        break;

      default:
        backgroundColor = ThemeColors.primaryTeal.withOpacity(0.15);
        textColor = ThemeColors.accentCyan;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ============================================================
// ADMIN DETAIL ROW
// ============================================================

class AdminDetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const AdminDetailRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: ThemeColors.accentCyan,
            size: 21,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADMIN INFO BOX
// ============================================================

class AdminInfoBox extends StatelessWidget {
  final String title;
  final String value;

  const AdminInfoBox({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: ThemeColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              color: ThemeColors.accentCyan,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADMIN POPUP ITEM
// ============================================================

class AdminPopupItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const AdminPopupItem({
    super.key,
    required this.icon,
    required this.title,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 19,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}