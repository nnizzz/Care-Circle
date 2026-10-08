import 'package:care_circle/providers/auth_provider.dart';
import 'package:care_circle/orphanage_screens/orphanage_home.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:care_circle/widgets/orphanagemodule_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/hivemodels.dart';

class receiveddonations extends StatefulWidget {
  const receiveddonations({super.key});

  @override
  State<receiveddonations> createState() => _receiveddonationsState();
}

class _receiveddonationsState extends State<receiveddonations> {
  Future<void> _refresh(String orphanageId) async {
    await FirebaseFirestore.instance.collection('donations').where('orphanageId', isEqualTo: orphanageId).get(GetOptions(source: Source.server));
  }

  Donation _fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final orphanageId = user?.id;
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
        backgroundColor: ThemeColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: ThemeColors.textLight),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => orphanagehome()));
            }
          },
        ),
        title: Text(
          'Received Donations',
          style: GoogleFonts.poppins(
            color: ThemeColors.textLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: orphanageId == null
          ? Center(child: Text('Please log in to view received donations.', style: GoogleFonts.poppins(color: ThemeColors.textLight)))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('donations')
                      .where('orphanageId', isEqualTo: orphanageId)
                      .snapshots(),
                  builder: (context, donationSnapshot) {
                    if (donationSnapshot.hasError) {
                      return Center(
                        child: Text(
                          'Unable to load donations: ${donationSnapshot.error}',
                          style: GoogleFonts.poppins(color: Colors.redAccent),
                        ),
                      );
                    }
                    if (!donationSnapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(color: ThemeColors.primaryTeal),
                      );
                    }

                    final confirmedDonations = donationSnapshot.data!.docs
                        .map(_fromDocument)
                        .where((donation) => donation.status.toLowerCase() == 'confirmed')
                        .toList()
                      ..sort((a, b) => b.date.compareTo(a.date));
                    final totalDonations = confirmedDonations.length;
                    final totalItems = confirmedDonations.fold<int>(
                      0,
                      (total, donation) => total + donation.quantity,
                    );

                    final donorNames = <String, String>{};
                    for (final doc in donationSnapshot.data!.docs) {
                      final name = doc.data()['donorName']?.toString();
                      if (name != null && name.isNotEmpty) donorNames[doc.data()['donorId']?.toString() ?? ''] = name;
                    }
                        return SafeArea(
                          child: RefreshIndicator(
                            onRefresh: () => _refresh(orphanageId),
                            child: ListView(
                              padding: const EdgeInsets.all(20),
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                const OrphanageHeaderCard(
                                  icon: Icons.volunteer_activism,
                                  title: 'Received Donations',
                                  subtitle: 'View donations approved by the admin',
                                ),
                                const SizedBox(height: 25),
                                const OrphanageSectionTitle(title: 'Overview'),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OrphanageSummaryCard(
                                        value: '$totalDonations',
                                        title: 'Total Donations',
                                        icon: Icons.favorite_outline,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OrphanageSummaryCard(
                                        value: '$totalItems',
                                        title: 'Items Received',
                                        icon: Icons.inventory_2_outlined,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 25),
                                OrphanageSectionTitle(
                                  title: 'Donation History',
                                  subtitle: '$totalDonations approved donation${totalDonations == 1 ? '' : 's'}',
                                ),
                                const SizedBox(height: 15),
                                if (confirmedDonations.isEmpty)
                                  const OrphanageEmptyReceivedDonations(),
                                if (confirmedDonations.isNotEmpty)
                                  ...confirmedDonations.map(
                                    (donation) => Padding(
                                      padding: const EdgeInsets.only(bottom: 15),
                                      child: OrphanageReceivedDonationCard(
                                        donation: donation,
                                        donorName: donorNames[donation.donorId] ?? 'Donor',
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        );
                  },
                ),
    );
  }
}
