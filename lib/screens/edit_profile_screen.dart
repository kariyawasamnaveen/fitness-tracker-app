import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _targetWeightController;
  late TextEditingController _medicalConditionsController;

  String? _selectedGender;
  DateTime? _selectedDob;
  String? _selectedGoal;
  String? _selectedActivity;
  DateTime? _selectedTargetDate;
  String? _selectedEnvironment;
  String? _selectedDiet;

  final List<String> _genders = ['Male', 'Female', 'Other', 'Not Specified'];
  final List<String> _goals = ['Weight Loss', 'Muscle Gain', 'Endurance', 'Stay Healthy'];
  final List<String> _activityLevels = ['Sedentary', 'Lightly Active', 'Active', 'Very Active'];
  final List<String> _environments = ['Home', 'Gym', 'Outdoors'];
  final List<String> _diets = ['Normal', 'Vegetarian', 'Vegan', 'Keto'];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<FitnessProvider>(context, listen: false);
    _nameController = TextEditingController(text: provider.userName);
    _targetWeightController = TextEditingController(text: provider.targetWeight > 0 ? provider.targetWeight.toString() : '');
    _medicalConditionsController = TextEditingController(text: provider.medicalConditions == 'None' ? '' : provider.medicalConditions);

    _selectedGender = provider.gender;
    _selectedDob = provider.dateOfBirth;
    _selectedGoal = provider.mainGoal;
    _selectedActivity = provider.activityLevel;
    _selectedTargetDate = provider.targetDate;
    _selectedEnvironment = provider.workoutEnvironment;
    _selectedDiet = provider.dietaryPreference;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetWeightController.dispose();
    _medicalConditionsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isDob) async {
    final initialDate = isDob ? (_selectedDob ?? DateTime.now().subtract(const Duration(days: 365 * 20))) : (_selectedTargetDate ?? DateTime.now().add(const Duration(days: 90)));
    final firstDate = isDob ? DateTime(1900) : DateTime.now();
    final lastDate = isDob ? DateTime.now() : DateTime.now().add(const Duration(days: 365 * 5));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.cyanAccent,
              onPrimary: Colors.black,
              surface: Color(0xFF1E2746),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDob) {
          _selectedDob = picked;
        } else {
          _selectedTargetDate = picked;
        }
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<FitnessProvider>(context, listen: false);
      provider.updateAdvancedProfile(
        name: _nameController.text.trim(),
        gender: _selectedGender ?? 'Not Specified',
        dateOfBirth: _selectedDob,
        mainGoal: _selectedGoal ?? 'Stay Healthy',
        activityLevel: _selectedActivity ?? 'Lightly Active',
        targetWeight: double.tryParse(_targetWeightController.text) ?? 0.0,
        targetDate: _selectedTargetDate,
        workoutEnvironment: _selectedEnvironment ?? 'Home',
        dietaryPreference: _selectedDiet ?? 'Normal',
        medicalConditions: _medicalConditionsController.text.trim().isEmpty ? 'None' : _medicalConditionsController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.cyanAccent,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1321),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('EDIT PROFILE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('SAVE', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: Consumer<FitnessProvider>(
        builder: (context, provider, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildHeader(provider),
                const SizedBox(height: 30),
                
                _buildSectionTitle('BASIC INFO'),
                _buildTextField('Display Name', _nameController, Icons.person_outline),
                _buildDropdown('Gender', _selectedGender, _genders, (val) => setState(() => _selectedGender = val), Icons.transgender),
                _buildDatePicker('Date of Birth', _selectedDob, () => _pickDate(context, true), Icons.cake_outlined),
                
                const SizedBox(height: 30),
                _buildSectionTitle('FITNESS GOALS'),
                _buildDropdown('Main Goal', _selectedGoal, _goals, (val) => setState(() => _selectedGoal = val), Icons.flag_outlined),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Target Weight', _targetWeightController, Icons.monitor_weight_outlined, isNumber: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildDatePicker('Deadline', _selectedTargetDate, () => _pickDate(context, false), Icons.event)),
                  ],
                ),
                
                const SizedBox(height: 30),
                _buildSectionTitle('LIFESTYLE & DIET'),
                _buildDropdown('Activity Level', _selectedActivity, _activityLevels, (val) => setState(() => _selectedActivity = val), Icons.directions_run),
                _buildDropdown('Dietary Preference', _selectedDiet, _diets, (val) => setState(() => _selectedDiet = val), Icons.restaurant),
                
                const SizedBox(height: 30),
                _buildSectionTitle('ENVIRONMENT & SAFETY'),
                _buildDropdown('Workout Environment', _selectedEnvironment, _environments, (val) => setState(() => _selectedEnvironment = val), Icons.landscape),
                _buildTextField('Injuries / Medical Conditions', _medicalConditionsController, Icons.medical_services_outlined, maxLines: 3, hint: 'E.g., Knee pain, Asthma, or leave blank'),
                
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('SAVE PROFILE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildHeader(FitnessProvider provider) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Colors.cyanAccent, Colors.blue]),
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF1E2746),
              child: Icon(Icons.person, size: 50, color: Colors.white54),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2746),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.cyanAccent, width: 1),
            ),
            child: Text(
              provider.fitnessLevelBadge,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(color: Colors.cyanAccent, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false, int maxLines = 1, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.cyanAccent.withOpacity(0.5)) : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white10)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.cyanAccent)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        initialValue: items.contains(value) ? value : null,
        onChanged: onChanged,
        dropdownColor: const Color(0xFF1E2746),
        style: const TextStyle(color: Colors.white),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.cyanAccent.withOpacity(0.5)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white10)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.cyanAccent)),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onTap, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.cyanAccent.withOpacity(0.5)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    date != null ? DateFormat('MMM dd, yyyy').format(date) : 'Select Date',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
