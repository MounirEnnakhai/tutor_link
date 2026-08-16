import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tutor_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

const _gradeMap = {
  'Primary': ['1st Grade', '2nd Grade', '3rd Grade', '4th Grade', '5th Grade', '6th Grade'],
  'Middle School': ['1st Year', '2nd Year', '3rd Year'],
  'High School': ['TC', '1ère Bac', '2ème Bac'],
  'Academic': <String>[],
};

class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  ConsumerState<CreateRequestScreen> createState() =>
      _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  String _selectedSubject = AppConstants.subjects.first;
  String _type = 'private';
  String _mode = 'both';
  String _educationLevel = AppConstants.educationLevels.first;
  String? _selectedGrade;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _budgetCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(currentUserProvider)!;
      final firestore = ref.read(firestoreProvider);

      await firestore.collection('student_requests').add({
        'studentId': user.id,
        'studentName': user.fullName,
        'studentPhotoUrl': user.photoUrl,
        'subject': _selectedSubject,
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'maxBudget': _budgetCtrl.text.isNotEmpty
            ? double.tryParse(_budgetCtrl.text)
            : null,
        'type': _type,
        'preferredMode': _mode,
        'location': _locationCtrl.text.trim(),
        'educationLevel': _educationLevel,
        'grade': _educationLevel == 'Academic' ? null : _selectedGrade,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ref.invalidate(myRequestsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request posted! Tutors will contact you soon.'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grades = _gradeMap[_educationLevel] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Post a Learning Request')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded,
                      color: AppTheme.primaryColor, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Describe what you need — tutors who match will respond to you!',
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
            const SizedBox(height: 20),

            // Subject
            AppDropdownField<String>(
              label: 'Subject',
              value: _selectedSubject,
              prefixIcon: Icons.book_outlined,
              items: AppConstants.subjects
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedSubject = v!),
            ),
            const SizedBox(height: 16),

            // Title
            AppTextField(
              controller: _titleCtrl,
              label: 'Request Title',
              hintText: 'e.g., Need help with Calculus for BAC exam',
              prefixIcon: Icons.title,
              validator: (v) =>
              v?.isEmpty == true ? 'Please add a title' : null,
            ),
            const SizedBox(height: 16),

            // Description
            AppTextField(
              controller: _descCtrl,
              label: 'Description',
              hintText:
              'Describe your level, goals, what topics you need help with...',
              maxLines: 4,
              validator: (v) => v != null && v.length < 20
                  ? 'Please write at least 20 characters'
                  : null,
            ),
            const SizedBox(height: 16),

            // Education Level
            AppDropdownField<String>(
              label: 'Your Education Level',
              value: _educationLevel,
              prefixIcon: Icons.school_outlined,
              items: AppConstants.educationLevels
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) => setState(() {
                _educationLevel = v!;
                _selectedGrade = null; // reset grade when level changes
              }),
            ),
            const SizedBox(height: 16),

            // Grade — only show if level has grades
            if (grades.isNotEmpty) ...[
              AppDropdownField<String>(
                label: 'Grade',
                value: _selectedGrade ?? grades.first,
                prefixIcon: Icons.grade_outlined,
                items: grades
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedGrade = v),
              ),
              const SizedBox(height: 16),
            ],

            // Academic notice
            if (_educationLevel == 'Academic') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppTheme.primaryColor, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Academic level — university and higher education.',
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
              const SizedBox(height: 16),
            ],

            // Max Budget
            AppTextField(
              controller: _budgetCtrl,
              label: 'Max Budget (MAD) — optional',
              hintText: 'e.g., 150',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.attach_money_rounded,
            ),
            const SizedBox(height: 20),

            // Type selector
            Text('Lesson Type', style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            Row(
              children: [
                _SelectChip(
                  label: 'Private',
                  icon: Icons.person_outline,
                  isSelected: _type == 'private',
                  onTap: () => setState(() => _type = 'private'),
                ),
                const SizedBox(width: 10),
                _SelectChip(
                  label: 'Group',
                  icon: Icons.group_outlined,
                  isSelected: _type == 'group',
                  onTap: () => setState(() => _type = 'group'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Preferred mode
            Text('Preferred Mode', style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            Row(
              children: [
                _SelectChip(
                  label: 'Online',
                  icon: Icons.videocam_outlined,
                  isSelected: _mode == 'online',
                  onTap: () => setState(() => _mode = 'online'),
                ),
                const SizedBox(width: 10),
                _SelectChip(
                  label: 'In-person',
                  icon: Icons.location_on_outlined,
                  isSelected: _mode == 'in-person',
                  onTap: () => setState(() => _mode = 'in-person'),
                ),
                const SizedBox(width: 10),
                _SelectChip(
                  label: 'Both',
                  icon: Icons.swap_horiz_rounded,
                  isSelected: _mode == 'both',
                  onTap: () => setState(() => _mode = 'both'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location
            AppTextField(
              controller: _locationCtrl,
              label: 'Location (optional)',
              hintText: 'Your city or district',
              prefixIcon: Icons.place_outlined,
            ),
            const SizedBox(height: 28),

            AppButton(
              label: 'Post Request',
              onPressed: _submit,
              isLoading: _isSubmitting,
              icon: Icons.send_rounded,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _SelectChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unselectedBg = theme.colorScheme.onSurface.withOpacity(0.08);
    final unselectedFg = theme.colorScheme.onSurface.withOpacity(0.7);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : unselectedBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? Colors.white : unselectedFg),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : unselectedFg,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}