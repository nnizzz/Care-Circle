import 'package:care_circle/models/hivemodels.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:care_circle/widgets/admin_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class adminorphanages extends StatefulWidget {
  final VoidCallback onBack;

  const adminorphanages({
    super.key,
    required this.onBack,
  });

  @override
  State<adminorphanages> createState() =>
      _adminorphanagesState();
}

class _adminorphanagesState extends State<adminorphanages> {
  final TextEditingController searchController =
      TextEditingController();

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

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

  // Convert Firestore document to Orphanage model
  Orphanage orphanageFromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return Orphanage(
      id: doc.id,
      userId: data['userId'] ?? doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      verified: data['verified'] ?? false,
      district: data['district'] ?? '',
      category: data['category'] ?? '',
    );
  }

  // Filter orphanages
  List<Orphanage> getFilteredOrphanages(
    List<Orphanage> orphanages,
  ) {
    final search =
        searchController.text.trim().toLowerCase();

    List<Orphanage> filtered =
        List<Orphanage>.from(orphanages);

    if (selectedFilter == 'Pending') {
      filtered = filtered
          .where((orphanage) => !orphanage.verified)
          .toList();
    }

    if (selectedFilter == 'Verified') {
      filtered = filtered
          .where((orphanage) => orphanage.verified)
          .toList();
    }

    if (search.isNotEmpty) {
      filtered = filtered.where((orphanage) {
        return orphanage.name
                .toLowerCase()
                .contains(search) ||
            orphanage.address
                .toLowerCase()
                .contains(search) ||
            orphanage.district
                .toLowerCase()
                .contains(search) ||
            orphanage.category
                .toLowerCase()
                .contains(search);
      }).toList();
    }

    return filtered;
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(
    String userId,
  ) async {
    try {
      final doc =
          await firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      debugPrint('User data error: $e');
    }

    return null;
  }

  // Verify orphanage
  Future<void> verifyOrphanage(
    Orphanage orphanage,
  ) async {
    try {
      await firestore
          .collection('orphanages')
          .doc(orphanage.id)
          .update({
        'verified': true,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${orphanage.name} verified successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to verify orphanage: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Reject or remove orphanage
  Future<void> deleteOrphanage(
    Orphanage orphanage,
  ) async {
    final bool isVerified = orphanage.verified;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ThemeColors.darkTeal,
          title: Text(
            isVerified
                ? 'Remove Orphanage?'
                : 'Reject Orphanage?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            isVerified
                ? 'Are you sure you want to remove ${orphanage.name}?'
                : 'Are you sure you want to reject ${orphanage.name}?',
            style: GoogleFonts.poppins(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
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
                Navigator.pop(context, true);
              },
              child: Text(
                isVerified ? 'Remove' : 'Reject',
                style: GoogleFonts.poppins(
                  color: Colors.redAccent,
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
      await firestore
          .collection('orphanages')
          .doc(orphanage.id)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isVerified
                ? 'Orphanage removed successfully!'
                : 'Orphanage rejected successfully!',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to remove orphanage: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show orphanage details
  void showOrphanageDetails(
    Orphanage orphanage,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeColors.darkTeal,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: getUserData(orphanage.userId),
          builder: (context, userSnapshot) {
            final userData = userSnapshot.data;

            final String email =
                userData?['email']?.toString() ??
                    'Not available';

            final String phone =
                userData?['phone']?.toString() ??
                    'Not available';

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(22),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top handle
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

                      SizedBox(height: 20),

                      Center(
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor:
                              ThemeColors.primaryTeal,
                          child: Icon(
                            Icons.home_work_outlined,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ),

                      SizedBox(height: 15),

                      Center(
                        child: Text(
                          orphanage.name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: 8),

                      Center(
                        child: AdminStatusBadge(
                          status: orphanage.verified
                              ? 'Verified'
                              : 'Pending',
                        ),
                      ),

                      SizedBox(height: 25),

                      AdminDetailRow(
                        icon: Icons.location_on_outlined,
                        title: 'Address',
                        value: orphanage.address.isEmpty
                            ? 'Not added'
                            : orphanage.address,
                      ),

                      SizedBox(height: 12),

                      AdminDetailRow(
                        icon: Icons.map_outlined,
                        title: 'District',
                        value: orphanage.district.isEmpty
                            ? 'Not added'
                            : orphanage.district,
                      ),

                      SizedBox(height: 12),

                      AdminDetailRow(
                        icon: Icons.category_outlined,
                        title: 'Orphanage Type',
                        value: orphanage.category.isEmpty
                            ? 'Not specified'
                            : orphanage.category,
                      ),

                      SizedBox(height: 12),

                      AdminDetailRow(
                        icon: Icons.description_outlined,
                        title: 'Description',
                        value:
                            orphanage.description.isEmpty
                                ? 'Not added'
                                : orphanage.description,
                      ),

                      SizedBox(height: 12),

                      AdminDetailRow(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value: email,
                      ),

                      SizedBox(height: 12),

                      AdminDetailRow(
                        icon: Icons.phone_outlined,
                        title: 'Phone',
                        value: phone,
                      ),

                      SizedBox(height: 10),

                      Divider(
                        color: Colors.white24,
                      ),

                      SizedBox(height: 15),

                      if (!orphanage.verified) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  ThemeColors.primaryTeal,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  12,
                                ),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);

                              await verifyOrphanage(
                                orphanage,
                              );
                            },
                            icon: Icon(
                              Icons.verified_outlined,
                              color: Colors.white,
                            ),
                            label: Text(
                              'Verify Orphanage',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Build orphanage card
  Widget buildOrphanageCard(
    Orphanage orphanage,
  ) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getUserData(orphanage.userId),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data;

        final String email =
            userData?['email']?.toString() ?? 'No email';

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: ThemeColors.darkTeal,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor:
                    ThemeColors.primaryTeal,
                child: Icon(
                  Icons.home_work_outlined,
                  color: Colors.white,
                ),
              ),

              SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      orphanage.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),

                    SizedBox(height: 3),

                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),

                    if (orphanage.category.isNotEmpty) ...[
                      SizedBox(height: 6),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeColors.primaryTeal
                              .withOpacity(0.20),
                          borderRadius:
                              BorderRadius.circular(7),
                        ),
                        child: Text(
                          orphanage.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: ThemeColors.lightCyan,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],

                    if (orphanage.district.isNotEmpty)
                      SizedBox(height: 5),

                    if (orphanage.district.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.white54,
                            size: 13,
                          ),
                          SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              orphanage.district,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 7),

                    AdminStatusBadge(
                      status: orphanage.verified
                          ? 'Verified'
                          : 'Pending',
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                color: ThemeColors.darkTeal,
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white70,
                ),
                onSelected: (value) {
                  if (value == 'view') {
                    showOrphanageDetails(orphanage);
                  }

                  if (value == 'verify') {
                    verifyOrphanage(orphanage);
                  }

                  if (value == 'delete') {
                    deleteOrphanage(orphanage);
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: 'view',
                      child: AdminPopupItem(
                        icon: Icons.visibility_outlined,
                        title: 'View Details',
                      ),
                    ),

                    if (!orphanage.verified)
                      PopupMenuItem(
                        value: 'verify',
                        child: AdminPopupItem(
                          icon: Icons.verified_outlined,
                          title: 'Verify',
                        ),
                      ),

                    PopupMenuItem(
                      value: 'delete',
                      child: AdminPopupItem(
                        icon: Icons.delete_outline,
                        title: orphanage.verified
                            ? 'Remove'
                            : 'Reject',
                        color: Colors.redAccent,
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        );
      },
    );
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
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Manage Orphanages',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: firestore
            .collection('orphanages')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: ThemeColors.accentCyan,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.redAccent,
                  ),
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          final allOrphanages = docs
              .map(
                (doc) =>
                    orphanageFromFirestore(doc),
              )
              .toList();

          final orphanages =
              getFilteredOrphanages(allOrphanages);

          final total = allOrphanages.length;

          final pending = allOrphanages
              .where(
                (orphanage) =>
                    !orphanage.verified,
              )
              .length;

          final verified = allOrphanages
              .where(
                (orphanage) =>
                    orphanage.verified,
              )
              .length;

          return Column(
            children: [
              // Counts
              Padding(
                padding: EdgeInsets.fromLTRB(
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
                        icon:
                            Icons.home_work_outlined,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: AdminCountCard(
                        title: 'Pending',
                        value: pending,
                        icon: Icons.schedule,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: AdminCountCard(
                        title: 'Verified',
                        value: verified,
                        icon:
                            Icons.verified_outlined,
                      ),
                    ),
                  ],
                ),
              ),

              // Search
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                child: TextField(
                  controller: searchController,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search orphanages...',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.white54,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white54,
                    ),
                    suffixIcon:
                        searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  searchController
                                      .clear();
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.white54,
                                ),
                              )
                            : null,
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

              SizedBox(height: 15),

              // Filters
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
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
                      title: 'Verified',
                      selected:
                          selectedFilter ==
                              'Verified',
                      onTap: () {
                        setState(() {
                          selectedFilter =
                              'Verified';
                        });
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15),

              // Orphanage list
              Expanded(
                child: orphanages.isEmpty
                    ? Center(
                        child: Text(
                          'No orphanages found',
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          18,
                          0,
                          18,
                          20,
                        ),
                        itemCount:
                            orphanages.length,
                        itemBuilder:
                            (context, index) {
                          return buildOrphanageCard(
                            orphanages[index],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}