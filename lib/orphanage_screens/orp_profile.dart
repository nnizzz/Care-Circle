import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:care_circle/models/hivemodels.dart';
import 'package:care_circle/auth/login_page.dart';
import 'package:care_circle/orphanage_screens/orp_navigation.dart';
import 'package:care_circle/providers/auth_provider.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:care_circle/widgets/orphanagemodule_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
class orphanageprofile extends StatefulWidget {
  const orphanageprofile({super.key});
  @override
  State<orphanageprofile> createState() =>
      _orphanageprofileState();
}
class _orphanageprofileState extends State<orphanageprofile> {
  final List<String> districts = [
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
    "Children's Home",
    'Old Age Home',
    'Special Needs Home',
    "Women's Shelter",
    'Rehabilitation Center',
    'Other',
  ];
  final _db = FirebaseFirestore.instance;
  Orphanage? _orphanage;
  User? _account;
  int _active = 0, _urgent = 0, _confirmed = 0;
  StreamSubscription? _orphanageSub, _accountSub, _requirementsSub, _donationsSub;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfileData());
  }
  void _loadProfileData() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    _orphanageSub?.cancel();
    _accountSub?.cancel();
    _requirementsSub?.cancel();
    _donationsSub?.cancel();
    _orphanageSub = _db.collection('orphanages').doc(user.id).snapshots().listen((doc) {
      if (!mounted || !doc.exists) return;
      final d = doc.data()!;
      setState(() => _orphanage = Orphanage(
        id: doc.id, userId: d['userId']?.toString() ?? user.id,
        name: d['name']?.toString() ?? '', address: d['address']?.toString() ?? '',
        description: d['description']?.toString() ?? '', image: d['image']?.toString() ?? '',
        verified: d['verified'] == true, district: d['district']?.toString() ?? '',
        category: d['category']?.toString() ?? '',
      ));
    });
    _accountSub = _db.collection('users').doc(user.id).snapshots().listen((doc) {
      if (!mounted || !doc.exists) return;
      final d = doc.data()!;
      setState(() => _account = User(
        id: doc.id, name: d['name']?.toString() ?? '',
        email: d['email']?.toString() ?? user.email,
        password: '', phone: d['phone']?.toString() ?? '',
        role: d['role']?.toString() ?? 'orphanage',
      ));
    });
    _requirementsSub = _db.collection('requirements')
        .where('orphanageId', isEqualTo: user.id).snapshots().listen((snapshot) {
      if (!mounted) return;
      final active = snapshot.docs.where((d) => (d.data()['status']?.toString() ?? 'Active').toLowerCase() == 'active');
      setState(() {
        _active = active.length;
        _urgent = active.where((d) => (d.data()['priority']?.toString() ?? '').toLowerCase() == 'high').length;
      });
    });
    _donationsSub = _db.collection('donations')
        .where('orphanageId', isEqualTo: user.id).snapshots().listen((snapshot) {
      if (!mounted) return;
      setState(() => _confirmed = snapshot.docs.where((d) =>
        (d.data()['status']?.toString() ?? '').toLowerCase() == 'confirmed').length);
    });
  }
  @override
  void dispose() {
    _orphanageSub?.cancel();
    _accountSub?.cancel();
    _requirementsSub?.cancel();
    _donationsSub?.cancel();
    super.dispose();
  }
  Future<void> _showEditProfileDialog() async {
    final user = _account;
    final orphanage = _orphanage;
    if (user == null || orphanage == null) {
      return;
    }
    final nameController = TextEditingController(
      text: orphanage.name,
    );
    final addressController = TextEditingController(
      text: orphanage.address,
    );
    final descriptionController = TextEditingController(
      text: orphanage.description,
    );
    final phoneController = TextEditingController(
      text: user.phone,
    );
    String selectedDistrict =
        districts.contains(orphanage.district)
            ? orphanage.district
            : districts.first;
    String selectedCategory =
        categories.contains(orphanage.category)
            ? orphanage.category
            : categories.first;
    final bool? updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ThemeColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 15,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom +
                        20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 45,
                        height: 4,
                        decoration: BoxDecoration(
                          color: ThemeColors.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Edit Profile',
                      style: GoogleFonts.poppins(
                        color: ThemeColors.textLight,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Update your orphanage information.',
                      style: GoogleFonts.poppins(
                        color: ThemeColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 25),
                    _editLabel('Orphanage Name'),
                    SizedBox(height: 7),
                    _editTextField(
                      controller: nameController,
                      hint: 'Enter orphanage name',
                      icon: Icons.home_work_outlined,
                    ),
                    SizedBox(height: 18),
                    _editLabel('Orphanage Type'),
                    SizedBox(height: 7),
                    _editDropdown(
                      value: selectedCategory,
                      items: categories,
                      icon: Icons.category_outlined,
                      onChanged: (value) {
                        if (value == null) return;
                        setSheetState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    SizedBox(height: 18),
                    _editLabel('Address'),
                    SizedBox(height: 7),
                    _editTextField(
                      controller: addressController,
                      hint: 'Enter address',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    SizedBox(height: 18),
                    _editLabel('District'),
                    SizedBox(height: 7),
                    _editDropdown(
                      value: selectedDistrict,
                      items: districts,
                      icon: Icons.map_outlined,
                      onChanged: (value) {
                        if (value == null) return;
                        setSheetState(() {
                          selectedDistrict = value;
                        });
                      },
                    ),
                    SizedBox(height: 18),
                    _editLabel('Description'),
                    SizedBox(height: 7),
                    _editTextField(
                      controller: descriptionController,
                      hint:
                          'Tell donors about your orphanage',
                      icon: Icons.description_outlined,
                      maxLines: 4,
                    ),
                    SizedBox(height: 18),
                    _editLabel('Phone Number'),
                    SizedBox(height: 7),
                    _editTextField(
                      controller: phoneController,
                      hint: 'Enter phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final name =
                              nameController.text.trim();
                          final address =
                              addressController.text.trim();
                          final description =
                              descriptionController.text.trim();
                          final phone =
                              phoneController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(
                              sheetContext,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please enter orphanage name.',
                                ),
                              ),
                            );
                            return;
                          }
                          if (address.isEmpty) {
                            ScaffoldMessenger.of(
                              sheetContext,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please enter address.',
                                ),
                              ),
                            );
                            return;
                          }
                          if (phone.isEmpty) {
                            ScaffoldMessenger.of(
                              sheetContext,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please enter phone number.',
                                ),
                              ),
                            );
                            return;
                          }
                          try {
                            final batch = _db.batch();
                            batch.update(_db.collection('orphanages').doc(orphanage.id), {
                              'name': name, 'address': address,
                              'district': selectedDistrict, 'category': selectedCategory,
                              'description': description,
                            });
                            batch.update(_db.collection('users').doc(user.id), {
                              'name': name, 'phone': phone,
                            });
                            await batch.commit();
                          } catch (e) {
                            if (sheetContext.mounted) {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                SnackBar(content: Text('Could not save profile: $e')),
                              );
                            }
                            return;
                          }
                          if (!sheetContext.mounted) {
                            return;
                          }
                          Navigator.pop(
                            sheetContext,
                            true,
                          );
                        },
                        icon: Icon(
                          Icons.save_outlined,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Save Changes',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeColors.primaryTeal,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    nameController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    if (updated == true && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile updated successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  Widget _editLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: ThemeColors.textLight,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
  Widget _editTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        color: ThemeColors.textLight,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: ThemeColors.textMuted,
          fontSize: 12,
        ),
        prefixIcon: Icon(
          icon,
          color: ThemeColors.secondaryTeal,
          size: 20,
        ),
        filled: true,
        fillColor: ThemeColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ThemeColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ThemeColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ThemeColors.accentCyan,
          ),
        ),
      ),
    );
  }
  Widget _editDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: ThemeColors.darkTeal,
      iconEnabledColor: ThemeColors.secondaryTeal,
      style: GoogleFonts.poppins(
        color: ThemeColors.textLight,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: ThemeColors.secondaryTeal,
          size: 20,
        ),
        filled: true,
        fillColor: ThemeColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ThemeColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ThemeColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ThemeColors.accentCyan,
          ),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
  void _logout() {
    Provider.of<AuthProvider>(
      context,
      listen: false,
    ).logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => loginpage(),
      ),
      (route) => false,
    );
  }
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ThemeColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Logout',
            style: GoogleFonts.poppins(
              color: ThemeColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.poppins(
              color: ThemeColors.textSecondary,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: ThemeColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.error,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final user = _account ?? context.watch<AuthProvider>().currentUser;
    final orphanage = _orphanage;
    final activeRequirements = _active;
    final urgentRequirements = _urgent;
    final confirmedDonations = _confirmed;
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
        backgroundColor: ThemeColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: ThemeColors.textLight),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => navigation()),
              (route) => false,
            );
          },
        ),
        title: Text(
          'Orphanage Profile',
          style: GoogleFonts.poppins(
            color: ThemeColors.textLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadProfileData();
          },
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(20),
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: ThemeColors.primaryGradient,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white
                              .withOpacity(0.20),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.home_work_outlined,
                        color: ThemeColors.textLight,
                        size: 38,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      orphanage?.name ?? 'Orphanage',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: ThemeColors.textLight,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      user?.email ?? '',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: ThemeColors.lightCyan,
                        fontSize: 11,
                      ),
                    ),
                    if (orphanage?.category.isNotEmpty ==
                        true) ...[
                      SizedBox(height: 8),
                      Text(
                        orphanage!.category,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: ThemeColors.lightCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            orphanage?.verified == true
                                ? Icons.verified
                                : Icons.info_outline,
                            color: orphanage?.verified ==
                                        true
                                    ? ThemeColors.lightCyan
                                    : ThemeColors.warning,
                            size: 15,
                          ),
                          SizedBox(width: 5),
                          Text(
                            orphanage?.verified == true
                                ? 'Verified Orphanage'
                                : 'Verification Pending',
                            style: GoogleFonts.poppins(
                              color: ThemeColors.textLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              Text(
                'Overview',
                style: GoogleFonts.poppins(
                  color: ThemeColors.textLight,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OrphanageProfileStatCard(
                      value: '$activeRequirements',
                      title: 'Active Needs',
                      icon: Icons.assignment_outlined,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: OrphanageProfileStatCard(
                      value: '$confirmedDonations',
                      title: 'Donations',
                      icon: Icons.volunteer_activism,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: OrphanageProfileStatCard(
                      value: '$urgentRequirements',
                      title: 'Urgent',
                      icon: Icons.priority_high,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
              Text(
                'Orphanage Information',
                style: GoogleFonts.poppins(
                  color: ThemeColors.textLight,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: ThemeColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    OrphanageProfileInfoTile(
                      icon: Icons.home_work_outlined,
                      title: 'Orphanage Name',
                      value: orphanage?.name ??
                          'Not available',
                    ),
                    OrphanageProfileDivider(),
                    OrphanageProfileInfoTile(
                      icon: Icons.category_outlined,
                      title: 'Orphanage Type',
                      value: orphanage?.category.isNotEmpty ==
                                  true
                              ? orphanage!.category
                              : 'Not specified',
                    ),
                    OrphanageProfileDivider(),
                    OrphanageProfileInfoTile(
                      icon: Icons.location_on_outlined,
                      title: 'Address',
                      value: orphanage
                                  ?.address.isNotEmpty ==
                              true
                          ? orphanage!.address
                          : 'Not added',
                    ),
                    OrphanageProfileDivider(),
                    OrphanageProfileInfoTile(
                      icon: Icons.map_outlined,
                      title: 'District',
                      value: orphanage?.district.isNotEmpty ==
                                  true
                              ? orphanage!.district
                              : 'Not added',
                    ),
                    OrphanageProfileDivider(),
                    OrphanageProfileInfoTile(
                      icon: Icons.description_outlined,
                      title: 'Description',
                      value: orphanage?.description
                                  .isNotEmpty ==
                              true
                          ? orphanage!.description
                          : 'Not added',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              Text(
                'Account Information',
                style: GoogleFonts.poppins(
                  color: ThemeColors.textLight,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: ThemeColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    OrphanageProfileInfoTile(
                      icon: Icons.person_outline,
                      title: 'Account Name',
                      value: user?.name ??
                          'Not available',
                    ),
                    OrphanageProfileDivider(),
                    OrphanageProfileInfoTile(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: user?.email ??
                          'Not available',
                    ),
                    OrphanageProfileDivider(),
                    OrphanageProfileInfoTile(
                      icon: Icons.phone_outlined,
                      title: 'Phone',
                      value: user?.phone.isNotEmpty ==
                                  true
                              ? user!.phone
                              : 'Not added',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              Text(
                'Account',
                style: GoogleFonts.poppins(
                  color: ThemeColors.textLight,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: ThemeColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: ThemeColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    OrphanageProfileActionTile(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profile',
                      onTap: _showEditProfileDialog,
                    ),
                    OrphanageProfileDivider(),
                    OrphanageProfileActionTile(
                      icon: Icons.notifications_none,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    OrphanageProfileDivider(),
                    OrphanageProfileActionTile(
                      icon: Icons.logout,
                      title: 'Logout',
                      color: ThemeColors.error,
                      onTap: _showLogoutDialog,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
