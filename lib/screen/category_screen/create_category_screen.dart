import 'package:dashboard_admin/core/responsive.dart';
import 'package:dashboard_admin/screen/category_screen/category_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CreateCategoryScreen extends StatelessWidget {
  CreateCategoryScreen({super.key});
  final CategoryScreenController screenController =
      Get.find<CategoryScreenController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (context.isMobile) {
              return _buildMobileLayout(context, screenController);
            } else {
              return _buildDesktopLayout(context, screenController);
            }
          },
        ),
      ),
    );
  }
}

Widget _buildDesktopLayout(
  BuildContext context,
  CategoryScreenController screenController,
) {
  return Container(
    constraints: const BoxConstraints(maxWidth: 1900),
    padding: const EdgeInsets.all(24),
    margin: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF171A3B),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: SingleChildScrollView(
      child: GetBuilder<CategoryScreenController>(
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => screenController.toggleChange(0),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(77),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Center(
                    child: Text(
                      'Create Category',
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Save Category'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// 3. ADDED: A placeholder layout for mobile.
Widget _buildMobileLayout(
  BuildContext context,
  CategoryScreenController screenController,
) {
  return _buildDesktopLayout(context, screenController);
}
