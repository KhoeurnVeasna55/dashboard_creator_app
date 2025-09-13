import 'package:dashboard_admin/screen/attributes/controller/attributes_controller.dart';
import 'package:dashboard_admin/screen/attributes/controller/attributes_screen_controller.dart';
import 'package:dashboard_admin/screen/attributes/model/attributes_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManageValuesScreen extends StatefulWidget {
  final String attributeId;
  final String attributeName;
  final String attributeType;

  const ManageValuesScreen({
    super.key,
    required this.attributeId,
    required this.attributeName,
    required this.attributeType,
  });

  @override
  State<ManageValuesScreen> createState() => _ManageValuesScreenState();
}

class _ManageValuesScreenState extends State<ManageValuesScreen> {
  final AttributesController controller = Get.find<AttributesController>();
  final AttributesScreenController _screenController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _labelController;
  late TextEditingController _valueController;
  late TextEditingController _swatchController;

  final RxBool _isAddingValue = false.obs;
  final RxString _selectedColor = ''.obs;
  final RxBool _showAddForm = false.obs;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController();
    _valueController = TextEditingController();
    _swatchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadValues(widget.attributeId);
    });
  }

  @override
  void dispose() {
    _labelController.dispose();
    _valueController.dispose();
    _swatchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
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
              _buildHeader(),
              Expanded(
                child: Row(
                  children: [
                    Expanded(flex: 3, child: _buildValuesSection()),
                    Expanded(flex: 2, child: _buildFormSection()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
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
              onTap: () => _screenController.goList(),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getTypeColor(widget.attributeType).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTypeIcon(widget.attributeType),
              color: _getTypeColor(widget.attributeType),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Values: ${widget.attributeName}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Type: ${_formatType(widget.attributeType)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade600.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue.shade600.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '${controller.currentValues.length} Values',
                style: TextStyle(
                  color: Colors.blue.shade300,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValuesSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Current Values',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _showAddForm.value = !_showAddForm.value,
                icon: Obx(
                  () => Icon(_showAddForm.value ? Icons.close : Icons.add),
                ),
                label: Obx(
                  () => Text(_showAddForm.value ? 'Cancel' : 'Add Value'),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (controller.currentValues.isEmpty) {
                return _buildEmptyState();
              }

              return _buildValuesList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No values added yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add values to make this attribute usable',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildValuesList() {
    return ListView.builder(
      itemCount: controller.currentValues.length,
      itemBuilder: (context, index) {
        final value = controller.currentValues[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: _buildValueDisplay(value),
            title: Text(
              value.label ?? value.value ?? '—',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: value.value != null && value.value != value.label
                ? Text(
                    'Value: ${value.value}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Delete Value',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  onPressed: () => _confirmDeleteValue(value),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildValueDisplay(dynamic value) {
    final swatch = value.meta?.swatch;
    if (swatch != null && swatch.toString().startsWith('#')) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _parseColor(swatch.toString()),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
      );
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getTypeColor(widget.attributeType).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getTypeColor(widget.attributeType).withValues(alpha: 0.3),
        ),
      ),
      child: Icon(
        _getTypeIcon(widget.attributeType),
        color: _getTypeColor(widget.attributeType),
        size: 20,
      ),
    );
  }

  Widget _buildFormSection() {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          gradient: _showAddForm.value
              ? LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.03),
                    Colors.white.withValues(alpha: 0.01),
                  ],
                )
              : null,
        ),
        child: _showAddForm.value
            ? _buildAddValueForm()
            : _buildFormPlaceholder(),
      ),
    );
  }

  Widget _buildFormPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 64,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Add New Value',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click "Add Value" to create a new attribute value',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddValueForm() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Value',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            if (widget.attributeType == 'color')
              _buildColorValueForm()
            else if (widget.attributeType == 'size')
              _buildSizeValueForm()
            else
              _buildGenericValueForm(),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed: _isAddingValue.value ? null : _addValue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isAddingValue.value
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Adding...'),
                          ],
                        )
                      : const Text('Add Value'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorValueForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField(
          controller: _labelController,
          label: 'Color Name',
          hint: 'e.g., Midnight Blue, Forest Green',
          icon: Icons.label_outlined,
          validator: (value) =>
              value?.isEmpty == true ? 'Color name is required' : null,
        ),
        const SizedBox(height: 24),

        // Color Picker Section
        const Text(
          'Color Swatch',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),

        Obx(
          () => Container(
            padding: const EdgeInsets.all(16),
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
            child: Column(
              children: [
                // Color preview and hex input
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _selectedColor.value.isNotEmpty
                            ? _parseColor(_selectedColor.value)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _swatchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: '#FF5733 or color name',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          if (value.startsWith('#') && value.length == 7) {
                            _selectedColor.value = value;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                            '#FF5733',
                            '#33FF57',
                            '#3357FF',
                            '#FF33F5',
                            '#F5FF33',
                            '#FF8C33',
                            '#8C33FF',
                            '#33FFF5',
                            '#FF3333',
                            '#33FF33',
                            '#000000',
                            '#FFFFFF',
                            '#808080',
                            '#FF69B4',
                            '#00CED1',
                          ]
                          .map(
                            (color) => GestureDetector(
                              onTap: () {
                                _selectedColor.value = color;
                                _swatchController.text = color;
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: _parseColor(color),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _selectedColor.value == color
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeValueForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField(
          controller: _labelController,
          label: 'Size Label',
          hint: 'e.g., Small, Medium, Large',
          icon: Icons.label_outlined,
          validator: (value) =>
              value?.isEmpty == true ? 'Size label is required' : null,
        ),
        const SizedBox(height: 24),

        _buildInputField(
          controller: _valueController,
          label: 'Size Code (Optional)',
          hint: 'e.g., S, M, L, XL',
          icon: Icons.code_outlined,
        ),
        const SizedBox(height: 24),

        // Quick size buttons
        const Text(
          'Quick Add',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL']
              .map(
                (size) => InkWell(
                  onTap: () {
                    _labelController.text = size;
                    _valueController.text = size;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    child: Text(
                      size,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildGenericValueForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField(
          controller: _labelController,
          label: 'Display Label',
          hint: 'Label shown to users',
          icon: Icons.label_outlined,
          validator: (value) =>
              value?.isEmpty == true ? 'Label is required' : null,
        ),
        const SizedBox(height: 24),

        _buildInputField(
          controller: _valueController,
          label: 'Internal Value (Optional)',
          hint: 'Internal system value',
          icon: Icons.code_outlined,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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
            style: const TextStyle(color: Colors.blueAccent),
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              prefixIcon: Icon(icon, color: const Color(0xFF6366F1), size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _addValue() async {
    if (!_formKey.currentState!.validate()) return;

    _isAddingValue.value = true;

    try {
      final label = _labelController.text.trim();
      final value = _valueController.text.trim().isEmpty
          ? label
          : _valueController.text.trim();

      // Create Meta object if we have a swatch
      Meta? meta;
      if (widget.attributeType == 'color' && _selectedColor.value.isNotEmpty) {
        meta = Meta(swatch: _selectedColor.value);
      }

      await controller.addValueToAttribute(
        widget.attributeId,
        label,
        value,
        meta,
      );

      // Clear form and refresh values
      _clearForm();
      await controller.loadValues(widget.attributeId);
      _showAddForm.value = false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add value: $e');
    } finally {
      _isAddingValue.value = false;
    }
  }

  void _clearForm() {
    _labelController.clear();
    _valueController.clear();
    _swatchController.clear();
    _selectedColor.value = '';
  }

  Future<void> _confirmDeleteValue(dynamic value) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Delete Value',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${value.label ?? value.value}"? This cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await controller.deleteValue(widget.attributeId, value.id);
      } catch (e) {
        Get.snackbar('Error', 'Failed to delete value: $e');
      }
    }
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'color':
        return Colors.purple;
      case 'size':
        return Colors.orange;
      case 'select':
        return Colors.blue;
      case 'text':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'color':
        return Icons.palette;
      case 'size':
        return Icons.straighten;
      case 'select':
        return Icons.list;
      case 'text':
        return Icons.text_fields;
      default:
        return Icons.category;
    }
  }

  String _formatType(String type) {
    return type[0].toUpperCase() + type.substring(1);
  }
}
