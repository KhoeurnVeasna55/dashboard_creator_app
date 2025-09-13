import 'package:dashboard_admin/screen/attributes/controller/attributes_controller.dart';
import 'package:dashboard_admin/screen/attributes/controller/attributes_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AtivityAttributesScreen extends StatelessWidget {
  AtivityAttributesScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AttributesController attributesController =
      Get.find<AttributesController>();
  final AttributesScreenController screenController = Get.find();

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
            child: _buildInfoSection(context),
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
            _buildInfoSection(context),
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
            _buildInfoSection(context),
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
                // Name Field
                _buildInputField(
                  controller: attributesController.name,
                  label: 'Attribute Name',
                  hint: 'Enter attribute name (e.g., Color, Size)',
                  icon: Icons.label_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter attribute name';
                    }
                    if (value.length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Code Field
                _buildInputField(
                  controller: attributesController.code,
                  label: 'Attribute Code',
                  hint: 'Enter unique code (e.g., color, size)',
                  icon: Icons.code_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter attribute code';
                    }
                    if (value.length < 2) {
                      return 'Code must be at least 2 characters';
                    }
                    // Only allow alphanumeric and underscores
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                      return 'Code can only contain letters, numbers, and underscores';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Type Dropdown
                _buildTypeDropdown(),
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
                attributesController.isEditing.value
                    ? 'Update Attribute'
                    : 'Create New Attribute',
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
            attributesController.isEditing.value
                ? 'Update product attribute properties and settings'
                : 'Create a new product attribute to organize your products',
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

  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attribute Type',
          style: TextStyle(
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
          child: Obx(
            () => DropdownButtonFormField<String>(
              value: attributesController.selectedTypeFilter.value,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.category_outlined,
                  color: Color(0xFF6366F1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
              dropdownColor: const Color(0xFF1A1A2E),
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
              hint: Text(
                'Select attribute type',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'select',
                  child: Row(
                    children: [
                      Icon(Icons.list, color: Colors.blue, size: 20),
                      SizedBox(width: 12),
                      Text('Select (Dropdown)'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'size',
                  child: Row(
                    children: [
                      Icon(Icons.straighten, color: Colors.orange, size: 20),
                      SizedBox(width: 12),
                      Text('Size'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'color',
                  child: Row(
                    children: [
                      Icon(Icons.palette, color: Colors.purple, size: 20),
                      SizedBox(width: 12),
                      Text('Color'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'text',
                  child: Row(
                    children: [
                      Icon(Icons.text_fields, color: Colors.green, size: 20),
                      SizedBox(width: 12),
                      Text('Text Input'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) =>
                  attributesController.selectedTypeFilter.value = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an attribute type';
                }
                return null;
              },
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
                  'Attribute Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Set whether this attribute is active and usable',
                  style: TextStyle(fontSize: 14, color: Colors.white54),
                ),
              ],
            ),
          ),
          // Obx(
          //   () => Switch(
          //     value: attributesController.isActiveAttribute.value,
          //     onChanged: (value) =>
          //         attributesController.isActiveAttribute.value = value,
          //     activeColor: const Color(0xFF10B981),
          //     activeTrackColor: const Color(0xFF10B981).withValues(alpha: 0.3),
          //   ),
          // ),
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
                attributesController.clearForm();
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
                onPressed: attributesController.isSaving.value
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
      if (attributesController.isSaving.value) {
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
                attributesController.isEditing.value
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
            attributesController.isEditing.value
                ? 'Update Attribute'
                : 'Create Attribute',
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

  Widget _buildInfoSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Attribute Types',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the appropriate type for your product attribute',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Attribute type explanations
              _buildInfoCard(
                icon: Icons.list,
                color: Colors.blue,
                title: 'Select (Dropdown)',
                description:
                    'Users can choose from predefined options like brand names or categories.',
                examples: 'Brand: Nike, Adidas, Puma',
              ),

              const SizedBox(height: 16),

              _buildInfoCard(
                icon: Icons.straighten,
                color: Colors.orange,
                title: 'Size',
                description:
                    'For sizing options like clothing sizes, shoe sizes, or dimensions.',
                examples: 'Size: XS, S, M, L, XL, XXL',
              ),

              const SizedBox(height: 16),

              _buildInfoCard(
                icon: Icons.palette,
                color: Colors.purple,
                title: 'Color',
                description:
                    'Color swatches with visual representation for easy selection.',
                examples: 'Color: Red, Blue, Green, Black',
              ),

              const SizedBox(height: 16),

              _buildInfoCard(
                icon: Icons.text_fields,
                color: Colors.green,
                title: 'Text Input',
                description:
                    'Free text input for custom values like descriptions or notes.',
                examples: 'Material: 100% Cotton, Polyester',
              ),

              const SizedBox(height: 32),

              // Tips section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.05),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Color(0xFFFFA726)),
                        SizedBox(width: 8),
                        Text(
                          'Tips',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('Use clear, descriptive names for attributes'),
                    _buildTip('Keep codes short and URL-friendly (no spaces)'),
                    _buildTip(
                      'Choose the most appropriate type for user experience',
                    ),
                    _buildTip('You can manage attribute values after creation'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required String examples,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.03),
            Colors.white.withValues(alpha: 0.01),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  examples,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 8, right: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFA726),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (attributesController.isEditing.value) {
        await attributesController.updateAttributes();
      } else {
        await attributesController.createAttributes();
      }
    }
  }
}
