import 'package:dashboard_admin/controllers/product_controller.dart';
import 'package:dashboard_admin/core/utils/custom_toast_noti.dart';
import 'package:dashboard_admin/models/category_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:toastification/toastification.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductController _productController = Get.find();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F2B),
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1900),
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF171A3B),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _productController.toggleChange(0),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(77),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.arrowLeft,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Center(
                      child: Obx(
                        () => Text(
                          _productController.isCreatingProduct.value
                              ? 'Create Product'
                              : 'Update Product',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 20,
                            children: [
                              // Product Name
                              buildLabel('Product Name *'),
                              buildTextField(
                                _productController.productNameController,
                                'Enter product name',
                                isRequired: true,
                              ),

                              // Description
                              buildLabel('Description'),
                              buildTextField(
                                _productController.descriptionController,
                                'Enter description',
                                maxLines: 4,
                                isRequired: false,
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildLabel('Price *'),
                                        buildTextField(
                                          _productController.priceController,
                                          'Enter price',
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          isRequired: true,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Price is required';
                                            }
                                            final price = double.tryParse(
                                              value,
                                            );
                                            if (price == null || price <= 0) {
                                              return 'Enter valid price > 0';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildLabel('Stock *'),
                                        buildTextField(
                                          _productController.stockController,
                                          'Enter stock',
                                          keyboardType: TextInputType.number,
                                          isRequired: true,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Stock is required';
                                            }
                                            final stock = int.tryParse(value);
                                            if (stock == null || stock < 0) {
                                              return 'Enter valid stock >= 0';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Category
                              buildLabel('Category *'),
                              Obx(() {
                                if (_productController
                                    .categoryController
                                    .isLoading) {
                                  return Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(40),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                return DropdownButtonFormField<CategoryModel>(
                                  items: _productController.categoryList.map((
                                    category,
                                  ) {
                                    return DropdownMenuItem<CategoryModel>(
                                      value: category,
                                      child: Text(
                                        category.name ?? 'No Name',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }).toList(),

                                  value:
                                      _productController.selectedCategory.value,

                                  onChanged: (newValue) {
                                    _productController.selectedCategory.value =
                                        newValue;
                                  },

                                  hint: const Text(
                                    'Select a category',
                                    style: TextStyle(color: Colors.white70),
                                  ),

                                  decoration: inputDecoration(
                                    hintText: 'Select a category',
                                  ),
                                  dropdownColor: const Color(0xFF171A3B),

                                  validator: (value) => value == null
                                      ? 'Please select a category'
                                      : null,
                                );
                              }),

                              // Brand
                              buildLabel('Brand *'),
                              buildTextField(
                                _productController.brandController,
                                'Enter brand',
                                isRequired: true,
                              ),

                              const SizedBox(height: 30),

                              Obx(() {
                                final isCreating =
                                    _productController.isCreatingProduct.value;

                                return SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isCreating
                                          ? Colors.grey
                                          : const Color(0xFF4F46E5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 6,
                                      shadowColor: Colors.deepPurpleAccent,
                                    ),
                                    onPressed: isCreating
                                        ? null
                                        : () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              if (_productController
                                                      .pickedImageBytesList
                                                      .isEmpty &&
                                                  _productController
                                                      .pickedImageFiles
                                                      .isEmpty) {
                                                Get.snackbar(
                                                  'Missing Images',
                                                  'Please select at least one product image',
                                                  backgroundColor:
                                                      Colors.orange,
                                                  colorText: Colors.white,
                                                );
                                                CustomToastNoti.show(
                                                  context: context,
                                                  title: 'Missing Image',
                                                  description:
                                                      'Please select at least one product image',
                                                  type:
                                                      ToastificationType.error,
                                                );
                                                return;
                                              }
                                              if (_productController
                                                  .isEditing
                                                  .value) {
                                                await _productController
                                                    .updateProduct();
                                                return;
                                              } else {
                                                await _productController
                                                    .uploadProduct(context);
                                              }
                                            }
                                          },
                                    child: _productController.isSaving.value
                                        ? CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : Text(
                                            _productController.isEditing.value
                                                ? 'Update Product'
                                                : 'Create Product',
                                          ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),

                        const SizedBox(width: 40),
                        buildImageSection(),
                        // Expanded(
                        //   flex: 1,
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.stretch,
                        //     children: [
                        //       buildLabel('Product Images *'),
                        //       const SizedBox(height: 10),

                        //       SizedBox(
                        //         height: context.height * 0.5,
                        //         child: Obx(() {
                        //           final bool hasImages =
                        //               _productController
                        //                   .pickedImageBytesList
                        //                   .isNotEmpty ||
                        //               _productController
                        //                   .pickedImageFiles
                        //                   .isNotEmpty;

                        //           return Container(
                        //             decoration: BoxDecoration(
                        //               color: Colors.white.withAlpha(20),
                        //               borderRadius: BorderRadius.circular(16),
                        //               border: Border.all(color: Colors.white24),
                        //             ),
                        //             child: hasImages
                        //                 ? GridView.builder(
                        //                     padding: const EdgeInsets.all(8),
                        //                     gridDelegate:
                        //                         const SliverGridDelegateWithFixedCrossAxisCount(
                        //                           crossAxisCount: 2,
                        //                           crossAxisSpacing: 8,
                        //                           mainAxisSpacing: 8,
                        //                         ),
                        //                     itemCount: kIsWeb
                        //                         ? _productController
                        //                               .pickedImageBytesList
                        //                               .length
                        //                         : _productController
                        //                               .pickedImageFiles
                        //                               .length,
                        //                     itemBuilder: (context, index) {
                        //                       return ClipRRect(
                        //                         borderRadius:
                        //                             BorderRadius.circular(8),
                        //                         child: Stack(
                        //                           alignment: Alignment.topRight,
                        //                           children: [
                        //                             kIsWeb
                        //                                 ? Image.memory(
                        //                                     _productController
                        //                                         .pickedImageBytesList[index],
                        //                                     fit: BoxFit.cover,
                        //                                     width:
                        //                                         double.infinity,
                        //                                     height:
                        //                                         double.infinity,
                        //                                   )
                        //                                 : Image.file(
                        //                                     _productController
                        //                                         .pickedImageFiles[index],
                        //                                     fit: BoxFit.cover,
                        //                                     width:
                        //                                         double.infinity,
                        //                                     height:
                        //                                         double.infinity,
                        //                                   ),
                        //                             Container(
                        //                               margin:
                        //                                   const EdgeInsets.all(
                        //                                     4,
                        //                                   ),
                        //                               decoration: BoxDecoration(
                        //                                 color: Colors.black54,
                        //                                 borderRadius:
                        //                                     BorderRadius.circular(
                        //                                       12,
                        //                                     ),
                        //                               ),
                        //                               child: IconButton(
                        //                                 icon: const Icon(
                        //                                   Icons.close,
                        //                                   color: Colors.white,
                        //                                   size: 16,
                        //                                 ),
                        //                                 onPressed: () =>
                        //                                     _productController
                        //                                         .removeImage(
                        //                                           index,
                        //                                         ),
                        //                               ),
                        //                             ),
                        //                           ],
                        //                         ),
                        //                       );
                        //                     },
                        //                   )
                        //                 : Center(
                        //                     child: Column(
                        //                       mainAxisAlignment:
                        //                           MainAxisAlignment.center,
                        //                       children: [
                        //                         Icon(
                        //                           LucideIcons.imagePlus,
                        //                           size: 64,
                        //                           color: Colors.white
                        //                               .withValues(alpha: 0.5),
                        //                         ),
                        //                         const SizedBox(height: 16),
                        //                         Text(
                        //                           'No Images Selected',
                        //                           style: TextStyle(
                        //                             color: Colors.white
                        //                                 .withValues(alpha: 0.7),
                        //                             fontSize: 16,
                        //                           ),
                        //                         ),
                        //                         const SizedBox(height: 8),
                        //                         Text(
                        //                           'Click below to add images',
                        //                           style: TextStyle(
                        //                             color: Colors.white
                        //                                 .withValues(alpha: 0.5),
                        //                             fontSize: 14,
                        //                           ),
                        //                         ),
                        //                       ],
                        //                     ),
                        //                   ),
                        //           );
                        //         }),
                        //       ),

                        //       const SizedBox(height: 20),

                        //       // Upload button
                        //       ElevatedButton.icon(
                        //         onPressed: _productController.pickImages,
                        //         icon: const Icon(
                        //           Icons.upload,
                        //           color: Colors.white,
                        //         ),
                        //         label: const Text(
                        //           'Upload Images',
                        //           style: TextStyle(color: Colors.white),
                        //         ),
                        //         style: ElevatedButton.styleFrom(
                        //           backgroundColor: const Color(0xFF4F46E5),
                        //           padding: const EdgeInsets.symmetric(
                        //             vertical: 16,
                        //           ),
                        //         ),
                        //       ),

                        //       const SizedBox(height: 16),

                        //       // Image count and guidelines
                        //       Obx(() {
                        //         final imageCount = kIsWeb
                        //             ? _productController
                        //                   .pickedImageBytesList
                        //                   .length
                        //             : _productController
                        //                   .pickedImageFiles
                        //                   .length;

                        //         return Column(
                        //           children: [
                        //             if (imageCount > 0)
                        //               Text(
                        //                 '$imageCount image${imageCount > 1 ? 's' : ''} selected',
                        //                 style: const TextStyle(
                        //                   color: Colors.green,
                        //                   fontWeight: FontWeight.w500,
                        //                 ),
                        //               ),
                        //             const SizedBox(height: 8),
                        //             Text(
                        //               'Guidelines:\n• At least 1 image required\n• Max 5 images\n• JPG, PNG formats\n• Max 5MB per image',
                        //               style: TextStyle(
                        //                 color: Colors.white.withValues(
                        //                   alpha: 0.6,
                        //                 ),
                        //                 fontSize: 12,
                        //               ),
                        //               textAlign: TextAlign.center,
                        //             ),
                        //           ],
                        //         );
                        //       }),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// UI Helper Functions
  Widget buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget buildImageSection() {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildLabel(
            _productController.isEditing.value
                ? 'Product Images *'
                : 'Upload Images *',
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: context.height * 0.5,
            child: Obx(() {
              final hasExistingImages =
                  _productController.existingImageUrls.isNotEmpty;
              final hasNewImages =
                  _productController.pickedImageBytesList.isNotEmpty ||
                  _productController.pickedImageFiles.isNotEmpty;
              final hasAnyImages = hasExistingImages || hasNewImages;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: hasAnyImages
                    ? SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Existing images section
                            if (hasExistingImages) ...[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Current Images',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                itemCount:
                                    _productController.existingImageUrls.length,
                                itemBuilder: (context, index) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Image.network(
                                          _productController
                                              .existingImageUrls[index],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.error,
                                                  ),
                                                );
                                              },
                                        ),
                                        Container(
                                          margin: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withValues(
                                              alpha: 0.8,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            onPressed: () => _productController
                                                .removeExistingImage(index),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],

                            if (hasNewImages) ...[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'New Images',
                                  style: TextStyle(
                                    color: Colors.green.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                itemCount: kIsWeb
                                    ? _productController
                                          .pickedImageBytesList
                                          .length
                                    : _productController
                                          .pickedImageFiles
                                          .length,
                                itemBuilder: (context, index) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        kIsWeb
                                            ? Image.memory(
                                                _productController
                                                    .pickedImageBytesList[index],
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              )
                                            : Image.file(
                                                _productController
                                                    .pickedImageFiles[index],
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              ),
                                        Container(
                                          margin: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withValues(
                                              alpha: 0.8,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            onPressed: () => _productController
                                                .removeImage(index),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.imagePlus,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _productController.isEditing.value
                                  ? 'No Images Available'
                                  : 'No Images Selected',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Click below to add images',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Upload button
          ElevatedButton.icon(
            onPressed: _productController.pickImages,
            icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
            label: Text(
              _productController.isEditing.value
                  ? 'Add More Images'
                  : 'Upload Images',
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          const SizedBox(height: 16),

          Obx(() {
            final existingCount = _productController.existingImageUrls.length;
            final newCount = kIsWeb
                ? _productController.pickedImageBytesList.length
                : _productController.pickedImageFiles.length;
            final totalCount = existingCount + newCount;

            return Column(
              children: [
                if (totalCount > 0)
                  Text(
                    _productController.isEditing.value
                        ? '$existingCount existing + $newCount new = $totalCount total'
                        : '$newCount image${newCount > 1 ? 's' : ''} selected',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Guidelines:\n• At least 1 image required\n• Max 5 images total\n• JPG, PNG formats\n• Max 5MB per image',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String hintText, {
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator:
          validator ??
          (isRequired
              ? (value) => value == null || value.trim().isEmpty
                    ? 'This field is required'
                    : null
              : null),
      decoration: inputDecoration(hintText: hintText),
      style: const TextStyle(color: Colors.white, fontSize: 16),
    );
  }

  InputDecoration inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withAlpha(40),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}
