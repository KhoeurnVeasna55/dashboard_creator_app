import 'package:dashboard_admin/controllers/product_controller.dart';
import 'package:dashboard_admin/core/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../models/product_model.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ProductController productController = Get.find();

    final List headerTabel = [
      'Image',
      'ID',
      'Title',
      'Price',
      'Stock',
      'Categoty',
      'Brand',
      'Cateted At',
      'Actions',
    ];

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = context.isMobile;

          return SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),

                  isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            TextField(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Theme.of(context).canvasColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: 'Search',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: theme.iconTheme.color,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(LucideIcons.plus),
                                    label: SelectableText(
                                      'Create',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(LucideIcons.download),
                                    label: const SelectableText('Excel'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SelectableText(
                                'Products',
                                style: theme.textTheme.titleLarge,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: constraints.maxWidth * 0.2,
                                    height: 50,
                                    child: TextField(
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Theme.of(
                                          context,
                                        ).canvasColor,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        hintText: 'Search',
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: theme.iconTheme.color,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      productController.toggleChange(1);
                                    },
                                    icon: Icon(
                                      LucideIcons.plus,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      'Create',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: Icon(
                                      LucideIcons.download,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      'Excel',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                  const SizedBox(height: 20),
                  Expanded(
                    child: isMobile
                        ? Obx(() {
                            final products = productController.productList;
                            return ListView.builder(
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: ListTile(
                                    title: SelectableText(product.name ?? ''),
                                    subtitle: SelectableText(
                                      'Category: ${product.category}\nPrice: \$${product.price} | Stock: ${product.stock} | Brand: ${product.brand} | Created: ${product.createdAt?.toLocal().toIso8601String()} | Updated: ${product.updatedAt?.toLocal().toIso8601String()}',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () {},
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
                                );
                              },
                            );
                          })
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.87,
                                decoration: BoxDecoration(
                                  color: Color(0xFF171A3B),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Obx(() {
                                  if (productController.isLoading.isTrue) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  final data = productController.productList;
                                  if (data.isEmpty) {
                                    return const Center(
                                      child: SelectableText(
                                        'No products found.',
                                      ),
                                    );
                                  }

                                  final productdata = data.map((product) {
                                    return ProductModel(
                                      id: product.id,
                                      name: product.name,
                                      description: product.description,
                                      price: product.price,
                                      brand: product.brand,
                                      imageUrls: product.imageUrls,
                                      stock: product.stock,
                                      category: product.category,
                                      createdAt: product.createdAt,
                                      updatedAt: product.updatedAt,
                                    );
                                  }).toList();

                                  return DataTable(
                                    columnSpacing: 20,
                                    columns: headerTabel
                                        .map(
                                          (title) => DataColumn(
                                            label: SelectableText(title),
                                          ),
                                        )
                                        .toList(),
                                    rows: productdata.map<DataRow>((product) {
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            (product.imageUrls?.isNotEmpty ==
                                                    true)
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4.0,
                                                        ),
                                                    child: Image.network(
                                                      product.imageUrls!.first,
                                                      width: 40,
                                                      height: 40,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return const Icon(
                                                              Icons
                                                                  .image_not_supported,
                                                            );
                                                          },
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.image_not_supported,
                                                  ),
                                          ),
                                          DataCell(
                                            SelectableText(
                                              product.id?.toString() ?? '',
                                            ),
                                          ),
                                          DataCell(
                                            SelectableText(product.name ?? ''),
                                          ),
                                          DataCell(
                                            SelectableText(
                                              product.price?.toStringAsFixed(
                                                    2,
                                                  ) ??
                                                  '0.00',
                                            ),
                                          ),
                                          DataCell(
                                            SelectableText(
                                              product.stock.toString(),
                                            ),
                                          ),
                                          DataCell(
                                            SelectableText(
                                              product.category!.name.toString(),
                                            ),
                                          ),

                                          DataCell(
                                            SelectableText(
                                              product.brand ?? 'Unknown',
                                            ),
                                          ),
                                          DataCell(
                                            SelectableText(
                                              product.createdAt != null
                                                  ? product.createdAt!
                                                        .toLocal()
                                                        .toIso8601String()
                                                  : 'Unknown',
                                            ),
                                          ),

                                          // DataCell(
                                          //   SelectableText(
                                          //     product.brand?.name ?? 'Unknown',
                                          //   ),
                                          // ),
                                          // DataCell(
                                          //   SelectableText(
                                          //     product.isActive == true
                                          //         ? 'Yes'
                                          //         : 'No',
                                          //   ),
                                          // ),
                                          DataCell(
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    color: Colors.blue,
                                                  ),
                                                  onPressed: () {
                                                    productController
                                                        .loadProductForEdit(
                                                          product,
                                                        );
                                                    
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () async {
                                                    _showDialog(
                                                      context,
                                                      'Are you sure that you want to delete this Product',
                                                      () {
                                                        Get.back();
                                                      },
                                                      () async {
                                                        final bool?
                                                        sucessDelete =
                                                            await productController
                                                                .deleteProduct(
                                                                  product.id!,
                                                                  context,
                                                                );
                                                        if (sucessDelete ==
                                                            true) {
                                                          await Future.delayed(
                                                            const Duration(
                                                              milliseconds: 500,
                                                            ),
                                                          );
                                                          Get.back();
                                                          await productController
                                                              .fetchAllProducts();
                                                        }
                                                      },
                                                    );
                                                    // productController
                                                    //     .deleteProduct(
                                                    //       product.id!,
                                                    //       context,
                                                    //     );
                                                    // await productController
                                                    //     .fetchAllProducts();
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  );
                                }),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void _showDialog(
  BuildContext context,
  String message,
  VoidCallback? onPressed1,
  VoidCallback? onPressed2,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmation'),
      content: Text(message),
      actions: [
        TextButton(onPressed: onPressed1, child: const Text('Cancel')),
        ElevatedButton(onPressed: onPressed2, child: const Text('Confirm')),
      ],
    ),
  );
}
