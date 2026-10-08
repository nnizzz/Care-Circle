import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:care_circle/models/hivemodels.dart';
import 'package:care_circle/providers/auth_provider.dart';
import 'package:care_circle/providers/donation_provider.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:care_circle/widgets/usermodule_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class detailpage extends StatefulWidget {
  final Orphanage orphanage;

  const detailpage({
    super.key,
    required this.orphanage,
  });

  @override
  State<detailpage> createState() => _detailpageState();
}

class _detailpageState extends State<detailpage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, int> remaining = {};

  int available(Requirement requirement) =>
      remaining[requirement.id] ?? requirement.quantity;

  Requirement parseRequirement(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Requirement(
      id: doc.id,
      orphanageId: data['orphanageId']?.toString() ?? '',
      item: data['item']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      priority: data['priority']?.toString() ?? 'Medium',
      status: data['status']?.toString() ?? 'Active',
    );
  }

  User? parseUser(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (!snapshot.exists) return null;
    final data = snapshot.data()!;
    return User(
      id: snapshot.id,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      password: '',
      phone: data['phone']?.toString() ?? '',
      role: data['role']?.toString() ?? 'orphanage',
    );
  }

  DonationProvider get donationProvider =>
      Provider.of<DonationProvider>(context, listen: false);

  Future<void> showDonateDialog(Requirement requirement) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final availableQuantity = available(requirement);

    if (availableQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This requirement is already fully covered.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (_) => UserDonationDialog(
        item: requirement.item,
        orphanageName: widget.orphanage.name,
        availableQuantity: availableQuantity,
        unit: 'items',
        onDonate: (quantity) async {
          final user = authProvider.currentUser;
          if (user == null) return;

          await donationProvider.addDonation(
            donorId: user.id,
            orphanageId: widget.orphanage.id,
            requirementId: requirement.id,
            item: requirement.item,
            quantity: quantity,
          );

          if (!mounted) return;
          setState(() {});

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Donation request submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void showRequirementPicker(List<Requirement> items) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeColors.darkTeal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) => UserRequirementPicker(
        requirements: items,
        getAvailableQuantity: available,
        onSelected: (requirement) {
          Navigator.pop(sheetContext);
          showDonateDialog(requirement);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: firestore.collection('requirements')
          .where('orphanageId', isEqualTo: widget.orphanage.id).snapshots(),
      builder: (context, requirementsSnapshot) {
        if (requirementsSnapshot.hasError) {
          return Scaffold(backgroundColor: ThemeColors.background,
            body: Center(child: Text('Unable to load requirements: ${requirementsSnapshot.error}',
              style: const TextStyle(color: Colors.white))));
        }
        if (!requirementsSnapshot.hasData) {
          return const Scaffold(backgroundColor: ThemeColors.background,
            body: Center(child: CircularProgressIndicator()));
        }
        final allRequirements = requirementsSnapshot.data!.docs
            .map(parseRequirement)
            .where((r) => r.status.toLowerCase() == 'active').toList();
        final urgent = allRequirements
            .where((r) => r.priority.toLowerCase() == 'high').toList();
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: firestore.collection('donations')
              .where('orphanageId', isEqualTo: widget.orphanage.id).snapshots(),
          builder: (context, donationsSnapshot) {
            if (donationsSnapshot.hasError) {
              return Scaffold(backgroundColor: ThemeColors.background,
                body: Center(child: Text('Unable to load donations: ${donationsSnapshot.error}',
                  style: const TextStyle(color: Colors.white))));
            }
            if (!donationsSnapshot.hasData) {
              return const Scaffold(backgroundColor: ThemeColors.background,
                body: Center(child: CircularProgressIndicator()));
            }
            final confirmed = <String, int>{};
            for (final doc in donationsSnapshot.data!.docs) {
              final data = doc.data();
              if ((data['status']?.toString() ?? '').toLowerCase() != 'confirmed') continue;
              final id = data['requirementId']?.toString() ?? '';
              confirmed[id] = (confirmed[id] ?? 0) +
                  ((data['quantity'] as num?)?.toInt() ?? 0);
            }
            remaining = {
              for (final r in allRequirements)
                r.id: (r.quantity - (confirmed[r.id] ?? 0)).clamp(0, r.quantity).toInt(),
            };
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: firestore.collection('users').doc(widget.orphanage.userId).snapshots(),
              builder: (context, userSnapshot) {
                final user = userSnapshot.hasData ? parseUser(userSnapshot.data!) : null;
                return _buildDetails(allRequirements, urgent, user);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDetails(List<Requirement> allRequirements,
      List<Requirement> urgent, User? user) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                UserDetailHeader(
                  orphanage: widget.orphanage,
                  onBack: () => Navigator.pop(context),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: UserInfoCard(
                              icon: Icons.inventory_2_outlined,
                              value: '${allRequirements.length}',
                              label: 'Needs',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: UserInfoCard(
                              icon: Icons.priority_high,
                              value: '${urgent.length}',
                              label: 'Urgent',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: UserInfoCard(
                              icon: Icons.verified_outlined,
                              value: widget.orphanage.verified ? 'Yes' : 'No',
                              label: 'Verified',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

// ORPHANAGE TYPE
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: ThemeColors.darkTeal,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: ThemeColors.border,
    ),
  ),
  child: Row(
    children: [
      Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: ThemeColors.primaryTeal.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.category_outlined,
          color: ThemeColors.accentCyan,
          size: 23,
        ),
      ),

      const SizedBox(width: 14),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orphanage Type',
              style: GoogleFonts.poppins(
                color: ThemeColors.textMuted,
                fontSize: 11,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              widget.orphanage.category.isNotEmpty
                  ? widget.orphanage.category
                  : 'Not specified',
              style: GoogleFonts.poppins(
                color: ThemeColors.textLight,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

const SizedBox(height: 30),

                      const UserSectionTitle(title: 'About'),
                      const SizedBox(height: 12),
                      Text(
                        widget.orphanage.description.isNotEmpty
                            ? widget.orphanage.description
                            : 'No description has been added yet.',
                        style: GoogleFonts.poppins(
                          color: ThemeColors.textSecondary,
                          height: 1.8,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const UserSectionTitle(title: 'Current Needs'),
                          Text(
                            '${allRequirements.length} Needs',
                            style: GoogleFonts.poppins(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      if (allRequirements.isEmpty)
                        const UserEmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: 'No active requirements',
                          subtitle:
                              'This orphanage has no active needs at the moment.',
                        )
                      else
                        ...allRequirements.map(
                          (r) => UserDetailRequirementCard(
                            requirement: r,
                            availableQuantity:
                                available(r),
                            onDonate: () => showDonateDialog(r),
                          ),
                        ),

                      if (urgent.isNotEmpty) ...[
                        const SizedBox(height: 30),
                        const UserSectionTitle(
                          title: 'Urgent Requirements',
                        ),
                        const SizedBox(height: 18),
                        ...urgent.map(
                          (r) => UserDetailRequirementCard(
                            requirement: r,
                            availableQuantity:
                                available(r),
                            urgent: true,
                            onDonate: () => showDonateDialog(r),
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),
                      const UserSectionTitle(title: 'Location'),
                      const SizedBox(height: 18),
                      UserLocationCard(orphanage: widget.orphanage),

                      const SizedBox(height: 30),
                      const UserSectionTitle(title: 'Contact'),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: ThemeColors.darkTeal,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            UserContactRow(
                              icon: Icons.phone_outlined,
                              title: 'Contact Number',
                              value: user?.phone ?? 'Not available',
                            ),
                            const SizedBox(height: 15),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 15),
                            UserContactRow(
                              icon: Icons.email_outlined,
                              title: 'Email',
                              value: user?.email ?? 'Not available',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: UserDetailBottomBar(
              enabled: allRequirements.isNotEmpty,
              onDonate: () => showRequirementPicker(allRequirements),
            ),
          ),
        ],
      ),
    );
  }
}
