import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../widgets/resin_ui.dart';
import 'support_screens.dart';

class BlockMergeSettingsScreen extends StatelessWidget {
  const BlockMergeSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = Get.find<BlockMergeSettingsController>();
    Widget toggle(String title, String subtitle, bool value,
            ValueChanged<bool> change) =>
        SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            title: Text(title, style: resinText(18)),
            subtitle:
                Text(subtitle, style: resinText(14, weight: FontWeight.w600)),
            value: value,
            onChanged: change,
            activeThumbColor: resinInk,
            activeTrackColor: resinMint);
    return ResinPage(
        child: ListView(padding: const EdgeInsets.all(16), children: [
      ResinHeader('SETTINGS', back: () => Get.back()),
      const SizedBox(height: 12),
      const ResinArt('objects', height: 130),
      const SizedBox(height: 8),
      ResinSurface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('PLAY FEEDBACK', style: resinText(17)),
        const SizedBox(height: 8),
        Obx(() => toggle('Sound effects', 'Soft cues for slides and merges.',
            s.soundEnabled.value, s.setSoundEnabled)),
        const Divider(),
        Obx(() => toggle('Haptics', 'A gentle touch of feedback.',
            s.vibrationEnabled.value, s.setVibrationEnabled)),
      ])),
      const SizedBox(height: 16),
      ResinSurface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('GUIDANCE', style: resinText(17)),
        const SizedBox(height: 8),
        Obx(() => toggle('Show tutorial', 'See the basics before a new game.',
            s.showTutorial.value, s.setShowTutorial)),
        ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.menu_book_rounded, color: resinInk),
            title: Text('How to play', style: resinText(18)),
            trailing: const Icon(Icons.chevron_right, color: resinInk),
            onTap: () => Get.to(() => const BlockMergeHelpScreen())),
      ])),
      const SizedBox(height: 20),
      ResinButton('RESET STATISTICS',
          color: resinMint, onTap: () => resetBlockStatistics(context, s)),
      const SizedBox(height: 12),
      Text('Clears scores, not your preferences.',
          textAlign: TextAlign.center, style: resinText(14)),
    ]));
  }
}
