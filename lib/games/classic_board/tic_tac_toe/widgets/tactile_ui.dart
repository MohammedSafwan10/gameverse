import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/game_difficulty.dart';

const tttInk = Color(0xFF092A50);
const tttOrange = Color(0xFFFF650B);
const tttBlue = Color(0xFF075CCE);
const tttCream = Color(0xFFFFF2DB);
const tttAssets = 'assets/images/games/tic_tac_toe/';

TextStyle tttText(double size, {Color color = tttInk, bool heavy = false}) =>
    TextStyle(
        fontFamily: heavy ? 'BarlowCondensed' : 'Barlow',
        fontSize: size,
        fontWeight: heavy ? FontWeight.w800 : FontWeight.w600,
        color: color);

class TactilePage extends StatelessWidget {
  const TactilePage({super.key, required this.builder});
  final Widget Function(BuildContext, BoxConstraints) builder;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: tttCream,
        body: Stack(children: [
          Positioned.fill(
              child: Image.asset('${tttAssets}cream-background.png',
                  fit: BoxFit.cover)),
          SafeArea(
              child: LayoutBuilder(
                  builder: (context, constraints) => Center(
                        child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: DefaultTextStyle(
                                style: tttText(15),
                                child: builder(context, constraints))),
                      ))),
        ]),
      );
}

class TactileSurface extends StatelessWidget {
  const TactileSurface(
      {super.key,
      required this.child,
      this.color = tttCream,
      this.padding = const EdgeInsets.all(16),
      this.radius = 24,
      this.selected = false});
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool selected;
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(color, Colors.white, .22)!,
                color,
                Color.lerp(color, const Color(0xFFB8905E), .12)!
              ]),
          border: Border.all(
              color: selected ? tttOrange : const Color(0xFFFFFCF2),
              width: selected ? 2.5 : 2),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF77542E).withValues(alpha: .20),
                blurRadius: 10,
                offset: const Offset(0, 6)),
            BoxShadow(
                color: color.withValues(alpha: .7),
                blurRadius: 1,
                offset: const Offset(0, 2))
          ],
        ),
        child: child,
      );
}

class TactileButton extends StatelessWidget {
  const TactileButton(this.label,
      {super.key, required this.onPressed, this.primary = false, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(24),
            child: TactileSurface(
                color: primary ? tttOrange : tttCream,
                radius: 24,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  if (icon != null) ...[
                    Icon(icon, color: primary ? Colors.white : tttInk),
                    const SizedBox(width: 10)
                  ],
                  Flexible(
                      child: Text(label,
                          textAlign: TextAlign.center,
                          style: tttText(22,
                              heavy: true,
                              color: primary ? Colors.white : tttInk)))
                ]))),
      ));
}

class TactileIcon extends StatelessWidget {
  const TactileIcon(this.icon,
      {super.key, required this.label, required this.onPressed});
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Tooltip(
      message: label,
      child: Semantics(
          label: label,
          button: true,
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: onPressed,
                  customBorder: const CircleBorder(),
                  child: TactileSurface(
                      radius: 50,
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                          width: 26,
                          height: 26,
                          child: Icon(icon, color: tttInk, size: 26)))))));
}

class TactileTitle extends StatelessWidget {
  const TactileTitle(this.title,
      {super.key, this.size = 40, this.color = tttInk});
  final String title;
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => Text(title,
      textAlign: TextAlign.center,
      style: tttText(size, color: color, heavy: true).copyWith(
          height: 1.05,
          shadows: [
            const Shadow(
                color: Color(0xFFB69E7B), offset: Offset(0, 3), blurRadius: 2)
          ]));
}

class TactileGameTitle extends StatelessWidget {
  const TactileGameTitle({super.key, this.size = 54});
  final double size;
  @override
  Widget build(BuildContext context) => FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        TactileTitle('TIC ', size: size),
        TactileTitle('TAC ', size: size, color: tttOrange),
        TactileTitle('TOE', size: size)
      ]));
}

class TactilePiece extends StatelessWidget {
  const TactilePiece(this.player, {super.key, this.size});
  final Player player;
  final double? size;
  @override
  Widget build(BuildContext context) => player == Player.none
      ? const SizedBox.shrink()
      : Image.asset(
          '$tttAssets${player == Player.x ? 'x-piece' : 'o-piece'}.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          excludeFromSemantics: true);
}

class TactileBoard extends StatelessWidget {
  const TactileBoard(
      {super.key,
      required this.board,
      this.onMove,
      this.winningLine = const [],
      this.enabled = false});
  final List<Player> board;
  final List<int> winningLine;
  final ValueChanged<int>? onMove;
  final bool enabled;
  @override
  Widget build(BuildContext context) => AspectRatio(
      aspectRatio: 1,
      child: TactileSurface(
        radius: 24,
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
            builder: (context, constraints) => Stack(children: [
                  GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: 9,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6),
                      itemBuilder: (context, i) {
                        final available = enabled && board[i] == Player.none;
                        return Semantics(
                            label:
                                'Row ${i ~/ 3 + 1}, column ${i % 3 + 1}, ${board[i] == Player.none ? 'empty' : board[i].symbol}',
                            button: available,
                            child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                    key: ValueKey('ttt-cell-$i'),
                                    onTap: available
                                        ? () => onMove?.call(i)
                                        : null,
                                    borderRadius: BorderRadius.circular(14),
                                    child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 180),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            gradient: const LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFFE8D2B1),
                                                  Color(0xFFFFF3DF),
                                                  Color(0xFFFFF8EB)
                                                ]),
                                            border: Border.all(
                                                color: winningLine.contains(i)
                                                    ? tttOrange
                                                    : const Color(0xFFD8BC95),
                                                width: 1.5)),
                                        padding: const EdgeInsets.all(3),
                                        child: AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 190),
                                            transitionBuilder: (child, animation) =>
                                                ScaleTransition(scale: animation, child: child),
                                            child: TactilePiece(board[i], key: ValueKey(board[i])))))));
                      }),
                  if (winningLine.length == 3)
                    Positioned.fill(
                        child: IgnorePointer(
                            child: CustomPaint(
                                painter: _WinningLine(
                                    winningLine,
                                    board[winningLine.first] == Player.x
                                        ? tttOrange
                                        : tttBlue)))),
                ])),
      ));
}

class _WinningLine extends CustomPainter {
  _WinningLine(this.line, this.color);
  final List<int> line;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    Offset center(int i) => Offset((i % 3 + .5) * (size.width + 6) / 3 - 3,
        (i ~/ 3 + .5) * (size.height + 6) / 3 - 3);
    canvas.drawLine(
        center(line.first),
        center(line.last),
        Paint()
          ..color = color.withValues(alpha: .65)
          ..strokeWidth = math.max(3, size.width / 65)
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_WinningLine old) =>
      old.line != line || old.color != color;
}

Future<bool> tactileConfirm(BuildContext context,
        {required String title,
        required String message,
        required String action,
        bool leave = false}) async =>
    await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                    child: TactileSurface(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(leave ? Icons.logout_rounded : Icons.restart_alt_rounded,
                      color: tttOrange, size: 48),
                  const SizedBox(height: 14),
                  TactileTitle(title, size: 30),
                  const SizedBox(height: 10),
                  Text(message,
                      textAlign: TextAlign.center, style: tttText(16)),
                  const SizedBox(height: 24),
                  TactileButton('KEEP PLAYING',
                      primary: leave,
                      onPressed: () => Navigator.pop(context, false)),
                  const SizedBox(height: 12),
                  TactileButton(action,
                      primary: !leave,
                      onPressed: () => Navigator.pop(context, true)),
                ])))))) ??
    false;

class TactileDifficultyPage extends StatefulWidget {
  const TactileDifficultyPage(
      {super.key,
      required this.initial,
      required this.onSelected,
      this.startGame = true});
  final GameDifficulty initial;
  final ValueChanged<GameDifficulty> onSelected;
  final bool startGame;
  @override
  State<TactileDifficultyPage> createState() => _TactileDifficultyPageState();
}

class _TactileDifficultyPageState extends State<TactileDifficultyPage> {
  late GameDifficulty selected = widget.initial;
  static const descriptions = [
    'A relaxed start',
    'A balanced challenge',
    'Think ahead',
    'Can you force a draw?'
  ];
  @override
  Widget build(BuildContext context) => TactilePage(
      builder: (context, c) => SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            Align(
                alignment: Alignment.centerLeft,
                child: TactileIcon(Icons.arrow_back_rounded,
                    label: 'Back', onPressed: () => Navigator.pop(context))),
            const SizedBox(height: 12),
            const TactileTitle('PLAY VS AI'),
            const SizedBox(height: 6),
            Text('Choose your challenge', style: tttText(18)),
            Image.asset('${tttAssets}paired-pieces.png',
                height: c.maxHeight < 650 ? 90 : 150),
            for (final difficulty in GameDifficulty.values)
              Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Semantics(
                      selected: selected == difficulty,
                      button: true,
                      child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                              onTap: () =>
                                  setState(() => selected = difficulty),
                              borderRadius: BorderRadius.circular(24),
                              child: TactileSurface(
                                  selected: selected == difficulty,
                                  padding: const EdgeInsets.all(13),
                                  child: Row(children: [
                                    TactilePiece(
                                        difficulty.index.isEven
                                            ? Player.x
                                            : Player.o,
                                        size: 46),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          Text(
                                              difficulty.displayName
                                                  .toUpperCase(),
                                              style: tttText(25, heavy: true)),
                                          Text(descriptions[difficulty.index],
                                              style: tttText(13)),
                                        ])),
                                    Icon(
                                        selected == difficulty
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: selected == difficulty
                                            ? tttOrange
                                            : const Color(0xFFAA9476)),
                                  ])))))),
            const SizedBox(height: 8),
            TactileButton(widget.startGame ? 'START GAME' : 'SAVE DIFFICULTY',
                primary: true,
                icon: Icons.arrow_forward_rounded,
                onPressed: () => widget.onSelected(selected)),
          ])));
}

class TactileHelpPage extends StatelessWidget {
  const TactileHelpPage({super.key});
  @override
  Widget build(BuildContext context) => TactilePage(
      builder: (context, c) => SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            Align(
                alignment: Alignment.centerLeft,
                child: TactileIcon(Icons.arrow_back_rounded,
                    label: 'Back', onPressed: () => Navigator.pop(context))),
            const SizedBox(height: 12),
            const TactileTitle('HOW TO PLAY'),
            Image.asset('${tttAssets}paired-pieces.png',
                height: c.maxHeight < 650 ? 70 : 110),
            _section('1', 'TAKE TURNS', 'Place your piece in an empty square.',
                const SizedBox.shrink()),
            _section(
                '2',
                'MAKE A LINE',
                'Match three across, down, or diagonally.',
                Row(children: [
                  for (final line in const [
                    [0, 1, 2],
                    [1, 4, 7],
                    [0, 4, 8]
                  ])
                    Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: TactileBoard(
                                board: List.generate(
                                    9,
                                    (i) => line.contains(i)
                                        ? Player.x
                                        : Player.none),
                                winningLine: line))),
                ])),
            _section(
                '3',
                'FULL BOARD?',
                'No winning line means a draw.',
                Center(
                    child: SizedBox(
                        width: 110,
                        child: TactileBoard(board: const [
                          Player.x,
                          Player.o,
                          Player.x,
                          Player.x,
                          Player.o,
                          Player.o,
                          Player.o,
                          Player.x,
                          Player.x
                        ])))),
            TactileButton('GOT IT',
                primary: true, onPressed: () => Navigator.pop(context)),
          ])));
  Widget _section(String n, String title, String text, Widget diagram) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TactileSurface(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  CircleAvatar(
                      backgroundColor: tttOrange,
                      child: Text(n, style: tttText(20, color: Colors.white))),
                  const SizedBox(width: 12),
                  Expanded(child: Text(title, style: tttText(26, heavy: true)))
                ]),
                const SizedBox(height: 8),
                Text(text, style: tttText(15)),
                const SizedBox(height: 10),
                diagram,
              ])));
}
