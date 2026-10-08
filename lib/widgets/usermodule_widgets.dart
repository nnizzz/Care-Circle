import 'package:care_circle/models/hivemodels.dart';
import 'package:care_circle/models/orphanage_models.dart' show OrphanageNeed;
import 'package:care_circle/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================

// USER MODULE CUSTOM WIDGETS

// ============================================================

// ============================================================

// IMPACT ITEM

// Used in user homepage

// ============================================================

class ImpactItem extends StatelessWidget {

  final String value;

  final String title;

  final IconData icon;

  const ImpactItem({

    super.key,

    required this.value,

    required this.title,

    required this.icon,

  });

  @override

  Widget build(BuildContext context) {

    return Column(

      children: [

        Icon(

          icon,

          color: ThemeColors.accentCyan,

          size: 24,

        ),

        const SizedBox(height: 6),

        Text(

          value,

          style: GoogleFonts.poppins(

            color: ThemeColors.textLight,

            fontSize: 22,

            fontWeight: FontWeight.bold,

          ),

        ),

        Text(

          title,

          textAlign: TextAlign.center,

          style: GoogleFonts.poppins(

            color: ThemeColors.lightCyan,

            fontSize: 11,

          ),

        ),

      ],

    );

  }

}

// ============================================================

// ORPHANAGE CARD

// Used in user homepage

// ============================================================

class OrphanageCard extends StatelessWidget {

  final Orphanage orphanage;

  final VoidCallback? onTap;

  const OrphanageCard({

    super.key,

    required this.orphanage,

    this.onTap,

  });

  @override

  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        width: 180,

        margin: const EdgeInsets.only(right: 14),

        decoration: BoxDecoration(

          color: ThemeColors.card,

          borderRadius: BorderRadius.circular(16),

          border: Border.all(color: ThemeColors.border),

          boxShadow: [

            BoxShadow(

              color: Colors.black.withOpacity(0.06),

              blurRadius: 8,

              offset: const Offset(0, 3),

            ),

          ],

        ),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            ClipRRect(

              borderRadius: const BorderRadius.vertical(

                top: Radius.circular(16),

              ),

              child: SizedBox(

                height: 125,

                width: double.infinity,

                child: orphanage.image.isNotEmpty

                    ? Image.asset(

                        orphanage.image,

                        fit: BoxFit.cover,

                        errorBuilder: (context, error, stackTrace) {

                          return _orphanageImageFallback();

                        },

                      )

                    : _orphanageImageFallback(),

              ),

            ),

            Padding(

              padding: const EdgeInsets.all(10),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Row(

                    children: [

                      Expanded(

                        child: Text(

                          orphanage.name,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: GoogleFonts.poppins(

                            fontSize: 14,

                            fontWeight: FontWeight.bold,

                            color: ThemeColors.textPrimary,

                          ),

                        ),

                      ),

                      if (orphanage.verified)

                        const Icon(

                          Icons.verified,

                          size: 15,

                          color: ThemeColors.primaryTeal,

                        ),

                    ],

                  ),

                  const SizedBox(height: 3),

                  Text(

                    orphanage.address.isNotEmpty

                        ? orphanage.address

                        : 'Address not added',

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: GoogleFonts.poppins(

                      fontSize: 11,

                      color: ThemeColors.textSecondary,

                    ),

                  ),

                  const SizedBox(height: 5),

                  Row(

                    children: [

                      const Icon(

                        Icons.location_on,

                        size: 14,

                        color: ThemeColors.primaryTeal,

                      ),

                      const SizedBox(width: 3),

                      Expanded(

                        child: Text(

                          orphanage.district.isNotEmpty

                              ? orphanage.district

                              : 'District not added',

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: GoogleFonts.poppins(

                            fontSize: 11,

                            fontWeight: FontWeight.w500,

                            color: ThemeColors.textPrimary,

                          ),

                        ),

                      ),

                    ],

                  ),

                ],

              ),

            ),

          ],

        ),

      ),

    );

  }

  Widget _orphanageImageFallback() {

    return Container(

      color: ThemeColors.darkTeal,

      child: const Center(

        child: Icon(

          Icons.home_work_outlined,

          color: ThemeColors.accentCyan,

          size: 42,

        ),

      ),

    );

  }

}

// ============================================================

// QUICK ACTION CARD

// Used in user homepage

// ============================================================

class QuickActionCard extends StatelessWidget {

  final IconData icon;

  final String title;

  final VoidCallback onTap;

  const QuickActionCard({

    super.key,

    required this.icon,

    required this.title,

    required this.onTap,

  });

  @override

  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        height: 95,

        decoration: BoxDecoration(

          gradient: ThemeColors.softGradient,

          borderRadius: BorderRadius.circular(18),

          boxShadow: [

            BoxShadow(

              color: ThemeColors.primaryTeal.withOpacity(0.15),

              blurRadius: 8,

              offset: const Offset(0, 3),

            ),

          ],

        ),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(

              icon,

              color: ThemeColors.textLight,

              size: 27,

            ),

            const SizedBox(height: 8),

            Text(

              title,

              textAlign: TextAlign.center,

              style: GoogleFonts.poppins(

                color: ThemeColors.textLight,

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

// RECENT DONATION CARD

// Used in user homepage

// ============================================================

class RecentDonationCard extends StatelessWidget {

  final Donation donation;

  final String orphanageName;

  const RecentDonationCard({

    super.key,

    required this.donation,

    required this.orphanageName,

  });

  @override

  Widget build(BuildContext context) {

    final status = donation.status.toLowerCase();

    final bool isConfirmed = status == 'confirmed';

    final bool isRejected = status == 'rejected';

    final Color statusColor = isConfirmed

        ? ThemeColors.success

        : isRejected

            ? ThemeColors.error

            : ThemeColors.warning;

    final IconData statusIcon = isConfirmed

        ? Icons.check_circle

        : isRejected

            ? Icons.cancel

            : Icons.schedule;

    return Row(

      children: [

        Container(

          height: 45,

          width: 45,

          decoration: BoxDecoration(

            color: ThemeColors.lightCyan,

            borderRadius: BorderRadius.circular(12),

          ),

          child: const Icon(

            Icons.inventory_2,

            color: ThemeColors.primaryTeal,

          ),

        ),

        const SizedBox(width: 12),

        Expanded(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                '${donation.item} × ${donation.quantity}',

                style: GoogleFonts.poppins(

                  color: ThemeColors.textPrimary,

                  fontSize: 14,

                  fontWeight: FontWeight.w500,

                ),

              ),

              const SizedBox(height: 3),

              Text(

                orphanageName,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: GoogleFonts.poppins(

                  color: ThemeColors.textSecondary,

                  fontSize: 11,

                ),

              ),

              const SizedBox(height: 2),

              Text(

                donation.status,

                style: GoogleFonts.poppins(

                  color: statusColor,

                  fontSize: 11,

                  fontWeight: FontWeight.w500,

                ),

              ),

            ],

          ),

        ),

        Icon(statusIcon, color: statusColor, size: 22),

      ],

    );

  }

}

// ============================================================

// URGENT REQUIREMENT CARD

// Used in user homepage

// ============================================================

class UrgentRequirementCard extends StatelessWidget {

  final Requirement requirement;

  final String orphanageName;

  final int remainingQuantity;

  final VoidCallback? onTap;

  const UrgentRequirementCard({

    super.key,

    required this.requirement,

    required this.orphanageName,

    required this.remainingQuantity,

    this.onTap,

  });

  @override

  Widget build(BuildContext context) {

    return InkWell(

      onTap: onTap,

      borderRadius: BorderRadius.circular(12),

      child: Padding(

        padding: const EdgeInsets.symmetric(vertical: 5),

        child: Row(

          children: [

            Container(

              height: 42,

              width: 42,

              decoration: BoxDecoration(

                color: ThemeColors.lightCyan,

                borderRadius: BorderRadius.circular(12),

              ),

              child: Icon(

                _requirementIcon(requirement.category),

                color: ThemeColors.primaryTeal,

                size: 21,

              ),

            ),

            const SizedBox(width: 12),

            Expanded(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(

                    requirement.item,

                    style: GoogleFonts.poppins(

                      color: ThemeColors.textPrimary,

                      fontSize: 14,

                      fontWeight: FontWeight.w500,

                    ),

                  ),

                  const SizedBox(height: 2),

                  Text(

                    orphanageName,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: GoogleFonts.poppins(

                      color: ThemeColors.textSecondary,

                      fontSize: 10,

                    ),

                  ),

                ],

              ),

            ),

            Text(

              '$remainingQuantity needed',

              style: GoogleFonts.poppins(

                color: ThemeColors.textSecondary,

                fontSize: 12,

              ),

            ),

          ],

        ),

      ),

    );

  }

  IconData _requirementIcon(String category) {

    switch (category.toLowerCase()) {

      case 'education':

        return Icons.school_outlined;

      case 'food':

        return Icons.restaurant_outlined;

      case 'clothing':

        return Icons.checkroom_outlined;

      case 'medical':

        return Icons.medical_services_outlined;

      default:

        return Icons.inventory_2_outlined;

    }

  }

}

// ============================================================

// USER DETAIL PAGE TOP BUTTON

// ============================================================

class UserTopButton extends StatelessWidget {

  final IconData icon;

  final VoidCallback onTap;

  const UserTopButton({

    super.key,

    required this.icon,

    required this.onTap,

  });

  @override

  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        height: 45,

        width: 45,

        decoration: BoxDecoration(

          color: Colors.white.withOpacity(0.2),

          borderRadius: BorderRadius.circular(14),

        ),

        child: Icon(

          icon,

          color: Colors.white,

          size: 20,

        ),

      ),

    );

  }

}

// ============================================================

// USER DETAIL PAGE INFO CARD

// ============================================================

class UserInfoCard extends StatelessWidget {

  final IconData icon;

  final String value;

  final String label;

  const UserInfoCard({

    super.key,

    required this.icon,

    required this.value,

    required this.label,

  });

  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.symmetric(

        vertical: 15,

        horizontal: 8,

      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.04),

            blurRadius: 10,

          ),

        ],

      ),

      child: Column(

        children: [

          Icon(

            icon,

            color: const Color(0xFF4B7BFF),

            size: 22,

          ),

          const SizedBox(height: 7),

          Text(

            value,

            textAlign: TextAlign.center,

            style: GoogleFonts.poppins(

              fontSize: 15,

              fontWeight: FontWeight.w600,

              color: Colors.black87,

            ),

          ),

          const SizedBox(height: 2),

          Text(

            label,

            textAlign: TextAlign.center,

            style: GoogleFonts.poppins(

              fontSize: 10,

              color: Colors.grey,

            ),

          ),

        ],

      ),

    );

  }

}

// ============================================================

// USER DETAIL PAGE NEED CARD

// ============================================================

class UserNeedCard extends StatelessWidget {

  final OrphanageNeed need;

  final VoidCallback? onDonate;

  const UserNeedCard({

    super.key,

    required this.need,

    this.onDonate,

  });

  @override

  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.04),

            blurRadius: 10,

          ),

        ],

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              Container(

                height: 48,

                width: 48,

                decoration: BoxDecoration(

                  color: const Color.fromARGB(

                    255,

                    235,

                    243,

                    250,

                  ),

                  borderRadius: BorderRadius.circular(15),

                ),

                child: Center(

                  child: Text(

                    need.icon,

                    style: const TextStyle(

                      fontSize: 24,

                    ),

                  ),

                ),

              ),

              const SizedBox(width: 12),

              Expanded(

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(

                      need.itemName,

                      style: GoogleFonts.poppins(

                        fontSize: 16,

                        fontWeight: FontWeight.w600,

                        color: Colors.black87,

                      ),

                    ),

                    const SizedBox(height: 3),

                    Text(

                      '${need.receivedQuantity.toInt()} / '

                      '${need.requiredQuantity.toInt()} '

                      '${need.unit}',

                      style: GoogleFonts.poppins(

                        fontSize: 12,

                        color: Colors.grey,

                      ),

                    ),

                  ],

                ),

              ),

              if (need.urgent)

                Container(

                  padding: const EdgeInsets.symmetric(

                    horizontal: 9,

                    vertical: 5,

                  ),

                  decoration: BoxDecoration(

                    color: Colors.red.shade50,

                    borderRadius: BorderRadius.circular(10),

                  ),

                  child: Text(

                    'URGENT',

                    style: GoogleFonts.poppins(

                      fontSize: 9,

                      fontWeight: FontWeight.w600,

                      color: Colors.red,

                    ),

                  ),

                ),

            ],

          ),

          const SizedBox(height: 15),

          ClipRRect(

            borderRadius: BorderRadius.circular(10),

            child: LinearProgressIndicator(

              value: need.progress.clamp(0.0, 1.0),

              minHeight: 8,

              backgroundColor: Colors.grey.shade200,

            ),

          ),

          const SizedBox(height: 8),

          Text(

            '${(need.progress * 100).toInt()}% fulfilled',

            style: GoogleFonts.poppins(

              fontSize: 11,

              color: Colors.grey,

            ),

          ),

          if (onDonate != null) ...[

            const SizedBox(height: 14),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton.icon(

                onPressed: onDonate,

                icon: const Icon(

                  Icons.volunteer_activism,

                  size: 18,

                ),

                label: Text(

                  'Donate Now',

                  style: GoogleFonts.poppins(

                    fontWeight: FontWeight.w600,

                  ),

                ),

                style: ElevatedButton.styleFrom(

                  backgroundColor:

                      const Color(0xFF4B7BFF),

                  foregroundColor: Colors.white,

                  padding: const EdgeInsets.symmetric(

                    vertical: 12,

                  ),

                  shape: RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(10),

                  ),

                ),

              ),

            ),

          ],

        ],

      ),

    );

  }

}

// ============================================================

// USER DETAIL PAGE URGENT NEED CARD

// ============================================================

class UserUrgentNeedCard extends StatelessWidget {

  final OrphanageNeed need;

  const UserUrgentNeedCard({

    super.key,

    required this.need,

  });

  @override

  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: Colors.red.shade50,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(

          color: Colors.red.shade100,

        ),

      ),

      child: Row(

        children: [

          Container(

            height: 45,

            width: 45,

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius: BorderRadius.circular(14),

            ),

            child: Center(

              child: Text(

                need.icon,

                style: const TextStyle(

                  fontSize: 22,

                ),

              ),

            ),

          ),

          const SizedBox(width: 12),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  need.itemName,

                  style: GoogleFonts.poppins(

                    fontSize: 15,

                    fontWeight: FontWeight.w600,

                    color: Colors.black87,

                  ),

                ),

                const SizedBox(height: 3),

                Text(

                  '${need.remainingQuantity.toInt()} '

                  '${need.unit} still needed',

                  style: GoogleFonts.poppins(

                    fontSize: 12,

                    color: Colors.red.shade700,

                  ),

                ),

              ],

            ),

          ),

          const Icon(

            Icons.arrow_forward_ios,

            size: 16,

            color: Colors.red,

          ),

        ],

      ),

    );

  }

}

// ============================================================

// USER DETAIL PAGE HELP CARD

// ============================================================

class UserHelpCard extends StatelessWidget {

  final IconData icon;

  final String title;

  final String description;

  const UserHelpCard({

    super.key,

    required this.icon,

    required this.title,

    required this.description,

  });

  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.04),

            blurRadius: 10,

          ),

        ],

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Container(

            height: 45,

            width: 45,

            decoration: BoxDecoration(

              color: const Color.fromARGB(

                255,

                230,

                241,

                250,

              ),

              borderRadius: BorderRadius.circular(14),

            ),

            child: Icon(

              icon,

              color: const Color(0xFF4B7BFF),

            ),

          ),

          const SizedBox(height: 12),

          Text(

            title,

            style: GoogleFonts.poppins(

              fontSize: 14,

              fontWeight: FontWeight.w600,

              color: Colors.black87,

            ),

          ),

          const SizedBox(height: 4),

          Text(

            description,

            style: GoogleFonts.poppins(

              fontSize: 11,

              color: Colors.grey,

              height: 1.4,

            ),

          ),

        ],

      ),

    );

  }

}

// ============================================================

// PROFILE SECTION TITLE

// ============================================================

class ProfileSectionTitle extends StatelessWidget {

  final String title;

  const ProfileSectionTitle({

    super.key,

    required this.title,

  });

  @override

  Widget build(BuildContext context) {

    return Align(

      alignment: Alignment.centerLeft,

      child: Text(

        title,

        style: GoogleFonts.poppins(

          color: ThemeColors.textLight,

          fontSize: 17,

          fontWeight: FontWeight.w600,

        ),

      ),

    );

  }

}

// ============================================================

// PROFILE INFORMATION TILE

// ============================================================

class ProfileInfoTile extends StatelessWidget {

  final IconData icon;

  final String title;

  final String value;

  const ProfileInfoTile({

    super.key,

    required this.icon,

    required this.title,

    required this.value,

  });

  @override

  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.symmetric(

        horizontal: 16,

        vertical: 14,

      ),

      child: Row(

        children: [

          Container(

            height: 42,

            width: 42,

            decoration: BoxDecoration(

              color: ThemeColors.accentCyan.withOpacity(0.10),

              borderRadius: BorderRadius.circular(12),

            ),

            child: Icon(

              icon,

              color: ThemeColors.accentCyan,

              size: 21,

            ),

          ),

          const SizedBox(width: 13),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  title,

                  style: GoogleFonts.poppins(

                    color: ThemeColors.textSecondary,

                    fontSize: 11,

                  ),

                ),

                const SizedBox(height: 3),

                Text(

                  value,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: GoogleFonts.poppins(

                    color: ThemeColors.textLight,

                    fontSize: 13,

                    fontWeight: FontWeight.w500,

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

// PROFILE ACTION TILE

// ============================================================

class ProfileActionTile extends StatelessWidget {

  final IconData icon;

  final String title;

  final String subtitle;

  final VoidCallback onTap;

  const ProfileActionTile({

    super.key,

    required this.icon,

    required this.title,

    required this.subtitle,

    required this.onTap,

  });

  @override

  Widget build(BuildContext context) {

    return InkWell(

      onTap: onTap,

      borderRadius: BorderRadius.circular(18),

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Row(

          children: [

            Container(

              height: 44,

              width: 44,

              decoration: BoxDecoration(

                color: ThemeColors.accentCyan.withOpacity(0.10),

                borderRadius: BorderRadius.circular(12),

              ),

              child: Icon(

                icon,

                color: ThemeColors.accentCyan,

                size: 21,

              ),

            ),

            const SizedBox(width: 13),

            Expanded(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(

                    title,

                    style: GoogleFonts.poppins(

                      color: ThemeColors.textLight,

                      fontSize: 13,

                      fontWeight: FontWeight.w500,

                    ),

                  ),

                  const SizedBox(height: 3),

                  Text(

                    subtitle,

                    style: GoogleFonts.poppins(

                      color: ThemeColors.textSecondary,

                      fontSize: 10,

                    ),

                  ),

                ],

              ),

            ),

            const Icon(

              Icons.arrow_forward_ios,

              size: 14,

              color: ThemeColors.textSecondary,

            ),

          ],

        ),

      ),

    );

  }

}

// ============================================================

// PROFILE IMPACT CARD

// ============================================================

class ProfileImpactCard extends StatelessWidget {

  final IconData icon;

  final String value;

  final String title;

  const ProfileImpactCard({

    super.key,

    required this.icon,

    required this.value,

    required this.title,

  });

  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.symmetric(

        horizontal: 8,

        vertical: 15,

      ),

      decoration: BoxDecoration(

        color: ThemeColors.card,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(

          color: ThemeColors.border,

        ),

      ),

      child: Column(

        children: [

          Icon(

            icon,

            color: ThemeColors.accentCyan,

            size: 22,

          ),

          const SizedBox(height: 7),

          Text(

            value,

            style: GoogleFonts.poppins(

              color: ThemeColors.textLight,

              fontSize: 17,

              fontWeight: FontWeight.w600,

            ),

          ),

          const SizedBox(height: 2),

          Text(

            title,

            textAlign: TextAlign.center,

            style: GoogleFonts.poppins(

              color: ThemeColors.textSecondary,

              fontSize: 9,

            ),

          ),

        ],

      ),

    );

  }

}

// ============================================================

// PROFILE DIVIDER

// ============================================================

class ProfileDivider extends StatelessWidget {

  const ProfileDivider({

    super.key,

  });

  @override

  Widget build(BuildContext context) {

    return const Divider(

      height: 1,

      indent: 70,

      color: ThemeColors.border,

    );

  }

}

// ============================================================

// USER REQUIREMENTS FILTER BUTTON

// ============================================================

class UserRequirementFilterButton extends StatelessWidget {

  final String title;

  final bool selected;

  final VoidCallback onTap;

  const UserRequirementFilterButton({

    super.key,

    required this.title,

    required this.selected,

    required this.onTap,

  });

  @override

  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        padding: const EdgeInsets.symmetric(

          horizontal: 18,

          vertical: 9,

        ),

        decoration: BoxDecoration(

          color: selected

              ? ThemeColors.accentCyan

              : ThemeColors.card,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(

            color: selected

                ? ThemeColors.accentCyan

                : ThemeColors.border,

          ),

        ),

        child: Text(

          title,

          style: GoogleFonts.poppins(

            color: selected

                ? Colors.black

                : ThemeColors.textLight,

            fontSize: 12,

            fontWeight: FontWeight.w500,

          ),

        ),

      ),

    );

  }

}

// ============================================================

// USER REQUIREMENTS EMPTY STATE

// ============================================================

class UserRequirementsEmptyState extends StatelessWidget {

  const UserRequirementsEmptyState({

    super.key,

  });

  @override

  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(30),

      decoration: BoxDecoration(

        color: ThemeColors.card,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(

          color: ThemeColors.border,

        ),

      ),

      child: Column(

        children: [

          const Icon(

            Icons.search_off,

            size: 45,

            color: ThemeColors.textSecondary,

          ),

          const SizedBox(height: 12),

          Text(

            'No requirements found',

            style: GoogleFonts.poppins(

              color: ThemeColors.textPrimary,

              fontWeight: FontWeight.w600,

            ),

          ),

          const SizedBox(height: 5),

          Text(

            'Try another search or filter.',

            textAlign: TextAlign.center,

            style: GoogleFonts.poppins(

              color: ThemeColors.textSecondary,

              fontSize: 12,

            ),

          ),

        ],

      ),

    );

  }

}

// ============================================================

// USER REQUIREMENT ITEM

// ============================================================

class UserRequirementItemCard extends StatelessWidget {

  final String orphanageName;

  final String address;

  final OrphanageNeed need;

  final VoidCallback onDonate;

  const UserRequirementItemCard({

    super.key,

    required this.orphanageName,

    required this.address,

    required this.need,

    required this.onDonate,

  });

  @override

  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.only(

        bottom: 18,

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Padding(

            padding: const EdgeInsets.only(

              left: 4,

              bottom: 8,

            ),

            child: Row(

              children: [

                const Icon(

                  Icons.home_work_outlined,

                  size: 18,

                  color: ThemeColors.accentCyan,

                ),

                const SizedBox(width: 7),

                Expanded(

                  child: Text(

                    orphanageName,

                    style: GoogleFonts.poppins(

                      color: ThemeColors.textLight,

                      fontSize: 14,

                      fontWeight: FontWeight.w600,

                    ),

                  ),

                ),

              ],

            ),

          ),

          Padding(

            padding: const EdgeInsets.only(

              left: 29,

              bottom: 10,

            ),

            child: Text(

              address,

              style: GoogleFonts.poppins(

                color: ThemeColors.textSecondary,

                fontSize: 11,

              ),

            ),

          ),

          UserNeedCard(

            need: need,

            onDonate: onDonate,

          ),

        ],

      ),

    );

  }

}

// ============================================================

// USER DONATION DIALOG

// ============================================================

class UserDonationDialog extends StatefulWidget {

  final String item;

  final String orphanageName;

  final int availableQuantity;

  final String unit;

  final Future<void> Function(int quantity) onDonate;

  const UserDonationDialog({

    super.key,

    required this.item,

    required this.orphanageName,

    required this.availableQuantity,

    required this.unit,

    required this.onDonate,

  });

  @override

  State<UserDonationDialog> createState() =>

      _UserDonationDialogState();

}

class _UserDonationDialogState

    extends State<UserDonationDialog> {

  final TextEditingController quantityController =

      TextEditingController();

  bool isLoading = false;

  @override

  void dispose() {

    quantityController.dispose();

    super.dispose();

  }

  Future<void> _donate() async {

    final quantity = int.tryParse(

      quantityController.text.trim(),

    );

    if (quantity == null || quantity <= 0) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text(

            'Please enter a valid quantity',

          ),

        ),

      );

      return;

    }

    if (quantity > widget.availableQuantity) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(

            'Only ${widget.availableQuantity} '

            '${widget.unit} are currently available to donate',

          ),

        ),

      );

      return;

    }

    setState(() {

      isLoading = true;

    });

    try {

      await widget.onDonate(quantity);

      if (!mounted) return;

      Navigator.pop(context);

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(

            'Failed to add donation: $e',

          ),

        ),

      );

    } finally {

      if (mounted) {

        setState(() {

          isLoading = false;

        });

      }

    }

  }

  @override

  Widget build(BuildContext context) {

    return AlertDialog(

      backgroundColor: ThemeColors.card,

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(18),

      ),

      title: Text(

        'Donate ${widget.item}',

        style: GoogleFonts.poppins(

          color: ThemeColors.textPrimary,

          fontWeight: FontWeight.w600,

        ),

      ),

      content: Column(

        mainAxisSize: MainAxisSize.min,

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(

            widget.orphanageName,

            style: GoogleFonts.poppins(

              color: ThemeColors.textSecondary,

              fontSize: 13,

            ),

          ),

          const SizedBox(height: 6),

          Text(

            'Available: '

            '${widget.availableQuantity} '

            '${widget.unit}',

            style: GoogleFonts.poppins(

              color: ThemeColors.primaryTeal,

              fontSize: 13,

              fontWeight: FontWeight.w500,

            ),

          ),

          const SizedBox(height: 18),

          TextField(

            controller: quantityController,

            keyboardType: TextInputType.number,

            enabled: !isLoading,

            style: GoogleFonts.poppins(

              color: ThemeColors.textPrimary,

            ),

            decoration: InputDecoration(

              labelText: 'Quantity',

              labelStyle: GoogleFonts.poppins(

                color: ThemeColors.textSecondary,

              ),

              suffixText: widget.unit,

              suffixStyle: GoogleFonts.poppins(

                color: ThemeColors.textSecondary,

              ),

              filled: true,

              fillColor: ThemeColors.backgroundLight,

              enabledBorder: OutlineInputBorder(

                borderRadius:

                    BorderRadius.circular(12),

                borderSide: const BorderSide(

                  color: ThemeColors.border,

                ),

              ),

              focusedBorder: OutlineInputBorder(

                borderRadius:

                    BorderRadius.circular(12),

                borderSide: const BorderSide(

                  color: ThemeColors.primaryTeal,

                ),

              ),

            ),

          ),

        ],

      ),

      actions: [

        TextButton(

          onPressed: isLoading

              ? null

              : () {

                  Navigator.pop(context);

                },

          child: Text(

            'Cancel',

            style: GoogleFonts.poppins(

              color: ThemeColors.textSecondary,

            ),

          ),

        ),

        ElevatedButton(

          onPressed: isLoading ? null : _donate,

          style: ElevatedButton.styleFrom(

            backgroundColor:

                ThemeColors.primaryTeal,

            foregroundColor: Colors.white,

            shape: RoundedRectangleBorder(

              borderRadius:

                  BorderRadius.circular(10),

            ),

          ),

          child: isLoading

              ? const SizedBox(

                  height: 18,

                  width: 18,

                  child: CircularProgressIndicator(

                    strokeWidth: 2,

                    color: Colors.white,

                  ),

                )

              : Text(

                  'Donate',

                  style: GoogleFonts.poppins(

                    fontWeight: FontWeight.w600,

                  ),

                ),

        ),

      ],

    );

  }

}

// ============================================================

// USER GENERIC EMPTY STATE

// ============================================================

class UserEmptyState extends StatelessWidget {

  final IconData icon;

  final String title;

  final String? subtitle;

  const UserEmptyState({

    super.key,

    required this.icon,

    required this.title,

    this.subtitle,

  });

  @override

  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(

        color: ThemeColors.darkTeal,

        borderRadius: BorderRadius.circular(18),

      ),

      child: Column(

        children: [

          Icon(icon, color: ThemeColors.textMuted, size: 40),

          const SizedBox(height: 10),

          Text(

            title,

            textAlign: TextAlign.center,

            style: GoogleFonts.poppins(

              color: ThemeColors.textLight,

              fontWeight: FontWeight.w500,

            ),

          ),

          if (subtitle != null) ...[

            const SizedBox(height: 4),

            Text(

              subtitle!,

              textAlign: TextAlign.center,

              style: GoogleFonts.poppins(

                color: ThemeColors.textMuted,

                fontSize: 11,

              ),

            ),

          ],

        ],

      ),

    );

  }

}

// ============================================================

// USER DETAIL CONTACT ROW

// ============================================================

class UserContactRow extends StatelessWidget {

  final IconData icon;

  final String title;

  final String value;

  const UserContactRow({

    super.key,

    required this.icon,

    required this.title,

    required this.value,

  });

  @override

  Widget build(BuildContext context) {

    return Row(

      children: [

        Container(

          height: 46,

          width: 46,

          decoration: BoxDecoration(

            color: ThemeColors.primaryTeal.withOpacity(0.25),

            borderRadius: BorderRadius.circular(13),

          ),

          child: Icon(icon, color: ThemeColors.accentCyan),

        ),

        const SizedBox(width: 13),

        Expanded(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                title,

                style: GoogleFonts.poppins(

                  fontSize: 11,

                  color: ThemeColors.textMuted,

                ),

              ),

              const SizedBox(height: 3),

              Text(

                value,

                style: GoogleFonts.poppins(

                  fontSize: 13,

                  fontWeight: FontWeight.w500,

                  color: ThemeColors.textLight,

                ),

              ),

            ],

          ),

        ),

      ],

    );

  }

}

// ============================================================
// USER DETAIL PAGE REUSABLE COMPACT WIDGETS
// ============================================================

class UserSectionTitle extends StatelessWidget {
  final String title;

  const UserSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        color: ThemeColors.lightCyan,
      ),
    );
  }
}

class UserDetailHeader extends StatelessWidget {
  final Orphanage orphanage;
  final VoidCallback onBack;

  const UserDetailHeader({
    super.key,
    required this.orphanage,
    required this.onBack,
  });

  Widget _fallback() => Container(
        color: ThemeColors.darkTeal,
        child: const Center(
          child: Icon(
            Icons.home_work_outlined,
            color: ThemeColors.accentCyan,
            size: 90,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.only(
      bottomLeft: Radius.circular(35),
      bottomRight: Radius.circular(35),
    );

    return Stack(
      children: [
        Container(
          height: 330,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: ThemeColors.darkTeal,
            borderRadius: radius,
          ),
          child: orphanage.image.isNotEmpty
              ? ClipRRect(
                  borderRadius: radius,
                  child: Image.asset(
                    orphanage.image,
                    width: double.infinity,
                    height: 330,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallback(),
                  ),
                )
              : _fallback(),
        ),
        Container(
          height: 330,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.15),
                Colors.black.withOpacity(0.75),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                UserTopButton(
                  icon: Icons.arrow_back,
                  onTap: onBack,
                ),
                if (orphanage.verified)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified,
                          color: Colors.lightBlueAccent,
                          size: 17,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Verified',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 35,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                orphanage.name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      orphanage.district.isNotEmpty
                          ? orphanage.district
                          : orphanage.address,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class UserDetailRequirementCard extends StatelessWidget {
  final Requirement requirement;
  final int availableQuantity;
  final bool urgent;
  final VoidCallback? onDonate;

  const UserDetailRequirementCard({
    super.key,
    required this.requirement,
    required this.availableQuantity,
    this.urgent = false,
    this.onDonate,
  });

  @override
  Widget build(BuildContext context) {
    final received = requirement.quantity - availableQuantity;
    final progress = requirement.quantity > 0
        ? (received / requirement.quantity).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.darkTeal,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: urgent
              ? Colors.orangeAccent.withOpacity(0.5)
              : ThemeColors.primaryTeal.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: urgent
                      ? Colors.orangeAccent.withOpacity(0.15)
                      : ThemeColors.primaryTeal.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  urgent ? Icons.priority_high : Icons.inventory_2_outlined,
                  color:
                      urgent ? Colors.orangeAccent : ThemeColors.accentCyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      requirement.item,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      requirement.category,
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (urgent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'URGENT',
                    style: GoogleFonts.poppins(
                      color: Colors.orangeAccent,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$received received',
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 11,
                ),
              ),
              Text(
                '${requirement.quantity} needed',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                urgent ? Colors.orangeAccent : ThemeColors.accentCyan,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: availableQuantity <= 0 ? null : onDonate,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                availableQuantity <= 0
                    ? 'Requirement Covered'
                    : 'Donate Items',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserLocationCard extends StatelessWidget {
  final Orphanage orphanage;

  const UserLocationCard({
    super.key,
    required this.orphanage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ThemeColors.darkTeal,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: ThemeColors.primaryTeal,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Address',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      orphanage.address.isNotEmpty
                          ? orphanage.address
                          : 'Address not added',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.map_outlined,
                color: Colors.white60,
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                orphanage.district.isNotEmpty
                    ? orphanage.district
                    : 'District not added',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserDetailBottomBar extends StatelessWidget {
  final bool enabled;
  final VoidCallback onDonate;

  const UserDetailBottomBar({
    super.key,
    required this.enabled,
    required this.onDonate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.darkTeal,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Support',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Make an Impact',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: enabled ? onDonate : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.volunteer_activism_outlined,
                size: 19,
              ),
              label: Text(
                'Donate Now',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserRequirementPicker extends StatelessWidget {
  final List<Requirement> requirements;
  final int Function(Requirement requirement) getAvailableQuantity;
  final void Function(Requirement requirement) onSelected;

  const UserRequirementPicker({
    super.key,
    required this.requirements,
    required this.getAvailableQuantity,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 45,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Choose a Requirement',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Select the item you would like to donate.',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 18),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: requirements.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: Colors.white12),
                itemBuilder: (context, index) {
                  final requirement = requirements[index];
                  final available = getAvailableQuantity(requirement);

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: ThemeColors.primaryTeal.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: ThemeColors.accentCyan,
                      ),
                    ),
                    title: Text(
                      requirement.item,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      available > 0
                          ? '$available items still needed'
                          : 'Requirement covered',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white38,
                      size: 15,
                    ),
                    enabled: available > 0,
                    onTap: available <= 0
                        ? null
                        : () => onSelected(requirement),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
