import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:care_circle/models/hivemodels.dart';
import 'package:care_circle/providers/donation_provider.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:care_circle/widgets/admin_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
class admindonations extends StatefulWidget {
  final VoidCallback onBack;
  const admindonations({
    super.key,
    required this.onBack,
  });
  @override
  State<admindonations> createState() =>
      _admindonationsState();
}
class _admindonationsState extends State<admindonations> {
  final TextEditingController searchController =
      TextEditingController();
  String selectedFilter = 'All';
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
  Map<String, Map<String, dynamic>> _users = {};
  Map<String, Map<String, dynamic>> _orphanages = {};
  Map<String, Map<String, dynamic>> _requirements = {};
  List<Donation> _allDonations = [];
  String getDonorName(String donorId) =>
      _users[donorId]?['name']?.toString() ?? 'Unknown Donor';
  User? getDonor(String donorId) {
    final data = _users[donorId];
    if (data == null) return null;
    return User(
      id: donorId,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      password: '',
      phone: data['phone']?.toString() ?? '',
      role: data['role']?.toString() ?? 'user',
    );
  }
  String getOrphanageName(String orphanageId) =>
      _orphanages[orphanageId]?['name']?.toString() ??
      'Unknown Orphanage';
  Orphanage? getOrphanage(String orphanageId) {
    final data = _orphanages[orphanageId];
    if (data == null) return null;
    return Orphanage(
      id: orphanageId,
      userId: data['userId']?.toString() ?? orphanageId,
      name: data['name']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      image: data['image']?.toString() ?? '',
      verified: data['verified'] == true,
      district: data['district']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
    );
  }
  Requirement? getRequirement(String requirementId) {
    final data = _requirements[requirementId];
    if (data == null) return null;
    return Requirement(
      id: requirementId,
      orphanageId: data['orphanageId']?.toString() ?? '',
      item: data['item']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      priority: data['priority']?.toString() ?? 'Medium',
      status: data['status']?.toString() ?? 'Active',
    );
  }
  Donation donationFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
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
  Widget loadingView() => Center(
    child: CircularProgressIndicator(color: ThemeColors.primaryTeal),
  );
  Widget errorView(Object? error) => Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        'Error loading donations: $error',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(color: Colors.redAccent),
      ),
    ),
  );
  List<Donation> getFilteredDonations() {
    final search =
        searchController.text.trim().toLowerCase();
    List<Donation> donations =
        List.of(_allDonations);
    if (selectedFilter == 'Pending') {
      donations = donations
          .where(
            (donation) =>
                donation.status.toLowerCase() ==
                'pending',
          )
          .toList();
    }
    if (selectedFilter == 'Confirmed') {
      donations = donations
          .where(
            (donation) =>
                donation.status.toLowerCase() ==
                'confirmed',
          )
          .toList();
    }
    if (selectedFilter == 'Rejected') {
      donations = donations
          .where(
            (donation) =>
                donation.status.toLowerCase() ==
                'rejected',
          )
          .toList();
    }
    if (search.isNotEmpty) {
      donations = donations.where((donation) {
        final donorName =
            getDonorName(donation.donorId)
                .toLowerCase();
        final orphanageName =
            getOrphanageName(donation.orphanageId)
                .toLowerCase();
        return donation.item
                .toLowerCase()
                .contains(search) ||
            donorName.contains(search) ||
            orphanageName.contains(search);
      }).toList();
    }
    donations.sort(
      (a, b) => b.date.compareTo(a.date),
    );
    return donations;
  }
  Future<void> confirmDonation(
    Donation donation,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ThemeColors.darkTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Confirm Donation?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to approve this '
            'donation of ${donation.quantity} '
            '${donation.item}?',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ThemeColors.primaryTeal,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text(
                'Confirm',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    try {
      final donationProvider =
          Provider.of<DonationProvider>(
        context,
        listen: false,
      );
      await donationProvider.confirmDonation(
        donation.id,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Donation confirmed successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> rejectDonation(
    Donation donation,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ThemeColors.darkTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Reject Donation?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to reject this '
            'donation of ${donation.quantity} '
            '${donation.item}?',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text(
                'Reject',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    try {
      final donationProvider =
          Provider.of<DonationProvider>(
        context,
        listen: false,
      );
      await donationProvider.rejectDonation(
        donation.id,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Donation rejected successfully!',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> deleteDonation(
    Donation donation,
  ) async {
    if (donation.status.toLowerCase() == 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please confirm or reject the pending '
            'donation instead of removing it.',
          ),
        ),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ThemeColors.darkTeal,
          title: Text(
            'Remove Donation?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to remove this '
            'donation of ${donation.item}?',
            style: GoogleFonts.poppins(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(
                'Remove',
                style: GoogleFonts.poppins(
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    final donationProvider =
        Provider.of<DonationProvider>(
      context,
      listen: false,
    );
    await donationProvider.deleteDonation(
      donation.id,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Donation removed successfully!',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
  void showDonationDetails(
    Donation donation,
  ) {
    final donor =
        getDonor(donation.donorId);
    final orphanage =
        getOrphanage(donation.orphanageId);
    final requirement =
        getRequirement(donation.requirementId);
    final bool isPending =
        donation.status.toLowerCase() == 'pending';
    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeColors.darkTeal,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      height: 4,
                      width: 45,
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor:
                          ThemeColors.primaryTeal,
                      child: const Icon(
                        Icons.volunteer_activism_outlined,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Text(
                      donation.item,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: AdminStatusBadge(
                      status: donation.status,
                    ),
                  ),
                  const SizedBox(height: 25),
                  AdminDetailRow(
                    icon: Icons.person_outline,
                    title: 'Donor',
                    value:
                        donor?.name ?? 'Unknown Donor',
                  ),
                  AdminDetailRow(
                    icon: Icons.email_outlined,
                    title: 'Donor Email',
                    value: donor?.email ??
                        'Not available',
                  ),
                  AdminDetailRow(
                    icon: Icons.home_work_outlined,
                    title: 'Orphanage',
                    value: orphanage?.name ??
                        'Unknown Orphanage',
                  ),
                  AdminDetailRow(
                    icon:
                        Icons.inventory_2_outlined,
                    title: 'Item',
                    value: donation.item,
                  ),
                  AdminDetailRow(
                    icon: Icons.numbers,
                    title: 'Quantity',
                    value:
                        donation.quantity.toString(),
                  ),
                  AdminDetailRow(
                    icon: Icons.category_outlined,
                    title: 'Requirement',
                    value: requirement?.item ??
                        'Requirement not available',
                  ),
                  AdminDetailRow(
                    icon:
                        Icons.calendar_today_outlined,
                    title: 'Date',
                    value:
                        formatDate(donation.date),
                  ),
                  AdminDetailRow(
                    icon: Icons.info_outline,
                    title: 'Status',
                    value: donation.status,
                  ),
                  const SizedBox(height: 5),
                  const Divider(
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: AdminInfoBox(
                          title: 'Quantity',
                          value: donation.quantity
                              .toString(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AdminInfoBox(
                          title: 'Status',
                          value: donation.status,
                        ),
                      ),
                    ],
                  ),
                  if (isPending) ...[
                    const SizedBox(height: 25),
                    Text(
                      'Admin Action',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                rejectDonation(
                                  donation,
                                );
                              },
                              icon: const Icon(
                                Icons.close,
                                color:
                                    Colors.redAccent,
                              ),
                              label: Text(
                                'Reject',
                                style:
                                    GoogleFonts.poppins(
                                  color:
                                      Colors.redAccent,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                              style:
                                  OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color:
                                      Colors.redAccent,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                confirmDonation(
                                  donation,
                                );
                              },
                              icon: const Icon(
                                Icons
                                    .check_circle_outline,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Confirm',
                                style:
                                    GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    ThemeColors
                                        .primaryTeal,
                                elevation: 0,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (!isPending) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: donation.status
                                    .toLowerCase() ==
                                'confirmed'
                            ? Colors.green
                                .withOpacity(0.10)
                            : Colors.red
                                .withOpacity(0.10),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            donation.status
                                        .toLowerCase() ==
                                    'confirmed'
                                ? Icons
                                    .check_circle_outline
                                : Icons
                                    .cancel_outlined,
                            color: donation.status
                                        .toLowerCase() ==
                                    'confirmed'
                                ? Colors.greenAccent
                                : Colors.redAccent,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              donation.status
                                          .toLowerCase() ==
                                      'confirmed'
                                  ? 'This donation has been confirmed by Admin.'
                                  : 'This donation has been rejected by Admin.',
                              style:
                                  GoogleFonts.poppins(
                                color:
                                    Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  String formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');
    final month =
        date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
  backgroundColor: ThemeColors.background,
  elevation: 0,
  automaticallyImplyLeading: false,
  leading: IconButton(
    onPressed: widget.onBack,
    icon: const Icon(
      Icons.arrow_back,
      color: Colors.white,
    ),
  ),
  title: Text(
    'Manage Donations',
    style: GoogleFonts.poppins(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
  ),
),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, usersSnapshot) {
          if (usersSnapshot.hasError) return errorView(usersSnapshot.error);
          if (!usersSnapshot.hasData) return loadingView();
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('orphanages').snapshots(),
            builder: (context, orphanagesSnapshot) {
              if (orphanagesSnapshot.hasError) {
                return errorView(orphanagesSnapshot.error);
              }
              if (!orphanagesSnapshot.hasData) return loadingView();
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('requirements').snapshots(),
                builder: (context, requirementsSnapshot) {
                  if (requirementsSnapshot.hasError) {
                    return errorView(requirementsSnapshot.error);
                  }
                  if (!requirementsSnapshot.hasData) return loadingView();
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection('donations').snapshots(),
                    builder: (context, donationsSnapshot) {
                      if (donationsSnapshot.hasError) {
                        return errorView(donationsSnapshot.error);
                      }
                      if (!donationsSnapshot.hasData) return loadingView();
                      _users = {
                        for (final doc in usersSnapshot.data!.docs)
                          doc.id: doc.data(),
                      };
                      _orphanages = {
                        for (final doc in orphanagesSnapshot.data!.docs)
                          doc.id: doc.data(),
                      };
                      _requirements = {
                        for (final doc in requirementsSnapshot.data!.docs)
                          doc.id: doc.data(),
                      };
                      _allDonations = donationsSnapshot.data!.docs
                          .map(donationFromDoc)
                          .toList();
                      final donations = getFilteredDonations();
                      final total = _allDonations.length;
                      final pending = _allDonations.where(
                        (donation) => donation.status.toLowerCase() == 'pending',
                      ).length;
                      final confirmed = _allDonations.where(
                        (donation) => donation.status.toLowerCase() == 'confirmed',
                      ).length;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  10,
                  18,
                  15,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AdminCountCard(
                        title: 'Total',
                        value: total,
                        icon: Icons
                            .volunteer_activism_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminCountCard(
                        title: 'Pending',
                        value: pending,
                        icon:
                            Icons.schedule_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminCountCard(
                        title: 'Confirmed',
                        value: confirmed,
                        icon: Icons
                            .check_circle_outline,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                child: TextField(
                  controller: searchController,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Search donations...',
                    hintStyle:
                        GoogleFonts.poppins(
                      color: Colors.white54,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.white54,
                    ),
                    filled: true,
                    fillColor:
                        ThemeColors.darkTeal,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection:
                      Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  children: [
                    AdminFilterChip(
                      title: 'All',
                      selected:
                          selectedFilter == 'All',
                      onTap: () {
                        setState(() {
                          selectedFilter = 'All';
                        });
                      },
                    ),
                    AdminFilterChip(
                      title: 'Pending',
                      selected:
                          selectedFilter ==
                              'Pending',
                      onTap: () {
                        setState(() {
                          selectedFilter =
                              'Pending';
                        });
                      },
                    ),
                    AdminFilterChip(
                      title: 'Confirmed',
                      selected:
                          selectedFilter ==
                              'Confirmed',
                      onTap: () {
                        setState(() {
                          selectedFilter =
                              'Confirmed';
                        });
                      },
                    ),
                    AdminFilterChip(
                      title: 'Rejected',
                      selected:
                          selectedFilter ==
                              'Rejected',
                      onTap: () {
                        setState(() {
                          selectedFilter =
                              'Rejected';
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: donations.isEmpty
                    ? Center(
                        child: Text(
                          'No donations found',
                          style:
                              GoogleFonts.poppins(
                            color:
                                Colors.white54,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          18,
                          0,
                          18,
                          20,
                        ),
                        itemCount:
                            donations.length,
                        itemBuilder:
                            (context, index) {
                          final donation =
                              donations[index];
                          final donor =
                              getDonor(
                            donation.donorId,
                          );
                          final orphanage =
                              getOrphanage(
                            donation
                                .orphanageId,
                          );
                          final isPending =
                              donation.status
                                      .toLowerCase() ==
                                  'pending';
                          return Container(
                            margin:
                                const EdgeInsets
                                    .only(
                              bottom: 12,
                            ),
                            padding:
                                const EdgeInsets
                                    .all(15),
                            decoration:
                                BoxDecoration(
                              color: ThemeColors
                                  .darkTeal,
                              borderRadius:
                                  BorderRadius
                                      .circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 52,
                                  width: 52,
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        ThemeColors
                                            .primaryTeal,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      14,
                                    ),
                                  ),
                                  child:
                                      const Icon(
                                    Icons
                                        .volunteer_activism_outlined,
                                    color:
                                        Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        '${donation.item} × ${donation.quantity}',
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                        style:
                                            GoogleFonts
                                                .poppins(
                                          color: Colors
                                              .white,
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                          fontSize:
                                              14,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        donor?.name ??
                                            'Unknown Donor',
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                        style:
                                            GoogleFonts
                                                .poppins(
                                          color: Colors
                                              .white70,
                                          fontSize:
                                              11,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        orphanage
                                                ?.name ??
                                            'Unknown Orphanage',
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                        style:
                                            GoogleFonts
                                                .poppins(
                                          color: Colors
                                              .white54,
                                          fontSize:
                                              10,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Row(
                                        children: [
                                          AdminStatusBadge(
                                            status:
                                                donation
                                                    .status,
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            formatDate(
                                              donation
                                                  .date,
                                            ),
                                            style:
                                                GoogleFonts
                                                    .poppins(
                                              color: Colors
                                                  .white54,
                                              fontSize:
                                                  9,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<
                                    String>(
                                  color: ThemeColors
                                      .darkTeal,
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color:
                                        Colors.white70,
                                  ),
                                  onSelected:
                                      (value) {
                                    if (value ==
                                        'view') {
                                      showDonationDetails(
                                        donation,
                                      );
                                    }
                                    if (value ==
                                        'delete') {
                                      deleteDonation(
                                        donation,
                                      );
                                    }
                                  },
                                  itemBuilder:
                                      (context) {
                                    return [
                                      const PopupMenuItem(
                                        value: 'view',
                                        child:
                                            AdminPopupItem(
                                          icon: Icons
                                              .visibility_outlined,
                                          title:
                                              'View Details',
                                        ),
                                      ),
                                      if (!isPending)
                                        const PopupMenuItem(
                                          value:
                                              'delete',
                                          child:
                                              AdminPopupItem(
                                            icon: Icons
                                                .delete_outline,
                                            title:
                                                'Remove',
                                            color: Colors
                                                .redAccent,
                                          ),
                                        ),
                                    ];
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
