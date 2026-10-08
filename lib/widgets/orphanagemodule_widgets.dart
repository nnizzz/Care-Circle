import 'package:care_circle/models/hivemodels.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
IconData orphanageCategoryIcon(String category) {
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
Color orphanagePriorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return ThemeColors.error;
    case 'medium':
      return ThemeColors.warning;
    case 'low':
      return ThemeColors.success;
    default:
      return ThemeColors.textMuted;
  }
}
Color orphanageStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'confirmed':
    case 'active':
    case 'completed':
      return ThemeColors.success;
    case 'pending':
      return ThemeColors.warning;
    default:
      return ThemeColors.textMuted;
  }
}
IconData orphanageStatusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'confirmed':
    case 'completed':
      return Icons.check_circle_outline;
    case 'active':
      return Icons.radio_button_checked;
    case 'pending':
      return Icons.access_time;
    default:
      return Icons.info_outline;
  }
}
String orphanageFormatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
class OrphanageHeaderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const OrphanageHeaderCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: ThemeColors.primaryGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: ThemeColors.textLight,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: ThemeColors.textLight,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: ThemeColors.lightCyan,
                    fontSize: 11,
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
class OrphanageSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const OrphanageSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: ThemeColors.textLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 5),
          Text(
            subtitle!,
            style: GoogleFonts.poppins(
              color: ThemeColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}
class OrphanageImpactItem extends StatelessWidget {
  final String value;
  final String title;
  final IconData icon;
  const OrphanageImpactItem({
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
class OrphanageQuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const OrphanageQuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 95,
        decoration: BoxDecoration(
          gradient: ThemeColors.softGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color:
                  ThemeColors.primaryTeal.withOpacity(0.15),
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
class OrphanageUrgentRequirementCard
    extends StatelessWidget {
  final Requirement requirement;
  final int remainingQuantity;
  const OrphanageUrgentRequirementCard({
    super.key,
    required this.requirement,
    required this.remainingQuantity,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: ThemeColors.lightCyan,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            orphanageCategoryIcon(
              requirement.category,
            ),
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
              Text(
                requirement.category,
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
    );
  }
}
class OrphanageRecentDonationCard
    extends StatelessWidget {
  final Donation donation;
  const OrphanageRecentDonationCard({
    super.key,
    required this.donation,
  });
  @override
  Widget build(BuildContext context) {
    final color =
        orphanageStatusColor(donation.status);
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
                donation.status,
                style: GoogleFonts.poppins(
                  color: ThemeColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Icon(
          orphanageStatusIcon(
            donation.status,
          ),
          color: color,
          size: 22,
        ),
      ],
    );
  }
}
class OrphanageFormLabel extends StatelessWidget {
  final String text;
  const OrphanageFormLabel({
    super.key,
    required this.text,
  });
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: ThemeColors.textLight,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
InputDecoration orphanageInputDecoration({
  required String hint,
  required IconData icon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.poppins(
      color: ThemeColors.textMuted,
      fontSize: 12,
    ),
    prefixIcon: Icon(
      icon,
      color: ThemeColors.primaryTeal,
      size: 21,
    ),
    filled: true,
    fillColor: ThemeColors.card,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 15,
      vertical: 15,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: ThemeColors.border,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: ThemeColors.border,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: ThemeColors.primaryTeal,
        width: 1.5,
      ),
    ),
  );
}
class OrphanageRequirementCard
    extends StatelessWidget {
  final Requirement requirement;
  const OrphanageRequirementCard({
    super.key,
    required this.requirement,
  });
  Future<bool> _ownsRequirement() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid != requirement.orphanageId) return false;
    final doc = await FirebaseFirestore.instance.collection('requirements').doc(requirement.id).get();
    return doc.exists && doc.data()?['orphanageId'] == uid;
  }
  Future<void> _edit(BuildContext context) async {
    final item = TextEditingController(text: requirement.item);
    final quantity = TextEditingController(text: requirement.quantity.toString());
    String category = requirement.category, priority = requirement.priority, status = requirement.status;
    final saved = await showDialog<bool>(context: context, builder: (dialogContext) => StatefulBuilder(
      builder: (context, update) => AlertDialog(
        backgroundColor: ThemeColors.card,
        title: Text('Edit Requirement', style: GoogleFonts.poppins(color: ThemeColors.textPrimary)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: item, style: TextStyle(color: ThemeColors.textPrimary), decoration: InputDecoration(labelText: 'Item')),
          TextField(controller: quantity, keyboardType: TextInputType.number, style: TextStyle(color: ThemeColors.textPrimary), decoration: InputDecoration(labelText: 'Quantity')),
          DropdownButtonFormField<String>(value: ['Food','Education','Clothing','Medical','Other'].contains(category) ? category : 'Other', items: ['Food','Education','Clothing','Medical','Other'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (x) => update(() => category = x!)),
          DropdownButtonFormField<String>(value: ['High','Medium','Low'].contains(priority) ? priority : 'Medium', items: ['High','Medium','Low'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (x) => update(() => priority = x!)),
          DropdownButtonFormField<String>(value: ['Active','Completed'].contains(status) ? status : 'Active', items: ['Active','Completed'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (x) => update(() => status = x!)),
        ])),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text('Cancel')),
          TextButton(onPressed: () { if (item.text.trim().isNotEmpty && (int.tryParse(quantity.text) ?? 0) > 0) Navigator.pop(dialogContext, true); }, child: Text('Save'))],
      ),
    ));
    if (saved == true) {
      try {
        if (!await _ownsRequirement()) throw Exception('You cannot edit this requirement.');
        final donations = await FirebaseFirestore.instance.collection('donations').where('requirementId', isEqualTo: requirement.id).get();
        final confirmedQty = donations.docs.where((d) => d.data()['status']?.toString().toLowerCase() == 'confirmed').fold<int>(0, (sum, d) => sum + ((d.data()['quantity'] as num?)?.toInt() ?? 0));
        if (int.parse(quantity.text) < confirmedQty) throw Exception('Quantity cannot be below $confirmedQty already confirmed items.');
        await FirebaseFirestore.instance.collection('requirements').doc(requirement.id).update({'item': item.text.trim(), 'quantity': int.parse(quantity.text), 'category': category, 'priority': priority, 'status': status});
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Requirement updated')));
      } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); }
    }
    item.dispose(); quantity.dispose();
  }
  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text('Delete Requirement?'), content: Text('Delete ${requirement.item}? This cannot be undone.'),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text('Delete'))],
    ));
    if (confirmed != true) return;
    try {
      if (!await _ownsRequirement()) throw Exception('You cannot delete this requirement.');
      final donations = await FirebaseFirestore.instance.collection('donations').where('requirementId', isEqualTo: requirement.id).limit(1).get();
      if (donations.docs.isNotEmpty) throw Exception('Cannot delete a requirement with donation history. Mark it Completed instead.');
      await FirebaseFirestore.instance.collection('requirements').doc(requirement.id).delete();
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Requirement deleted')));
    } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); }
  }
  @override
  Widget build(BuildContext context) {
    final priorityColor =
        orphanagePriorityColor(
      requirement.priority,
    );
    final statusColor =
        orphanageStatusColor(
      requirement.status,
    );
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ThemeColors.darkTeal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              ThemeColors.border.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: ThemeColors.primaryTeal
                  .withOpacity(0.2),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              orphanageCategoryIcon(
                requirement.category,
              ),
              color: ThemeColors.accentCyan,
              size: 25,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  requirement.item,
                  style: GoogleFonts.poppins(
                    color: ThemeColors.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  requirement.category,
                  style: GoogleFonts.poppins(
                    color: ThemeColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 5,
                  children: [
                    Text(
                      '${requirement.quantity} needed',
                      style: GoogleFonts.poppins(
                        color:
                            ThemeColors.lightCyan,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor
                            .withOpacity(0.15),
                        borderRadius:
                            BorderRadius.circular(6),
                      ),
                      child: Text(
                        requirement.priority,
                        style:
                            GoogleFonts.poppins(
                          color: priorityColor,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color:
                  statusColor.withOpacity(0.15),
              borderRadius:
                  BorderRadius.circular(8),
            ),
            child: Text(
              requirement.status,
              style: GoogleFonts.poppins(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          PopupMenuButton<String>(icon: Icon(Icons.more_vert, color: ThemeColors.textLight), color: ThemeColors.card,
            onSelected: (action) => action == 'edit' ? _edit(context) : _delete(context),
            itemBuilder: (_) => [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))],
          ),
        ],
      ),
    );
  }
}
class OrphanageEmptyRequirements
    extends StatelessWidget {
  const OrphanageEmptyRequirements({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: ThemeColors.darkTeal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: ThemeColors.accentCyan,
            size: 45,
          ),
          const SizedBox(height: 12),
          Text(
            'No Requirements Yet',
            style: GoogleFonts.poppins(
              color: ThemeColors.textLight,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Add your first requirement to get started.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: ThemeColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
class OrphanageStatusBadge extends StatelessWidget {
  final String status;
  const OrphanageStatusBadge({
    super.key,
    required this.status,
  });
  @override
  Widget build(BuildContext context) {
    final color =
        orphanageStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
class OrphanageDonationRequestCard
    extends StatelessWidget {
  final Donation donation;
  final String donorName;
  final VoidCallback onTap;
  const OrphanageDonationRequestCard({
    super.key,
    required this.donation,
    required this.donorName,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: ThemeColors.darkTeal,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color:
                ThemeColors.border.withOpacity(0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: ThemeColors.primaryTeal
                        .withOpacity(0.18),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: ThemeColors.accentCyan,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        donorName,
                        style: GoogleFonts.poppins(
                          color:
                              ThemeColors.textLight,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      Text(
                        orphanageFormatDate(
                          donation.date,
                        ),
                        style: GoogleFonts.poppins(
                          color:
                              ThemeColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                OrphanageStatusBadge(
                  status: donation.status,
                ),
              ],
            ),
            const SizedBox(height: 15),
            Divider(
              color: ThemeColors.border
                  .withOpacity(0.12),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  color: ThemeColors.accentCyan,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        donation.item,
                        style: GoogleFonts.poppins(
                          color:
                              ThemeColors.textLight,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Quantity: ${donation.quantity}',
                        style: GoogleFonts.poppins(
                          color:
                              ThemeColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: ThemeColors.textMuted,
                  size: 15,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class OrphanageEmptyDonations
    extends StatelessWidget {
  const OrphanageEmptyDonations({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: ThemeColors.darkTeal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              ThemeColors.border.withOpacity(0.12),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.volunteer_activism_outlined,
            color: ThemeColors.accentCyan,
            size: 45,
          ),
          const SizedBox(height: 12),
          Text(
            'No Donation Requests',
            style: GoogleFonts.poppins(
              color: ThemeColors.textLight,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'New donations will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: ThemeColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
class OrphanageInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const OrphanageInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.darkTeal,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color:
              ThemeColors.border.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: ThemeColors.primaryTeal
                  .withOpacity(0.15),
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: ThemeColors.accentCyan,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: ThemeColors.textMuted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: ThemeColors.textLight,
                    fontSize: 14,
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
class OrphanageRequestStatusCard
    extends StatelessWidget {
  final String status;
  const OrphanageRequestStatusCard({
    super.key,
    required this.status,
  });
  @override
  Widget build(BuildContext context) {
    final color =
        orphanageStatusColor(status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.darkTeal,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              orphanageStatusIcon(status),
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Current donation status',
                  style: GoogleFonts.poppins(
                    color: ThemeColors.textMuted,
                    fontSize: 10,
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
class OrphanageSummaryCard
    extends StatelessWidget {
  final String value;
  final String title;
  final IconData icon;
  const OrphanageSummaryCard({
    super.key,
    required this.value,
    required this.title,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            color: ThemeColors.primaryTeal,
            size: 25,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: ThemeColors.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: ThemeColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
class OrphanageReceivedDonationCard
    extends StatelessWidget {
  final Donation donation;
  final String donorName;
  const OrphanageReceivedDonationCard({
    super.key,
    required this.donation,
    required this.donorName,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: ThemeColors.primaryTeal
                      .withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: ThemeColors.primaryTeal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      donorName,
                      style: GoogleFonts.poppins(
                        color:
                            ThemeColors.textPrimary,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      orphanageFormatDate(
                        donation.date,
                      ),
                      style: GoogleFonts.poppins(
                        color: ThemeColors
                            .textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: ThemeColors.success
                      .withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 13,
                      color: ThemeColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Confirmed',
                      style: GoogleFonts.poppins(
                        color:
                            ThemeColors.success,
                        fontSize: 9,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(
            color: ThemeColors.divider,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: ThemeColors.primaryTeal,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  donation.item,
                  style: GoogleFonts.poppins(
                    color:
                        ThemeColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                'Qty: ${donation.quantity}',
                style: GoogleFonts.poppins(
                  color:
                      ThemeColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class OrphanageEmptyReceivedDonations
    extends StatelessWidget {
  const OrphanageEmptyReceivedDonations({
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
            Icons.volunteer_activism_outlined,
            size: 45,
            color: ThemeColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'No confirmed donations',
            style: GoogleFonts.poppins(
              color: ThemeColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Confirmed donations will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: ThemeColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
class OrphanageProfileInfoTile
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const OrphanageProfileInfoTile({
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
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: ThemeColors.primaryTeal
                .withOpacity(0.15),
            borderRadius:
                BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: ThemeColors.accentCyan,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: ThemeColors.textMuted,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
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
    );
  }
}
class OrphanageProfileStatCard
    extends StatelessWidget {
  final String value;
  final String title;
  final IconData icon;
  const OrphanageProfileStatCard({
    super.key,
    required this.value,
    required this.title,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: ThemeColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: ThemeColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: ThemeColors.primaryTeal,
            size: 24,
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: ThemeColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
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
class OrphanageProfileActionTile
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  const OrphanageProfileActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });
  @override
  Widget build(BuildContext context) {
    final itemColor =
        color ?? ThemeColors.textLight;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 12,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ??
                  ThemeColors.accentCyan,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: itemColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: color ??
                  ThemeColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
class OrphanageProfileDivider
    extends StatelessWidget {
  const OrphanageProfileDivider({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Divider(
      color:
          ThemeColors.border.withOpacity(0.15),
      height: 1,
    );
  }
}