import 'package:care_circle/orphanage_screens/orp_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:care_circle/models/hivemodels.dart';
import 'package:care_circle/orphanage_screens/add_requirements.dart';
import 'package:care_circle/orphanage_screens/manage_require.dart';
import 'package:care_circle/orphanage_screens/received_donations.dart';
import 'package:care_circle/providers/auth_provider.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:care_circle/widgets/orphanagemodule_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class orphanagehome extends StatefulWidget {
  const orphanagehome({super.key});

  @override
  State<orphanagehome> createState() => _orphanagehomeState();
}

class _orphanagehomeState extends State<orphanagehome> {
  List<Requirement> _requirements(QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((doc) {
        final d = doc.data();
        return Requirement(
          id: doc.id,
          orphanageId: d['orphanageId']?.toString() ?? '',
          item: d['item']?.toString() ?? '',
          category: d['category']?.toString() ?? '',
          quantity: (d['quantity'] as num?)?.toInt() ?? 0,
          priority: d['priority']?.toString() ?? 'Medium',
          status: d['status']?.toString() ?? 'Active',
        );
      }).toList();

  List<Donation> _donations(QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((doc) {
        final d = doc.data();
        final date = d['date'];
        return Donation(
          id: doc.id,
          donorId: d['donorId']?.toString() ?? '',
          orphanageId: d['orphanageId']?.toString() ?? '',
          requirementId: d['requirementId']?.toString() ?? '',
          item: d['item']?.toString() ?? '',
          quantity: (d['quantity'] as num?)?.toInt() ?? 0,
          date: date is Timestamp ? date.toDate() : DateTime.tryParse(date?.toString() ?? '') ?? DateTime.now(),
          status: d['status']?.toString() ?? 'Pending',
        );
      }).toList();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: ThemeColors.background,
        body: Center(child: Text('Please log in to view the dashboard.')),
      );
    }

    final db = FirebaseFirestore.instance;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: db.collection('orphanages').doc(user.id).snapshots(),
      builder: (context, orphanageSnapshot) {
        if (orphanageSnapshot.hasError) {
          return _message('Unable to load orphanage: ${orphanageSnapshot.error}');
        }
        if (!orphanageSnapshot.hasData) {
          return _loading();
        }
        final orphanageDoc = orphanageSnapshot.data!;
        if (!orphanageDoc.exists) {
          return _message('Orphanage profile not found.');
        }
        final orphanageId = orphanageDoc.id;
        final orphanageName = orphanageDoc.data()?['name']?.toString() ?? '';
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: db.collection('requirements').where('orphanageId', isEqualTo: orphanageId).snapshots(),
          builder: (context, requirementSnapshot) {
            if (requirementSnapshot.hasError) {
              return _message('Unable to load requirements: ${requirementSnapshot.error}');
            }
            if (!requirementSnapshot.hasData) return _loading();
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: db.collection('donations').where('orphanageId', isEqualTo: orphanageId).snapshots(),
              builder: (context, donationSnapshot) {
                if (donationSnapshot.hasError) {
                  return _message('Unable to load donations: ${donationSnapshot.error}');
                }
                if (!donationSnapshot.hasData) return _loading();

                final requirements = _requirements(requirementSnapshot.data!);
                final donations = _donations(donationSnapshot.data!);
                final activeRequirements = requirements.where((r) => r.status.toLowerCase() == 'active').toList();
                final urgentRequirements = activeRequirements.where((r) => r.priority.toLowerCase() == 'high').toList();
                final confirmed = donations.where((d) => d.status.toLowerCase() == 'confirmed').toList();
                final confirmedCount = confirmed.length;
                final pendingCount = donations.where((d) => d.status.toLowerCase() == 'pending').length;
                final confirmedByRequirement = <String, int>{};
                for (final donation in confirmed) {
                  confirmedByRequirement.update(donation.requirementId, (n) => n + donation.quantity, ifAbsent: () => donation.quantity);
                }
                int remaining(Requirement requirement) {
                  final left = requirement.quantity - (confirmedByRequirement[requirement.id] ?? 0);
                  return left > 0 ? left : 0;
                }
                final totalItemsNeeded = activeRequirements.fold<int>(0, (total, requirement) => total + remaining(requirement));
                final recentDonations = List<Donation>.from(confirmed)..sort((a, b) => b.date.compareTo(a.date));
                final latestDonations = recentDonations.take(3).toList();

    return Scaffold(
      backgroundColor: ThemeColors.background,

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: ThemeColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orphanage Dashboard',
              style: GoogleFonts.poppins(
                color: ThemeColors.textLight,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Manage your care & donations',
              style: GoogleFonts.poppins(
                color: ThemeColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: ThemeColors.textLight,
            ),
          ),
        ],
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ====================================================
              // WELCOME HEADER
              // ====================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: ThemeColors.primaryGradient,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back!',
                            style: GoogleFonts.poppins(
                              color: ThemeColors.lightCyan,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            orphanageName,
                            style: GoogleFonts.poppins(
                              color: ThemeColors.textLight,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Manage your needs and donations',
                            style: GoogleFonts.poppins(
                              color: ThemeColors.lightCyan,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.volunteer_activism,
                        color: ThemeColors.textLight,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              // ====================================================
              // OVERVIEW
              // ====================================================

              const SizedBox(height: 25),

              Text(
                'Overview',
                style: GoogleFonts.poppins(
                  color: ThemeColors.textLight,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 5,
                ),
                decoration: BoxDecoration(
                  color: ThemeColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: ThemeColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    // ACTIVE REQUIREMENTS

                    Expanded(
                      child: OrphanageImpactItem(
                        value:
                            '${activeRequirements.length}',
                        title: 'Active\nRequirements',
                        icon: Icons.assignment_outlined,
                      ),
                    ),

                    // CONFIRMED / APPROVED DONATIONS

                    Expanded(
                      child: OrphanageImpactItem(
                        value: '$confirmedCount',
                        title: 'Donations\nReceived',
                        icon: Icons.volunteer_activism,
                      ),
                    ),

                    // PENDING DONATIONS

                    Expanded(
                      child: OrphanageImpactItem(
                        value:
                            '$pendingCount',
                        title: 'Pending\nDonations',
                        icon: Icons.priority_high,
                      ),
                    ),

                    // REMAINING ITEMS

                    Expanded(
                      child: OrphanageImpactItem(
                        value: '$totalItemsNeeded',
                        title: 'Items\nNeeded',
                        icon: Icons.inventory_2_outlined,
                      ),
                    ),
                  ],
                ),
              ),
              // QUICK ACTIONS
              const SizedBox(height: 25),

              Text(
                'Quick Actions',
                style: GoogleFonts.poppins(
                  color: ThemeColors.textLight,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.55,
                children: [
                  // ADD REQUIREMENT

                  OrphanageQuickActionCard(
                    icon: Icons.add_circle_outline,
                    title: 'Add Requirement',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const addrequirement(),
                        ),
                      );
                    },
                  ),

                  // MANAGE REQUIREMENTS

                  OrphanageQuickActionCard(
                    icon: Icons.assignment_outlined,
                    title: 'Manage Requirements',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const managerequirements(),
                        ),
                      );
                    },
                  ),

                  // RECEIVED / APPROVED DONATIONS

                  OrphanageQuickActionCard(
                    icon: Icons.volunteer_activism,
                    title: 'Donations',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const receiveddonations(),
                        ),
                      );
                    },
                  ),

                  OrphanageQuickActionCard(
                    icon: Icons.person_outline,
                    title: 'My Profile',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const orphanageprofile(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              // URGENT REQUIREMENTS
              const SizedBox(height: 25),

              Text(
                'Urgent Requirements',
                style: GoogleFonts.poppins(
                  color: ThemeColors.textLight,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: ThemeColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: ThemeColors.border,
                  ),
                ),
                child: urgentRequirements.isEmpty
                    // NO URGENT REQUIREMENTS   
                   ? Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: ThemeColors.success,
                              size: 35,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No urgent requirements',
                              style: GoogleFonts.poppins(
                                color:
                                    ThemeColors.textPrimary,
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    // REAL URGENT REQUIREMENTS
                    : Column(
                        children: List.generate(
                          urgentRequirements.length,
                          (index) {
                            final requirement =
                                urgentRequirements[index];

                            return Column(
                              children: [
                                OrphanageUrgentRequirementCard(
                                  requirement:
                                      requirement,
                                  remainingQuantity:
                                      remaining(requirement),
                                ),
                                if (index !=
                                    urgentRequirements
                                            .length -
                                        1)
                                  const SizedBox(
                                    height: 15,
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
              ),
              // RECENT APPROVED DONATIONS
              const SizedBox(height: 25),

              Text(
                'Recent Donations',
                style: GoogleFonts.poppins(
                  color: ThemeColors.textLight,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: ThemeColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: ThemeColors.border,
                  ),
                ),
                child: latestDonations.isEmpty
                    // NO APPROVED DONATIONS
                    ? Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons
                                  .volunteer_activism_outlined,
                              color:
                                  ThemeColors.textSecondary,
                              size: 35,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No donations yet',
                              style: GoogleFonts.poppins(
                                color:
                                    ThemeColors.textPrimary,
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Admin-approved donations will appear here.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: ThemeColors
                                    .textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      )

                    // REAL CONFIRMED DONATIONS
                    : Column(
                        children: List.generate(
                          latestDonations.length,
                          (index) {
                            final donation =
                                latestDonations[index];

                            return Column(
                              children: [
                                OrphanageRecentDonationCard(
                                  donation: donation,
                                ),
                                if (index !=
                                    latestDonations.length -
                                        1)
                                  const SizedBox(
                                    height: 15,
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
              },
            );
          },
        );
      },
    );
  }

  Widget _loading() => const Scaffold(
    backgroundColor: ThemeColors.background,
    body: Center(child: CircularProgressIndicator()),
  );

  Widget _message(String message) => Scaffold(
    backgroundColor: ThemeColors.background,
    body: Center(child: Text(message, style: const TextStyle(color: ThemeColors.textLight))),
  );
}
