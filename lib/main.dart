import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';
import 'core/di/dependency_injection.dart';
import 'core/services/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CacheService().init();
  await DependencyInjection.init();

  // Roboto Condensed (wordmark, section headers) and JetBrains Mono (the
  // `// signal:live` tags) come from google_fonts. Pre-warm them so the splash
  // doesn't render its wordmark in a fallback face on first launch; if the
  // device is offline the fallback stack is used and the app still runs.
  GoogleFonts.config.allowRuntimeFetching = true;
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.robotoCondensed(),
      GoogleFonts.jetBrainsMono(),
    ]);
  } catch (e) {
    debugPrint('Font pre-caching failed: $e');
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // The app is dark-only — light status bar icons on every screen.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(const StreamCastApp());
}
