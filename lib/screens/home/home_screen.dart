import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

const _ink = Color(0xFF191919);
const _cream = Color(0xFFFFFAF0);
const _orange = Color(0xFFFF5A16);
const _cobalt = Color(0xFF1455D9);

enum _GameMood { quick, smart, classic }

class _FeaturedGame {
  const _FeaturedGame({
    required this.title,
    required this.displayTitle,
    required this.tagline,
    required this.route,
    required this.image,
    required this.panelColor,
    required this.buttonColor,
  });

  final String title;
  final String displayTitle;
  final String tagline;
  final String route;
  final String image;
  final Color panelColor;
  final Color buttonColor;
}

const _featuredGames = <_FeaturedGame>[
  _FeaturedGame(
    title: 'Memory Match',
    displayTitle: 'MEMORY\nMATCH',
    tagline: 'Train your brain',
    route: '/memory-match',
    image: 'assets/images/games/memory_match_home_hero_v2.png',
    panelColor: _orange,
    buttonColor: _orange,
  ),
  _FeaturedGame(
    title: 'Chess',
    displayTitle: 'CHESS',
    tagline: 'Plan your victory',
    route: '/chess',
    image: 'assets/images/games/chess_home_hero.png',
    panelColor: Color(0xFF6F42C1),
    buttonColor: Color(0xFF6F42C1),
  ),
  _FeaturedGame(
    title: 'Quiz Master',
    displayTitle: 'QUIZ\nMASTER',
    tagline: 'Challenge your mind',
    route: '/quiz-master',
    image: 'assets/images/games/quiz_master_home_hero.png',
    panelColor: Color(0xFF7A3FC1),
    buttonColor: Color(0xFF7A3FC1),
  ),
];

class _HomeGame {
  const _HomeGame({
    required this.name,
    required this.route,
    required this.image,
    required this.tint,
    required this.moods,
  });

  final String name;
  final String route;
  final String image;
  final Color tint;
  final Set<_GameMood> moods;
}

const _homeGames = <_HomeGame>[
  _HomeGame(
    name: 'Tic Tac Toe',
    route: '/tic-tac-toe',
    image: 'assets/images/home/games/tic_tac_toe.png',
    tint: Color(0xFFE4F5E9),
    moods: {_GameMood.quick, _GameMood.classic},
  ),
  _HomeGame(
    name: 'Chess',
    route: '/chess',
    image: 'assets/images/home/games/chess.png',
    tint: Color(0xFFF1E7FB),
    moods: {_GameMood.smart, _GameMood.classic},
  ),
  _HomeGame(
    name: 'Flappy Bird',
    route: '/flappy-bird',
    image: 'assets/images/home/games/flappy_bird.png',
    tint: Color(0xFFDDF3FF),
    moods: {_GameMood.quick},
  ),
  _HomeGame(
    name: 'Connect Four',
    route: '/connect-four',
    image: 'assets/images/home/games/connect_four.png',
    tint: Color(0xFFDDEEFF),
    moods: {_GameMood.quick, _GameMood.smart, _GameMood.classic},
  ),
  _HomeGame(
    name: 'Memory Match',
    route: '/memory-match',
    image: 'assets/images/games/memory_match_home_hero.png',
    tint: Color(0xFFFFE4ED),
    moods: {_GameMood.quick, _GameMood.smart},
  ),
  _HomeGame(
    name: 'Block Merge',
    route: '/block-merge',
    image: 'assets/images/home/games/block_merge.png',
    tint: Color(0xFFFFE7D9),
    moods: {_GameMood.smart},
  ),
  _HomeGame(
    name: 'Quiz Master',
    route: '/quiz-master',
    image: 'assets/images/home/games/quiz_master.png',
    tint: Color(0xFFF1E4FF),
    moods: {_GameMood.smart},
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _gamesKey = GlobalKey();
  _GameMood? _selectedMood;

  List<_HomeGame> get _visibleGames => _selectedMood == null
      ? _homeGames
      : _homeGames
          .where((game) => game.moods.contains(_selectedMood))
          .toList(growable: false);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: _cream,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.85, -0.8),
              radius: 1.3,
              colors: [Color(0xFFFFF4D8), _cream],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final denseMobile = constraints.maxWidth < 370;
                    final horizontalPadding = constraints.maxWidth < 370
                        ? 12.0
                        : constraints.maxWidth < 600
                            ? 20.0
                            : 32.0;

                    return ListView(
                      controller: _scrollController,
                      key: const Key('home-scroll-view'),
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        denseMobile ? 6 : 18,
                        horizontalPadding,
                        denseMobile ? 18 : 32,
                      ),
                      children: [
                        _HomeHeader(onSearch: _showSearch),
                        SizedBox(height: denseMobile ? 8 : 22),
                        Text(
                          'Ready to play?',
                          key: const Key('home-headline'),
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                color: _ink,
                                fontSize: denseMobile ? 29 : 42,
                                height: 1.02,
                                letterSpacing: -1.6,
                                fontWeight: FontWeight.w900,
                              ),
                        ).animate().fadeIn(duration: 350.ms).slideY(begin: .08),
                        SizedBox(height: denseMobile ? 14 : 22),
                        _FeaturedCarousel(
                          onPlay: (route) => Get.toNamed(route),
                        ),
                        SizedBox(height: denseMobile ? 14 : 30),
                        _SectionTitle(
                          title: 'Pick a mood',
                          trailing: _selectedMood == null ? null : 'Clear',
                          onTrailingTap: _selectedMood == null
                              ? null
                              : () => setState(() => _selectedMood = null),
                        ),
                        SizedBox(height: denseMobile ? 8 : 14),
                        _MoodPicker(
                          selected: _selectedMood,
                          onSelected: (mood) {
                            setState(() {
                              _selectedMood =
                                  _selectedMood == mood ? null : mood;
                            });
                          },
                        ),
                        SizedBox(height: denseMobile ? 20 : 32),
                        KeyedSubtree(
                          key: _gamesKey,
                          child: _SectionTitle(
                            title: _selectedMood == null
                                ? 'All games'
                                : '${_moodLabel(_selectedMood!)} games',
                            trailing: '${_visibleGames.length}',
                          ),
                        ),
                        SizedBox(height: denseMobile ? 8 : 14),
                        _GamesGrid(games: _visibleGames),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: _HomeNavigation(
          onGamesTap: _scrollToGames,
          onProfileTap: () => Get.toNamed('/profile'),
        ),
      ),
    );
  }

  void _showSearch() {
    showSearch<void>(
      context: context,
      delegate: _GameSearchDelegate(
        games: _homeGames,
        onSelected: (game) => Get.toNamed(game.route),
      ),
    );
  }

  void _scrollToGames() {
    final gamesContext = _gamesKey.currentContext;
    if (gamesContext == null) return;
    Scrollable.ensureVisible(
      gamesContext,
      duration: 450.ms,
      curve: Curves.easeOutCubic,
      alignment: .08,
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: _cream,
            surfaceTintColor: Colors.transparent,
            title: const Text('Leave GameVerse?'),
            content: const Text('Are you sure you want to exit the app?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('STAY'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: FilledButton.styleFrom(backgroundColor: _orange),
                child: const Text('EXIT'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final denseMobile = MediaQuery.sizeOf(context).width < 370;
    return Row(
      children: [
        Expanded(
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Semantics(
              header: true,
              child: Text.rich(
                const TextSpan(
                  children: [
                    TextSpan(text: 'Game'),
                    TextSpan(
                      text: 'Verse',
                      style: TextStyle(color: _orange),
                    ),
                  ],
                ),
                key: const Key('gameverse-wordmark'),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: _ink,
                      fontSize: denseMobile ? 25 : 31,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                    ),
              ),
            ),
          ),
        ),
        SizedBox(width: denseMobile ? 8 : 12),
        _RoundAction(
          key: const Key('home-search-button'),
          icon: Icons.search_rounded,
          tooltip: 'Search games',
          onTap: onSearch,
        ),
        SizedBox(width: denseMobile ? 7 : 10),
        Semantics(
          button: true,
          label: 'Open profile',
          child: InkWell(
            onTap: () => Get.toNamed('/profile'),
            customBorder: const CircleBorder(),
            child: Container(
              width: denseMobile ? 42 : 50,
              height: denseMobile ? 42 : 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFDCE8FF),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A151515),
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.face_rounded,
                color: _cobalt,
                size: denseMobile ? 24 : 29,
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final denseMobile = MediaQuery.sizeOf(context).width < 370;
    return Material(
      color: Colors.white.withValues(alpha: .88),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: const Color(0x22151515),
      child: IconButton(
        constraints: BoxConstraints.tightFor(
          width: denseMobile ? 42 : 50,
          height: denseMobile ? 42 : 50,
        ),
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon, color: _ink, size: denseMobile ? 22 : 27),
      ),
    );
  }
}

class _FeaturedCarousel extends StatefulWidget {
  const _FeaturedCarousel({required this.onPlay});

  final ValueChanged<String> onPlay;

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  final PageController _pageController = PageController();
  Timer? _advanceTimer;
  int _currentPage = 0;
  bool _isTouching = false;
  bool _reduceMotion = false;
  bool _didPrecacheArtwork = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    _reduceMotion = reduceMotion;

    if (!_didPrecacheArtwork) {
      _didPrecacheArtwork = true;
      Future.wait(
        _featuredGames.map(
          (game) => precacheImage(AssetImage(game.image), context),
        ),
      ).whenComplete(() {
        if (mounted) _scheduleAdvance();
      });
      return;
    }

    _scheduleAdvance();
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _scheduleAdvance() {
    _advanceTimer?.cancel();
    if (_reduceMotion || _isTouching) return;
    _advanceTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || !_pageController.hasClients || _isTouching) return;
      final nextPage = (_currentPage + 1) % _featuredGames.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _setTouching(bool value) {
    if (_isTouching == value) return;
    _isTouching = value;
    if (value) {
      _advanceTimer?.cancel();
    } else {
      _scheduleAdvance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = math.max(218.0, math.min(300.0, width * .72));
        final compact = width < 350;

        return Semantics(
          container: true,
          label:
              'Featured game ${_currentPage + 1} of ${_featuredGames.length}: ${_featuredGames[_currentPage].title}',
          child: Listener(
            onPointerDown: (_) => _setTouching(true),
            onPointerUp: (_) => _setTouching(false),
            onPointerCancel: (_) => _setTouching(false),
            child: Container(
              key: const Key('featured-game-carousel'),
              height: height,
              decoration: BoxDecoration(
                color: _cobalt,
                borderRadius: BorderRadius.circular(compact ? 34 : 44),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F1749B4),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  PageView.builder(
                    key: const Key('featured-game-pages'),
                    controller: _pageController,
                    itemCount: _featuredGames.length,
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                      _scheduleAdvance();
                    },
                    itemBuilder: (context, index) => _FeaturedSlide(
                      key: Key('featured-slide-$index'),
                      game: _featuredGames[index],
                      compact: compact,
                      width: width,
                      onPlay: () => widget.onPlay(_featuredGames[index].route),
                    ),
                  ),
                  Positioned(
                    top: compact ? 10 : 14,
                    right: compact ? 12 : 16,
                    child: _CarouselDots(
                      count: _featuredGames.length,
                      selectedIndex: _currentPage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(duration: 500.ms).scale(
              begin: const Offset(.985, .985),
              curve: Curves.easeOutCubic,
            );
      },
    );
  }
}

class _FeaturedSlide extends StatelessWidget {
  const _FeaturedSlide({
    super.key,
    required this.game,
    required this.compact,
    required this.width,
    required this.onPlay,
  });

  final _FeaturedGame game;
  final bool compact;
  final double width;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: Key('featured-${game.route}'),
      fit: StackFit.expand,
      children: [
        Image.asset(
          game.image,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.medium,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: compact ? .46 : .48,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: game.panelColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(compact ? 82 : 120),
                  bottomRight: Radius.circular(compact ? 44 : 72),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 20 : 28,
              compact ? 24 : 30,
              width * (compact ? .54 : .55),
              compact ? 22 : 28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    game.displayTitle,
                    key: Key('featured-title-${game.route}'),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontSize: compact ? 31 : 42,
                          height: .9,
                          letterSpacing: -1.8,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                SizedBox(height: compact ? 10 : 14),
                Text(
                  game.tagline,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontSize: compact ? 13 : 15,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: compact ? 14 : 20),
                FilledButton.icon(
                  key: Key('featured-play-${game.route}'),
                  onPressed: onPlay,
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  label: const Text('PLAY'),
                  style: FilledButton.styleFrom(
                    minimumSize: Size(compact ? 108 : 132, 48),
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 14 : 18,
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: game.buttonColor,
                    elevation: 3,
                    shadowColor: const Color(0x33000000),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .3,
                    ),
                    shape: const StadiumBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CarouselDots extends StatelessWidget {
  const _CarouselDots({required this.count, required this.selectedIndex});

  final int count;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x33000000),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (index) {
            final selected = index == selectedIndex;
            return AnimatedContainer(
              key: Key('featured-dot-$index-${selected ? 'selected' : 'idle'}'),
              duration: const Duration(milliseconds: 220),
              width: selected ? 18 : 6,
              height: 6,
              margin: EdgeInsets.only(right: index == count - 1 ? 0 : 5),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.white60,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.trailing,
    this.onTrailingTap,
  });

  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    final titleWidget = Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: _ink,
            fontSize: MediaQuery.sizeOf(context).width < 370 ? 15 : 18,
            letterSpacing: .2,
            fontWeight: FontWeight.w900,
          ),
    );

    if (trailing == null) return titleWidget;
    return Row(
      children: [
        Expanded(child: titleWidget),
        if (onTrailingTap == null)
          Text(
            trailing!,
            style: const TextStyle(
              color: Color(0xFF77736C),
              fontWeight: FontWeight.w800,
            ),
          )
        else
          TextButton(onPressed: onTrailingTap, child: Text(trailing!)),
      ],
    );
  }
}

class _MoodPicker extends StatelessWidget {
  const _MoodPicker({required this.selected, required this.onSelected});

  final _GameMood? selected;
  final ValueChanged<_GameMood> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 3;
        final spacing = constraints.maxWidth < 340 ? 6.0 : 10.0;
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * spacing)) / columns;
        return Wrap(
          spacing: spacing,
          children: [
            _MoodChip(
              width: itemWidth,
              label: 'Quick',
              icon: Icons.bolt_rounded,
              foreground: const Color(0xFF008D61),
              background: const Color(0xFFDDF5E9),
              selected: selected == _GameMood.quick,
              onTap: () => onSelected(_GameMood.quick),
            ),
            _MoodChip(
              width: itemWidth,
              label: 'Smart',
              icon: Icons.psychology_rounded,
              foreground: _cobalt,
              background: const Color(0xFFDCE9FF),
              selected: selected == _GameMood.smart,
              onTap: () => onSelected(_GameMood.smart),
            ),
            _MoodChip(
              width: itemWidth,
              label: 'Classic',
              icon: Icons.star_rounded,
              foreground: const Color(0xFFDD3159),
              background: const Color(0xFFFFDFE7),
              selected: selected == _GameMood.classic,
              onTap: () => onSelected(_GameMood.classic),
            ),
          ],
        );
      },
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.width,
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: '$label games',
      child: AnimatedScale(
        duration: 180.ms,
        scale: selected ? .97 : 1,
        child: Material(
          color: selected ? foreground : background,
          borderRadius: BorderRadius.circular(24),
          elevation: selected ? 1 : 0,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              width: width,
              height: width < 100 ? 44 : 52,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width < 100 ? 5 : 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: width < 100 ? 29 : 33,
                      height: width < 100 ? 29 : 33,
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : foreground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: selected ? foreground : Colors.white,
                        size: width < 100 ? 17 : 19,
                      ),
                    ),
                    SizedBox(width: width < 100 ? 4 : 7),
                    Flexible(
                      child: Text(
                        label.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          color: selected ? Colors.white : _ink,
                          fontSize: width < 100 ? 9 : 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GamesGrid extends StatelessWidget {
  const _GamesGrid({required this.games});

  final List<_HomeGame> games;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 620 ? 2 : 3;
        final spacing = constraints.maxWidth < 370 ? 8.0 : 12.0;
        final cardWidth =
            (constraints.maxWidth - ((columns - 1) * spacing)) / columns;
        final cardHeight = math.max(82.0, cardWidth * .60);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var index = 0; index < games.length; index++)
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: _GameCard(game: games[index], index: index),
              ),
          ],
        );
      },
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game, required this.index});

  final _HomeGame game;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Play ${game.name}',
      child: Material(
        color: game.tint,
        borderRadius: BorderRadius.circular(18),
        elevation: 1,
        shadowColor: const Color(0x22191919),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('game-${game.name.toLowerCase().replaceAll(' ', '-')}'),
          onTap: () => Get.toNamed(game.route),
          child: Row(
            children: [
              Expanded(
                flex: 11,
                child: SizedBox.expand(
                  child: Image.asset(
                    game.image,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Text(
                    game.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _ink,
                          fontSize: 12,
                          height: 1.05,
                          letterSpacing: -.35,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (index * 35).ms)
        .fadeIn(duration: 280.ms)
        .slideY(begin: .06);
  }
}

class _HomeNavigation extends StatelessWidget {
  const _HomeNavigation({required this.onGamesTap, required this.onProfileTap});

  final VoidCallback onGamesTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFCF6),
        border: Border(top: BorderSide(color: Color(0x11000000))),
        boxShadow: [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.fromLTRB(
          12,
          MediaQuery.sizeOf(context).width < 370 ? 4 : 8,
          12,
          MediaQuery.sizeOf(context).width < 370 ? 4 : 8,
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(
                    label: 'Home',
                    icon: Icons.home_rounded,
                    selected: true,
                    onTap: () {},
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    label: 'Games',
                    icon: Icons.sports_esports_rounded,
                    onTap: onGamesTap,
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    label: 'Profile',
                    icon: Icons.person_rounded,
                    onTap: onProfileTap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final denseMobile = MediaQuery.sizeOf(context).width < 370;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? _orange : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: denseMobile ? 48 : 58,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: selected ? Colors.white : _ink,
                  size: denseMobile ? 21 : 25,
                ),
                const SizedBox(height: 2),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: selected ? Colors.white : _ink,
                    fontSize: denseMobile ? 9 : 10,
                    letterSpacing: .35,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameSearchDelegate extends SearchDelegate<void> {
  _GameSearchDelegate({required this.games, required this.onSelected})
      : super(
          searchFieldStyle: const TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        );

  final List<_HomeGame> games;
  final ValueChanged<_HomeGame> onSelected;

  @override
  String get searchFieldLabel => 'Search games';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final base = Theme.of(context);
    final readableText = base.textTheme.apply(
      bodyColor: _ink,
      displayColor: _ink,
    );
    return base.copyWith(
      scaffoldBackgroundColor: _cream,
      textTheme: readableText,
      primaryTextTheme: readableText,
      appBarTheme: const AppBarTheme(
        backgroundColor: _cream,
        foregroundColor: _ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme:
          const InputDecorationTheme(border: InputBorder.none),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: _orange,
        selectionColor: Color(0x33FF5A16),
        selectionHandleColor: _orange,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            tooltip: 'Clear search',
            onPressed: () => query = '',
            icon: const Icon(Icons.close_rounded),
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        tooltip: 'Back',
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back_rounded),
      );

  @override
  Widget buildResults(BuildContext context) => _buildMatches(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildMatches(context);

  Widget _buildMatches(BuildContext context) {
    final normalized = query.trim().toLowerCase();
    final matches = games
        .where((game) =>
            normalized.isEmpty || game.name.toLowerCase().contains(normalized))
        .toList(growable: false);

    if (matches.isEmpty) {
      return const Center(child: Text('No games found'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: matches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final game = matches[index];
        return ListTile(
          tileColor: game.tint,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(game.image,
                width: 52, height: 52, fit: BoxFit.cover),
          ),
          title: Text(game.name,
              style: const TextStyle(fontWeight: FontWeight.w800)),
          trailing: const Icon(Icons.arrow_forward_rounded),
          onTap: () {
            close(context, null);
            onSelected(game);
          },
        );
      },
    );
  }
}

String _moodLabel(_GameMood mood) => switch (mood) {
      _GameMood.quick => 'Quick',
      _GameMood.smart => 'Smart',
      _GameMood.classic => 'Classic',
    };
