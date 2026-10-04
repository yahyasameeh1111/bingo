import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/widgets/bingo_button.dart';
import '../../models/community_profile.dart';
import '../../models/household.dart';
import '../../providers/app_providers.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  final Household household;

  const EditProfileDialog({super.key, required this.household});

  static Future<bool?> show(BuildContext context, Household household) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileDialog(household: household),
    );
  }

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _houseController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  Uint8List? _newPhotoBytes;
  String? _newPhotoMime;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.household.name ?? '');
    _houseController = TextEditingController(text: widget.household.house ?? '');
    _addressController = TextEditingController(text: widget.household.address ?? '');
    _phoneController = TextEditingController(text: widget.household.phone ?? '');
    _emailController = TextEditingController(text: widget.household.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _houseController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final mime = picked.mimeType ?? 'image/jpeg';
        setState(() {
          _newPhotoBytes = bytes;
          _newPhotoMime = mime;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to choose photo: $e');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      String? photoUrl = widget.household.photo;

      if (_newPhotoBytes != null) {
        final storage = ref.read(storageServiceProvider);
        photoUrl = await storage.uploadProfilePhoto(
          bytes: _newPhotoBytes!,
          householdId: widget.household.id,
          mimeType: _newPhotoMime ?? 'image/jpeg',
        );
      }

      final updatedHousehold = widget.household.copyWith(
        name: _nameController.text.trim(),
        house: _houseController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        photo: photoUrl,
      );

      final householdRepo = ref.read(householdRepositoryProvider);
      await householdRepo.updateHousehold(updatedHousehold);

      // Also sync community profile
      final currentUid = ref.read(authServiceProvider).currentUid ?? widget.household.id;
      final communityRepo = ref.read(communityRepositoryProvider);
      final profile = CommunityProfile(
        uid: currentUid,
        name: updatedHousehold.displayName,
        handle: widget.household.id.toLowerCase(),
        photoUrl: photoUrl,
        panchayat: updatedHousehold.panchayat,
        ward: updatedHousehold.ward,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await communityRepo.upsertProfile(profile);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Failed to save changes: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomInset + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: AppRadii.fullRadius,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Avatar preview & edit button
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.limeAccent,
                      backgroundImage: _newPhotoBytes != null
                          ? MemoryImage(_newPhotoBytes!)
                          : (widget.household.photo != null && widget.household.photo!.isNotEmpty
                              ? NetworkImage(widget.household.photo!) as ImageProvider
                              : null),
                      child: (_newPhotoBytes == null &&
                              (widget.household.photo == null || widget.household.photo!.isEmpty))
                          ? Text(
                              widget.household.shortInitials,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimaryLight,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickPhoto,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.limeAccent : AppColors.darkPillSurface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: isDark ? AppColors.textPrimaryLight : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Full Name / Head of Family
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Head of Family / Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Please enter household name' : null,
              ),
              const SizedBox(height: 14),

              // House / Building Name
              TextFormField(
                controller: _houseController,
                decoration: const InputDecoration(
                  labelText: 'House Name / Number',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
              ),
              const SizedBox(height: 14),

              // Address
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 14),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 14),

              // Email Address
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: AppRadii.smRadius,
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              BingoButton(
                label: 'Save Changes',
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
