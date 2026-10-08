import 'package:care_circle/database/hivedb.dart';
import 'package:care_circle/models/hivemodels.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:care_circle/widgets/admin_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class adminusers extends StatefulWidget {
  const adminusers({super.key});

  @override
  State<adminusers> createState() => _adminusersState();
}

class _adminusersState extends State<adminusers> {
  final TextEditingController searchController =
      TextEditingController();

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

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

  User userFromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return User(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      password: '',
      phone: data['phone']?.toString() ?? '',
      role: data['role']?.toString() ?? 'user',
    );
  }

  List<User> getUsers(List<User> allUsers) {
    final search =
        searchController.text.trim().toLowerCase();

    List<User> users = allUsers
        .where(
          (user) =>
              user.role.toLowerCase() == 'user',
        )
        .toList();

    if (search.isNotEmpty) {
      users = users.where((user) {
        return user.name.toLowerCase().contains(search) ||
            user.email.toLowerCase().contains(search) ||
            user.phone.toLowerCase().contains(search);
      }).toList();
    }

    return users;
  }

  Future<void> deleteUser(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ThemeColors.darkTeal,
          title: Text(
            'Remove User?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to remove ${user.name}?',
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

    try {
      await firestore
          .collection('users')
          .doc(user.id)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User removed successfully!',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'permission-denied'
                ? 'Permission denied while removing user.'
                : 'Unable to remove user.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showUserDetails(User user) {
    final donations = HiveDB.donations.values
        .where(
          (donation) => donation.donorId == user.id,
        )
        .toList();

    final pendingDonations = donations
        .where(
          (donation) =>
              donation.status.toLowerCase() == 'pending',
        )
        .length;

    final completedDonations = donations
        .where(
          (donation) =>
              donation.status.toLowerCase() ==
                  'confirmed' ||
              donation.status.toLowerCase() ==
                  'completed',
        )
        .length;

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
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(22),
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

                  SizedBox(height: 20),

                  Center(
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor:
                          ThemeColors.primaryTeal,
                      child: Text(
                        user.name.isNotEmpty
                            ? user.name[0].toUpperCase()
                            : 'U',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  Center(
                    child: Text(
                      user.name,
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
                      status: 'User',
                    ),
                  ),

                  SizedBox(height: 25),

                  AdminDetailRow(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: user.email,
                  ),

                  AdminDetailRow(
                    icon: Icons.phone_outlined,
                    title: 'Phone',
                    value: user.phone.isEmpty
                        ? 'Not available'
                        : user.phone,
                  ),

                  AdminDetailRow(
                    icon: Icons.person_outline,
                    title: 'Role',
                    value: user.role,
                  ),

                  SizedBox(height: 5),

                  Divider(
                    color: Colors.white24,
                  ),

                  SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: AdminInfoBox(
                          title: 'Donations',
                          value:
                              donations.length.toString(),
                        ),
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: AdminInfoBox(
                          title: 'Pending',
                          value:
                              pendingDonations.toString(),
                        ),
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: AdminInfoBox(
                          title: 'Completed',
                          value:
                              completedDonations.toString(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int getDonationCount(String userId) {
    return HiveDB.donations.values
        .where(
          (donation) => donation.donorId == userId,
        )
        .length;
  }

  int getTotalDonations(List<User> users) {
    final userIds = users
        .where(
          (user) =>
              user.role.toLowerCase() == 'user',
        )
        .map((user) => user.id)
        .toSet();

    return HiveDB.donations.values
        .where(
          (donation) =>
              userIds.contains(donation.donorId),
        )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
        backgroundColor: ThemeColors.background,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Manage Users',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream:
            firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: ThemeColors.primaryTeal,
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

          final allUsers = docs
              .map(
                (doc) => userFromFirestore(doc),
              )
              .toList();

          final users = getUsers(allUsers);

          final donorUsers = allUsers
              .where(
                (user) =>
                    user.role.toLowerCase() ==
                    'user',
              )
              .toList();

          final totalUsers = donorUsers.length;

          final totalDonations =
              getTotalDonations(donorUsers);

          return Column(
            children: [
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
                        title: 'Users',
                        value: totalUsers,
                        icon: Icons.people_outline,
                      ),
                    ),

                    SizedBox(width: 10),

                    Expanded(
                      child: AdminCountCard(
                        title: 'Donations',
                        value: totalDonations,
                        icon: Icons
                            .volunteer_activism_outlined,
                      ),
                    ),
                  ],
                ),
              ),

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
                    hintText: 'Search users...',
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
                                  searchController.clear();
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.white54,
                                ),
                              )
                            : null,
                    filled: true,
                    fillColor: ThemeColors.darkTeal,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 18),

              Expanded(
                child: users.isEmpty
                    ? Center(
                        child: Text(
                          'No users found',
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
                        itemCount: users.length,
                        itemBuilder:
                            (context, index) {
                          final user =
                              users[index];

                          final donationCount =
                              getDonationCount(
                            user.id,
                          );

                          return Container(
                            margin: EdgeInsets.only(
                              bottom: 12,
                            ),
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color:
                                  ThemeColors.darkTeal,
                              borderRadius:
                                  BorderRadius.circular(
                                16,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 27,
                                  backgroundColor:
                                      ThemeColors
                                          .primaryTeal,
                                  child: Text(
                                    user.name.isNotEmpty
                                        ? user.name[0]
                                            .toUpperCase()
                                        : 'U',
                                    style:
                                        GoogleFonts.poppins(
                                      color:
                                          Colors.white,
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),

                                SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        user.name,
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                        style: GoogleFonts
                                            .poppins(
                                          color:
                                              Colors.white,
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                          fontSize: 14,
                                        ),
                                      ),

                                      SizedBox(height: 3),

                                      Text(
                                        user.email,
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                        style: GoogleFonts
                                            .poppins(
                                          color: Colors
                                              .white60,
                                          fontSize: 11,
                                        ),
                                      ),

                                      SizedBox(height: 5),

                                      Text(
                                        '$donationCount donations',
                                        style: GoogleFonts
                                            .poppins(
                                          color: ThemeColors
                                              .accentCyan,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                PopupMenuButton<String>(
                                  color:
                                      ThemeColors.darkTeal,
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: Colors.white70,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'view') {
                                      showUserDetails(
                                        user,
                                      );
                                    }

                                    if (value ==
                                        'delete') {
                                      deleteUser(user);
                                    }
                                  },
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                        value: 'view',
                                        child:
                                            AdminPopupItem(
                                          icon: Icons
                                              .visibility_outlined,
                                          title:
                                              'View Details',
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child:
                                            AdminPopupItem(
                                          icon: Icons
                                              .delete_outline,
                                          title: 'Remove',
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
      ),
    );
  }
}