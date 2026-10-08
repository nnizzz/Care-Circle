import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:care_circle/models/hivemodels.dart';
import 'package:care_circle/models/orphanage_models.dart';
import 'package:care_circle/providers/auth_provider.dart';
import 'package:care_circle/providers/donation_provider.dart';
import 'package:care_circle/providers/orphanage_provider.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:care_circle/user_screens/navigation.dart';
import 'package:care_circle/widgets/usermodule_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class userrequire extends StatefulWidget {
  const userrequire({super.key});

  @override
  State<userrequire> createState() =>
      _userrequireState();
}

class _userrequireState extends State<userrequire> {
  final TextEditingController searchController =
      TextEditingController();

  String selectedFilter = 'All';
  final Map<String, Orphanage> _orphanages = {};
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _orphanageSubscription;

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      setState(() {});
    });

    _orphanageSubscription = FirebaseFirestore.instance
        .collection('orphanages').snapshots().listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _orphanages.clear();
        for (final doc in snapshot.docs) {
          final data = doc.data();
          _orphanages[doc.id] = Orphanage(
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
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrphanageProvider>(
        context,
        listen: false,
      ).loadAllRequirements();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _orphanageSubscription?.cancel();
    super.dispose();
  }

  List<_RequirementItem> get allRequirements {
    final provider =
        Provider.of<OrphanageProvider>(
      context,
      listen: false,
    );

    final List<_RequirementItem> result = [];

    for (final requirement
        in provider.requirements) {
      if (requirement.status.toLowerCase() != 'active') continue;
      final orphanage = _orphanages[requirement.orphanageId];

      if (orphanage == null) {
        continue;
      }

      result.add(
        _RequirementItem(
          orphanage: orphanage,
          requirement: requirement,
        ),
      );
    }

    return result;
  }

  List<_RequirementItem> get filteredRequirements {
    final search =
        searchController.text
            .toLowerCase()
            .trim();

    return allRequirements.where((item) {
      final matchesSearch =
          item.requirement.item
                  .toLowerCase()
                  .contains(search) ||
              item.orphanage.name
                  .toLowerCase()
                  .contains(search) ||
              item.orphanage.address
                  .toLowerCase()
                  .contains(search);

      bool matchesFilter = true;

      if (selectedFilter == 'Urgent') {
        matchesFilter =
            item.requirement.priority
                    .toLowerCase() ==
                'high';
      }

      return matchesSearch &&
          matchesFilter;
    }).toList();
  }

  List<_RequirementItem> get urgentRequirements {
    return allRequirements.where((item) {
      return item.requirement.priority
              .toLowerCase() ==
          'high';
    }).toList();
  }

  OrphanageNeed convertToNeed(
    Requirement requirement,
    DonationProvider donationProvider,
  ) {
    final receivedQuantity =
        donationProvider
            .getConfirmedQuantity(
      requirement.id,
    );

    return OrphanageNeed(
      id: requirement.id,
      itemName: requirement.item,
      icon: _getIcon(
        requirement.category,
      ),
      requiredQuantity:
          requirement.quantity,
      receivedQuantity:
          receivedQuantity,
      unit: 'items',
      urgent: requirement.priority
              .toLowerCase() ==
          'high',
      description:
          '${requirement.priority} priority '
          '${requirement.category.toLowerCase()} requirement.',
    );
  }

  String _getIcon(String category) {
    switch (category) {
      case 'Education':
        return '📚';

      case 'Food':
        return '🍚';

      case 'Clothing':
        return '👕';

      case 'Medical':
        return '💊';

      default:
        return '📦';
    }
  }

  void showDonateDialog(
    Orphanage orphanage,
    Requirement requirement,
  ) {
    final donationProvider =
        Provider.of<DonationProvider>(
      context,
      listen: false,
    );

    final availableQuantity =
        donationProvider
            .getAvailableQuantity(
      requirement,
    );

    if (availableQuantity <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'This requirement is already fully covered',
          ),
        ),
      );

      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return UserDonationDialog(
          item: requirement.item,
          orphanageName: orphanage.name,
          availableQuantity:
              availableQuantity,
          unit: 'items',

          onDonate: (quantity) async {
            final authProvider =
                Provider.of<AuthProvider>(
              context,
              listen: false,
            );

            final currentUser =
                authProvider.currentUser;

            if (currentUser == null) {
              throw Exception(
                'Please login before donating',
              );
            }

            await donationProvider
                .addDonation(
              donorId: currentUser.id,
              orphanageId:
                  orphanage.id,
              requirementId:
                  requirement.id,
              item: requirement.item,
              quantity: quantity,
            );

            if (!mounted) return;

            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content: Text(
                  'Donation of $quantity items '
                  '${requirement.item} '
                  'added successfully!',
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<OrphanageProvider>();

    final donationProvider =
        context.watch<DonationProvider>();

    final requirements =
        filteredRequirements;

    final urgentNeeds =
        urgentRequirements;

    return Scaffold(
      backgroundColor:
          ThemeColors.background,

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        centerTitle: false,

        title: Text(
          'Requirements',
          style: GoogleFonts.poppins(
            color: ThemeColors.textLight,
            fontSize: 22,
            fontWeight:
                FontWeight.w600,
          ),
        ),

        leading: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context, MaterialPageRoute(builder: (_) => navixs()), (route) => false);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color:
                ThemeColors.textLight,
          ),
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
                'Help provide what children need',
                style: GoogleFonts.poppins(
                  color: ThemeColors
                      .textSecondary,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 18),

              Container(
                decoration: BoxDecoration(
                  color: ThemeColors.card,
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                  border: Border.all(
                    color:
                        ThemeColors.border,
                  ),
                ),
                child: TextField(
                  controller:
                      searchController,
                  style:
                      GoogleFonts.poppins(
                    color: ThemeColors
                        .textPrimary,
                  ),
                  decoration:
                      InputDecoration(
                    hintText:
                        'Search requirements...',
                    hintStyle:
                        GoogleFonts.poppins(
                      color: ThemeColors
                          .textSecondary,
                    ),
                    prefixIcon:
                        const Icon(
                      Icons.search,
                      color: ThemeColors
                          .primaryTeal,
                    ),
                    suffixIcon:
                        searchController
                                .text
                                .isNotEmpty
                            ? IconButton(
                                onPressed:
                                    () {
                                  searchController
                                      .clear();
                                },
                                icon:
                                    const Icon(
                                  Icons.clear,
                                  color: ThemeColors
                                      .textSecondary,
                                ),
                              )
                            : null,
                    border:
                        InputBorder.none,
                    contentPadding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
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
                child: Row(
                  children: [
                    Expanded(
                      child: ImpactItem(
                        value:
                            '${allRequirements.length}',
                        title:
                            'Requirements',
                        icon: Icons
                            .inventory_2_outlined,
                      ),
                    ),

                    Container(
                      height: 45,
                      width: 1,
                      color:
                          ThemeColors.border,
                    ),

                    Expanded(
                      child: ImpactItem(
                        value:
                            '${urgentNeeds.length}',
                        title:
                            'Urgent Needs',
                        icon:
                            Icons.priority_high,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              Text(
                'Filter',
                style: GoogleFonts.poppins(
                  color:
                      ThemeColors.textLight,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  UserRequirementFilterButton(
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

                  const SizedBox(
                    width: 10,
                  ),

                  UserRequirementFilterButton(
                    title: 'Urgent',
                    selected:
                        selectedFilter ==
                            'Urgent',
                    onTap: () {
                      setState(() {
                        selectedFilter =
                            'Urgent';
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 25),

              if (selectedFilter ==
                      'All' &&
                  searchController
                      .text.isEmpty &&
                  urgentNeeds
                      .isNotEmpty) ...[
                Text(
                  'Urgent Requirements',
                  style:
                      GoogleFonts.poppins(
                    color: ThemeColors
                        .textLight,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                SizedBox(
                  height: 105,
                  child:
                      ListView.builder(
                    scrollDirection:
                        Axis.horizontal,
                    itemCount:
                        urgentNeeds.length,
                    itemBuilder:
                        (context, index) {
                      final item =
                          urgentNeeds[
                              index];

                      final need =
                          convertToNeed(
                        item.requirement,
                        donationProvider,
                      );

                      return Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          right: 12,
                        ),
                        child: SizedBox(
                          width: 220,
                          child:
                              UserUrgentNeedCard(
                            need: need,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),
              ],

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  Text(
                    selectedFilter ==
                            'Urgent'
                        ? 'Urgent Needs'
                        : 'All Requirements',
                    style:
                        GoogleFonts.poppins(
                      color: ThemeColors
                          .textLight,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  Text(
                    '${requirements.length}',
                    style:
                        GoogleFonts.poppins(
                      color: ThemeColors
                          .accentCyan,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (requirements.isEmpty)
                const UserRequirementsEmptyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount:
                      requirements.length,
                  itemBuilder:
                      (context, index) {
                    final item =
                        requirements[index];

                    final need =
                        convertToNeed(
                      item.requirement,
                      donationProvider,
                    );

                    return UserRequirementItemCard(
                      orphanageName:
                          item.orphanage.name,
                      address:
                          item.orphanage.address,
                      need: need,
                      onDonate: () {
                        showDonateDialog(
                          item.orphanage,
                          item.requirement,
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequirementItem {
  final Orphanage orphanage;
  final Requirement requirement;

  _RequirementItem({
    required this.orphanage,
    required this.requirement,
  });
}
