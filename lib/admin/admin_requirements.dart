import 'package:care_circle/database/hivedb.dart';
import 'package:care_circle/models/hivemodels.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:care_circle/widgets/admin_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class adminrequirements extends StatefulWidget {
  final VoidCallback onBack;

  const adminrequirements({
    super.key,
    required this.onBack,
  });

  @override
  State<adminrequirements> createState() =>
      _adminrequirementsState();
}

class _adminrequirementsState
    extends State<adminrequirements> {
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

  List<Requirement> getFilteredRequirements(
    List<Requirement> allRequirements,
    Map<String, String> orphanageNames,
  ) {
    final search =
        searchController.text.trim().toLowerCase();

    List<Requirement> requirements =
        List.from(allRequirements);

    if (selectedFilter == 'Active') {
      requirements = requirements
          .where(
            (requirement) =>
                requirement.status.toLowerCase() ==
                'active',
          )
          .toList();
    }

    if (selectedFilter == 'Completed') {
      requirements = requirements
          .where(
            (requirement) =>
                requirement.status.toLowerCase() ==
                'completed',
          )
          .toList();
    }

    if (selectedFilter == 'High Priority') {
      requirements = requirements
          .where(
            (requirement) =>
                requirement.priority.toLowerCase() ==
                'high',
          )
          .toList();
    }

    if (search.isNotEmpty) {
      requirements = requirements.where(
        (requirement) {
          final orphanageName =
              (orphanageNames[
                          requirement.orphanageId] ??
                      'Unknown Orphanage')
                  .toLowerCase();

          return requirement.item
                  .toLowerCase()
                  .contains(search) ||
              requirement.category
                  .toLowerCase()
                  .contains(search) ||
              orphanageName.contains(search);
        },
      ).toList();
    }

    return requirements;
  }

  Future<void> updateStatus(
    Requirement requirement,
    String status,
  ) async {
    try {
      await firestore
          .collection('requirements')
          .doc(requirement.id)
          .update({
        'status': status,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Requirement marked as $status',
          ),
          backgroundColor:
              ThemeColors.primaryTeal,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to update requirement',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteRequirement(
    Requirement requirement,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ThemeColors.darkTeal,
          title: Text(
            'Remove Requirement?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to remove ${requirement.item}?',
            style: GoogleFonts.poppins(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
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
                  context,
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

    try {
      await firestore
          .collection('requirements')
          .doc(requirement.id)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Requirement removed successfully!',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to remove requirement',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showRequirementDetails(
    Requirement requirement,
    String orphanageName,
  ) {
    final donations =
        HiveDB.donations.values
            .where(
              (donation) =>
                  donation.requirementId ==
                  requirement.id,
            )
            .toList();

    int receivedQuantity = 0;

    for (final donation in donations) {
      if (donation.status.toLowerCase() ==
              'confirmed' ||
          donation.status.toLowerCase() ==
              'completed') {
        receivedQuantity += donation.quantity;
      }
    }

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
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      height: 4,
                      width: 45,
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
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
                        Icons
                            .inventory_2_outlined,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  Center(
                    child: Text(
                      requirement.item,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 8),

                  Center(
                    child: AdminStatusBadge(
                      status:
                          requirement.status,
                    ),
                  ),

                  SizedBox(height: 25),

                  AdminDetailRow(
                    icon:
                        Icons.home_work_outlined,
                    title: 'Orphanage',
                    value: orphanageName,
                  ),

                  AdminDetailRow(
                    icon:
                        Icons.category_outlined,
                    title: 'Category',
                    value:
                        requirement.category,
                  ),

                  AdminDetailRow(
                    icon:
                        Icons.inventory_outlined,
                    title:
                        'Required Quantity',
                    value: requirement.quantity
                        .toString(),
                  ),

                  AdminDetailRow(
                    icon: Icons.priority_high,
                    title: 'Priority',
                    value:
                        requirement.priority,
                  ),

                  AdminDetailRow(
                    icon: Icons.info_outline,
                    title: 'Status',
                    value:
                        requirement.status,
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
                          title: 'Required',
                          value: requirement
                              .quantity
                              .toString(),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: AdminInfoBox(
                          title: 'Received',
                          value:
                              receivedQuantity
                                  .toString(),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: AdminInfoBox(
                          title: 'Donations',
                          value: donations.length
                              .toString(),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  if (requirement.status
                          .toLowerCase() ==
                      'active')
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child:
                          ElevatedButton.icon(
                        style: ElevatedButton
                            .styleFrom(
                          backgroundColor:
                              ThemeColors
                                  .primaryTeal,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(
                            context,
                          );

                          await updateStatus(
                            requirement,
                            'Completed',
                          );
                        },
                        icon: Icon(
                          Icons
                              .check_circle_outline,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Mark as Completed',
                          style:
                              GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  if (requirement.status
                          .toLowerCase() ==
                      'completed')
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child:
                          ElevatedButton.icon(
                        style: ElevatedButton
                            .styleFrom(
                          backgroundColor:
                              ThemeColors
                                  .primaryTeal,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(
                            context,
                          );

                          await updateStatus(
                            requirement,
                            'Active',
                          );
                        },
                        icon: Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Mark as Active',
                          style:
                              GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
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
        backgroundColor:
            ThemeColors.background,
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
          'Manage Requirements',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: firestore
            .collection('requirements')
            .snapshots(),
        builder: (
          context,
          requirementSnapshot,
        ) {
          if (requirementSnapshot.connectionState ==
              ConnectionState.waiting) {
            return Center(
              child:
                  CircularProgressIndicator(
                color:
                    ThemeColors.primaryTeal,
              ),
            );
          }

          if (requirementSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Unable to load requirements.\n${requirementSnapshot.error}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.redAccent,
                  ),
                ),
              ),
            );
          }

          return StreamBuilder<
              QuerySnapshot<
                  Map<String, dynamic>>>(
            stream: firestore
                .collection('orphanages')
                .snapshots(),
            builder: (
              context,
              orphanageSnapshot,
            ) {
              if (orphanageSnapshot
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

              if (orphanageSnapshot
                  .hasError) {
                return Center(
                  child: Padding(
                    padding:
                        EdgeInsets.all(20),
                    child: Text(
                      'Unable to load orphanages.\n${orphanageSnapshot.error}',
                      textAlign:
                          TextAlign.center,
                      style:
                          GoogleFonts.poppins(
                        color:
                            Colors.redAccent,
                      ),
                    ),
                  ),
                );
              }

              final allRequirements =
                  requirementSnapshot
                          .data?.docs
                          .map(
                            requirementFromFirestore,
                          )
                          .toList() ??
                      [];

              final orphanageNames =
                  <String, String>{};

              for (final document
                  in orphanageSnapshot
                          .data?.docs ??
                      []) {
                final data =
                    document.data();

                orphanageNames[
                        document.id] =
                    data['name']
                            ?.toString() ??
                        'Unknown Orphanage';
              }

              final requirements =
                  getFilteredRequirements(
                allRequirements,
                orphanageNames,
              );

              final total =
                  allRequirements.length;

              final active =
                  allRequirements
                      .where(
                        (requirement) =>
                            requirement.status
                                .toLowerCase() ==
                            'active',
                      )
                      .length;

              final highPriority =
                  allRequirements
                      .where(
                        (requirement) =>
                            requirement.priority
                                    .toLowerCase() ==
                                'high' &&
                            requirement.status
                                    .toLowerCase() ==
                                'active',
                      )
                      .length;

              return Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.fromLTRB(
                      18,
                      10,
                      18,
                      15,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child:
                              AdminCountCard(
                            title: 'Total',
                            value: total,
                            icon: Icons
                                .inventory_2_outlined,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child:
                              AdminCountCard(
                            title: 'Active',
                            value: active,
                            icon: Icons
                                .pending_actions_outlined,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child:
                              AdminCountCard(
                            title: 'Urgent',
                            value:
                                highPriority,
                            icon: Icons
                                .priority_high,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    child: TextField(
                      controller:
                          searchController,
                      style:
                          GoogleFonts.poppins(
                        color: Colors.white,
                      ),
                      decoration:
                          InputDecoration(
                        hintText:
                            'Search requirements...',
                        hintStyle:
                            GoogleFonts.poppins(
                          color:
                              Colors.white54,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color:
                              Colors.white54,
                        ),
                        filled: true,
                        fillColor:
                            ThemeColors
                                .darkTeal,
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection:
                          Axis.horizontal,
                      padding:
                          EdgeInsets.symmetric(
                        horizontal: 18,
                      ),
                      children: [
                        AdminFilterChip(
                          title: 'All',
                          selected:
                              selectedFilter ==
                                  'All',
                          onTap: () {
                            setState(() {
                              selectedFilter =
                                  'All';
                            });
                          },
                        ),
                        AdminFilterChip(
                          title: 'Active',
                          selected:
                              selectedFilter ==
                                  'Active',
                          onTap: () {
                            setState(() {
                              selectedFilter =
                                  'Active';
                            });
                          },
                        ),
                        AdminFilterChip(
                          title: 'Completed',
                          selected:
                              selectedFilter ==
                                  'Completed',
                          onTap: () {
                            setState(() {
                              selectedFilter =
                                  'Completed';
                            });
                          },
                        ),
                        AdminFilterChip(
                          title:
                              'High Priority',
                          selected:
                              selectedFilter ==
                                  'High Priority',
                          onTap: () {
                            setState(() {
                              selectedFilter =
                                  'High Priority';
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 15),

                  Expanded(
                    child:
                        requirements.isEmpty
                            ? Center(
                                child: Text(
                                  'No requirements found',
                                  style: GoogleFonts
                                      .poppins(
                                    color: Colors
                                        .white54,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    EdgeInsets
                                        .fromLTRB(
                                  18,
                                  0,
                                  18,
                                  20,
                                ),
                                itemCount:
                                    requirements
                                        .length,
                                itemBuilder:
                                    (
                                  context,
                                  index,
                                ) {
                                  final requirement =
                                      requirements[
                                          index];

                                  final orphanageName =
                                      orphanageNames[
                                              requirement
                                                  .orphanageId] ??
                                          'Unknown Orphanage';

                                  return Container(
                                    margin:
                                        EdgeInsets
                                            .only(
                                      bottom: 12,
                                    ),
                                    padding:
                                        EdgeInsets
                                            .all(
                                      15,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color:
                                          ThemeColors
                                              .darkTeal,
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        16,
                                      ),
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
                                          child: Icon(
                                            Icons
                                                .inventory_2_outlined,
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
                                                  fontWeight:
                                                      FontWeight
                                                          .w600,
                                                  fontSize:
                                                      14,
                                                ),
                                              ),

                                              SizedBox(
                                                height:
                                                    3,
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
                                                          .white60,
                                                  fontSize:
                                                      11,
                                                ),
                                              ),

                                              SizedBox(
                                                height:
                                                    5,
                                              ),

                                              Row(
                                                children: [
                                                  AdminStatusBadge(
                                                    status:
                                                        requirement
                                                            .status,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        7,
                                                  ),
                                                  if (requirement
                                                          .priority
                                                          .toLowerCase() ==
                                                      'high')
                                                    Text(
                                                      'HIGH PRIORITY',
                                                      style:
                                                          GoogleFonts
                                                              .poppins(
                                                        color:
                                                            Colors
                                                                .redAccent,
                                                        fontSize:
                                                            9,
                                                        fontWeight:
                                                            FontWeight
                                                                .w600,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        PopupMenuButton<
                                            String>(
                                          color:
                                              ThemeColors
                                                  .darkTeal,
                                          icon: Icon(
                                            Icons
                                                .more_vert,
                                            color:
                                                Colors
                                                    .white70,
                                          ),
                                          onSelected:
                                              (value) {
                                            if (value ==
                                                'view') {
                                              showRequirementDetails(
                                                requirement,
                                                orphanageName,
                                              );
                                            }

                                            if (value ==
                                                'complete') {
                                              updateStatus(
                                                requirement,
                                                'Completed',
                                              );
                                            }

                                            if (value ==
                                                'active') {
                                              updateStatus(
                                                requirement,
                                                'Active',
                                              );
                                            }

                                            if (value ==
                                                'delete') {
                                              deleteRequirement(
                                                requirement,
                                              );
                                            }
                                          },
                                          itemBuilder:
                                              (context) {
                                            return [
                                              PopupMenuItem(
                                                value:
                                                    'view',
                                                child:
                                                    AdminPopupItem(
                                                  icon:
                                                      Icons.visibility_outlined,
                                                  title:
                                                      'View Details',
                                                ),
                                              ),

                                              if (requirement
                                                      .status
                                                      .toLowerCase() ==
                                                  'active')
                                                PopupMenuItem(
                                                  value:
                                                      'complete',
                                                  child:
                                                      AdminPopupItem(
                                                    icon:
                                                        Icons.check_circle_outline,
                                                    title:
                                                        'Mark Completed',
                                                  ),
                                                ),

                                              if (requirement
                                                      .status
                                                      .toLowerCase() ==
                                                  'completed')
                                                PopupMenuItem(
                                                  value:
                                                      'active',
                                                  child:
                                                      AdminPopupItem(
                                                    icon:
                                                        Icons.refresh,
                                                    title:
                                                        'Mark Active',
                                                  ),
                                                ),

                                              PopupMenuItem(
                                                value:
                                                    'delete',
                                                child:
                                                    AdminPopupItem(
                                                  icon:
                                                      Icons.delete_outline,
                                                  title:
                                                      'Remove',
                                                  color:
                                                      Colors.redAccent,
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
      ),
    );
  }
}