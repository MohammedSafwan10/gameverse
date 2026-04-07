import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;
import '../controllers/game_controller.dart';
import 'game_screen.dart';
import '../widgets/chess_board_preview.dart';
import 'package:gameverse/widgets/premium_background.dart';

class ChessSettingsScreen extends GetView<ChessGameController> {
  const ChessSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    dev.log('Building ChessSettingsScreen', name: 'Chess');
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Chess Settings'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const PremiumBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Game Settings Section
                    _buildSectionTitle(context, 'Game Preferences', Icons.tune),
                    _buildSettingsCard(
                      context,
                      children: [
                        _buildSwitchTile(
                          context,
                          title: 'Show Legal Moves',
                          subtitle: 'Highlight possible moves for pieces',
                          icon: Icons.lightbulb_outline,
                          value: controller.showLegalMoves,
                          onChanged: (_) => controller.toggleLegalMoves(),
                        ),
                        _buildDivider(),
                        _buildSwitchTile(
                          context,
                          title: 'Show Last Move',
                          subtitle: 'Highlight the previous move',
                          icon: Icons.history,
                          value: controller.showLastMove,
                          onChanged: (_) => controller.toggleLastMove(),
                        ),
                        _buildDivider(),
                        _buildSwitchTile(
                          context,
                          title: 'Sound Effects',
                          subtitle: 'Play audio during game',
                          icon: Icons.volume_up_outlined,
                          value: controller.soundService.isSoundEnabled,
                          onChanged: (_) =>
                              controller.soundService.toggleSound(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Board Theme Section
                    _buildSectionTitle(
                        context, 'Board Style', Icons.palette_outlined),
                    const SizedBox(height: 12),
                    _buildBoardThemeSelector(context),

                    const SizedBox(height: 32),

                    // Statistics Section
                    _buildSectionTitle(
                        context, 'Your Progress', Icons.analytics_outlined),
                    const SizedBox(height: 12),
                    _buildStatisticsGrid(context),

                    const SizedBox(height: 32),

                    // Position Tools Section
                    _buildSectionTitle(
                        context, 'Position Tools', Icons.code_rounded),
                    _buildSettingsCard(
                      context,
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.copy_all_rounded,
                                color: theme.colorScheme.primary),
                          ),
                          title: const Text('Copy FEN'),
                          subtitle: const Text('Copy the current position as FEN'),
                          onTap: () => _copyFen(context),
                        ),
                        _buildDivider(),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.input_rounded,
                                color: theme.colorScheme.primary),
                          ),
                          title: const Text('Import FEN'),
                          subtitle: const Text('Load a position from FEN'),
                          onTap: () => _showImportFenDialog(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Data Management Section
                    _buildSectionTitle(
                        context, 'Danger Zone', Icons.dangerous_outlined),
                    _buildSettingsCard(
                      context,
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.delete_forever_outlined,
                                color: Colors.red),
                          ),
                          title: Text(
                            'Reset All Data',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle:
                              const Text('Clear all statistics and settings'),
                          onTap: () => _showResetConfirmation(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context,
      {required List<Widget> children}) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required RxBool value,
    required Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);
    return Obx(() => SwitchListTile(
          value: value.value,
          onChanged: (val) {
            controller.soundService.playMenuSelectionSound();
            onChanged(val);
          },
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall,
          ),
          activeThumbColor: theme.colorScheme.primary,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ));
  }

  Widget _buildDivider() {
    return const Divider(indent: 64, endIndent: 16);
  }

  Widget _buildBoardThemeSelector(BuildContext context) {
    final themes = [
      (
        'Classic',
        'classic',
        'Wood',
        [Colors.brown.shade800, Colors.brown.shade200]
      ),
      (
        'Modern',
        'modern',
        'Blue',
        [Colors.blue.shade800, Colors.blue.shade200]
      ),
      (
        'Forest',
        'forest',
        'Green',
        [Colors.green.shade800, Colors.green.shade200]
      ),
      (
        'Royal',
        'royal',
        'Purple',
        [Colors.purple.shade800, Colors.amber.shade200]
      ),
      ('Ocean', 'ocean', 'Teal', [Colors.teal.shade800, Colors.cyan.shade200]),
      (
        'Sunset',
        'sunset',
        'Warm',
        [Colors.deepOrange.shade800, Colors.pink.shade200]
      ),
    ];

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: themes.length,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (context, index) {
          final themeData = themes[index];
          return _buildThemeItem(
            context,
            name: themeData.$1,
            value: themeData.$2,
            description: themeData.$3,
            colors: themeData.$4,
          );
        },
      ),
    );
  }

  Widget _buildThemeItem(
    BuildContext context, {
    required String name,
    required String value,
    required String description,
    required List<Color> colors,
  }) {
    final theme = Theme.of(context);
    return Obx(() {
      final isSelected = controller.boardTheme.value == value;
      return GestureDetector(
        onTap: () {
          controller.soundService.playMenuSelectionSound();
          controller.updateBoardTheme(value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 120,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.1),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ChessBoardPreview(
                    colors: colors,
                    isSelected: isSelected,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: isSelected
                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatisticsGrid(BuildContext context) {
    return Obx(() {
      final stats = controller.storageService;
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: [
          _buildStatCard(context, 'Played', stats.gamesPlayed.toString(),
              Icons.sports_esports, Colors.blue),
          _buildStatCard(context, 'Won', stats.gamesWon.toString(),
              Icons.emoji_events, Colors.green),
          _buildStatCard(context, 'Lost', stats.gamesLost.toString(),
              Icons.close, Colors.red),
          _buildStatCard(context, 'Draw', stats.gamesDraw.toString(),
              Icons.balance, Colors.orange),
        ],
      );
    });
  }

  Widget _buildStatCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyFen(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: controller.exportFen()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('FEN copied')),
    );
  }

  Future<void> _showImportFenDialog(BuildContext context) async {
    final textController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Import FEN'),
        content: TextField(
          controller: textController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Paste a FEN string',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final fen = textController.text.trim();
              if (fen.isEmpty) return;
              try {
                controller.importFen(fen);
                Navigator.of(dialogContext).pop();
                Get.until((route) => route.isFirst);
                Get.to(() => const ChessGameScreen(),
                    transition: Transition.rightToLeft);
                Get.snackbar(
                  'Position Loaded',
                  'FEN position imported successfully.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar(
                  'Invalid FEN',
                  e.toString(),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('LOAD'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Reset All Data'),
        content: const Text(
          'Are you sure you want to reset all game statistics and settings? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              controller.storageService.clearAllData();
              Get.back();
              Get.snackbar(
                'Reset Complete',
                'All game data has been cleared.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }
}
