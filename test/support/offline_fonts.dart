import 'package:flutter/services.dart';

/// Exercise production typography instead of unreadable Ahem test glyphs.
Future<void> loadOfflineFonts() async {
  for (final family in ['Outfit', 'Inter']) {
    final loader = FontLoader(family);
    for (final weight in [400, 500, 600, 700, 800, 900]) {
      loader.addFont(rootBundle.load('assets/fonts/$family-$weight.ttf'));
    }
    await loader.load();
  }
  final display = FontLoader('BarlowCondensed');
  for (final weight in ['SemiBold', 'Bold', 'ExtraBold', 'Black']) {
    display
        .addFont(rootBundle.load('assets/fonts/BarlowCondensed-$weight.ttf'));
  }
  await display.load();
  await (FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
      .load();
}
