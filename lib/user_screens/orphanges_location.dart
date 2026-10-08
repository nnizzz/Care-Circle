import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:care_circle/models/hivemodels.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:care_circle/user_screens/orp_details.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class nearby extends StatefulWidget {
  const nearby({super.key});

  @override
  State<nearby> createState() => _nearbyState();
}

class _nearbyState extends State<nearby> {
  final TextEditingController searchController = TextEditingController();

  String selectedDistrict = 'All Districts';
  String selectedCategory = 'All Types';

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

  final List<String> categories = [
    'All Types',
    "Children's Home",
    'Old Age Home',
    'Special Needs Home',
    "Women's Shelter",
    'Rehabilitation Center',
    'Other',
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
  List<Orphanage> getFilteredOrphanages(List<Orphanage> allOrphanages) {
    final search = searchController.text.trim().toLowerCase();

    List<Orphanage> orphanages = List.of(allOrphanages);
    if (selectedDistrict != 'All Districts') {
      orphanages = orphanages
          .where(
            (orphanage) =>
                orphanage.district.toLowerCase() ==
                selectedDistrict.toLowerCase(),
          )
          .toList();
    }
    if (selectedCategory != 'All Types') {
      orphanages = orphanages
          .where(
            (orphanage) =>
                orphanage.category.toLowerCase() ==
                selectedCategory.toLowerCase(),
          )
          .toList();
    }
    if (search.isNotEmpty) {
      orphanages = orphanages.where((orphanage) {
        return orphanage.name.toLowerCase().contains(search) ||
            orphanage.address.toLowerCase().contains(search) ||
            orphanage.district.toLowerCase().contains(search) ||
            orphanage.category.toLowerCase().contains(search);
      }).toList();
    }

    return orphanages;
  }
  InputDecoration filterDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: Colors.white60,
        fontSize: 12,
      ),
      prefixIcon: Icon(
        icon,
        color: Colors.white70,
        size: 19,
      ),
      filled: true,
      fillColor: ThemeColors.darkTeal,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: ThemeColors.primaryTeal,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,

      appBar: AppBar(
        backgroundColor: ThemeColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Orphanages',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('orphanages').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Unable to load orphanages: ${snapshot.error}',
              style: const TextStyle(color: Colors.white70)));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final allOrphanages = snapshot.data!.docs.map((doc) {
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
          }).toList();
          final orphanages = getFilteredOrphanages(allOrphanages);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  10,
                  18,
                  0,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: ThemeColors.darkTeal,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: ThemeColors.primaryTeal,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.home_work_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Registered Orphanages',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Find registered orphanages and support their needs',
                              style: GoogleFonts.poppins(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(
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
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.white54,
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white54,
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: ThemeColors.darkTeal,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: ThemeColors.primaryTeal,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedDistrict,
                        dropdownColor: ThemeColors.darkTeal,
                        isExpanded: true,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white70,
                        ),
                        decoration: filterDecoration(
                          label: 'District',
                          icon: Icons.location_on_outlined,
                        ),
                        items: districts.map((district) {
                          return DropdownMenuItem<String>(
                            value: district,
                            child: Text(
                              district,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedDistrict = value;
                            });
                          }
                        },
                      ),
                    ),

                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        dropdownColor: ThemeColors.darkTeal,
                        isExpanded: true,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white70,
                        ),
                        decoration: filterDecoration(
                          label: 'Type',
                          icon: Icons.category_outlined,
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              category,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _resultTitle(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeColors.primaryTeal,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        orphanages.length.toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Expanded(
                child: orphanages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          0,
                          18,
                          25,
                        ),
                        itemCount: orphanages.length,
                        itemBuilder: (context, index) {
                          final orphanage = orphanages[index];

                          return _buildOrphanageCard(
                            orphanage,
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
  String _resultTitle() {
    if (selectedDistrict == 'All Districts' &&
        selectedCategory == 'All Types') {
      return 'Registered Orphanages';
    }

    if (selectedDistrict != 'All Districts' &&
        selectedCategory == 'All Types') {
      return '$selectedDistrict Orphanages';
    }

    if (selectedDistrict == 'All Districts' &&
        selectedCategory != 'All Types') {
      return selectedCategory;
    }

    return '$selectedCategory in $selectedDistrict';
  }
  Widget _buildOrphanageCard(
    Orphanage orphanage,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => detailpage(
              orphanage: orphanage,
            ),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: ThemeColors.darkTeal,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 68,
              width: 68,
              decoration: BoxDecoration(
                color: ThemeColors.primaryTeal,
                borderRadius: BorderRadius.circular(14),
              ),
              child: orphanage.image.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        orphanage.image,
                        fit: BoxFit.cover,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Icon(
                            Icons.home_work_outlined,
                            color: Colors.white,
                            size: 32,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.home_work_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
            ),

            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          orphanage.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(width: 5),

                      if (orphanage.verified)
                        const Icon(Icons.verified, color: Colors.greenAccent, size: 17),
                    ],
                  ),
                  if (orphanage.category.isNotEmpty) ...[
                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeColors.primaryTeal.withOpacity(
                          0.22,
                        ),
                        borderRadius: BorderRadius.circular(8),
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

                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: ThemeColors.accentCyan,
                        size: 15,
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          orphanage.district.isEmpty
                              ? 'District not added'
                              : orphanage.district,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (orphanage.address.isNotEmpty) ...[
                    const SizedBox(height: 4),

                    Text(
                      orphanage.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],

                  const SizedBox(height: 7),

                  Text(
                    orphanage.verified ? 'Verified Orphanage' : 'Verification Pending',
                    style: GoogleFonts.poppins(
                      color: orphanage.verified ? Colors.greenAccent : Colors.orangeAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white38,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildEmptyState() {
    String message;

    if (selectedDistrict == 'All Districts' &&
        selectedCategory == 'All Types') {
      message = 'No registered orphanages are available yet.';
    } else if (selectedDistrict != 'All Districts' &&
        selectedCategory == 'All Types') {
      message =
          'No registered orphanages found in $selectedDistrict.';
    } else if (selectedDistrict == 'All Districts' &&
        selectedCategory != 'All Types') {
      message =
          'No $selectedCategory orphanages are available.';
    } else {
      message =
          'No $selectedCategory found in $selectedDistrict.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.home_work_outlined,
              size: 65,
              color: Colors.white24,
            ),

            const SizedBox(height: 15),

            Text(
              'No orphanages found',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
            if (selectedDistrict != 'All Districts' ||
                selectedCategory != 'All Types' ||
                searchController.text.isNotEmpty) ...[
              const SizedBox(height: 16),

              TextButton.icon(
                onPressed: () {
                  setState(() {
                    selectedDistrict = 'All Districts';
                    selectedCategory = 'All Types';
                    searchController.clear();
                  });
                },
                icon: Icon(
                  Icons.refresh_rounded,
                  color: ThemeColors.accentCyan,
                  size: 18,
                ),
                label: Text(
                  'Clear Filters',
                  style: GoogleFonts.poppins(
                    color: ThemeColors.accentCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}