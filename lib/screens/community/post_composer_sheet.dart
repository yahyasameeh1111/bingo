import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/widgets/bingo_button.dart';
import '../../core/widgets/bingo_chip.dart';
import '../../models/community_poll.dart';
import '../../models/community_post.dart';
import '../../providers/app_providers.dart';

class PostComposerSheet extends ConsumerStatefulWidget {
  const PostComposerSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PostComposerSheet(),
    );
  }

  @override
  ConsumerState<PostComposerSheet> createState() => _PostComposerSheetState();
}

class _PostComposerSheetState extends ConsumerState<PostComposerSheet> {
  final _contentController = TextEditingController();
  final _linkUrlController = TextEditingController();
  final _linkTitleController = TextEditingController();

  String _selectedType = 'post'; // 'post', 'photo', 'poll', 'link'
  Uint8List? _selectedImageBytes;
  String? _selectedImageMime;

  // Poll state
  final List<TextEditingController> _pollOptionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _contentController.dispose();
    _linkUrlController.dispose();
    _linkTitleController.dispose();
    for (final c in _pollOptionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final mime = picked.mimeType ?? 'image/jpeg';
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageMime = mime;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to select image: $e');
    }
  }

  void _addPollOption() {
    if (_pollOptionControllers.length < 5) {
      setState(() {
        _pollOptionControllers.add(TextEditingController());
      });
    }
  }

  void _removePollOption(int index) {
    if (_pollOptionControllers.length > 2) {
      setState(() {
        final controller = _pollOptionControllers.removeAt(index);
        controller.dispose();
      });
    }
  }

  Future<void> _submitPost() async {
    final text = _contentController.text.trim();
    if (text.isEmpty && _selectedImageBytes == null && _selectedType != 'link') {
      setState(() => _errorMessage = 'Please write something or attach media.');
      return;
    }

    if (_selectedType == 'poll') {
      final validOptions = _pollOptionControllers
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (validOptions.length < 2) {
        setState(() => _errorMessage = 'Please provide at least 2 poll options.');
        return;
      }
    }

    if (_selectedType == 'link') {
      final link = _linkUrlController.text.trim();
      if (link.isEmpty || (!link.startsWith('http://') && !link.startsWith('https://'))) {
        setState(() => _errorMessage = 'Please provide a valid URL starting with http:// or https://');
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      final currentUid = auth.currentUid ?? 'anonymous';
      final household = ref.read(currentHouseholdProvider).value;

      String? uploadedImageUrl;
      if (_selectedImageBytes != null) {
        final storage = ref.read(storageServiceProvider);
        uploadedImageUrl = await storage.uploadCommunityImage(
          bytes: _selectedImageBytes!,
          mimeType: _selectedImageMime ?? 'image/jpeg',
        );
      }

      CommunityPoll? poll;
      if (_selectedType == 'poll') {
        final rawTexts = _pollOptionControllers
            .map((c) => c.text.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        final options = <PollOption>[];
        for (int i = 0; i < rawTexts.length; i++) {
          options.add(PollOption(index: i, text: rawTexts[i], votes: 0));
        }
        poll = CommunityPoll(
          question: text.isNotEmpty ? text : 'Community Poll',
          options: options,
          totalVotes: 0,
        );
      }

      final authorName = household?.headOfFamily ?? 'Resident';
      final authorHandle = (household?.id ?? currentUid).toLowerCase();

      final post = CommunityPost(
        id: '',
        authorUid: currentUid,
        authorName: authorName,
        authorHandle: authorHandle,
        authorPhoto: household?.photoUrl,
        householdId: household?.id,
        panchayat: household?.panchayat,
        ward: household?.ward,
        text: text,
        postType: _selectedType,
        imageUrl: uploadedImageUrl,
        linkUrl: _selectedType == 'link' ? _linkUrlController.text.trim() : null,
        linkTitle: _selectedType == 'link' && _linkTitleController.text.trim().isNotEmpty
            ? _linkTitleController.text.trim()
            : null,
        poll: poll,
        createdAt: DateTime.now(),
      );

      final repo = ref.read(communityRepositoryProvider);
      await repo.createPost(post);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post published to neighborhood!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Failed to publish post: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final household = ref.watch(currentHouseholdProvider).value;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
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

            // Header & Author Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.limeAccent,
                  backgroundImage: household?.photoUrl != null && household!.photoUrl!.isNotEmpty
                      ? NetworkImage(household.photoUrl!)
                      : null,
                  child: household?.photoUrl == null || household!.photoUrl!.isEmpty
                      ? Text(
                          household != null && household.headOfFamily.isNotEmpty
                              ? household.headOfFamily.substring(0, 1).toUpperCase()
                              : 'B',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryLight,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        household?.headOfFamily ?? 'Neighborhood Member',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Posting to ${household?.panchayat ?? "Ward Community"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Type Chips Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  BingoChip(
                    label: 'Post',
                    icon: Icons.chat_bubble_outline_rounded,
                    isSelected: _selectedType == 'post',
                    onTap: () => setState(() => _selectedType = 'post'),
                  ),
                  const SizedBox(width: 8),
                  BingoChip(
                    label: 'Photo',
                    icon: Icons.image_outlined,
                    isSelected: _selectedType == 'photo',
                    onTap: () {
                      setState(() => _selectedType = 'photo');
                      if (_selectedImageBytes == null) {
                        _pickImage();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  BingoChip(
                    label: 'Poll',
                    icon: Icons.poll_outlined,
                    isSelected: _selectedType == 'poll',
                    onTap: () => setState(() => _selectedType = 'poll'),
                  ),
                  const SizedBox(width: 8),
                  BingoChip(
                    label: 'Link',
                    icon: Icons.link_rounded,
                    isSelected: _selectedType == 'link',
                    onTap: () => setState(() => _selectedType = 'link'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Text Input
            TextField(
              controller: _contentController,
              maxLines: _selectedType == 'poll' ? 2 : 4,
              minLines: 2,
              decoration: InputDecoration(
                hintText: _selectedType == 'poll'
                    ? 'Ask a question for the neighborhood poll...'
                    : "Share an update, recycling tip, or waste query...",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 12),

            // Image Preview if Photo selected
            if (_selectedType == 'photo') ...[
              if (_selectedImageBytes != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: AppRadii.mdRadius,
                      child: Image.memory(
                        _selectedImageBytes!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImageBytes = null),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                )
              else
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Choose Photo'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.mdRadius),
                  ),
                ),
              const SizedBox(height: 12),
            ],

            // Poll Options if Poll selected
            if (_selectedType == 'poll') ...[
              const Text(
                'Poll Options (2 - 5)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < _pollOptionControllers.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pollOptionControllers[i],
                          decoration: InputDecoration(
                            hintText: 'Option ${i + 1}',
                            filled: true,
                            fillColor: isDark ? const Color(0xFF1E2428) : AppColors.sageSurfaceLight,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: AppRadii.smRadius,
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      if (_pollOptionControllers.length > 2) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => _removePollOption(i),
                        ),
                      ],
                    ],
                  ),
                ),
              if (_pollOptionControllers.length < 5)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addPollOption,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Option', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              const SizedBox(height: 12),
            ],

            // Link inputs if Link selected
            if (_selectedType == 'link') ...[
              TextField(
                controller: _linkUrlController,
                decoration: InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://example.com/article',
                  prefixIcon: const Icon(Icons.link_rounded),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E2428) : AppColors.sageSurfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: AppRadii.smRadius,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _linkTitleController,
                decoration: InputDecoration(
                  labelText: 'Link Title (Optional)',
                  hintText: 'e.g. Clean Energy Report',
                  prefixIcon: const Icon(Icons.title_rounded),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E2428) : AppColors.sageSurfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: AppRadii.smRadius,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Error Banner
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: AppRadii.smRadius,
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Submit Button
            BingoButton(
              label: 'Publish Post',
              isLoading: _isSubmitting,
              onPressed: _submitPost,
            ),
          ],
        ),
      ),
    );
  }
}
