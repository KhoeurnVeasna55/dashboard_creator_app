// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:dashboard_admin/controllers/category_controller.dart';
import 'package:dashboard_admin/core/URL/url.dart';
import 'package:dashboard_admin/core/utils/custom_toast_noti.dart';
import 'package:dashboard_admin/models/category_model.dart';
import 'package:dashboard_admin/models/product_model.dart';
import 'package:dashboard_admin/services/product_service.dart';
import 'package:dashboard_admin/screen/products-screen/create_prdouct_screen.dart';
import 'package:dashboard_admin/screen/products-screen/product_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';

class ProductController extends GetxController {
  var productList = <ProductModel>[].obs;
  var isLoading = true.obs;

  final pickedImageFiles = <File>[].obs;
  final pickedImageBytesList = <Uint8List>[].obs;
  final pickedImageNames = <String>[].obs;
  final selectedCategory = Rx<CategoryModel?>(null);
  final isCreatingProduct = false.obs;

  final RxInt currentIndex = 0.obs;
  final screens = [ProductPage(), CreateProductScreen()];

  late TextEditingController productNameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController moreDetailsController;
  late TextEditingController brandController;
  late TextEditingController stockController;

  final CategoryController categoryController = Get.find<CategoryController>();
  List<CategoryModel> get categoryList => categoryController.categories;

  final isEditing = false.obs;
  final isSaving = false.obs;
  var editingProductId = Rxn<String>();
  final existingImageUrls = <String>[].obs;
  final imagesToDelete = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    productNameController = TextEditingController();
    descriptionController = TextEditingController();
    priceController = TextEditingController();
    brandController = TextEditingController();
    stockController = TextEditingController();
    moreDetailsController = TextEditingController();

    fetchAllProducts();

    ever(currentIndex, (index) {
      if (index == 0) {
        Future.delayed(const Duration(milliseconds: 100), () {
          fetchAllProducts();
        });
      }
    });
  }

  @override
  void onClose() {
    productNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    brandController.dispose();
    stockController.dispose();
    moreDetailsController.dispose();
    super.onClose();
  }

  void toggleChange(int index) {
    currentIndex.value = index;

    if (index == 0) {
      fetchAllProducts();
    }
  }

  void loadProductForEdit(ProductModel product) {
    isEditing.value = true;
    editingProductId.value = product.id;
    productNameController.text = product.name ?? '';
    descriptionController.text = product.description ?? '';
    priceController.text = product.price?.toString() ?? '';
    stockController.text = product.stock?.toString() ?? '';
    brandController.text = product.brand ?? '';
    selectedCategory.value = product.category;

    existingImageUrls.clear();
    existingImageUrls.addAll(product.imageUrls ?? []);

    pickedImageFiles.clear();
    pickedImageBytesList.clear();
    pickedImageNames.clear();

    currentIndex.value = 1;
  }

  void removeExistingImage(int index) {
    if (index < existingImageUrls.length) {
      final imageUrl = existingImageUrls[index];
      imagesToDelete.add(imageUrl);
      existingImageUrls.removeAt(index);
    }
  }

  Future<void> fetchAllProducts() async {
    try {
      isLoading(true);
      log(" Fetching products...");

      final productResponse = await ProductService.fetchAllProduct();
      log(" Got ${productResponse.length} products from API");

      productList.clear();
      productList.assignAll(productResponse);
      log(" Product list updated with ${productList.length} items");

      update();
    } catch (e) {
      log("❌ Error fetching products: $e");
      Get.snackbar('Error', 'Could not fetch products.');
    } finally {
      isLoading(false);
    }
  }

  Future<void> forceRefresh() async {
    await fetchAllProducts();
  }

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      pickedImageFiles.clear();
      pickedImageBytesList.clear();
      pickedImageNames.clear();

      for (var file in pickedFiles) {
        if (kIsWeb) {
          pickedImageBytesList.add(await file.readAsBytes());
          pickedImageNames.add(file.name);
        } else {
          pickedImageFiles.add(File(file.path));
        }
      }
    }
  }

  void removeImage(int index) {
    if (kIsWeb) {
      if (index < pickedImageBytesList.length) {
        pickedImageBytesList.removeAt(index);
        pickedImageNames.removeAt(index);
      }
    } else {
      if (index < pickedImageFiles.length) {
        pickedImageFiles.removeAt(index);
      }
    }
  }

  Future<void> uploadProduct(BuildContext context) async {
    if (productNameController.text.isEmpty ||
        priceController.text.isEmpty ||
        stockController.text.isEmpty ||
        brandController.text.isEmpty ||
        selectedCategory.value == null) {
      CustomToastNoti.show(
        context: context,
        title: 'Error',
        description: 'Please filed all the data',
        type: ToastificationType.error,
      );
      return;
    }

    final price = double.tryParse(priceController.text);
    final stock = int.tryParse(stockController.text);
    if (price == null || stock == null) {
      CustomToastNoti.show(
        context: context,
        title: 'Error',
        description: 'Price and Stock must be valid numbers.',
        type: ToastificationType.error,
      );
      return;
    }

    try {
      isCreatingProduct(true);
      log("🚀 Starting product upload...");

      final uri = Uri.parse('$URL/api/products');
      final request = http.MultipartRequest('POST', uri);

      if (kIsWeb && pickedImageBytesList.isNotEmpty) {
        for (int i = 0; i < pickedImageBytesList.length; i++) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'images',
              pickedImageBytesList[i],
              filename: pickedImageNames[i],
            ),
          );
        }
      } else if (!kIsWeb && pickedImageFiles.isNotEmpty) {
        for (var file in pickedImageFiles) {
          request.files.add(
            await http.MultipartFile.fromPath('images', file.path),
          );
        }
      }

      request.fields['name'] = productNameController.text;
      request.fields['description'] = descriptionController.text;
      request.fields['price'] = price.toString();
      request.fields['moreDetails'] = moreDetailsController.text;
      request.fields['categoryId'] = selectedCategory.value!.id!;
      request.fields['brand'] = brandController.text;
      request.fields['stock'] = stock.toString();

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        log("✅ Product created successfully");

        _clearForm();

        await fetchAllProducts();

        toggleChange(0);

        CustomToastNoti.show(
          title: 'Success!',
          context: context,
          description: 'Product created and added to list!',
          type: ToastificationType.success,
        );

        log("🎉 Product creation flow completed");
      } else {
        CustomToastNoti.show(
          context: context,
          title: 'Error',
          description: 'Something went wrong.',
          type: ToastificationType.error,
        );
        log('Failed to create product: ${response.statusCode} - $respStr');
      }
    } catch (e) {
      CustomToastNoti.show(
        context: context,
        title: 'Error',
        description: 'Unexpected error: $e',
        type: ToastificationType.error,
      );
      log('Error uploading product: $e');
    } finally {
      isCreatingProduct(false);
    }
  }

  void _clearForm() {
    productNameController.clear();
    descriptionController.clear();
    priceController.clear();
    moreDetailsController.clear();
    brandController.clear();
    stockController.clear();
    selectedCategory.value = null;
    pickedImageFiles.clear();
    pickedImageBytesList.clear();
    pickedImageNames.clear();
    existingImageUrls.clear();
    imagesToDelete.clear();
    isEditing.value = false;
    editingProductId.value = null;
  }

  Future<bool?> deleteProduct(String productId, BuildContext context) async {
    try {
      isLoading(true);
      await ProductService().deleteProduct(productId);
      productList.removeWhere((product) => product.id == productId);
      update();

      CustomToastNoti.show(
        title: 'Success!',
        context: context,
        description: 'Product was deleted successfully.',
        type: ToastificationType.success,
      );
      return true;
    } catch (e) {
      log("Error deleting product: $e");
      CustomToastNoti.show(
        context: context,
        title: 'Error',
        description: 'Could not delete product.',
        type: ToastificationType.error,
      );
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateProduct() async {
    if (editingProductId.value == null ||
        productNameController.text.isEmpty ||
        selectedCategory.value == null) {
      Get.snackbar('Error', 'Product Name and Category are required.');
      return;
    }

    // Check if we have at least one image (existing or new)
    final hasImages =
        existingImageUrls.isNotEmpty ||
        pickedImageBytesList.isNotEmpty ||
        pickedImageFiles.isNotEmpty;

    if (!hasImages) {
      Get.snackbar('Error', 'At least one image is required.');
      return;
    }

    try {
      isSaving(true);
      log("🔄 Starting product update for ID: ${editingProductId.value}");

      final uri = Uri.parse('$URL/api/products/${editingProductId.value}');
      final request = http.MultipartRequest('PUT', uri);

      // Add form fields
      request.fields['name'] = productNameController.text;
      request.fields['description'] = descriptionController.text;
      request.fields['price'] = priceController.text;
      request.fields['stock'] = stockController.text;
      request.fields['brand'] = brandController.text;
      request.fields['categoryId'] = selectedCategory.value!.id!;

      // ✅ Send existing images that should be kept
      if (existingImageUrls.isNotEmpty) {
        request.fields['existingImages'] = existingImageUrls.join(',');
      }

      // ✅ Add new image files if any
      if (kIsWeb && pickedImageBytesList.isNotEmpty) {
        log("📸 Adding ${pickedImageBytesList.length} new images");
        for (int i = 0; i < pickedImageBytesList.length; i++) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'images', // ✅ Use 'images' to match API
              pickedImageBytesList[i],
              filename: pickedImageNames[i],
            ),
          );
        }
      } else if (!kIsWeb && pickedImageFiles.isNotEmpty) {
        log("📸 Adding ${pickedImageFiles.length} new images");
        for (var file in pickedImageFiles) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'images', // ✅ Use 'images' to match API
              file.path,
            ),
          );
        }
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        log("✅ Product updated successfully");

        _clearForm();
        await fetchAllProducts();
        toggleChange(0);

        Get.snackbar(
          'Success',
          'Product updated successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        log('❌ Failed to update product: ${response.statusCode} - $respStr');
        Get.snackbar(
          'Error',
          'Failed to update product: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log('💥 Update product error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving(false);
    }
  }
}
