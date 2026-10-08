import 'package:care_circle/admin/admin_users.dart';
import 'package:care_circle/models/hivemodels.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:care_circle/widgets/admin_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class dashboards extends StatelessWidget {
  final Function(int) onTabChange;

  const dashboards({
    super.key,
    required this.onTabChange,
  });

  Requirement requirementFromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    return Requirement(
      id: document.id,
      orphanageId:
          data['orphanageId']?.toString() ?? '',
      item: data['item']?.toString() ?? '',
      category:
          data['category']?.toString() ?? '',
      quantity:
          (data['quantity'] as num?)?.toInt() ?? 0,
      priority:
          data['priority']?.toString() ?? 'Medium',
      status:
          data['status']?.toString() ?? 'Active',
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
        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Dashboard',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Care:Circle Management',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                SnackBar(
                  content: Text(
                    'Notifications will be added next.',
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.notifications_none_outlined,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 5),
        ],
      ),

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .snapshots(),
        builder: (context, usersSnapshot) {
          if (usersSnapshot.connectionState ==
              ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: ThemeColors.primaryTeal,
              ),
            );
          }

          if (usersSnapshot.hasError) {
            return _errorWidget(
              usersSnapshot.error.toString(),
            );
          }

          return StreamBuilder<
              QuerySnapshot<
                  Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('orphanages')
                .snapshots(),
            builder: (
              context,
              orphanagesSnapshot,
            ) {
              if (orphanagesSnapshot
                      .connectionState ==
                  ConnectionState.waiting) {
                return Center(
                  child:
                      CircularProgressIndicator(
                    color:
                        ThemeColors.primaryTeal,
                  ),
                );
              }

              if (orphanagesSnapshot.hasError) {
                return _errorWidget(
                  orphanagesSnapshot.error
                      .toString(),
                );
              }

              return StreamBuilder<
                  QuerySnapshot<
                      Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('requirements')
                    .snapshots(),
                builder: (
                  context,
                  requirementsSnapshot,
                ) {
                  if (requirementsSnapshot
                          .connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child:
                          CircularProgressIndicator(
                        color: ThemeColors
                            .primaryTeal,
                      ),
                    );
                  }

                  if (requirementsSnapshot
                      .hasError) {
                    return _errorWidget(
                      requirementsSnapshot.error
                          .toString(),
                    );
                  }

                  final userDocs =
                      usersSnapshot.data?.docs ??
                          [];

                  final orphanageDocs =
                      orphanagesSnapshot
                              .data?.docs ??
                          [];

                  final requirementDocs =
                      requirementsSnapshot
                              .data?.docs ??
                          [];

                  final totalUsers =
                      userDocs.where((doc) {
                    final data = doc.data();

                    return data['role']
                            ?.toString()
                            .toLowerCase() ==
                        'user';
                  }).length;

                  final totalOrphanages =
                      orphanageDocs.length;

                  final pendingOrphanages =
                      orphanageDocs.where((doc) {
                    final data = doc.data();

                    return data['verified'] !=
                        true;
                  }).length;

                  final orphanageNames =
                      <String, String>{};

                  for (final document
                      in orphanageDocs) {
                    final data =
                        document.data();

                    orphanageNames[
                            document.id] =
                        data['name']
                                ?.toString() ??
                            'Unknown Orphanage';
                  }

                  final requirements =
                      requirementDocs
                          .map(
                            requirementFromFirestore,
                          )
                          .toList();

                  final totalRequirements =
                      requirements.length;

                  final activeRequirements =
                      requirements
                          .where(
                            (requirement) =>
                                requirement.status
                                    .toLowerCase() ==
                                'active',
                          )
                          .length;

                  final urgentRequirements =
                      requirements
                          .where(
                            (requirement) =>
                                requirement.priority
                                            .toLowerCase() ==
                                        'high' &&
                                    requirement.status
                                            .toLowerCase() ==
                                        'active',
                          )
                          .toList();

                  final donorNames = <String, String>{};
                  for (final doc in userDocs) {
                    donorNames[doc.id] =
                        doc.data()['name']?.toString() ?? 'Unknown Donor';
                  }

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('donations')
                        .snapshots(),
                    builder: (context, donationsSnapshot) {
                      if (donationsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: ThemeColors.primaryTeal,
                          ),
                        );
                      }

                      if (donationsSnapshot.hasError) {
                        return _errorWidget(
                          donationsSnapshot.error.toString(),
                        );
                      }

                      final donationDocs = donationsSnapshot.data?.docs ?? [];
                      final totalDonations = donationDocs.length;
                      final pendingDonations = donationDocs.where((doc) {
                        return doc.data()['status']
                                ?.toString()
                                .toLowerCase() ==
                            'pending';
                      }).length;

                      final recentDonations = donationDocs.map((doc) {
                        final data = doc.data();
                        final rawDate = data['date'];
                        DateTime date = DateTime.fromMillisecondsSinceEpoch(0);
                        if (rawDate is Timestamp) {
                          date = rawDate.toDate();
                        }
                        return Donation(
                          id: doc.id,
                          donorId: data['donorId']?.toString() ?? '',
                          orphanageId: data['orphanageId']?.toString() ?? '',
                          requirementId: data['requirementId']?.toString() ?? '',
                          item: data['item']?.toString() ?? '',
                          quantity: (data['quantity'] as num?)?.toInt() ?? 0,
                          date: date,
                          status: data['status']?.toString() ?? 'Pending',
                        );
                      }).toList();

                      recentDonations.sort(
                        (a, b) => b.date.compareTo(a.date),
                      );
                      final displayedDonations =
                          recentDonations.take(4).toList();

                      return SingleChildScrollView(
                        padding:
                            EdgeInsets.fromLTRB(
                          18,
                          15,
                          18,
                          25,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Container(
                              width:
                                  double.infinity,
                              padding:
                                  EdgeInsets.all(
                                20,
                              ),
                              decoration:
                                  BoxDecoration(
                                gradient:
                                    ThemeColors
                                        .primaryGradient,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  18,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          'Welcome, Admin',
                                          style:
                                              GoogleFonts
                                                  .poppins(
                                            color:
                                                Colors
                                                    .white,
                                            fontSize:
                                                20,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Manage Care:Circle from one place',
                                          style:
                                              GoogleFonts
                                                  .poppins(
                                            color:
                                                Colors
                                                    .white70,
                                            fontSize:
                                                11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons
                                        .admin_panel_settings_outlined,
                                    color:
                                        Colors.white,
                                    size: 45,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 25),

                            Text(
                              'Overview',
                              style:
                                  GoogleFonts.poppins(
                                color:
                                    Colors.white,
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            SizedBox(height: 12),

                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics:
                                  NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio:
                                  1.45,
                              children: [
                                AdminStatCard(
                                  title:
                                      'Total Users',
                                  value: totalUsers
                                      .toString(),
                                  icon: Icons
                                      .people_outline,
                                ),
                                AdminStatCard(
                                  title:
                                      'Orphanages',
                                  value:
                                      totalOrphanages
                                          .toString(),
                                  icon: Icons
                                      .home_work_outlined,
                                ),
                                AdminStatCard(
                                  title:
                                      'Requirements',
                                  value:
                                      totalRequirements
                                          .toString(),
                                  icon: Icons
                                      .inventory_2_outlined,
                                ),
                                AdminStatCard(
                                  title:
                                      'Donations',
                                  value:
                                      totalDonations
                                          .toString(),
                                  icon: Icons
                                      .volunteer_activism_outlined,
                                ),
                              ],
                            ),

                            SizedBox(height: 28),

                            Text(
                              'Quick Actions',
                              style:
                                  GoogleFonts.poppins(
                                color:
                                    Colors.white,
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            SizedBox(height: 12),

                            GridView.count(
                              crossAxisCount: 4,
                              shrinkWrap: true,
                              physics:
                                  NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio:
                                  0.85,
                              children: [
                                AdminActionCard(
                                  title: 'Users',
                                  icon: Icons
                                      .people_outline,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                adminusers(),
                                      ),
                                    );
                                  },
                                ),
                                AdminActionCard(
                                  title:
                                      'Orphanages',
                                  icon: Icons
                                      .home_work_outlined,
                                  onTap: () {
                                    onTabChange(
                                      1,
                                    );
                                  },
                                ),
                                AdminActionCard(
                                  title: 'Needs',
                                  icon: Icons
                                      .inventory_2_outlined,
                                  onTap: () {
                                    onTabChange(
                                      2,
                                    );
                                  },
                                ),
                                AdminActionCard(
                                  title:
                                      'Donations',
                                  icon: Icons
                                      .volunteer_activism_outlined,
                                  onTap: () {
                                    onTabChange(
                                      3,
                                    );
                                  },
                                ),
                              ],
                            ),

                            SizedBox(height: 28),

                            Text(
                              'Attention Needed',
                              style:
                                  GoogleFonts.poppins(
                                color:
                                    Colors.white,
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child:
                                      AdminCountCard(
                                    title:
                                        'Pending Orphanages',
                                    value:
                                        pendingOrphanages,
                                    icon: Icons
                                        .home_work_outlined,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child:
                                      AdminCountCard(
                                    title:
                                        'Active Needs',
                                    value:
                                        activeRequirements,
                                    icon: Icons
                                        .inventory_2_outlined,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child:
                                      AdminCountCard(
                                    title:
                                        'Pending Donations',
                                    value:
                                        pendingDonations,
                                    icon: Icons
                                        .schedule_outlined,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 28),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Text(
                                  'Urgent Requirements',
                                  style:
                                      GoogleFonts
                                          .poppins(
                                    color: Colors
                                        .white,
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    onTabChange(
                                      2,
                                    );
                                  },
                                  child: Text(
                                    'View All',
                                    style:
                                        GoogleFonts
                                            .poppins(
                                      color: ThemeColors
                                          .accentCyan,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 5),

                            if (urgentRequirements
                                .isEmpty)
                              Container(
                                width:
                                    double.infinity,
                                padding:
                                    EdgeInsets.all(
                                  20,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      ThemeColors
                                          .darkTeal,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    15,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons
                                          .check_circle_outline,
                                      color:
                                          ThemeColors
                                              .accentCyan,
                                      size: 32,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'No urgent requirements',
                                      style:
                                          GoogleFonts
                                              .poppins(
                                        color: Colors
                                            .white60,
                                        fontSize:
                                            12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ...urgentRequirements
                                  .take(3)
                                  .map(
                                (requirement) {
                                  final orphanageName =
                                      orphanageNames[
                                              requirement
                                                  .orphanageId] ??
                                          'Unknown Orphanage';

                                  return Container(
                                    width: double
                                        .infinity,
                                    margin:
                                        EdgeInsets
                                            .only(
                                      bottom: 10,
                                    ),
                                    padding:
                                        EdgeInsets
                                            .all(
                                      14,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color:
                                          ThemeColors
                                              .darkTeal,
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        15,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 45,
                                          width: 45,
                                          decoration:
                                              BoxDecoration(
                                            color: Colors
                                                .redAccent
                                                .withOpacity(
                                              0.15,
                                            ),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons
                                                .priority_high,
                                            color: Colors
                                                .redAccent,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 12,
                                        ),
                                        Expanded(
                                          child:
                                              Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                requirement
                                                    .item,
                                                maxLines:
                                                    1,
                                                overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                style:
                                                    GoogleFonts
                                                        .poppins(
                                                  color:
                                                      Colors
                                                          .white,
                                                  fontSize:
                                                      13,
                                                  fontWeight:
                                                      FontWeight
                                                          .w600,
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    2,
                                              ),
                                              Text(
                                                orphanageName,
                                                maxLines:
                                                    1,
                                                overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                style:
                                                    GoogleFonts
                                                        .poppins(
                                                  color:
                                                      Colors
                                                          .white54,
                                                  fontSize:
                                                      10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${requirement.quantity}',
                                          style:
                                              GoogleFonts
                                                  .poppins(
                                            color:
                                                ThemeColors
                                                    .accentCyan,
                                            fontSize:
                                                16,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                            SizedBox(height: 25),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Text(
                                  'Recent Donations',
                                  style:
                                      GoogleFonts
                                          .poppins(
                                    color: Colors
                                        .white,
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    onTabChange(
                                      3,
                                    );
                                  },
                                  child: Text(
                                    'View All',
                                    style:
                                        GoogleFonts
                                            .poppins(
                                      color: ThemeColors
                                          .accentCyan,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 5),

                            if (displayedDonations
                                .isEmpty)
                              Container(
                                width:
                                    double.infinity,
                                padding:
                                    EdgeInsets.all(
                                  20,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      ThemeColors
                                          .darkTeal,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    15,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons
                                          .volunteer_activism_outlined,
                                      color:
                                          ThemeColors
                                              .accentCyan,
                                      size: 32,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'No donations yet',
                                      style:
                                          GoogleFonts
                                              .poppins(
                                        color: Colors
                                            .white60,
                                        fontSize:
                                            12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ...displayedDonations
                                  .map(
                                (donation) {
                                  final donorName =
                                      donorNames[donation.donorId] ??
                                          'Unknown Donor';
                                  final orphanageName =
                                      orphanageNames[donation.orphanageId] ??
                                          'Unknown Orphanage';

                                  return Container(
                                    width: double
                                        .infinity,
                                    margin:
                                        EdgeInsets
                                            .only(
                                      bottom: 10,
                                    ),
                                    padding:
                                        EdgeInsets
                                            .all(
                                      14,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color:
                                          ThemeColors
                                              .darkTeal,
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        15,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 45,
                                          width: 45,
                                          decoration:
                                              BoxDecoration(
                                            color:
                                                ThemeColors
                                                    .primaryTeal,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons
                                                .volunteer_activism_outlined,
                                            color:
                                                Colors
                                                    .white,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 12,
                                        ),
                                        Expanded(
                                          child:
                                              Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                '${donation.item} × ${donation.quantity}',
                                                maxLines:
                                                    1,
                                                overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                style:
                                                    GoogleFonts
                                                        .poppins(
                                                  color:
                                                      Colors
                                                          .white,
                                                  fontSize:
                                                      13,
                                                  fontWeight:
                                                      FontWeight
                                                          .w600,
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    2,
                                              ),
                                              Text(
                                                '$donorName → $orphanageName',
                                                maxLines:
                                                    1,
                                                overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                style:
                                                    GoogleFonts
                                                        .poppins(
                                                  color:
                                                      Colors
                                                          .white54,
                                                  fontSize:
                                                      10,
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    5,
                                              ),
                                              AdminStatusBadge(
                                                status:
                                                    donation
                                                        .status,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
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

  Widget _errorWidget(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Error: $error',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}