import 'package:dashboard_admin/core/utils/app_colors.dart';
import 'package:dashboard_admin/core/utils/custom_toast_noti.dart';
import 'package:dashboard_admin/screen/banner_screen/controller/banner_controller.dart';
import 'package:dashboard_admin/screen/banner_screen/controller/createbanner_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AtivityBannerScreen extends StatelessWidget {
  AtivityBannerScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final BannerController bannerController = Get.find<BannerController>();
  final CreatebannerscreenController screenController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 1200) {
              return _buildDesktopLayout(context);
            } else if (constraints.maxWidth > 800) {
              return _buildTabletLayout(context);
            } else {
              return _buildMobileLayout(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Left Panel - Form
        Expanded(
          flex: 3,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                  Color(0xFF0F0F23),
                ],
              ),
            ),
            child: _buildFormContent(context, isDesktop: true),
          ),
        ),
        // Right Panel - Image Upload
        Expanded(
          flex: 2,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF16213E),
                  Color(0xFF1A1A2E),
                  Color(0xFF0F0F23),
                ],
              ),
            ),
            child: _buildImageSection(context),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F0F23)],
          ),
        ),
        child: Column(
          children: [
            _buildFormContent(context, isTablet: true),
            _buildImageSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F0F23)],
          ),
        ),
        child: Column(
          children: [
            _buildFormContent(context, isMobile: true),
            _buildImageSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent(
    BuildContext context, {
    bool isDesktop = false,
    bool isTablet = false,
    bool isMobile = false,
  }) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 48 : (isTablet ? 32 : 24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),
            SizedBox(height: isDesktop ? 48 : 32),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Field
                  _buildInputField(
                    controller: bannerController.title,
                    label: 'Banner Title',
                    hint: 'Enter banner title',
                    icon: Icons.title_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter banner title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Subtitle Field
                  _buildInputField(
                    controller: bannerController.subtitle,
                    label: 'Banner Subtitle',
                    hint: 'Enter banner subtitle (optional)',
                    icon: Icons.subtitles_outlined,
                  ),
                  const SizedBox(height: 24),

                  // Description Field
                  _buildInputField(
                    controller: bannerController.desc,
                    label: 'Description',
                    hint: 'Enter banner description',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter banner description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Link URL Field
                  _buildInputField(
                    controller: bannerController.linkUrl,
                    label: 'Link URL',
                    hint: 'https://example.com (optional)',
                    icon: Icons.link_outlined,
                  ),
                  const SizedBox(height: 24),

                  // Position Field
                  _buildInputField(
                    controller: bannerController.position,
                    label: 'Display Position',
                    hint: 'Enter display position (1, 2, 3...)',
                    icon: Icons.sort_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter display position';
                      }
                      final position = int.tryParse(value);
                      if (position == null || position < 1) {
                        return 'Please enter a valid position number (1 or higher)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          label: 'Start Date',
                          value: bannerController.startDate.value,
                          onTap: () => _selectDate(context, isStartDate: true),
                          icon: Icons.date_range_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateField(
                          label: 'End Date',
                          value: bannerController.endDate.value,
                          onTap: () => _selectDate(context, isStartDate: false),
                          icon: Icons.event_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Status Toggle
                  _buildStatusToggle(),
                  SizedBox(height: isDesktop ? 48 : 32),

                  // Action Buttons
                  _buildActionButtons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: InkWell(
                onTap: () => screenController.goList(),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Obx(
              () => Text(
                bannerController.isEditing.value
                    ? 'Update Banner'
                    : 'Create New Banner',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(
          () => Text(
            bannerController.isEditing.value
                ? 'Update banner information and settings'
                : 'Create a new promotional banner for your website',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.black),
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              prefixIcon: Icon(icon, color: const Color(0xFF6366F1)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(icon, color: const Color(0xFF6366F1)),
                  const SizedBox(width: 16),
                  Text(
                    value != null
                        ? '${value.day}/${value.month}/${value.year}'
                        : 'Select Date',
                    style: TextStyle(
                      color: value != null
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.toggle_on_outlined, color: Color(0xFF6366F1)),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Banner Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Set whether this banner is active and visible',
                  style: TextStyle(fontSize: 14, color: Colors.white54),
                ),
              ],
            ),
          ),
          Obx(
            () => Switch(
              value: bannerController.isActiveBanner.value,
              onChanged: (value) =>
                  bannerController.isActiveBanner.value = value,
              activeColor: const Color(0xFF10B981),
              activeTrackColor: const Color(0xFF10B981).withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: TextButton(
              onPressed: () {
                bannerController.clearForm();
                screenController.goList();
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Obx(
            () => Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed:
                    (bannerController.isSaving.value ||
                        bannerController.imageController.isUploading.value)
                    ? null
                    : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _buildButtonChild(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonChild() {
    return Obx(() {
      if (bannerController.imageController.isUploading.value) {
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Uploading...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        );
      } else if (bannerController.isSaving.value) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => Text(
                bannerController.isEditing.value
                    ? 'Updating...'
                    : 'Creating...',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      } else {
        return Obx(
          () => Text(
            bannerController.isEditing.value
                ? 'Update Banner'
                : 'Create Banner',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        );
      }
    });
  }

  Widget _buildImageSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.hasBoundedHeight;

        Widget slot(Widget child, {double boxedHeight = 360}) {
          return bounded
              ? Expanded(child: child)
              : SizedBox(height: boxedHeight, child: child);
        }

        return Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  bannerController.isEditing.value
                      ? 'Change Banner Image'
                      : 'Banner Image',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload a high-quality image for your promotional banner',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              slot(Obx(() => _buildImagePreview())),

              Obx(() {
                final hasOld =
                    bannerController.existingImageUrl.value.isNotEmpty;
                final ic = bannerController.imageController;
                final hasNew = kIsWeb
                    ? ic.imageBytesList.isNotEmpty
                    : ic.imageFiles.isNotEmpty;

                if (bannerController.isEditing.value && hasOld && hasNew) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Previous Image',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(20),
                          width: 300,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 2,
                              color: AppColors.borderColro.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              bannerController.existingImageUrl.value,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePreview() {
    final ic = bannerController.imageController;
    final hasNew = kIsWeb
        ? ic.imageBytesList.isNotEmpty
        : ic.imageFiles.isNotEmpty;
    final hasOldUrl = bannerController.existingImageUrl.value.isNotEmpty;

    if (ic.isUploading.value) {
      return _buildUploadingState();
    }

    if (hasNew) {
      final Widget image = kIsWeb
          ? Image.memory(ic.imageBytesList.first, fit: BoxFit.cover)
          : Image.file(ic.imageFiles.first, fit: BoxFit.cover);

      return _previewShell(
        image: image,
        onChange: bannerController.pickImage,
        onRemove: () => ic.clearSelection(),
      );
    }

    if (hasOldUrl) {
      final url = bannerController.existingImageUrl.value;
      return _previewShell(
        image: Image.network(url, fit: BoxFit.cover),
        onChange: bannerController.pickImage,
        onRemove: () => bannerController.existingImageUrl.value = '',
      );
    }

    return _buildImageUploadArea();
  }

  Widget _buildUploadingState() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        color: Colors.black.withValues(alpha: 0.3),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF6366F1), strokeWidth: 3),
          SizedBox(height: 16),
          Text(
            'Uploading banner image...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadArea() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderColro.withValues(alpha: 0.3),
          width: 2,
          style: BorderStyle.values[1],
        ),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: InkWell(
        onTap: bannerController.pickImage,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.2),
                    const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  ],
                ),
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Click to upload banner image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recommended size: 1200x400px for best results',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewShell({
    required Widget image,
    required Future<void> Function() onChange,
    required VoidCallback onRemove,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9, // Banner aspect ratio
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: image,
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: ElevatedButton.icon(
              onPressed: onChange,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.image, size: 18, color: Colors.white),
              label: const Text(
                "Change",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: ElevatedButton.icon(
              onPressed: onRemove,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.delete, size: 18, color: Colors.white),
              label: const Text(
                "Remove",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (bannerController.startDate.value ?? DateTime.now())
          : (bannerController.endDate.value ??
                DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStartDate) {
        bannerController.startDate.value = picked;
        // If end date is before start date, reset it
        if (bannerController.endDate.value != null &&
            bannerController.endDate.value!.isBefore(picked)) {
          bannerController.endDate.value = null;
        }
      } else {
        bannerController.endDate.value = picked;
      }
    }
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      // Validate date range
      final startDate = bannerController.startDate.value;
      final endDate = bannerController.endDate.value;

      if (startDate == null) {
        CustomToastNoti.show(
          title: 'Error',
          description: 'Please select a start date',
        );
        return;
      }

      if (endDate != null && endDate.isBefore(startDate)) {
        CustomToastNoti.show(
          title: 'Error',
          description: 'End date cannot be before start date',
        );
        return;
      }

        if (bannerController.isEditing.value) {
          // You'll need to add updateBanner() method to your controller
          await bannerController.updateBanner();
        } else {
          await bannerController.createBanner();
        }
      }
    }
  }
