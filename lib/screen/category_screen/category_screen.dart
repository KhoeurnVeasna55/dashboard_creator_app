import 'package:dashboard_admin/core/responsive.dart';
import 'package:dashboard_admin/controllers/category_controller.dart';
import 'package:dashboard_admin/screen/category_screen/category_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoryController controller = Get.put(CategoryController());
    final CategoryScreenController screeenController = Get.put(
      CategoryScreenController(),
    );
    return Scaffold(
      body: SafeArea(
        child: context.isMobile
            ? _buildMobileLayout(context, controller)
            : _buildDesktopLayout(context, controller, screeenController),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    CategoryController controller,
    CategoryScreenController screenController,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Categories', style: theme.textTheme.titleLarge),
              Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => screenController.toggleChange(1),
                    icon: Icon(LucideIcons.plus, color: Colors.white),
                    label: Text(
                      'Create',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Obx(() {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.categories.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }
        
          return Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.87,
                decoration: BoxDecoration(
                  color: Color(0xFF171A3B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    Colors.blueGrey.shade800,
                  ),
                  dataRowMaxHeight: 60,
                  columns: const [
                    DataColumn(label: Text('Image')),
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Slug')),
                    DataColumn(label: Text('Created At')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: [
                    ...controller.categories.map((category) {
                      return DataRow(
                        cells: [
                          DataCell(
                            (category.imageUrl?.isNotEmpty == true)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      category.imageUrl!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.category),
                          ),
                          DataCell(Text(category.id ?? '')),
                          DataCell(Text(category.name ?? '')),
                          DataCell(Text(category.slug ?? '')),
                          DataCell(
                            Text(
                              category.createdAt != null
                                  ? DateFormat(
                                      'yyyy-MM-dd HH:mm',
                                    ).format(category.createdAt!)
                                  : '',
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    controller.toggleChange(1);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          );
        }),
        
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    CategoryController controller,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.plus),
            label: const Text('Create New Category'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.categories.isEmpty) {
              return const Center(child: Text('No categories found.'));
            }
            return ListView.builder(
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: (category.imageUrl?.isNotEmpty == true)
                        ? Image.network(
                            category.imageUrl!,
                            width: 40,
                            height: 40,
                          )
                        : const Icon(Icons.category),
                    title: Text(category.name ?? ''),
                    subtitle: Text(category.slug ?? ''),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
