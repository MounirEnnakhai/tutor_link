import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

// ─── Education data ───────────────────────────────────────────────────────────

const _levels = ['Primary', 'Middle School', 'High School', 'Academic'];

const _grades = {
  'Primary': ['1st Grade', '2nd Grade', '3rd Grade', '4th Grade', '5th Grade', '6th Grade'],
  'Middle School': ['1st Year', '2nd Year', '3rd Year'],
  'High School': ['TC', '1ère Bac', '2ème Bac'],
  'Academic': <String>[],
};

class StudentOnboardingScreen extends ConsumerStatefulWidget {
  const StudentOnboardingScreen({super.key});

  @override
  ConsumerState<StudentOnboardingScreen> createState() =>
      _StudentOnboardingScreenState();
}

class _StudentOnboardingScreenState
    extends ConsumerState<StudentOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  String _selectedLevel = _levels.first;
  String? _selectedGrade;
  bool _isSaving = false;
  int _step = 0; // 0 = personal info, 1 = education

  @override
  void initState() {
    super.initState();
    // Pre-fill name from auth
    final user = ref.read(currentUserProvider);
    if (user != null) _nameCtrl.text = user.fullName;
    _selectedGrade = _grades[_selectedLevel]?.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLevel != 'Academic' && _selectedGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your grade')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = ref.read(currentUserProvider)!;
      final firestore = ref.read(firestoreProvider);

      await firestore
          .collection('users')
          .doc(user.id)
          .update({
        'fullName': _nameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'educationLevel': _selectedLevel,
        'grade': _selectedLevel == 'Academic' ? null : _selectedGrade,
        'isProfileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ref.invalidate(authStateProvider);

      if (!mounted) return;
      context.go(AppRoutes.studentHome);
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
    final theme = Theme.of(context);

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
                        child: const Icon(Icons.school_rounded,
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
                    'Welcome! 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tell us a bit about yourself so we\ncan find the perfect tutors for you.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Progress indicator
                  Row(
                    children: List.generate(2, (i) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i == 0 ? 6 : 0),
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
                    'Step ${_step + 1} of 2',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _step == 0
                      ? _PersonalInfoStep(
                    nameCtrl: _nameCtrl,
                    phoneCtrl: _phoneCtrl,
                    cityCtrl: _cityCtrl,
                  )
                      : _EducationStep(
                    selectedLevel: _selectedLevel,
                    selectedGrade: _selectedGrade,
                    onLevelChanged: (level) {
                      setState(() {
                        _selectedLevel = level;
                        _selectedGrade =
                        _grades[level]?.isNotEmpty == true
                            ? _grades[level]!.first
                            : null;
                      });
                    },
                    onGradeChanged: (grade) =>
                        setState(() => _selectedGrade = grade),
                  ),
                ),
              ),
            ),

            // Buttons
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
                      label: _step == 0 ? 'Next' : 'Get Started',
                      isLoading: _isSaving,
                      icon: _step == 0
                          ? Icons.arrow_forward_rounded
                          : Icons.check_rounded,
                      onPressed: () {
                        if (_step == 0) {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _step = 1);
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

class _PersonalInfoStep extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController cityCtrl;

  const _PersonalInfoStep({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.cityCtrl,
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
          'This helps tutors know who they\'re teaching.',
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
      ],
    );
  }
}

class _EducationStep extends StatelessWidget {
  final String selectedLevel;
  final String? selectedGrade;
  final ValueChanged<String> onLevelChanged;
  final ValueChanged<String?> onGradeChanged;

  const _EducationStep({
    required this.selectedLevel,
    required this.selectedGrade,
    required this.onLevelChanged,
    required this.onGradeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grades = _grades[selectedLevel] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Education Level',
            style: theme.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          'We\'ll match you with tutors who teach your level.',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            fontFamily: 'Poppins',
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),

        // Level selector
        Text('School Level', style: theme.textTheme.titleSmall),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: _levels.map((level) {
            final isSelected = selectedLevel == level;
            return GestureDetector(
              onTap: () => onLevelChanged(level),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.12)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : theme.colorScheme.onSurface.withOpacity(0.15),
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
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Grade selector
        if (grades.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Your Grade', style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: grades.map((grade) {
              final isSelected = selectedGrade == grade;
              return GestureDetector(
                onTap: () => onGradeChanged(grade),
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
                    grade,
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

        if (selectedLevel == 'Academic') ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Academic level includes university and higher education students.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}