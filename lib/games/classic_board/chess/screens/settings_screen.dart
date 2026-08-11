import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../services/sound_service.dart';
import '../services/storage_service.dart';
import '../theme/chess_design.dart';

class ChessSettingsScreen extends GetView<ChessGameController> {
  const ChessSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<ChessStorageService>();
    final sound = Get.find<ChessSoundService>();
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: ChessDesign.background),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                  child: Row(children: [
                    IconButton.filled(
                      onPressed: Get.back,
                      style: IconButton.styleFrom(
                          backgroundColor: ChessDesign.ivory,
                          foregroundColor: ChessDesign.ink),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('CHESS SETTINGS',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1)),
                    ),
                  ]),
                ),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
                    children: [
                      _StatsCard(storage: storage),
                      const SizedBox(height: 12),
                      _Panel(
                        title: 'GAME FEEL',
                        icon: Icons.tune_rounded,
                        children: [
                          Obx(() => _SettingSwitch(
                                icon: sound.isSoundEnabled.value
                                    ? Icons.volume_up_rounded
                                    : Icons.volume_off_rounded,
                                title: 'Sound effects',
                                subtitle: 'Moves, captures, checks and wins',
                                value: sound.isSoundEnabled.value,
                                onChanged: (_) => sound.toggleSound(),
                              )),
                          Obx(() => _SettingSwitch(
                                icon: Icons.ads_click_rounded,
                                title: 'Legal move hints',
                                subtitle: 'Highlight valid destination squares',
                                value: controller.showLegalMoves.value,
                                onChanged: (_) => controller.toggleLegalMoves(),
                              )),
                          Obx(() => _SettingSwitch(
                                icon: Icons.swap_horiz_rounded,
                                title: 'Last move marker',
                                subtitle: 'Keep the previous move highlighted',
                                value: controller.showLastMove.value,
                                onChanged: (_) => controller.toggleLastMove(),
                              )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _Panel(
                        title: 'BOARD COLLECTION',
                        icon: Icons.grid_view_rounded,
                        children: [
                          Obx(() => _ThemeGrid(
                                selected: controller.boardTheme.value,
                                onSelect: controller.updateBoardTheme,
                              )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _Panel(
                        title: 'ADVANCED',
                        icon: Icons.construction_rounded,
                        children: [
                          _ActionTile(
                            icon: Icons.file_download_outlined,
                            title: 'Import a position',
                            subtitle: 'Load a standard FEN position',
                            onTap: () => _importFen(context),
                          ),
                          _ActionTile(
                            icon: Icons.copy_all_rounded,
                            title: 'Copy current position',
                            subtitle: 'Export the board as FEN',
                            onTap: () => _copyFen(context),
                          ),
                          _ActionTile(
                            icon: Icons.delete_sweep_outlined,
                            title: 'Reset Chess data',
                            subtitle: 'Clear statistics and preferences',
                            destructive: true,
                            onTap: () => _resetData(context, storage),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _importFen(BuildContext context) async {
    final input = TextEditingController();
    final fen = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ChessDesign.ivory,
        title: const Text('Import FEN',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: TextField(
          controller: input,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
              hintText: 'Paste a valid FEN position',
              border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('CANCEL')),
          FilledButton(
              onPressed: () => Get.back(result: input.text.trim()),
              child: const Text('IMPORT')),
        ],
      ),
    );
    if (fen == null || fen.isEmpty) return;
    try {
      controller.importFen(fen);
      if (context.mounted) _notice(context, 'Position imported');
    } catch (_) {
      if (context.mounted) {
        _notice(context, 'That FEN is not valid', error: true);
      }
    }
  }

  Future<void> _copyFen(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: controller.exportFen()));
    if (context.mounted) _notice(context, 'FEN copied');
  }

  Future<void> _resetData(
      BuildContext context, ChessStorageService storage) async {
    final yes = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: ChessDesign.ivory,
            title: const Text('Reset Chess data?',
                style: TextStyle(fontWeight: FontWeight.w900)),
            content: const Text(
                'This clears Chess statistics, preferences, and the saved match.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('CANCEL')),
              FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style:
                      FilledButton.styleFrom(backgroundColor: ChessDesign.red),
                  child: const Text('RESET')),
            ],
          ),
        ) ??
        false;
    if (!yes) return;
    await storage.clearAllData();
    controller.showLegalMoves.value = true;
    controller.showLastMove.value = true;
    controller.boardTheme.value = 'classic';
    Get.find<ChessSoundService>().isSoundEnabled.value = true;
    if (context.mounted) _notice(context, 'Chess data reset');
  }

  void _notice(BuildContext context, String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? ChessDesign.red : ChessDesign.navy,
      behavior: SnackBarBehavior.floating,
    ));
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.storage});
  final ChessStorageService storage;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: ChessDesign.ivoryPanel(radius: 26),
        child: Obx(() => Row(children: [
              const Icon(Icons.emoji_events_rounded,
                  color: ChessDesign.gold, size: 42),
              const SizedBox(width: 15),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  children: [
                    _stat('PLAYED', storage.gamesPlayed),
                    _stat('WON', storage.gamesWon),
                    _stat('DRAW', storage.gamesDraw),
                    _stat('LOST', storage.gamesLost),
                  ],
                ),
              ),
            ])),
      );
  Widget _stat(String label, int value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(children: [
          Text('$value',
              style: const TextStyle(
                  color: ChessDesign.navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w900)),
          Text(label,
              style: const TextStyle(
                  color: ChessDesign.ink,
                  fontSize: 8,
                  fontWeight: FontWeight.w800)),
        ]),
      );
}

class _Panel extends StatelessWidget {
  const _Panel(
      {required this.title, required this.icon, required this.children});
  final String title;
  final IconData icon;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        decoration: ChessDesign.ivoryPanel(radius: 26),
        child: Column(children: [
          Row(children: [
            Icon(icon, color: ChessDesign.orange, size: 21),
            const SizedBox(width: 9),
            Text(title,
                style: const TextStyle(
                    color: ChessDesign.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1)),
          ]),
          const SizedBox(height: 8),
          ...children,
        ]),
      );
}

class _SettingSwitch extends StatelessWidget {
  const _SettingSwitch(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.value,
      required this.onChanged});
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: ChessDesign.navy),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: ChessDesign.orange),
      );
}

class _ThemeGrid extends StatelessWidget {
  const _ThemeGrid({required this.selected, required this.onSelect});
  final String selected;
  final ValueChanged<String> onSelect;
  static const ids = [
    'classic',
    'modern',
    'forest',
    'royal',
    'ocean',
    'sunset'
  ];
  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.25,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: ids.map((id) {
          final palette = ChessBoardPalette.fromId(id);
          final active = selected == id;
          return InkWell(
            onTap: () => onSelect(id),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color:
                    active ? const Color(0xFFFFE4D5) : const Color(0xFFF0E8D7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: active ? ChessDesign.orange : Colors.transparent,
                    width: 2),
              ),
              child: Column(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Row(children: [
                      Expanded(child: ColoredBox(color: palette.light)),
                      Expanded(child: ColoredBox(color: palette.dark)),
                    ]),
                  ),
                ),
                const SizedBox(height: 4),
                Text(palette.name.toUpperCase(),
                    style: const TextStyle(
                        color: ChessDesign.ink,
                        fontSize: 9,
                        fontWeight: FontWeight.w900)),
              ]),
            ),
          );
        }).toList(),
      );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap,
      this.destructive = false});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;
  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        leading:
            Icon(icon, color: destructive ? ChessDesign.red : ChessDesign.navy),
        title: Text(title,
            style: TextStyle(
                color: destructive ? ChessDesign.red : ChessDesign.ink,
                fontSize: 14,
                fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right_rounded),
      );
}
