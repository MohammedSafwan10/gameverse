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
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: Row(children: [
                      IconButton.filled(
                        onPressed: Get.back,
                        icon: const Icon(Icons.arrow_back_rounded),
                        style: IconButton.styleFrom(
                            backgroundColor: ChessDesign.ivory,
                            foregroundColor: ChessDesign.ink),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text('HOW TO PLAY',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  letterSpacing: 1.2)),
                        ),
                      ),
                    ]),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                      children: const [
                        _GuideCard(
                            number: '1',
                            title: 'Protect your king',
                            body:
                                'Your goal is checkmate: attack the rival king so it has no legal escape.',
                            icon: Icons.shield_rounded,
                            color: ChessDesign.orange),
                        _GuideCard(
                            number: '2',
                            title: 'Tap, then move',
                            body:
                                'Tap one of your pieces. Highlighted squares show every legal move you can make.',
                            icon: Icons.touch_app_rounded,
                            color: ChessDesign.teal),
                        _GuideCard(
                            number: '3',
                            title: 'Know the pieces',
                            body:
                                'Rooks move straight, bishops diagonally, queens both ways, knights jump, and pawns move forward.',
                            icon: Icons.grid_view_rounded,
                            color: ChessDesign.gold),
                        _GuideCard(
                            number: '4',
                            title: 'Special moves',
                            body:
                                'Castle to protect your king. Reach the far rank with a pawn to promote it.',
                            icon: Icons.auto_awesome_rounded,
                            color: Color(0xFF7C5CE7)),
                        _GuideCard(
                            number: '5',
                            title: 'Watch the clock',
                            body:
                                'In timed games, each move starts your opponent’s clock. Running out of time loses the match.',
                            icon: Icons.timer_rounded,
                            color: ChessDesign.red),
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

class _GuideCard extends StatelessWidget {
  const _GuideCard(
      {required this.number,
      required this.title,
      required this.body,
      required this.icon,
      required this.color});
  final String number;
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: ChessDesign.ivoryPanel(radius: 24),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: Colors.white, size: 27)),
          const SizedBox(width: 15),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('$number  $title',
                    style: const TextStyle(
                        color: ChessDesign.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(body,
                    style: TextStyle(
                        color: ChessDesign.ink.withValues(alpha: .72),
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w600)),
              ])),
        ]),
      );
}
