import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/offer_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tutor_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class CreateOfferScreen extends ConsumerStatefulWidget {
  final String? editOfferId;
  const CreateOfferScreen({super.key, this.editOfferId});

  @override
  ConsumerState<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends ConsumerState<CreateOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _maxStudentsCtrl = TextEditingController();

  OfferType _offerType = OfferType.privateLesson;
  String _selectedSubject = AppConstants.subjects.first;
  String _teachingMode = 'Online';
  bool _isOnline = true;
  bool _isLoading = false;
  bool _isEditing = false;

  final List<ScheduleSlot> _schedule = [];

  bool get isEditing => widget.editOfferId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) _loadExistingOffer();
  }

  Future<void> _loadExistingOffer() async {
    final offer = await ref.read(offerByIdProvider(widget.editOfferId!).future);
    setState(() {
      _titleCtrl.text = offer.title;
      _descCtrl.text = offer.description;
      _priceCtrl.text =
          (offer.hourlyRate ?? offer.monthlyPrice ?? 0).toStringAsFixed(0);
      _locationCtrl.text = offer.location ?? '';
      _offerType = offer.type;
      _selectedSubject = offer.subject;
      _teachingMode = offer.teachingMode ?? 'Online';
      _isEditing = true;
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    _maxStudentsCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveOffer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProvider)!;
      final tutor = ref.read(currentTutorProfileProvider).valueOrNull;
      final firestore = ref.read(firestoreProvider);
      final price = double.tryParse(_priceCtrl.text) ?? 0;
      final offerId = isEditing ? widget.editOfferId! : const Uuid().v4();

      final offer = {
        'tutorId': tutor?.id ?? user.id,
        'tutorName': user.fullName,
        'tutorPhotoUrl': user.photoUrl,
        'subject': _selectedSubject,
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'type': _offerType == OfferType.groupClass ? 'groupClass' : 'privateLesson',
        'status': 'active',
        if (_offerType == OfferType.privateLesson) ...{
          'hourlyRate': price,
          'teachingMode': _teachingMode,
          'availabilitySchedule': _schedule
              .map((s) => {'day': s.day, 'startTime': s.startTime, 'endTime': s.endTime})
              .toList(),
        },
        if (_offerType == OfferType.groupClass) ...{
          'monthlyPrice': price,
          'maxStudents': int.tryParse(_maxStudentsCtrl.text) ?? 10,
          'availableSeats': int.tryParse(_maxStudentsCtrl.text) ?? 10,
          'isOnline': _isOnline,
          'classSchedule': _schedule
              .map((s) => {'day': s.day, 'startTime': s.startTime, 'endTime': s.endTime})
              .toList(),
        },
        'location': _locationCtrl.text.trim(),
        'tags': [_selectedSubject],
        if (!isEditing) 'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await firestore
          .collection(AppConstants.offersCollection)
          .doc(offerId)
          .set(offer, SetOptions(merge: true));

      ref.invalidate(offersByTutorProvider);
      ref.invalidate(featuredOffersProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Offer updated!' : 'Offer published!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Offer' : 'Create Offer')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Offer Type', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                _TypeSelector(
                  label: 'Private Lesson',
                  icon: Icons.person_outline,
                  isSelected: _offerType == OfferType.privateLesson,
                  onTap: () => setState(() => _offerType = OfferType.privateLesson),
                ),
                const SizedBox(width: 12),
                _TypeSelector(
                  label: 'Group Class',
                  icon: Icons.group_outlined,
                  isSelected: _offerType == OfferType.groupClass,
                  onTap: () => setState(() => _offerType = OfferType.groupClass),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
            AppTextField(
              controller: _titleCtrl,
              label: 'Offer Title',
              hintText: 'e.g., Advanced Calculus for BAC',
              prefixIcon: Icons.title,
              validator: (v) => v?.isEmpty == true ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _descCtrl,
              label: 'Description',
              hintText: 'Describe your offer, teaching approach, prerequisites...',
              maxLines: 4,
              validator: (v) => v?.isEmpty == true ? 'Description is required' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _priceCtrl,
              label: _offerType == OfferType.privateLesson
                  ? 'Hourly Rate (MAD)'
                  : 'Monthly Price (MAD)',
              hintText: '150',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.attach_money_rounded,
              validator: (v) {
                if (v?.isEmpty == true) return 'Price is required';
                if (double.tryParse(v!) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (_offerType == OfferType.privateLesson) ...[
              AppDropdownField<String>(
                label: 'Teaching Mode',
                value: _teachingMode,
                prefixIcon: Icons.location_on_outlined,
                items: AppConstants.teachingModes
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _teachingMode = v!),
              ),
              const SizedBox(height: 16),
            ],
            if (_offerType == OfferType.groupClass) ...[
              AppTextField(
                controller: _maxStudentsCtrl,
                label: 'Maximum Students',
                hintText: '10',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.group_outlined,
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Online Class',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                value: _isOnline,
                activeColor: AppTheme.primaryColor,
                onChanged: (v) => setState(() => _isOnline = v),
              ),
              const SizedBox(height: 4),
            ],
            AppTextField(
              controller: _locationCtrl,
              label: 'Location (optional)',
              hintText: 'City, district or "Online"',
              prefixIcon: Icons.place_outlined,
            ),
            const SizedBox(height: 20),
            _ScheduleBuilder(
              schedule: _schedule,
              onChanged: (s) => setState(() {
                _schedule.clear();
                _schedule.addAll(s);
              }),
            ),
            const SizedBox(height: 28),
            AppButton(
              label: isEditing ? 'Update Offer' : 'Publish Offer',
              onPressed: _saveOffer,
              isLoading: _isLoading,
              icon: Icons.publish_rounded,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _TypeSelector({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unselectedBorder = theme.colorScheme.onSurface.withOpacity(0.15);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.1)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : unselectedBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                  size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleBuilder extends StatefulWidget {
  final List<ScheduleSlot> schedule;
  final ValueChanged<List<ScheduleSlot>> onChanged;
  const _ScheduleBuilder({required this.schedule, required this.onChanged});

  @override
  State<_ScheduleBuilder> createState() => _ScheduleBuilderState();
}

class _ScheduleBuilderState extends State<_ScheduleBuilder> {
  final _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday'
  ];

  void _addSlot() async {
    String selectedDay = _days.first;
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Schedule Slot'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedDay,
                items: _days
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedDay = v!),
                decoration: const InputDecoration(labelText: 'Day'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final t = await showTimePicker(
                            context: context, initialTime: startTime);
                        if (t != null) setDialogState(() => startTime = t);
                      },
                      child: Text('Start: ${startTime.format(context)}'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final t = await showTimePicker(
                            context: context, initialTime: endTime);
                        if (t != null) setDialogState(() => endTime = t);
                      },
                      child: Text('End: ${endTime.format(context)}'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final slot = ScheduleSlot(
                  day: selectedDay,
                  startTime: startTime.format(context),
                  endTime: endTime.format(context),
                );
                final updated = [...widget.schedule, slot];
                widget.onChanged(updated);
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emptyBg = theme.colorScheme.onSurface.withOpacity(0.05);
    final emptyBorder = theme.colorScheme.onSurface.withOpacity(0.12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Schedule', style: theme.textTheme.titleMedium),
            TextButton.icon(
              onPressed: _addSlot,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Slot'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.schedule.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: emptyBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: emptyBorder),
            ),
            child: Center(
              child: Text(
                'No schedule slots yet.\nTap "Add Slot" to add availability.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontFamily: 'Poppins',
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          ...widget.schedule.asMap().entries.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Text(e.value.day,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                const Spacer(),
                Text('${e.value.startTime} – ${e.value.endTime}',
                    style: const TextStyle(fontFamily: 'Poppins')),
                IconButton(
                  icon: Icon(Icons.close,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.4)),
                  onPressed: () {
                    final updated = [...widget.schedule]..removeAt(e.key);
                    widget.onChanged(updated);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          )),
      ],
    );
  }
}