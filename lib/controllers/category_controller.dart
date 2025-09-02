import 'dart:developer';
import 'dart:io';

import 'package:dashboard_admin/models/category_model.dart';
import 'package:dashboard_admin/screen/category_screen/category_screen.dart';
import 'package:dashboard_admin/screen/category_screen/create_category_screen.dart';
import 'package:dashboard_admin/services/category_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  final _categories = <CategoryModel>[].obs;
  final _isLoading = false.obs;
  final _isLoadingMore = false.obs;
  final _currentPage = 1.obs;
  final _totalPages = 1.obs;
  final _totalCategories = 0.obs;
  final _searchQuery = ''.obs;
  final _activeFilter = Rxn<bool>();
  final _error = ''.obs;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  int get totalCategories => _totalCategories.value;
  String get searchQuery => _searchQuery.value;
  bool? get activeFilter => _activeFilter.value;
  String get error => _error.value;
  bool get hasMorePages => _currentPage.value < _totalPages.value;
  bool get hasCategories => _categories.isNotEmpty;
  bool get hasError => _error.value.isNotEmpty;

  final _categoryService = CategoryService();

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final RxInt pageIndex = 0.obs;
  final screen = [CategoryScreen(), CreateCategoryScreen()];

  @override
  void onInit() {
    super.onInit();
    loadData();

    scrollController.addListener(_onScroll);
    debounce(
      _searchQuery,
      (_) => _performSearch(),
      time: Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (hasMorePages && !isLoading && !isLoadingMore) {
        loadMoreData();
      }
    }
  }

  void toggleChange(int index) {
    pageIndex.value = index;
  }

  void loadData({bool showLoading = true}) async {
    try {
      if (showLoading) {
        _isLoading.value = true;
      }
      _error.value = '';

      final response = await _categoryService.getAllCategories(
        1,
        10,
        _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
        _activeFilter.value,
      );

      if (response != null) {
        log("Total pages available: ${response.pages}");
        log("Total items found: ${response.total}");

        _categories.value = response.items ?? [];
        _currentPage.value = response.page ?? 1;
        _totalPages.value = response.pages ?? 1;
        _totalCategories.value = response.total ?? 0;

        if (response.items != null) {
          for (var category in response.items!) {
            log("- ${category.name}");
          }
        }
      } else {
        _error.value = "Could not fetch categories.";
        log("Could not fetch categories.");
      }
    } catch (e) {
      _error.value = e.toString();
      log('Error in loadData: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void loadMoreData() async {
    if (!hasMorePages || _isLoadingMore.value) return;

    try {
      _isLoadingMore.value = true;

      final response = await _categoryService.getAllCategories(
        _currentPage.value + 1,
        10,
        _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
        _activeFilter.value,
      );

      if (response != null && response.items != null) {
        _categories.addAll(response.items!);
        _currentPage.value = response.page ?? _currentPage.value;
        _totalPages.value = response.pages ?? _totalPages.value;
        _totalCategories.value = response.total ?? _totalCategories.value;

        log(
          "Loaded page ${response.page}, total items now: ${_categories.length}",
        );
      }
    } catch (e) {
      log('Error in loadMoreData: $e');
      Get.snackbar(
        'Error',
        'Failed to load more categories',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoadingMore.value = false;
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    _currentPage.value = 1;
    loadData(showLoading: false);
  }

  // Search functionality
  void onSearchChanged(String query) {
    _searchQuery.value = query;
  }

  void _performSearch() {
    _currentPage.value = 1;
    loadData();
  }

  void clearSearch() {
    searchController.clear();
    _searchQuery.value = '';
  }

  // Filter functionality
  void setActiveFilter(bool? isActive) {
    _activeFilter.value = isActive;
    _currentPage.value = 1;
    loadData();
  }

  // Retry functionality
  void retry() {
    loadData();
  }

  // Create category with image upload
  Future<void> createCategoryWithImage({
    required String name,
    required String description,
    required bool isActive,
    File? imageFile,
  }) async {
    try {
      _isLoading.value = true;
      String? imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _categoryService.uploadImage(imageFile, 'categories');
        if (imageUrl == null) {
          throw Exception('Failed to upload image');
        }
      }

      // Create category
      final category = await _categoryService.createCategory(
        name,
        description,
        isActive,
        imageUrl,
      );

      if (category != null) {
        // Add to the beginning of the list
        _categories.insert(0, category);
        _totalCategories.value++;

        Get.snackbar(
          'Success',
          'Category created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        log('Category created: ${category.name}');
      } else {
        throw Exception('Failed to create category');
      }
    } catch (e) {
      log('Error creating category: $e');
      Get.snackbar(
        'Error',
        'Failed to create category: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Pick and preview image
  Future<File?> pickImage() async {
    return await _categoryService.pickImage();
  }

  // Navigate to category details
  void goToCategoryDetails(CategoryModel category) {
    Get.toNamed('/category-details', arguments: category);
  }
}
