import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/models/stream_item.dart';
import '../../../../core/routes/app_routes.dart';
import '../../domain/services/explore_service.dart';

/// State for the Explore tab.
class ExploreController extends GetxController {
  ExploreController({required ExploreService exploreService})
    : _service = exploreService;

  final ExploreService _service;

  final TextEditingController searchController = TextEditingController();

  final Rxn<StreamPlatform> platform = Rxn<StreamPlatform>();
  final RxList<StreamItem> results = <StreamItem>[].obs;
  final RxBool isLoading = false.obs;

  /// Debounces keystrokes so a fast typist doesn't fire a query per character.
  Timer? _debounce;
  static const Duration _debounceDelay = Duration(milliseconds: 260);

  List<StreamPlatform?> get filters => ExploreService.filters;

  String get resultsTitle => _service.resultsTitle(platform.value);

  /// "11 items" — the count beside the results heading.
  String get countLabel {
    final n = results.length;
    return '$n item${n == 1 ? '' : 's'}';
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onQueryChanged);
    search();
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, search);
  }

  void selectPlatform(StreamPlatform? next) {
    platform.value = next;
    search();
  }

  Future<void> search() async {
    isLoading.value = true;
    final found = await _service.search(
      query: searchController.text,
      platform: platform.value,
    );
    results.assignAll(found);
    isLoading.value = false;
  }

  void openStream(StreamItem item) =>
      Get.toNamed(AppRoutes.watch, arguments: item);

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
