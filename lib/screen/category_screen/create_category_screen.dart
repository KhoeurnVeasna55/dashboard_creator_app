import 'package:dashboard_admin/core/utils/app_colors.dart';
import 'package:dashboard_admin/screen/category_screen/category_screen_controller.dart';
import 'package:dashboard_admin/screen/category_screen/controller/category_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateCategoryScreen extends StatelessWidget {
  CreateCategoryScreen({super.key});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final CategoryScreenController categoryScreenController = Get.find();
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
    return Container(
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
                _buildInputField(
                  controller: categoryController.ctrname,
                  label: 'Category Name',
                  hint: 'Enter category name',
                  icon: Icons.category_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter category name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                _buildInputField(
                  controller: categoryController.ctrdescription,
                  label: 'Description',
                  hint: 'Enter category description',
                  icon: Icons.description_outlined,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter category description';
                    }
                    return null;
                  },
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    final CategoryScreenController categoryScreenController = Get.find();
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
                onTap: () => categoryScreenController.goList(),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              categoryController.isEditing.value
                  ? 'Update Category'
                  : 'Create New Category',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          categoryController.isEditing.value
              ? 'Update a product to orginze your product'
              : 'Add a new category to organize your products',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.7),
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
                  'Category Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Set whether this category is active',
                  style: TextStyle(fontSize: 14, color: Colors.white54),
                ),
              ],
            ),
          ),
          Obx(
            () => Switch(
              value: categoryController.isActiveCategory.value,
              onChanged: (value) =>
                  categoryController.isActiveCategory.value = value,
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
                categoryController.clearForm(); // Clear form on cancel
                final CategoryScreenController categoryScreenController =
                    Get.find();
                categoryScreenController.goList();
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
                    (categoryController.isSaving.value ||
                        categoryController.imageController.isUploading.value)
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
      if (categoryController.imageController.isUploading.value) {
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
      } else if (categoryController.isSaving.value) {
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
              'Creating...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        );
      } else {
        return Text(
          categoryController.isEditing.value
              ? 'Update Category'
              : 'Create Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        );
      }
    });
  }

  Widget _buildImageSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints
            .hasBoundedHeight;

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
              Text(
                categoryController.isEditing.value
                    ? 'Change New Image '
                    : 'Category Image',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload an image to represent this category',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
slot(Obx(() => _buildImagePreview())),


              Obx(() {
                final hasOld =
                    categoryController.existingImageUrl.value.isNotEmpty;
                final ic = categoryController.imageController;
                final hasNew = kIsWeb
                    ? ic.imageBytesList.isNotEmpty
                    : ic.imageFiles.isNotEmpty;

                if (categoryController.isEditing.value && hasOld && hasNew) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Previous image',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(20),
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 2,
                              color: AppColors.borderColro.withOpacity(0.3),
                            ),
                          ),
                          child: Image.network(
                            categoryController.existingImageUrl.value,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
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
            'Uploading image...',
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
        onTap: categoryController.pickImage,
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
              'Click to upload image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload images in their original quality',
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

  Widget _buildImagePreview() {
    final ic = categoryController.imageController;

    final hasNew = kIsWeb
        ? ic.imageBytesList.isNotEmpty
        : ic.imageFiles.isNotEmpty;
    final hasOldUrl = categoryController.existingImageUrl.value.isNotEmpty;

    if (ic.isUploading.value) {
      return _buildUploadingState();
    }

    // 1) New local selection
    if (hasNew) {
      final Widget image = kIsWeb
          ? Image.memory(ic.imageBytesList.first, fit: BoxFit.cover)
          : Image.file(ic.imageFiles.first, fit: BoxFit.cover);

      return _previewShell(
        image: image,
        onChange: categoryController.pickImage,
        onRemove: () {
          ic.clearSelection();
        },
      );
    }

    // 2) No new selection, but editing with an existing image
    if (hasOldUrl) {
      final url = categoryController.existingImageUrl.value;
      return _previewShell(
        image: Image.network(url, fit: BoxFit.cover),
        onChange: categoryController.pickImage,
        onRemove: () {
          // Remove the existing image from the form state
          categoryController.existingImageUrl.value = '';
        },
      );
    }

    // 3) Nothing selected/loaded yet → prompt to upload
    return _buildImageUploadArea();
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
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1,
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
                backgroundColor: Colors.black.withOpacity(0.5),
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
                backgroundColor: Colors.red.withOpacity(0.5),
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

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (categoryController.isEditing.value) {
        await categoryController.updateCategory();
      } else {
        await categoryController.createCategory();
      }
    }
  }
}
