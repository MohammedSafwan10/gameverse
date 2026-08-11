import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../bindings/game_binding.dart';
import '../models/game_mode.dart';
import '../models/game_state.dart';
import '../theme/memory_match_theme.dart';
import 'game_screen.dart';

const _assetRoot = 'assets/images/games/memory_match';

class MemoryMatchModeSelectionScreen extends StatefulWidget {
  const MemoryMatchModeSelectionScreen({super.key});

  @override
  State<MemoryMatchModeSelectionScreen> createState() =>
      _MemoryMatchModeSelectionScreenState();
}

class _MemoryMatchModeSelectionScreenState
    extends State<MemoryMatchModeSelectionScreen> {
  @override
  void initState() {
    super.initState();
    MemoryMatchBinding.initDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 700;
    return Scaffold(
      body: MemoryMatchBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: MemoryMatchIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onPressed: Get.back,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(14, compact ? 5 : 10, 14, 18),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        children: [
                          _HeroPanel(compact: compact),
                          SizedBox(height: compact ? 10 : 14),
                          _ClassicCard(
                            compact: compact,
                            onTap: () =>
                                _showDifficulty(MemoryMatchMode.classic),
                          ),
                          SizedBox(height: compact ? 10 : 14),
                          Row(
                            children: [
                              Expanded(
                                child: _SmallModeCard(
                                  mode: MemoryMatchMode.timeTrial,
                                  image: '$_assetRoot/stopwatch_v1.png',
                                  subtitle: 'Beat the clock',
                                  compact: compact,
                                  onTap: () => _showDifficulty(
                                      MemoryMatchMode.timeTrial),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _SmallModeCard(
                                  mode: MemoryMatchMode.challenge,
                                  image: '$_assetRoot/challenge_arrow_v1.png',
                                  subtitle: 'Harder each level',
                                  compact: compact,
                                  onTap: () => _showDifficulty(
                                      MemoryMatchMode.challenge),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: compact ? 10 : 14),
                          SizedBox(
                            height: 48,
                            width: minOf(size.width - 70, 300),
                            child: OutlinedButton.icon(
                              onPressed: _showHelp,
                              icon: const Icon(Icons.menu_book_rounded),
                              label: const Text('HOW TO PLAY'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: MemoryMatchTheme.cream,
                                foregroundColor: MemoryMatchTheme.ink,
                                side: BorderSide.none,
                                elevation: 5,
                                shadowColor: Colors.black26,
                                textStyle: MemoryMatchTheme.body(
                                  weight: FontWeight.w900,
                                ),
                                shape: const StadiumBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDifficulty(MemoryMatchMode mode) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.88,
          ),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
          decoration: const BoxDecoration(
            color: MemoryMatchTheme.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: MemoryMatchTheme.ink.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: mode == MemoryMatchMode.classic
                            ? MemoryMatchTheme.mintPale
                            : mode == MemoryMatchMode.timeTrial
                                ? const Color(0xFFFFE5D6)
                                : const Color(0xFFE2F7E8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image.asset(
                        mode == MemoryMatchMode.classic
                            ? '$_assetRoot/rocket_card_v1.png'
                            : mode == MemoryMatchMode.timeTrial
                                ? '$_assetRoot/stopwatch_v1.png'
                                : '$_assetRoot/challenge_arrow_v1.png',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('PICK A DIFFICULTY',
                                style: MemoryMatchTheme.display(size: 23)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${mode.displayName} · Choose your board size',
                            style: MemoryMatchTheme.body(
                              size: 12,
                              color: MemoryMatchTheme.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                for (final difficulty in GameDifficulty.values) ...[
                  _DifficultyTile(
                    difficulty: difficulty,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Get.to(
                        () => MemoryMatchGameScreen(
                          mode: mode,
                          difficulty: difficulty,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 9),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showHelp() => showDialog<void>(
        context: context,
        builder: (dialogContext) => Dialog(
          insetPadding: const EdgeInsets.all(20),
          backgroundColor: MemoryMatchTheme.cream,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Image.asset('$_assetRoot/rocket_card_v1.png',
                        width: 52, height: 52),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text('HOW TO PLAY',
                          style: MemoryMatchTheme.display(size: 23)),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _HelpStep('1', 'Flip two cards',
                    'Tap cards to reveal the hidden pictures.'),
                const _HelpStep('2', 'Find matching pairs',
                    'Remember each position and clear the board.'),
                const _HelpStep('3', 'Build a combo',
                    'Consecutive matches multiply your score.'),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: MemoryMatchPrimaryButton(
                    label: 'GOT IT',
                    icon: Icons.check_rounded,
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

double minOf(double a, double b) => a < b ? a : b;

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
        height: compact ? 140 : 155,
        padding: EdgeInsets.all(compact ? 15 : 20),
        decoration: BoxDecoration(
          color: MemoryMatchTheme.cream,
          borderRadius: BorderRadius.circular(28),
          boxShadow: MemoryMatchTheme.softShadow,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: LayoutBuilder(
                builder: (context, constraints) => FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MEMORY\nMATCH',
                          style: MemoryMatchTheme.display(
                            size: compact ? 28 : 35,
                            color: MemoryMatchTheme.orange,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text('Choose your challenge',
                            maxLines: 1,
                            style: MemoryMatchTheme.body(
                              size: compact ? 11 : 13,
                              weight: FontWeight.w800,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: 4,
                    bottom: 10,
                    child: Transform.rotate(
                      angle: -.08,
                      child: Image.asset('$_assetRoot/rocket_card_v1.png'),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 20,
                    bottom: -2,
                    child: Transform.rotate(
                      angle: .10,
                      child: Image.asset('$_assetRoot/flower_card_v1.png'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ClassicCard extends StatelessWidget {
  const _ClassicCard({required this.compact, required this.onTap});

  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: MemoryMatchTheme.orange,
        elevation: 7,
        shadowColor: Colors.black38,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: SizedBox(
            height: compact ? 200 : 180,
            child: Padding(
              padding: EdgeInsets.all(compact ? 14 : 18),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: LayoutBuilder(
                      builder: (context, constraints) => FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CLASSIC',
                                  style: MemoryMatchTheme.display(
                                    size: compact ? 25 : 32,
                                    color: Colors.white,
                                  )),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                height: 3,
                                width: 74,
                                color: MemoryMatchTheme.orangeDark,
                              ),
                              Text('Find every pair\nat your own pace',
                                  style: MemoryMatchTheme.body(
                                    size: compact ? 11 : 13,
                                    color: Colors.white,
                                    weight: FontWeight.w700,
                                  )),
                              const SizedBox(height: 8),
                              const _RoundArrow(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: GridView.count(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      children: [
                        Image.asset('$_assetRoot/rocket_card_v1.png'),
                        Image.asset('$_assetRoot/flower_card_v1.png'),
                        Image.asset('$_assetRoot/flower_card_v1.png'),
                        Image.asset('$_assetRoot/rocket_card_v1.png'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _SmallModeCard extends StatelessWidget {
  const _SmallModeCard({
    required this.mode,
    required this.image,
    required this.subtitle,
    required this.compact,
    required this.onTap,
  });

  final MemoryMatchMode mode;
  final String image;
  final String subtitle;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: MemoryMatchTheme.cream,
        elevation: 6,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: SizedBox(
            height: compact ? 178 : 172,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Image.asset(image, fit: BoxFit.contain)),
                  const SizedBox(height: 4),
                  FittedBox(
                    child: Text(mode.displayName.toUpperCase(),
                        style: MemoryMatchTheme.display(size: 18)),
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      maxLines: 1,
                      style: MemoryMatchTheme.body(
                        size: 10,
                        weight: FontWeight.w700,
                      )),
                  const SizedBox(height: 5),
                  const _RoundArrow(small: true),
                ],
              ),
            ),
          ),
        ),
      );
}

class _RoundArrow extends StatelessWidget {
  const _RoundArrow({this.small = false});
  final bool small;

  @override
  Widget build(BuildContext context) => Container(
        width: small ? 30 : 36,
        height: small ? 30 : 36,
        decoration: const BoxDecoration(
          color: MemoryMatchTheme.cream,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.arrow_forward_rounded,
            size: small ? 18 : 22, color: MemoryMatchTheme.orange),
      );
}

class _DifficultyTile extends StatelessWidget {
  const _DifficultyTile({required this.difficulty, required this.onTap});
  final GameDifficulty difficulty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (grid, pairs, color) = switch (difficulty) {
      GameDifficulty.easy => ('4 × 3', '6 pairs', MemoryMatchTheme.mint),
      GameDifficulty.medium => ('4 × 4', '8 pairs', MemoryMatchTheme.orange),
      GameDifficulty.hard => ('5 × 4', '10 pairs', MemoryMatchTheme.pink),
    };
    final recommended = difficulty == GameDifficulty.medium;
    return Material(
      color: color.withValues(alpha: .12),
      elevation: recommended ? 4 : 0,
      shadowColor: color.withValues(alpha: .28),
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  grid,
                  style: MemoryMatchTheme.body(
                    size: 13,
                    color: Colors.white,
                    weight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 7,
                      runSpacing: 3,
                      children: [
                        Text(difficulty.name.toUpperCase(),
                            style: MemoryMatchTheme.display(size: 17)),
                        if (recommended)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: MemoryMatchTheme.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'POPULAR',
                              style: MemoryMatchTheme.body(
                                size: 8,
                                color: Colors.white,
                                weight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                        '$pairs · ${difficulty == GameDifficulty.easy ? 'Relaxed start' : difficulty == GameDifficulty.medium ? 'Balanced challenge' : 'Memory master'}',
                        style: MemoryMatchTheme.body(
                          size: 12,
                          color: MemoryMatchTheme.muted,
                        )),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: MemoryMatchTheme.cream,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: MemoryMatchTheme.orange),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpStep extends StatelessWidget {
  const _HelpStep(this.number, this.title, this.text);
  final String number;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: MemoryMatchTheme.cobalt,
              child: Text(number,
                  style: MemoryMatchTheme.body(
                    color: Colors.white,
                    weight: FontWeight.w900,
                  )),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: MemoryMatchTheme.body(weight: FontWeight.w900)),
                  Text(text,
                      style: MemoryMatchTheme.body(
                        size: 12,
                        color: MemoryMatchTheme.muted,
                      )),
                ],
              ),
            ),
          ],
        ),
      );
}
