import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;
import '../controllers/game_controller.dart';
import '../widgets/chess_board_preview.dart';

class ChessSettingsScreen extends GetView<ChessGameController> {
  const ChessSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    dev.log('Building ChessSettingsScreen', name: 'Chess');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(
                red: theme.colorScheme.primary.r.toDouble(),
                green: theme.colorScheme.primary.g.toDouble(),
                blue: theme.colorScheme.primary.b.toDouble(),
                alpha: 0.1,
              ),
              theme.colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Game Settings Section
                  _buildSection(
                    title: 'Game Settings',
                    icon: Icons.settings,
                    children: [
                      Obx(() {
                        dev.log(
                            'Rebuilding legal moves switch, value: ${controller.showLegalMoves.value}',
                            name: 'Chess');
                        return SwitchListTile(
                          value: controller.showLegalMoves.value,
                          onChanged: (_) {
                            dev.log('Toggling legal moves', name: 'Chess');
                            controller.soundService.playMenuSelectionSound();
                            controller.toggleLegalMoves();
                          },
                          title: const Text('Show Legal Moves'),
                          subtitle: const Text(
                              'Highlight possible moves for selected piece'),
                          secondary: const Icon(Icons.help_outline),
                        );
                      }),
                      Obx(() {
                        dev.log(
                            'Rebuilding last move switch, value: ${controller.showLastMove.value}',
                            name: 'Chess');
                        return SwitchListTile(
                          value: controller.showLastMove.value,
                          onChanged: (_) {
                            dev.log('Toggling last move', name: 'Chess');
                            controller.soundService.playMenuSelectionSound();
                            controller.toggleLastMove();
                          },
                          title: const Text('Show Last Move'),
                          subtitle: const Text('Highlight the last move made'),
                          secondary: const Icon(Icons.history),
                        );
                      }),
                      Obx(() {
                        dev.log(
                            'Rebuilding sound switch, value: ${controller.soundService.isSoundEnabled.value}',
                            name: 'Chess');
                        return SwitchListTile(
                          value: controller.soundService.isSoundEnabled.value,
                          onChanged: (_) {
                            dev.log('Toggling sound', name: 'Chess');
                            controller.soundService.toggleSound();
                          },
                          title: const Text('Sound Effects'),
                          subtitle:
                              const Text('Play sound effects during the game'),
                          secondary: const Icon(Icons.volume_up),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Board Theme Section
                  _buildSection(
                    title: 'Board Theme',
                    icon: Icons.palette,
                    children: [
                      LayoutBuilder(
                          builder: (context, constraints) {
                          // Adjust dimensions based on screen size
                          final isSmallScreen = constraints.maxWidth < 360;
                          final isMediumScreen = constraints.maxWidth < 600;
                          final cardWidth = constraints.maxWidth > 600
                              ? 180.0
                              : isSmallScreen
                                  ? (constraints.maxWidth - 50) / 2
                                  : 140.0;

                          // Use grid layout on very small screens
                          if (isSmallScreen) {
                            final themes = [
                              (
                                'Classic',
                                'classic',
                                'Brown and ivory',
                                [Colors.brown.shade800, Colors.brown.shade200]
                              ),
                              (
                                'Modern',
                                'modern',
                                'Blue and white',
                                [Colors.blue.shade800, Colors.blue.shade200]
                              ),
                              (
                                'Forest',
                                'forest',
                                'Green and cream',
                                [Colors.green.shade800, Colors.green.shade200]
                              ),
                              (
                                'Royal',
                                'royal',
                                'Purple and gold',
                                [Colors.purple.shade800, Colors.amber.shade200]
                              ),
                              (
                                'Ocean',
                                'ocean',
                                'Teal and aqua',
                                [Colors.teal.shade800, Colors.cyan.shade200]
                              ),
                              (
                                'Sunset',
                                'sunset',
                                'Orange and pink',
                                [
                                  Colors.deepOrange.shade800,
                                  Colors.pink.shade200
                                ]
                              ),
                            ];

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: themes.length,
                              itemBuilder: (context, index) {
                                final theme = themes[index];
                                return _buildThemeOption(theme.$1, theme.$2,
                                    theme.$3, theme.$4, cardWidth);
                              },
                            );
                          }

                          // Adjust height based on card width
                          final sectionHeight = isMediumScreen ? 170.0 : 200.0;

                          return SizedBox(
                            height: sectionHeight,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                  horizontal: isMediumScreen ? 4 : 8,
                                  vertical: isMediumScreen ? 4 : 8),
                              children: [
                                _buildThemeOption(
                                  'Classic',
                                  'classic',
                                  'Brown and ivory',
                                  [
                                    Colors.brown.shade800,
                                    Colors.brown.shade200
                                  ],
                                  cardWidth,
                                ),
                                _buildThemeOption(
                                  'Modern',
                                  'modern',
                                  'Blue and white',
                                  [Colors.blue.shade800, Colors.blue.shade200],
                                  cardWidth,
                                ),
                                _buildThemeOption(
                                  'Forest',
                                  'forest',
                                  'Green and cream',
                                  [
                                    Colors.green.shade800,
                                    Colors.green.shade200
                                  ],
                                  cardWidth,
                                ),
                                _buildThemeOption(
                                  'Royal',
                                  'royal',
                                  'Purple and gold',
                                  [
                                    Colors.purple.shade800,
                                    Colors.amber.shade200
                                  ],
                                  cardWidth,
                                ),
                                _buildThemeOption(
                                  'Ocean',
                                  'ocean',
                                  'Teal and aqua',
                                  [Colors.teal.shade800, Colors.cyan.shade200],
                                  cardWidth,
                                ),
                                _buildThemeOption(
                                  'Sunset',
                                  'sunset',
                                  'Orange and pink',
                                  [
                                    Colors.deepOrange.shade800,
                                    Colors.pink.shade200
                                  ],
                                  cardWidth,
                                ),
                              ],
                            ),
                            );
                          },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Statistics Section
                  _buildSection(
                    title: 'Statistics',
                    icon: Icons.bar_chart,
                    children: [
                      Obx(() {
                        dev.log(
                            'Rebuilding statistics section in settings screen',
                            name: 'Chess');
                        final storageService = controller.storageService;
                        return Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.sports_esports,
                                  color: Get.theme.colorScheme.primary),
                        title: const Text('Games Played'),
                        trailing: SizedBox(
                          width: 50,
                                child: Text(
                                  storageService.gamesPlayed.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.end,
                                ),
                        ),
                      ),
                      ListTile(
                              leading: const Icon(Icons.emoji_events,
                                  color: Colors.amber),
                        title: const Text('Games Won'),
                        trailing: SizedBox(
                          width: 50,
                                child: Text(
                                  storageService.gamesWon.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                              textAlign: TextAlign.end,
                                ),
                        ),
                      ),
                      ListTile(
                              leading:
                                  const Icon(Icons.close, color: Colors.red),
                        title: const Text('Games Lost'),
                        trailing: SizedBox(
                          width: 50,
                                child: Text(
                                  storageService.gamesLost.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.end,
                                ),
                        ),
                      ),
                      ListTile(
                              leading: const Icon(Icons.balance,
                                  color: Colors.orange),
                        title: const Text('Games Draw'),
                        trailing: SizedBox(
                          width: 50,
                                child: Text(
                                  storageService.gamesDraw.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                              textAlign: TextAlign.end,
                                ),
                              ),
                            ),
                          ],
                            );
                          }),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Reset Section
                  _buildSection(
                    title: 'Reset',
                    icon: Icons.restart_alt,
                    children: [
                      ListTile(
                        leading:
                            const Icon(Icons.delete_forever, color: Colors.red),
                        title: const Text('Reset All Data'),
                        subtitle: const Text(
                            'Clear all game statistics and settings'),
                        onTap: () => _showResetConfirmation(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: Get.theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    String name,
    String value,
    String description,
    List<Color> colors,
    double cardWidth,
  ) {
    return Obx(() {
      final isSelected = controller.boardTheme.value == value;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: GestureDetector(
          onTap: () {
            controller.soundService.playMenuSelectionSound();
            controller.updateBoardTheme(value);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: cardWidth,
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Get.theme.colorScheme.primary
                    : Get.theme.colorScheme.outline.withValues(
                        red: Get.theme.colorScheme.outline.r.toDouble(),
                        green: Get.theme.colorScheme.outline.g.toDouble(),
                        blue: Get.theme.colorScheme.outline.b.toDouble(),
                        alpha: 0.5,
                      ),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Get.theme.colorScheme.primary.withValues(
                          red: Get.theme.colorScheme.primary.r.toDouble(),
                          green: Get.theme.colorScheme.primary.g.toDouble(),
                          blue: Get.theme.colorScheme.primary.b.toDouble(),
                          alpha: 0.3,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Preview
                Container(
                  height: cardWidth < 130 ? 80 : 100,
                  margin: EdgeInsets.all(cardWidth < 130 ? 6 : 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          red: 0.0,
                          green: 0.0,
                          blue: 0.0,
                          alpha: 0.1,
                        ),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ChessBoardPreview(
                      colors: colors,
                      isSelected: isSelected,
                    ),
                  ),
                ),
                // Theme name
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: cardWidth < 130 ? 8 : 12),
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: cardWidth < 130 ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Get.theme.colorScheme.primary
                          : Get.theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                // Theme description
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      cardWidth < 130 ? 8 : 12,
                      cardWidth < 130 ? 2 : 4,
                      cardWidth < 130 ? 8 : 12,
                      cardWidth < 130 ? 8 : 12),
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: cardWidth < 130 ? 10 : 12,
                      color: Get.theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showResetConfirmation(BuildContext context) {
    dev.log('Showing reset confirmation dialog', name: 'Chess');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
          'Are you sure you want to reset all game statistics and settings? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              dev.log('Reset cancelled', name: 'Chess');
              Get.back();
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              dev.log('Resetting all data', name: 'Chess');
              controller.storageService.clearAllData();
              Get.back();
              Get.snackbar(
                'Reset Complete',
                'All game data has been cleared.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text(
              'RESET',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
