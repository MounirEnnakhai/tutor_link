import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

const _teachingLevels = [
  'Primary',
  'Middle School',
  'High School',
  'Academic',
];

class TutorOnboardingScreen extends ConsumerStatefulWidget {
  const TutorOnboardingScreen({super.key});

  @override
  ConsumerState<TutorOnboardingScreen> createState() =>
      _TutorOnboardingScreenState();
}

class _TutorOnboardingScreenState
    extends ConsumerState<TutorOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  List<String> _selectedSubjects = [];
  List<String> _selectedLevels = [];
  List<String> _selectedModes = [];
  int _step = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user != null) _nameCtrl.text = user.fullName;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _toggleLevel(String level) {
    setState(() {
      if (level == 'Academic') {
        // Academic is exclusive
        _selectedLevels = ['Academic'];
      } else {
        // Remove academic if selecting other levels
        _selectedLevels.remove('Academic');
        if (_selectedLevels.contains(level)) {
          _selectedLevels.remove(level);
        } else {
          _selectedLevels.add(level);
        }
      }
    });
  }

  Future<void> _save() async {
    if (_selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one subject')),
      );
      return;
    }
    if (_selectedLevels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one teaching level')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = ref.read(currentUserProvider)!;
      final firestore = ref.read(firestoreProvider);

      // Update user doc
      await firestore.collection('users').doc(user.id).update({
        'fullName': _nameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'isProfileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update tutor doc
      await firestore.collection('tutors').doc(user.id).set({
        'userId': user.id,
        'fullName': _nameCtrl.text.trim(),
        'email': user.email,
        'biography': _bioCtrl.text.trim(),
        'subjects': _selectedSubjects,
        'teachingLevels': _selectedLevels,
        'teachingModes': _selectedModes,
        'phoneNumber': _phoneCtrl.text.trim(),
        'location': {'city': _cityCtrl.text.trim(), 'latitude': 0.0, 'longitude': 0.0},
        'isActive': true,
        'rating': 0.0,
        'totalReviews': 0,
        'totalStudents': 0,
        'verificationStatus': 'notSubmitted',
        'educationLevel': '',
        'qualifications': [],
        'certifications': [],
        'teachingLanguages': [],
        'yearsOfExperience': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ref.invalidate(authStateProvider);

      if (!mounted) return;
      context.go(AppRoutes.tutorDashboard);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSteps = 3;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.cast_for_education_rounded,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'TutorLink',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Set up your tutor profile 🎓',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete your profile to start\nconnecting with students.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: List.generate(totalSteps, (i) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
                        height: 4,
                        decoration: BoxDecoration(
                          color: i <= _step
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Step ${_step + 1} of $totalSteps',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: [
                    _Step1Personal(
                      nameCtrl: _nameCtrl,
                      phoneCtrl: _phoneCtrl,
                      cityCtrl: _cityCtrl,
                      bioCtrl: _bioCtrl,
                    ),
                    _Step2Subjects(
                      selectedSubjects: _selectedSubjects,
                      onChanged: (s) => setState(() => _selectedSubjects = s),
                    ),
                    _Step3Levels(
                      selectedLevels: _selectedLevels,
                      selectedModes: _selectedModes,
                      onLevelToggle: _toggleLevel,
                      onModesChanged: (m) => setState(() => _selectedModes = m),
                    ),
                  ][_step],
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _step--),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: _step < 2 ? 'Next' : 'Start Teaching',
                      isLoading: _isSaving,
                      icon: _step < 2
                          ? Icons.arrow_forward_rounded
                          : Icons.check_rounded,
                      onPressed: () {
                        if (_step < 2) {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _step++);
                          }
                        } else {
                          _save();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 1: Personal Info ────────────────────────────────────────────────────

class _Step1Personal extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController bioCtrl;

  const _Step1Personal({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.cityCtrl,
    required this.bioCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Personal Information',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          'Tell students who you are.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontFamily: 'Poppins',
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),
        AppTextField(
          controller: nameCtrl,
          label: 'Full Name',
          prefixIcon: Icons.person_outline,
          validator: (v) => v?.isEmpty == true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: phoneCtrl,
          label: 'Phone Number',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (v) => v?.isEmpty == true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: cityCtrl,
          label: 'City',
          prefixIcon: Icons.location_city_outlined,
          validator: (v) => v?.isEmpty == true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: bioCtrl,
          label: 'Short Bio',
          hintText: 'Tell students about your teaching experience...',
          maxLines: 4,
          validator: (v) =>
          (v?.length ?? 0) < 20 ? 'Please write at least 20 characters' : null,
        ),
      ],
    );
  }
}

// ─── Step 2: Subjects ─────────────────────────────────────────────────────────

class _Step2Subjects extends StatelessWidget {
  final List<String> selectedSubjects;
  final ValueChanged<List<String>> onChanged;

  const _Step2Subjects({
    required this.selectedSubjects,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subjects You Teach', style: theme.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          'Select all subjects you can teach.',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            fontFamily: 'Poppins',
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppConstants.subjects.map((subject) {
            final isSelected = selectedSubjects.contains(subject);
            return GestureDetector(
              onTap: () {
                final updated = List<String>.from(selectedSubjects);
                if (isSelected) {
                  updated.remove(subject);
                } else {
                  updated.add(subject);
                }
                onChanged(updated);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : theme.colorScheme.onSurface.withOpacity(0.15),
                  ),
                ),
                child: Text(
                  subject,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Step 3: Teaching Levels + Modes ─────────────────────────────────────────

class _Step3Levels extends StatelessWidget {
  final List<String> selectedLevels;
  final List<String> selectedModes;
  final ValueChanged<String> onLevelToggle;
  final ValueChanged<List<String>> onModesChanged;

  const _Step3Levels({
    required this.selectedLevels,
    required this.selectedModes,
    required this.onLevelToggle,
    required this.onModesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAcademic = selectedLevels.contains('Academic');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Teaching Levels', style: theme.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          'Which school levels do you teach?',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            fontFamily: 'Poppins',
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),

        // Academic notice
        if (isAcademic)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppTheme.primaryColor, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Academic level cannot be combined with other levels.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: _teachingLevels.map((level) {
            final isSelected = selectedLevels.contains(level);
            final isDisabled = isAcademic && level != 'Academic';

            return GestureDetector(
              onTap: isDisabled ? null : () => onLevelToggle(level),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.12)
                      : isDisabled
                      ? theme.colorScheme.surface.withOpacity(0.4)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : theme.colorScheme.onSurface
                        .withOpacity(isDisabled ? 0.08 : 0.15),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    level,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : theme.colorScheme.onSurface
                          .withOpacity(isDisabled ? 0.3 : 0.7),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 28),
        Text('Teaching Mode', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppConstants.teachingModes.map((mode) {
            final isSelected = selectedModes.contains(mode);
            return GestureDetector(
              onTap: () {
                final updated = List<String>.from(selectedModes);
                if (isSelected) {
                  updated.remove(mode);
                } else {
                  updated.add(mode);
                }
                onModesChanged(updated);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.secondaryColor
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.secondaryColor
                        : theme.colorScheme.onSurface.withOpacity(0.15),
                  ),
                ),
                child: Text(
                  mode,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}