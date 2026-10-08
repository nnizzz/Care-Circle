import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:care_circle/models/hivemodels.dart';
import 'package:care_circle/providers/auth_provider.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:care_circle/user_screens/donate_page.dart';
import 'package:care_circle/user_screens/orp_details.dart';
import 'package:care_circle/user_screens/orphanges_location.dart';
import 'package:care_circle/user_screens/requirments.dart';
import 'package:care_circle/widgets/usermodule_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class homeuser extends StatefulWidget {
  const homeuser({super.key});

  @override
  State<homeuser> createState() => _homeuserState();
}

class _homeuserState extends State<homeuser> {
  final TextEditingController searchController = TextEditingController();

  String selectedDistrict = 'All Districts';

  final List<String> districts = [
    'All Districts',
    'Alappuzha',
    'Ernakulam',
    'Idukki',
    'Kannur',
    'Kasaragod',
    'Kollam',
    'Kottayam',
    'Kozhikode',
    'Malappuram',
    'Palakkad',
    'Pathanamthitta',
    'Thiruvananthapuram',
    'Thrissur',
    'Wayanad',
  ];

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Orphanage orphanageFromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Orphanage(
      id: doc.id,
      userId: data['userId']?.toString() ?? doc.id,
      name: data['name']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      image: data['image']?.toString() ?? '',
      verified: data['verified'] == true,
      district: data['district']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
    );
  }

  Requirement requirementFromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
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

  Donation donationFromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final rawDate = data['date'];
    return Donation(
      id: doc.id,
      donorId: data['donorId']?.toString() ?? '',
      orphanageId: data['orphanageId']?.toString() ?? '',
      requirementId: data['requirementId']?.toString() ?? '',
      item: data['item']?.toString() ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      date: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
      status: data['status']?.toString() ?? 'Pending',
    );
  }

  String getOrphanageName(String orphanageId) =>
      _orphanages.where((o) => o.id == orphanageId).firstOrNull?.name ?? 'Orphanage';

  List<Orphanage> _orphanages = [];

  void openRequirementOrphanage(Requirement requirement) {
    final matches = _orphanages.where((o) => o.id == requirement.orphanageId);
    if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Orphanage not found.')),
      );
      return;
    }
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => detailpage(orphanage: matches.first),
    ));
  }

  void openNearby() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const nearby(),
      ),
    );
  }

  void openRequirements() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const userrequire(),
      ),
    );
  }

  void openDonations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const userdonations(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).currentUser;

    final userName = currentUser?.name ?? 'User';

    return Scaffold(
      backgroundColor: ThemeColors.background,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('orphanages').snapshots(),
          builder: (context, orphanageSnapshot) {
            if (orphanageSnapshot.hasError) {
              return Center(child: Text('Unable to load orphanages: ${orphanageSnapshot.error}', style: const TextStyle(color: ThemeColors.textLight)));
            }
            final orphanages = orphanageSnapshot.data?.docs.map(orphanageFromFirestore).toList() ?? <Orphanage>[];
            _orphanages = orphanages;
            final verifiedOrphanages = orphanages;
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('requirements').snapshots(),
              builder: (context, requirementSnapshot) {
                if (requirementSnapshot.hasError) {
                  return Center(child: Text('Unable to load requirements: ${requirementSnapshot.error}', style: const TextStyle(color: ThemeColors.textLight)));
                }
                final knownIds = orphanages.map((o) => o.id).toSet();
                final urgentRequirements = (requirementSnapshot.data?.docs.map(requirementFromFirestore).toList() ?? <Requirement>[])
                    .where((r) => knownIds.contains(r.orphanageId) && r.priority.toLowerCase() == 'high' && r.status.toLowerCase() == 'active')
                    .toList();
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: currentUser == null
                  ? null
                  : FirebaseFirestore.instance
                      .collection('donations')
                      .where('donorId', isEqualTo: currentUser.id)
                      .snapshots(),
              builder: (context, donationSnapshot) {
                final userDonations = donationSnapshot.data?.docs
                        .map(donationFromFirestore)
                        .toList() ??
                    <Donation>[];
                userDonations.sort((a, b) => b.date.compareTo(a.date));
                if (donationSnapshot.hasError) {
                  return Center(child: Text('Unable to load donations: ${donationSnapshot.error}', style: const TextStyle(color: ThemeColors.textLight)));
                }

            final confirmedDonations = userDonations
                .where(
                  (donation) =>
                      donation.status.toLowerCase() == 'confirmed',
                )
                .toList();

            final totalItems = confirmedDonations.fold<int>(
              0,
              (sum, donation) => sum + donation.quantity,
            );

            final orphanagesHelped = confirmedDonations
                .map((donation) => donation.orphanageId)
                .toSet()
                .length;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(userName),

                  const SizedBox(height: 20),

                  _buildDistrictSelector(),

                  const SizedBox(height: 25),

                  const UserSectionTitle(
                    title: 'Quick Actions',
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.favorite_rounded,
                          title: 'Donate',
                          onTap: openRequirements,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.home_rounded,
                          title: 'Orphanages',
                          onTap: openNearby,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                     
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.inventory_2_rounded,
                          title: 'My Donations',
                          onTap: openDonations,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  _sectionHeader(
                    title: 'Urgent Requirements',
                    leading: const Icon(
                      Icons.circle,
                      color: ThemeColors.error,
                      size: 10,
                    ),
                    action: 'View All →',
                    onTap: openRequirements,
                  ),

                  const SizedBox(height: 15),

                  if (urgentRequirements.isEmpty)
                    const UserEmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'No urgent requirements available.',
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: ThemeColors.card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: ThemeColors.border,
                        ),
                      ),
                      child: Column(
                        children: urgentRequirements.take(3).map(
                          (requirement) {
                            return UrgentRequirementCard(
                              requirement: requirement,
                              orphanageName: getOrphanageName(
                                requirement.orphanageId,
                              ),
                              remainingQuantity: requirement.quantity,
                              onTap: () =>
                                  openRequirementOrphanage(requirement),
                            );
                          },
                        ).toList(),
                      ),
                    ),

                  const SizedBox(height: 30),

                  _sectionHeader(
                    title: 'Verified Orphanages',
                    action: 'Show All',
                    onTap: openNearby,
                  ),

                  const SizedBox(height: 15),

                  if (verifiedOrphanages.isEmpty)
                    const UserEmptyState(
                      icon: Icons.home_work_outlined,
                      title: 'No verified orphanages available.',
                    )
                  else
                    SizedBox(
                      height: 215,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: verifiedOrphanages.length,
                        itemBuilder: (context, index) {
                          final orphanage =
                              verifiedOrphanages[index];

                          return OrphanageCard(
                            orphanage: orphanage,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => detailpage(
                                    orphanage: orphanage,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 30),

                  _sectionHeader(
                    title: 'Your Recent Donations',
                    action: 'View All',
                    onTap: openDonations,
                  ),

                  const SizedBox(height: 15),

                  if (userDonations.isEmpty)
                    const UserEmptyState(
                      icon: Icons.volunteer_activism_outlined,
                      title: 'You have not made any donations yet.',
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: ThemeColors.card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: ThemeColors.border,
                        ),
                      ),
                      child: Column(
                        children: userDonations.take(3).map(
                          (donation) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              child: RecentDonationCard(
                                donation: donation,
                                orphanageName: getOrphanageName(
                                  donation.orphanageId,
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),

                  const SizedBox(height: 30),

                  Text(
                    '💙 Your Impact',
                    style: GoogleFonts.poppins(
                      color: ThemeColors.textPrimary,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  _buildImpact(
                    donations: userDonations.length,
                    items: totalItems,
                    orphanages: orphanagesHelped,
                    confirmed: confirmedDonations.length,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
              },
            );
              },
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // SMALL HOMEPAGE SECTIONS
  // ============================================================

  Widget _buildGreeting(String userName) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: ThemeColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.primaryTeal.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  'Hello, $userName!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.textLight,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Ready to make an impact?',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: ThemeColors.lightCyan,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: ThemeColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ThemeColors.border,
        ),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: selectedDistrict,
            dropdownColor: ThemeColors.card,
            decoration: InputDecoration(
              labelText: 'Select District',
              prefixIcon: const Icon(
                Icons.location_on_rounded,
                color: ThemeColors.primaryTeal,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: districts.map((district) {
              return DropdownMenuItem<String>(
                value: district,
                child: Text(
                  district,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: ThemeColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                selectedDistrict = value;
              });
            },
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: openNearby,
              icon: const Icon(
                Icons.home_work_outlined,
                size: 18,
              ),
              label: Text(
                'Find Orphanages',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primaryTeal,
                foregroundColor: ThemeColors.textLight,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String action,
    required VoidCallback onTap,
    Widget? leading,
  }) {
    return Row(
      children: [
        if (leading != null) ...[
          leading,
          const SizedBox(width: 8),
        ],
        Expanded(
          child: UserSectionTitle(title: title),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: GoogleFonts.poppins(
              color: ThemeColors.primaryTeal,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImpact({
    required int donations,
    required int items,
    required int orphanages,
    required int confirmed,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: ThemeColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.primaryTeal.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ImpactItem(
                  value: '$donations',
                  title: 'Donations',
                  icon: Icons.favorite_rounded,
                ),
              ),
              Expanded(
                child: ImpactItem(
                  value: '$items',
                  title: 'Items',
                  icon: Icons.inventory_2_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ImpactItem(
                  value: '$orphanages',
                  title: 'Orphanages',
                  icon: Icons.home_rounded,
                ),
              ),
              Expanded(
                child: ImpactItem(
                  value: '$confirmed',
                  title: 'Confirmed',
                  icon: Icons.verified_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}