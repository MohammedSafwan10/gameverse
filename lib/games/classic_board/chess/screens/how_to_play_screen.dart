import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/chess_design.dart';

class ChessHowToPlayScreen extends StatelessWidget {
  const ChessHowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: ChessDesign.background),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(child: _GuideHeader()),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                      sliver: SliverList.list(children: const [
                        _WinCard(),
                        SizedBox(height: 12),
                        _MoveCard(),
                        SizedBox(height: 12),
                        _SpecialMovesCard(),
                        SizedBox(height: 16),
                        _StartButton(),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class _GuideHeader extends StatelessWidget {
  const _GuideHeader();

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        padding: const EdgeInsets.fromLTRB(10, 11, 16, 11),
        decoration: BoxDecoration(
          color: ChessDesign.ivory,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: ChessDesign.gold, width: 2),
          boxShadow: ChessDesign.raisedShadow,
        ),
        child: Row(children: [
          IconButton.filled(
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: ChessDesign.navy,
              foregroundColor: ChessDesign.ivory,
              minimumSize: const Size(48, 48),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text('HOW TO PLAY',
                  maxLines: 1,
                  style: TextStyle(
                    color: ChessDesign.navy,
                    fontFamily: 'BarlowCondensed',
                    fontWeight: FontWeight.w900,
                    fontSize: 31,
                    height: .95,
                    letterSpacing: .6,
                  )),
            ),
          ),
          const Icon(Icons.workspace_premium_rounded,
              color: ChessDesign.gold, size: 30),
        ]),
      );
}

class _WinCard extends StatelessWidget {
  const _WinCard();

  @override
  Widget build(BuildContext context) => _IvoryCard(
        child: SizedBox(
          height: 130,
          child: Row(children: [
            Expanded(
              flex: 5,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _Eyebrow('THE GOAL'),
                    const SizedBox(height: 4),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text('WIN THE GAME',
                          maxLines: 1,
                          style: TextStyle(
                            color: ChessDesign.navy,
                            fontFamily: 'BarlowCondensed',
                            fontSize: 27,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          )),
                    ),
                    const SizedBox(height: 8),
                    Text('Checkmate the rival king so it has no legal escape.',
                        style: TextStyle(
                          color: ChessDesign.ink.withValues(alpha: .72),
                          fontSize: 11.5,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                        )),
                  ]),
            ),
            Expanded(
              flex: 4,
              child: Stack(alignment: Alignment.bottomCenter, children: [
                Positioned(
                  right: 0,
                  bottom: 1,
                  child: Transform.rotate(
                    angle: math.pi / 2.7,
                    child: SizedBox(
                      width: 76,
                      height: 76,
                      child: Image.asset(
                          'assets/images/games/chess/pieces_v2/black_king.png',
                          fit: BoxFit.contain),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: 92,
                    height: 118,
                    child: Image.asset(
                        'assets/images/games/chess/pieces_v2/white_king.png',
                        fit: BoxFit.contain),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      );
}

class _MoveCard extends StatelessWidget {
  const _MoveCard();

  @override
  Widget build(BuildContext context) => _IvoryCard(
        child: Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const _Eyebrow('YOUR TURN'),
              const SizedBox(height: 4),
              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('MAKE A MOVE',
                    maxLines: 1,
                    style: TextStyle(
                      color: ChessDesign.navy,
                      fontFamily: 'BarlowCondensed',
                      fontSize: 24,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    )),
              ),
              const SizedBox(height: 7),
              Text(
                  'Tap a piece, then tap one of its highlighted legal squares.',
                  style: TextStyle(
                    color: ChessDesign.ink.withValues(alpha: .72),
                    fontSize: 11,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  )),
            ]),
          ),
          const SizedBox(width: 12),
          const _MiniBoard(),
        ]),
      );
}

class _MiniBoard extends StatelessWidget {
  const _MiniBoard();

  @override
  Widget build(BuildContext context) => Container(
        width: 116,
        height: 116,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: ChessDesign.navyDeep,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ChessDesign.gold, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4),
            itemCount: 16,
            itemBuilder: (context, index) {
              final row = index ~/ 4;
              final col = index % 4;
              final highlighted = index == 6 || index == 9 || index == 14;
              return ColoredBox(
                color: highlighted
                    ? ChessDesign.orange
                    : (row + col).isEven
                        ? const Color(0xFFFFE6B4)
                        : ChessDesign.navy,
                child: index == 10
                    ? Padding(
                        padding: const EdgeInsets.all(1),
                        child: Image.asset(
                            'assets/images/games/chess/pieces_v2/white_knight.png'),
                      )
                    : null,
              );
            },
          ),
        ),
      );
}

class _SpecialMovesCard extends StatelessWidget {
  const _SpecialMovesCard();

  @override
  Widget build(BuildContext context) => _IvoryCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const _Eyebrow('POWER PLAYS'),
          const SizedBox(height: 4),
          const Text('SPECIAL MOVES',
              style: TextStyle(
                color: ChessDesign.navy,
                fontFamily: 'BarlowCondensed',
                fontSize: 25,
                height: 1,
                fontWeight: FontWeight.w900,
              )),
          const SizedBox(height: 10),
          const Row(children: [
            _MoveTile(
              label: 'CASTLING',
              detail: 'King + rook',
              first: 'white_king',
              second: 'white_rook',
            ),
            SizedBox(width: 7),
            _MoveTile(
              label: 'EN PASSANT',
              detail: 'Pawn capture',
              first: 'white_pawn',
              second: 'black_pawn',
            ),
            SizedBox(width: 7),
            _MoveTile(
              label: 'PROMOTION',
              detail: 'Pawn to queen',
              first: 'white_pawn',
              second: 'white_queen',
            ),
          ]),
        ]),
      );
}

class _MoveTile extends StatelessWidget {
  const _MoveTile(
      {required this.label,
      required this.detail,
      required this.first,
      required this.second});
  final String label;
  final String detail;
  final String first;
  final String second;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.fromLTRB(3, 6, 3, 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD7C8AA)),
          ),
          child: Column(children: [
            SizedBox(
              height: 52,
              child: Stack(alignment: Alignment.center, children: [
                Positioned(
                  left: 2,
                  child: Image.asset(
                      'assets/images/games/chess/pieces_v2/$first.png',
                      width: 45,
                      height: 52),
                ),
                Positioned(
                  right: 1,
                  child: Image.asset(
                      'assets/images/games/chess/pieces_v2/$second.png',
                      width: 45,
                      height: 52),
                ),
              ]),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label,
                  style: const TextStyle(
                      color: ChessDesign.navy,
                      fontSize: 10,
                      fontWeight: FontWeight.w900)),
            ),
            Text(detail,
                maxLines: 1,
                style: TextStyle(
                    color: ChessDesign.ink.withValues(alpha: .58),
                    fontSize: 8,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}

class _StartButton extends StatelessWidget {
  const _StartButton();

  @override
  Widget build(BuildContext context) => FilledButton.icon(
        onPressed: Get.back,
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: ChessDesign.orange,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          elevation: 7,
          shadowColor: ChessDesign.orange.withValues(alpha: .5),
        ),
        icon: const Icon(Icons.play_arrow_rounded, size: 26),
        label: const Text('START PLAYING',
            style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1)),
      );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
        color: ChessDesign.orange,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ));
}

class _IvoryCard extends StatelessWidget {
  const _IvoryCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ChessDesign.ivory,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: ChessDesign.gold.withValues(alpha: .82), width: 1.5),
          boxShadow: ChessDesign.raisedShadow,
        ),
        child: child,
      );
}
