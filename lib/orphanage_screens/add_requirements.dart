import 'package:care_circle/providers/orphanage_provider.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:care_circle/widgets/orphanagemodule_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class addrequirement extends StatefulWidget {
  const addrequirement({super.key});

  @override
  State<addrequirement> createState() => _addrequirementState();
}

class _addrequirementState extends State<addrequirement> {
  final itemController = TextEditingController();
  final quantityController = TextEditingController();
  final categories = ['Education', 'Food', 'Clothing', 'Medical', 'Other'];
  final priorities = ['Low', 'Medium', 'High'];
  String selectedCategory = 'Education';
  String selectedPriority = 'Medium';
  bool isLoading = false;

  @override
  void dispose() {
    itemController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> addRequirement() async {
    if (isLoading) return;
    if (itemController.text.trim().isEmpty || quantityController.text.trim().isEmpty) {
      _message('Please fill all fields');
      return;
    }
    final quantity = int.tryParse(quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      _message('Please enter a valid quantity');
      return;
    }
    setState(() => isLoading = true);
    try {
      await context.read<OrphanageProvider>().addRequirement(
        item: itemController.text.trim(),
        category: selectedCategory,
        quantity: quantity,
        priority: selectedPriority,
      );
      if (!mounted) return;
      _message('Requirement added successfully');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _message(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
        backgroundColor: ThemeColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeColors.textLight),
        title: Text('Add Requirement', style: GoogleFonts.poppins(
          color: ThemeColors.textLight, fontSize: 18, fontWeight: FontWeight.w600,
        )),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OrphanageHeaderCard(
                icon: Icons.add_task,
                title: 'Create Requirement',
                subtitle: 'Add an item your orphanage currently needs',
              ),
              const SizedBox(height: 25),
              const OrphanageFormLabel(text: 'Item Name'),
              const SizedBox(height: 8),
              TextField(
                controller: itemController,
                style: GoogleFonts.poppins(color: ThemeColors.textPrimary, fontSize: 13),
                decoration: orphanageInputDecoration(
                  hint: 'Example: School Bags', icon: Icons.inventory_2_outlined,
                ),
              ),
              const SizedBox(height: 20),
              const OrphanageFormLabel(text: 'Category'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: orphanageInputDecoration(
                  hint: 'Select category', icon: Icons.category_outlined,
                ),
                items: categories.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category, style: GoogleFonts.poppins(
                    color: ThemeColors.textPrimary, fontSize: 13,
                  )),
                )).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedCategory = value);
                },
              ),
              const SizedBox(height: 20),
              const OrphanageFormLabel(text: 'Quantity'),
              const SizedBox(height: 8),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(color: ThemeColors.textPrimary, fontSize: 13),
                decoration: orphanageInputDecoration(
                  hint: 'Example: 20', icon: Icons.numbers,
                ),
              ),
              const SizedBox(height: 20),
              const OrphanageFormLabel(text: 'Priority'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedPriority,
                decoration: orphanageInputDecoration(
                  hint: 'Select priority', icon: Icons.flag_outlined,
                ),
                items: priorities.map((priority) => DropdownMenuItem(
                  value: priority,
                  child: Text(priority, style: GoogleFonts.poppins(
                    color: ThemeColors.textPrimary, fontSize: 13,
                  )),
                )).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedPriority = value);
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : addRequirement,
                  icon: isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: ThemeColors.textLight,
                          ),
                        )
                      : const Icon(Icons.add, color: ThemeColors.textLight),
                  label: Text(isLoading ? 'Adding...' : 'Add Requirement',
                    style: GoogleFonts.poppins(
                      color: ThemeColors.textLight, fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.primaryTeal,
                    disabledBackgroundColor: ThemeColors.primaryTeal.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: Text(
                  'You can update or manage this requirement later.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: ThemeColors.textMuted, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
