import 'package:care_circle/database/hivedb.dart';
import 'package:care_circle/models/hivemodels.dart';
import 'package:care_circle/providers/auth_provider.dart';
import 'package:care_circle/providers/donation_provider.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:care_circle/user_screens/navigation.dart';
import 'package:care_circle/widgets/usermodule_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
class userdonations extends StatefulWidget {
  const userdonations({super.key});
  @override
  State<userdonations> createState() => _userdonationsState();
}
class _userdonationsState extends State<userdonations> {
  String selectedFilter = 'All';
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadMyDonations();
    });
  }
  void _loadMyDonations() {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    final donationProvider = Provider.of<DonationProvider>(
      context,
      listen: false,
    );
    final user = authProvider.currentUser;
    if (user == null) {
      return;
    }
    donationProvider.loadDonationsByDonor(
      user.id,
    );
  }
  List<Donation> _filteredDonations(
    List<Donation> donations,
  ) {
    if (selectedFilter == 'All') {
      return donations;
    }
    return donations.where((donation) {
      return donation.status.toLowerCase() ==
          selectedFilter.toLowerCase();
    }).toList();
  }
  int _confirmedCount(
    List<Donation> donations,
  ) {
    return donations.where((donation) {
      return donation.status.toLowerCase() ==
          'confirmed';
    }).length;
  }
  int _pendingCount(
    List<Donation> donations,
  ) {
    return donations.where((donation) {
      return donation.status.toLowerCase() ==
          'pending';
    }).length;
  }
  String _getOrphanageName(
    String orphanageId,
  ) {
    final orphanage =
        HiveDB.orphanages.get(orphanageId);
    if (orphanage != null) {
      return orphanage.name;
    }
    for (final orphanage
        in HiveDB.orphanages.values) {
      if (orphanage.id == orphanageId) {
        return orphanage.name;
      }
    }
    return 'Orphanage';
  }
  String _formatDate(DateTime date) {
    final months = [
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
    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }
  @override
  Widget build(BuildContext context) {
    final donationProvider =
        Provider.of<DonationProvider>(context);
    final allDonations =
        donationProvider.donations;
    final donations =
        _filteredDonations(allDonations);
    final confirmedCount =
        _confirmedCount(allDonations);
    final pendingCount =
        _pendingCount(allDonations);
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'My Donations',
          style: GoogleFonts.poppins(
            color: ThemeColors.textLight,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => navixs()),
            (route) => false,
          ),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ThemeColors.textLight,
          ),
        ),
        iconTheme: const IconThemeData(
          color: ThemeColors.textLight,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Track your contributions and impact',
                style: GoogleFonts.poppins(
                  color:
                      ThemeColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeColors.card,
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color: ThemeColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ImpactItem(
                        value:
                            '${allDonations.length}',
                        title: 'Total Donations',
                        icon:
                            Icons.volunteer_activism,
                      ),
                    ),
                    Container(
                      height: 45,
                      width: 1,
                      color: ThemeColors.border,
                    ),
                    Expanded(
                      child: ImpactItem(
                        value:
                            '$confirmedCount',
                        title: 'Confirmed',
                        icon:
                            Icons.check_circle_outline,
                      ),
                    ),
                    Container(
                      height: 45,
                      width: 1,
                      color: ThemeColors.border,
                    ),
                    Expanded(
                      child: ImpactItem(
                        value:
                            '$pendingCount',
                        title: 'Pending',
                        icon:
                            Icons.schedule,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Text(
                'Donation History',
                style: GoogleFonts.poppins(
                  color: ThemeColors.textLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal,
                child: Row(
                  children: [
                    _filterButton('All'),
                    const SizedBox(width: 8),
                    _filterButton(
                      'Confirmed',
                    ),
                    const SizedBox(width: 8),
                    _filterButton(
                      'Pending',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (donations.isEmpty)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: ThemeColors.card,
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                    border: Border.all(
                      color:
                          ThemeColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons
                            .volunteer_activism_outlined,
                        size: 45,
                        color: ThemeColors
                            .textSecondary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No donations found',
                        style:
                            GoogleFonts.poppins(
                          color:
                              ThemeColors.textLight,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        selectedFilter == 'All'
                            ? 'Your donations will appear here.'
                            : 'No ${selectedFilter.toLowerCase()} donations found.',
                        textAlign:
                            TextAlign.center,
                        style:
                            GoogleFonts.poppins(
                          color: ThemeColors
                              .textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount:
                      donations.length,
                  itemBuilder:
                      (context, index) {
                    final donation =
                        donations[index];
                    return _donationCard(
                      donation,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _donationCard(
    Donation donation,
  ) {
    final bool confirmed =
        donation.status.toLowerCase() ==
            'confirmed';
    final statusColor = confirmed
        ? ThemeColors.success
        : ThemeColors.warning;
    final statusIcon = confirmed
        ? Icons.check_circle_outline
        : Icons.schedule;
    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.card,
        borderRadius:
            BorderRadius.circular(16),
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
                  color: ThemeColors
                      .accentCyan
                      .withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons
                      .volunteer_activism_outlined,
                  color:
                      ThemeColors.accentCyan,
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
                      donation.item,
                      style:
                          GoogleFonts.poppins(
                        color: ThemeColors
                            .textPrimary,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _getOrphanageName(
                        donation.orphanageId,
                      ),
                      style:
                          GoogleFonts.poppins(
                        color: ThemeColors
                            .textSecondary,
                        fontSize: 11,
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
                  color: statusColor
                      .withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(
                    8,
                  ),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 13,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      donation.status,
                      style:
                          GoogleFonts.poppins(
                        color: statusColor,
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
          const SizedBox(height: 15),
          Divider(
            color: ThemeColors.divider,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color:
                    ThemeColors.primaryTeal,
                size: 17,
              ),
              const SizedBox(width: 7),
              Text(
                'Quantity: ${donation.quantity}',
                style: GoogleFonts.poppins(
                  color: ThemeColors
                      .textSecondary,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons
                    .calendar_today_outlined,
                color:
                    ThemeColors.primaryTeal,
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                _formatDate(
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
        ],
      ),
    );
  }
  Widget _filterButton(
    String title,
  ) {
    final bool selected =
        selectedFilter == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: selected
              ? ThemeColors.accentCyan
              : ThemeColors.card,
          borderRadius:
              BorderRadius.circular(20),
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
            fontWeight:
                FontWeight.w500,
          ),
        ),
      ),
    );
  }
}