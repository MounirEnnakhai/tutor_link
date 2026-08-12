import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/tutor_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tutor_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class TutorProfileEditScreen extends ConsumerStatefulWidget {
  const TutorProfileEditScreen({super.key});

  @override
  ConsumerState<TutorProfileEditScreen> createState() =>
      _TutorProfileEditScreenState();
}

class _TutorProfileEditScreenState
    extends ConsumerState<TutorProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _qualCtrl = TextEditingController();
  final _certCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  List<String> _selectedSubjects = [];
  List<String> _selectedLanguages = [];
  List<String> _selectedModes = [];
  String _educationLevel = AppConstants.educationLevels.first;
  int _yearsExp = 0;
  File? _newPhoto;
  bool _isSaving = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  void _loadProfile() {
    final tutor = ref.read(currentTutorProfileProvider).valueOrNull;
    if (tutor == null) return;
    setState(() {
      _nameCtrl.text = tutor.fullName;
      _bioCtrl.text = tutor.biography;
      _phoneCtrl.text = tutor.phoneNumber ?? '';
      _qualCtrl.text = tutor.qualifications.join('\n');
      _certCtrl.text = tutor.certifications.join('\n');
      _cityCtrl.text = tutor.location?.city ?? '';
      _selectedSubjects = List.from(tutor.subjects);
      _selectedLanguages = List.from(tutor.teachingLanguages);
      _selectedModes = List.from(tutor.teachingModes);
      _educationLevel = tutor.educationLevel.isNotEmpty
          ? tutor.educationLevel
          : AppConstants.educationLevels.first;
      _yearsExp = tutor.yearsOfExperience;
      _isLoaded = true;
    });
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _newPhoto = File(picked.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final user = ref.read(currentUserProvider)!;
      final tutorDs = ref.read(tutorDataSourceProvider);
      final firestore = ref.read(firestoreProvider);

      String? photoUrl;
      if (_newPhoto != null) {
        photoUrl = await tutorDs.uploadProfilePicture(
          tutorId: user.id,
          image: _newPhoto!,
        );
      }

      final qualifications = _qualCtrl.text
          .split('\n')
          .map((q) => q.trim())
          .where((q) => q.isNotEmpty)
          .toList();

      final certifications = _certCtrl.text
          .split('\n')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();

      final updates = <String, dynamic>{
        'fullName': _nameCtrl.text.trim(),
        'biography': _bioCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'subjects': _selectedSubjects,
        'teachingLanguages': _selectedLanguages,
        'teachingModes': _selectedModes,
        'educationLevel': _educationLevel,
        'yearsOfExperience': _yearsExp,
        'qualifications': qualifications,
        'certifications': certifications,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (_cityCtrl.text.isNotEmpty)
          'location': {
            'city': _cityCtrl.text.trim(),
            'latitude': 0.0,
            'longitude': 0.0,
          },
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await firestore
          .collection(AppConstants.tutorsCollection)
          .doc(user.id)
          .update(updates);

      await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .update({
        'fullName': _nameCtrl.text.trim(),
        if (photoUrl != null) 'photoUrl': photoUrl,
      });

      ref.invalidate(currentTutorProfileProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _phoneCtrl.dispose();
    _qualCtrl.dispose();
    _certCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Save',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
      body: !_isLoaded
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor:
                      AppTheme.primaryColor.withOpacity(0.15),
                      backgroundImage: _newPhoto != null
                          ? FileImage(_newPhoto!) as ImageProvider
                          : null,
                      child: _newPhoto == null
                          ? Text(
                        _nameCtrl.text.isNotEmpty
                            ? _nameCtrl.text[0].toUpperCase()
                            : 'T',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      )
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Tap to change photo',
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 12,
                    fontFamily: 'Poppins'),
              ),
            ),
            const SizedBox(height: 28),

            _FormSection(title: 'Basic Info', children: [
              AppTextField(
                controller: _nameCtrl,
                label: 'Full Name',
                prefixIcon: Icons.person_outline,
                validator: (v) =>
                v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _phoneCtrl,
                label: 'Phone Number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _cityCtrl,
                label: 'City',
                prefixIcon: Icons.location_city_outlined,
              ),
            ]),
            const SizedBox(height: 20),

            _FormSection(title: 'About You', children: [
              AppTextField(
                controller: _bioCtrl,
                label: 'Biography',
                hintText:
                'Tell students about yourself, your teaching philosophy...',
                maxLines: 5,
                validator: (v) =>
                v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              AppDropdownField<String>(
                label: 'Education Level',
                value: _educationLevel,
                prefixIcon: Icons.school_outlined,
                items: AppConstants.educationLevels
                    .map((l) =>
                    DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _educationLevel = v!),
              ),
              const SizedBox(height: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Years of Experience',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _yearsExp > 0
                            ? () => setState(() => _yearsExp--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: AppTheme.primaryColor,
                      ),
                      Text(
                        '$_yearsExp',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins'),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _yearsExp++),
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppTheme.primaryColor,
                      ),
                      Text('years',
                          style: TextStyle(
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.5),
                              fontFamily: 'Poppins')),
                    ],
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 20),

            _FormSection(title: 'Subjects', children: [
              _MultiSelectChips(
                options: AppConstants.subjects,
                selected: _selectedSubjects,
                onChanged: (v) =>
                    setState(() => _selectedSubjects = v),
              ),
            ]),
            const SizedBox(height: 20),

            _FormSection(title: 'Teaching Languages', children: [
              _MultiSelectChips(
                options: AppConstants.languages,
                selected: _selectedLanguages,
                onChanged: (v) =>
                    setState(() => _selectedLanguages = v),
              ),
            ]),
            const SizedBox(height: 20),

            _FormSection(title: 'Teaching Modes', children: [
              _MultiSelectChips(
                options: AppConstants.teachingModes,
                selected: _selectedModes,
                onChanged: (v) => setState(() => _selectedModes = v),
              ),
            ]),
            const SizedBox(height: 20),

            _FormSection(title: 'Qualifications', children: [
              AppTextField(
                controller: _qualCtrl,
                label: 'Qualifications (one per line)',
                hintText: 'e.g.\nMaster\'s in Mathematics',
                maxLines: 4,
              ),
            ]),
            const SizedBox(height: 20),

            _FormSection(title: 'Certifications', children: [
              AppTextField(
                controller: _certCtrl,
                label: 'Certifications (one per line)',
                hintText: 'e.g.\nCambridge CELTA',
                maxLines: 4,
              ),
            ]),
            const SizedBox(height: 28),

            AppButton(
              label: 'Save Profile',
              onPressed: _save,
              isLoading: _isSaving,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _FormSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: theme.colorScheme.onSurface.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _MultiSelectChips extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  const _MultiSelectChips({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);
        return FilterChip(
          label: Text(opt,
              style:
              const TextStyle(fontSize: 12, fontFamily: 'Poppins')),
          selected: isSelected,
          selectedColor: AppTheme.primaryColor.withOpacity(0.15),
          checkmarkColor: AppTheme.primaryColor,
          showCheckmark: true,
          onSelected: (val) {
            final updated = List<String>.from(selected);
            if (val) {
              updated.add(opt);
            } else {
              updated.remove(opt);
            }
            onChanged(updated);
          },
        );
      }).toList(),
    );
  }
}