import 'package:care_circle/models/hivemodels.dart';
import 'package:care_circle/orphanage_screens/add_requirements.dart';
import 'package:care_circle/providers/auth_provider.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:care_circle/widgets/orphanagemodule_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class managerequirements extends StatefulWidget {
  const managerequirements({super.key});

  @override
  State<managerequirements> createState() => _managerequirementsState();
}

class _managerequirementsState extends State<managerequirements> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
        backgroundColor: ThemeColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: ThemeColors.textLight),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeColors.textLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Manage Requirements', style: GoogleFonts.poppins(color: ThemeColors.textLight, fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: user == null
          ? Center(child: Text('Please log in to view requirements.', style: GoogleFonts.poppins(color: ThemeColors.textLight)))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('requirements').where('orphanageId', isEqualTo: user.id).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Unable to load requirements: ${snapshot.error}', style: GoogleFonts.poppins(color: ThemeColors.error))));
                }
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: ThemeColors.primaryTeal));
                final requirements = snapshot.data!.docs.map((doc) {
                  final data = doc.data();
                  return Requirement(
                    id: doc.id,
                    orphanageId: data['orphanageId']?.toString() ?? '',
                    item: data['item']?.toString() ?? '',
                    category: data['category']?.toString() ?? '',
                    quantity: (data['quantity'] as num?)?.toInt() ?? 0,
                    priority: data['priority']?.toString() ?? 'Medium',
                    status: data['status']?.toString() ?? 'Active',
                  );
                }).toList();
                return SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Requirements', style: GoogleFonts.poppins(color: ThemeColors.textLight, fontSize: 22, fontWeight: FontWeight.w700)),
                        SizedBox(height: 6),
                        Text('Manage the items your orphanage needs', style: GoogleFonts.poppins(color: ThemeColors.textMuted, fontSize: 13)),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => addrequirement()));
                            },
                            icon: Icon(Icons.add),
                            label: Text('Add Requirement', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeColors.primaryTeal,
                              foregroundColor: ThemeColors.textLight,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        if (requirements.isEmpty)
                          OrphanageEmptyRequirements()
                        else
                          ...requirements.map((requirement) => Padding(
                            padding: EdgeInsets.only(bottom: 15),
                            child: OrphanageRequirementCard(requirement: requirement),
                          )),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
