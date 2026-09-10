import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/models/stream_item.dart';
import '../../domain/services/link_parser_service.dart';

/// Drives the Add-to-Feed sheet.
class AddLinkController extends GetxController {
  AddLinkController({required LinkParserService linkParserService})
    : _service = linkParserService;

  final LinkParserService _service;

  final TextEditingController urlController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController channelController = TextEditingController();

  /// The platform detected from the pasted URL, null when unrecognised.
  final Rxn<StreamPlatform> platform = Rxn<StreamPlatform>();

  final RxBool isSaving = false.obs;

  /// True when all three fields are filled and the URL is recognised.
  final RxBool canSubmit = false.obs;

  @override
  void onInit() {
    super.onInit();
    urlController.addListener(_onChanged);
    titleController.addListener(_onChanged);
    channelController.addListener(_onChanged);
  }

  void _onChanged() {
    platform.value = _service.detect(urlController.text);
    canSubmit.value =
        platform.value != null &&
        titleController.text.trim().isNotEmpty &&
        channelController.text.trim().isNotEmpty;
  }

  /// Chip label under the URL field.
  String get detectionLabel => platform.value?.label ?? 'no link detected';

  /// Helper copy explaining how this link will play.
  String get playbackNote => _service.playbackNote(platform.value);

  Future<StreamItem?> submit() async {
    if (!canSubmit.value || isSaving.value) return null;
    isSaving.value = true;
    try {
      return await _service.add(
        url: urlController.text,
        title: titleController.text,
        channelName: channelController.text,
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    urlController.dispose();
    titleController.dispose();
    channelController.dispose();
    super.onClose();
  }
}
