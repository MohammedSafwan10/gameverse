import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;
import '../controllers/game_controller.dart';
import 'game_screen.dart';
import '../widgets/chess_board_preview.dart';
import 'package:gameverse/theme/app_theme.dart';

class ChessSettingsScreen extends GetView<ChessGameController> {
  const ChessSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    dev.log('Building ChessSettingsScreen', name: 'Chess');
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: Colors.white),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // Chess specific animated/gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E293B), // Deep slate
                  Color(0xFF0F172A),
                ],
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF4B860).withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF4B860).withValues(alpha: 0.15),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
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
                    const SizedBox(height: 16),
                    _buildBoardThemeSelector(context),

                    const SizedBox(height: 32),

                    // Statistics Section
                    _buildSectionTitle(
                        context, 'Your Progress', Icons.analytics_outlined),
                    const SizedBox(height: 16),
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
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4B860)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.copy_all_rounded,
                                color: Color(0xFFF4B860), size: 20),
                          ),
                          title: const Text('Copy FEN',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                          subtitle: Text('Copy current position as FEN',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12)),
                          onTap: () => _copyFen(context),
                        ),
                        _buildDivider(),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4B860)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.input_rounded,
                                color: Color(0xFFF4B860), size: 20),
                          ),
                          title: const Text('Import FEN',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                          subtitle: Text('Load a position from FEN',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12)),
                          onTap: () => _showImportFenDialog(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Data Management Section
                    _buildSectionTitle(
                        context, 'Danger Zone', Icons.dangerous_outlined,
                        isDanger: true),
                    _buildSettingsCard(
                      context,
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.delete_forever_outlined,
                                color: Colors.redAccent, size: 20),
                          ),
                          title: const Text(
                            'Reset All Data',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text('Clear all statistics and settings',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12)),
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

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon,
      {bool isDanger = false}) {
    final color = isDanger ? Colors.redAccent : const Color(0xFFF4B860);
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context,
      {required List<Widget> children}) {
    return Container(
      decoration: AppTheme.glassmorphicDecoration(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        borderColor: Colors.white.withValues(alpha: 0.1),
        borderRadius: 24,
      ),
      clipBehavior: Clip.antiAlias,
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
    final accentColor = const Color(0xFFF4B860);
    return Obx(() => SwitchListTile(
          value: value.value,
          onChanged: (val) {
            controller.soundService.playMenuSelectionSound();
            onChanged(val);
          },
          secondary: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
          activeThumbColor: accentColor,
          activeTrackColor: accentColor.withValues(alpha: 0.3),
          inactiveThumbColor: Colors.white.withValues(alpha: 0.4),
          inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ));
  }

  Widget _buildDivider() {
    return Divider(
        indent: 64,
        endIndent: 16,
        color: Colors.white.withValues(alpha: 0.1),
        height: 1);
  }

  Widget _buildBoardThemeSelector(BuildContext context) {
    final themes = [
      (
        'Classic',
        'classic',
        'Wood',
        [const Color(0xFFB58863), const Color(0xFFF0D9B5)]
      ),
      (
        'Modern',
        'modern',
        'Blue',
        [const Color(0xFF4B7399), const Color(0xFFE8EDF9)]
      ),
      (
        'Forest',
        'forest',
        'Green',
        [const Color(0xFF779556), const Color(0xFFE2E2BD)]
      ),
      (
        'Royal',
        'royal',
        'Purple',
        [const Color(0xFF7B1FA2), const Color(0xFFFFE0B2)]
      ),
      (
        'Ocean',
        'ocean',
        'Teal',
        [const Color(0xFF006064), const Color(0xFFE0F7FA)]
      ),
      (
        'Sunset',
        'sunset',
        'Warm',
        [const Color(0xFFE64A19), const Color(0xFFFCE4EC)]
      ),
    ];

    return SizedBox(
      height: 170,
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
    final accentColor = const Color(0xFFF4B860);
    return Obx(() {
      final isSelected = controller.boardTheme.value == value;
      return GestureDetector(
        onTap: () {
          controller.soundService.playMenuSelectionSound();
          controller.updateBoardTheme(value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 130,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : Colors.white.withValues(alpha: 0.1),
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2), width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ChessBoardPreview(
                    colors: colors,
                    isSelected: isSelected,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
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
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
        children: [
          _buildStatCard(context, 'Played', stats.gamesPlayed.toString(),
              Icons.sports_esports, Colors.blueAccent),
          _buildStatCard(context, 'Won', stats.gamesWon.toString(),
              Icons.emoji_events, Colors.greenAccent),
          _buildStatCard(context, 'Lost', stats.gamesLost.toString(),
              Icons.close, Colors.redAccent),
          _buildStatCard(context, 'Draw', stats.gamesDraw.toString(),
              Icons.balance, Colors.orangeAccent),
        ],
      );
    });
  }

  Widget _buildStatCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassmorphicDecoration(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        borderColor: color.withValues(alpha: 0.3),
        borderRadius: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: Colors.white.withValues(alpha: 0.6),
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
      SnackBar(
        content: const Text('FEN copied to clipboard'),
        backgroundColor: const Color(0xFFF4B860),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _showImportFenDialog(BuildContext context) async {
    final textController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text('Import FEN',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Paste a FEN string to load a specific chess position.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: textController,
              minLines: 2,
              maxLines: 4,
              style: const TextStyle(
                  color: Colors.white, fontFamily: 'monospace', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'FEN string here...',
                hintStyle:
                    TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.2),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child:
                const Text('CANCEL', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF4B860),
              foregroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
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
                  backgroundColor: Colors.green.shade800,
                  colorText: Colors.white,
                  borderRadius: 16,
                  margin: const EdgeInsets.all(16),
                );
              } catch (e) {
                Get.snackbar(
                  'Invalid FEN',
                  e.toString(),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.redAccent,
                  colorText: Colors.white,
                  borderRadius: 16,
                  margin: const EdgeInsets.all(16),
                );
              }
            },
            child: const Text('LOAD POSITION',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text('Reset All Data',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to reset all game statistics and settings? This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child:
                const Text('CANCEL', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white),
            onPressed: () {
              controller.storageService.clearAllData();
              Get.back();
              Get.snackbar(
                'Reset Complete',
                'All game data has been cleared.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.redAccent,
                colorText: Colors.white,
                borderRadius: 16,
                margin: const EdgeInsets.all(16),
              );
            },
            child: const Text('RESET EVERYTHING',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
