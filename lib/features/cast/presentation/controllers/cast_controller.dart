import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/models/cast_device.dart';
import '../../../../core/models/stream_item.dart';
import '../../domain/services/cast_service.dart';

/// Owns the casting session for the whole app.
///
/// Registered permanently: a cast survives navigation, so the "Casting to
/// Living Room TV" banner keeps its state as the user moves between the feed,
/// a stream and the library.
///
/// Discovery is a live stream, not a one-shot scan — receivers appear and
/// vanish as they wake and sleep — so the sheet stays in [CastState.searching]
/// until either a device shows up or [discoveryTimeout] elapses.
class CastController extends GetxController {
  CastController({required CastService castService}) : _service = castService;

  final CastService _service;

  /// How long to wait before declaring the network empty.
  static const Duration discoveryTimeout = Duration(seconds: 8);

  final Rx<CastState> state = CastState.idle.obs;
  final RxList<CastDevice> devices = <CastDevice>[].obs;
  final Rxn<CastDevice> connectedDevice = Rxn<CastDevice>();

  /// Whether the banner's remote panel is expanded.
  final RxBool remoteExpanded = false.obs;

  final RxBool isPaused = false.obs;
  final RxInt volume = 62.obs;

  /// Set when the connected stream is a web-only player that would need the
  /// relay — the banner says so rather than showing a dead transport.
  final RxBool isRelayPending = false.obs;

  StreamSubscription<List<CastDevice>>? _devicesSub;
  StreamSubscription<bool>? _connectionSub;
  Timer? _timeout;

  bool get isCasting => connectedDevice.value != null;

  bool get isSupported => _service.isSupported;

  @override
  void onInit() {
    super.onInit();
    _service.init();

    // The SDK can drop a session on its own — the receiver is switched off, or
    // another sender takes it over — so trust it, not our own last write.
    _connectionSub = _service.connectionStream().listen((connected) {
      if (!connected && isCasting) _clearSession();
    });
  }

  /// Opens the sheet and starts listening for receivers.
  Future<void> startDiscovery() async {
    state.value = CastState.searching;
    devices.clear();

    if (!isSupported) {
      state.value = CastState.notFound;
      return;
    }

    await _service.startDiscovery();

    _devicesSub?.cancel();
    _devicesSub = _service.devicesStream().listen((found) {
      devices.assignAll(found);
      if (found.isNotEmpty && state.value == CastState.searching) {
        _timeout?.cancel();
        state.value = CastState.found;
      }
    });

    _timeout?.cancel();
    _timeout = Timer(discoveryTimeout, () {
      if (state.value == CastState.searching) {
        state.value = devices.isEmpty ? CastState.notFound : CastState.found;
      }
    });
  }

  /// Connects to [device] and, when [item] is given, starts it playing there.
  Future<void> connect(CastDevice device, {StreamItem? item}) async {
    final ok = await _service.connect(device);
    if (!ok) {
      state.value = CastState.notFound;
      return;
    }

    connectedDevice.value = device;
    state.value = CastState.connected;
    isPaused.value = false;
    _stopDiscovery();

    if (item == null) return;
    isRelayPending.value = !await _service.loadOnReceiver(item);
  }

  /// Sends [item] to the already-connected receiver.
  Future<void> play(StreamItem item) async {
    if (!isCasting) return;
    isRelayPending.value = !await _service.loadOnReceiver(item);
  }

  /// How [item] can reach a receiver — drives the sheet's explanatory copy.
  CastAvailability availabilityFor(StreamItem item) =>
      _service.availabilityFor(item);

  Future<void> disconnect() async {
    await _service.disconnect();
    _clearSession();
  }

  void _clearSession() {
    connectedDevice.value = null;
    remoteExpanded.value = false;
    isRelayPending.value = false;
    state.value = CastState.idle;
  }

  /// Closes the sheet without tearing down an active session.
  void dismissSheet() {
    _stopDiscovery();
    if (!isCasting) state.value = CastState.idle;
  }

  void _stopDiscovery() {
    _timeout?.cancel();
    _devicesSub?.cancel();
    _devicesSub = null;
    // Scanning is expensive; stop as soon as the sheet is done with it.
    _service.stopDiscovery();
  }

  void toggleRemote() => remoteExpanded.toggle();

  Future<void> togglePlayPause() async {
    isPaused.toggle();
    await _service.setPaused(isPaused.value);
  }

  Future<void> setVolume(int value) async {
    volume.value = value;
    await _service.setVolume(value);
  }

  @override
  void onClose() {
    _timeout?.cancel();
    _devicesSub?.cancel();
    _connectionSub?.cancel();
    super.onClose();
  }
}
