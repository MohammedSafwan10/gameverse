import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../theme/chess_design.dart';

class GameOptionsDialog extends StatefulWidget {
  const GameOptionsDialog({super.key, required this.mode});

  final ChessGameMode mode;

  @override
  State<GameOptionsDialog> createState() => _GameOptionsDialogState();
}

class _GameOptionsDialogState extends State<GameOptionsDialog> {
  bool timed = false;
  int minutes = 10;
  int difficulty = 2;

  bool get isAi => widget.mode == ChessGameMode.ai;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final compact = screen.height < 650;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          EdgeInsets.symmetric(horizontal: screen.width < 350 ? 10 : 16),
      child: Container(
        constraints:
            BoxConstraints(maxWidth: 410, maxHeight: screen.height * .92),
        decoration: BoxDecoration(
          color: ChessDesign.ivory,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: ChessDesign.gold, width: 2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x99000818),
                blurRadius: 28,
                offset: Offset(0, 14)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(18, compact ? 14 : 20, 18, 18),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _DialogHero(isAi: isAi, compact: compact),
              SizedBox(height: compact ? 12 : 18),
              const _SectionTitle('PLAY MODE'),
              const SizedBox(height: 8),
              _ModePicker(
                timed: timed,
                onChanged: (value) => setState(() => timed = value),
              ),
              const SizedBox(height: 14),
              const _SectionTitle('TIME PER PLAYER'),
              const SizedBox(height: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: timed ? 1 : .48,
                child: Row(
                  children: [5, 10, 15, 30]
                      .map((value) => Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              child: _MinuteChip(
                                value: value,
                                selected: minutes == value,
                                enabled: timed,
                                onTap: () => setState(() {
                                  timed = true;
                                  minutes = value;
                                }),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              SizedBox(height: compact ? 14 : 18),
              if (isAi) ...[
                const _SectionTitle('AI DIFFICULTY'),
                const SizedBox(height: 8),
                Row(children: [
                  _Difficulty(
                    value: 1,
                    selected: difficulty,
                    label: 'EASY',
                    caption: 'Learning',
                    asset: 'assets/images/games/chess/pieces_v2/white_pawn.png',
                    onTap: _setDifficulty,
                  ),
                  const SizedBox(width: 7),
                  _Difficulty(
                    value: 2,
                    selected: difficulty,
                    label: 'MEDIUM',
                    caption: 'Balanced',
                    asset:
                        'assets/images/games/chess/pieces_v2/white_knight.png',
                    onTap: _setDifficulty,
                  ),
                  const SizedBox(width: 7),
                  _Difficulty(
                    value: 3,
                    selected: difficulty,
                    label: 'HARD',
                    caption: 'Expert',
                    asset:
                        'assets/images/games/chess/pieces_v2/black_queen.png',
                    onTap: _setDifficulty,
                  ),
                ]),
              ] else
                const _LocalPlayersCard(),
              SizedBox(height: compact ? 16 : 22),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: Get.back,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      foregroundColor: ChessDesign.navy,
                      side: const BorderSide(color: ChessDesign.navy, width: 2),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('BACK',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () => Get.back(result: {
                      'timerEnabled': timed,
                      'timePerPlayer': minutes,
                      'difficulty': difficulty,
                    }),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      backgroundColor: ChessDesign.orange,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 5,
                      shadowColor: ChessDesign.orange.withValues(alpha: .45),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('START MATCH',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, letterSpacing: .7)),
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  void _setDifficulty(int value) => setState(() => difficulty = value);
}

class _DialogHero extends StatelessWidget {
  const _DialogHero({required this.isAi, required this.compact});

  final bool isAi;
  final bool compact;

  @override
  Widget build(BuildContext context) => Row(children: [
        SizedBox(
          width: compact ? 72 : 84,
          height: compact ? 64 : 76,
          child: Stack(alignment: Alignment.center, children: [
            Container(
              width: compact ? 60 : 68,
              height: compact ? 60 : 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ChessDesign.navy,
                border: Border.all(color: ChessDesign.gold, width: 3),
              ),
              child: const Icon(Icons.timer_rounded,
                  color: ChessDesign.ivory, size: 34),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                    color: ChessDesign.orange, shape: BoxShape.circle),
                child: Icon(
                    isAi ? Icons.memory_rounded : Icons.people_alt_rounded,
                    color: Colors.white,
                    size: 17),
              ),
            ),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text('MATCH SETUP',
                  maxLines: 1,
                  style: TextStyle(
                    color: ChessDesign.navy,
                    fontFamily: 'BarlowCondensed',
                    fontSize: 31,
                    height: .95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
                  )),
            ),
            const SizedBox(height: 5),
            Text(isAi ? 'CHALLENGE THE COMPUTER' : 'PLAY TOGETHER',
                style: const TextStyle(
                  color: ChessDesign.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                )),
          ]),
        ),
      ]);
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: const TextStyle(
              color: ChessDesign.ink,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.25,
            )),
      );
}

class _ModePicker extends StatelessWidget {
  const _ModePicker({required this.timed, required this.onChanged});
  final bool timed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE8DDC7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          _ModeChoice(
            label: 'CASUAL',
            icon: Icons.all_inclusive_rounded,
            active: !timed,
            onTap: () => onChanged(false),
          ),
          _ModeChoice(
            label: 'TIMED',
            icon: Icons.timer_rounded,
            active: timed,
            onTap: () => onChanged(true),
          ),
        ]),
      );
}

class _ModeChoice extends StatelessWidget {
  const _ModeChoice(
      {required this.label,
      required this.icon,
      required this.active,
      required this.onTap});
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: active ? ChessDesign.navy : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: active
                  ? const [
                      BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 5,
                          offset: Offset(0, 2))
                    ]
                  : null,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon,
                  size: 17,
                  color: active ? ChessDesign.ivory : ChessDesign.ink),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    color: active ? ChessDesign.ivory : ChessDesign.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  )),
            ]),
          ),
        ),
      );
}

class _MinuteChip extends StatelessWidget {
  const _MinuteChip(
      {required this.value,
      required this.selected,
      required this.enabled,
      required this.onTap});
  final int value;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected && enabled ? ChessDesign.orange : Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected && enabled
                  ? ChessDesign.orange
                  : const Color(0xFFD7C8AA),
              width: 1.5,
            ),
          ),
          child: Text('$value',
              style: TextStyle(
                color: selected && enabled ? Colors.white : ChessDesign.ink,
                fontWeight: FontWeight.w900,
              )),
        ),
      );
}

class _Difficulty extends StatelessWidget {
  const _Difficulty({
    required this.value,
    required this.selected,
    required this.label,
    required this.caption,
    required this.asset,
    required this.onTap,
  });

  final int value;
  final int selected;
  final String label;
  final String caption;
  final String asset;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final active = value == selected;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(value),
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.fromLTRB(3, 5, 3, 8),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFFE8D9) : Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
                color: active ? ChessDesign.orange : const Color(0xFFD7C8AA),
                width: 2),
            boxShadow: active
                ? const [
                    BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 7,
                        offset: Offset(0, 3))
                  ]
                : null,
          ),
          child: Column(children: [
            SizedBox(
                height: 52, child: Image.asset(asset, fit: BoxFit.contain)),
            Text(label,
                style: const TextStyle(
                    color: ChessDesign.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w900)),
            Text(caption,
                style: TextStyle(
                  color: ChessDesign.ink.withValues(alpha: .60),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                )),
          ]),
        ),
      ),
    );
  }
}

class _LocalPlayersCard extends StatelessWidget {
  const _LocalPlayersCard();

  @override
  Widget build(BuildContext context) => Container(
        height: 94,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD7C8AA), width: 1.5),
        ),
        child: Row(children: [
          Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text('PASS & PLAY',
                        maxLines: 1,
                        style: TextStyle(
                            color: ChessDesign.navy,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .8)),
                  ),
                  const SizedBox(height: 4),
                  Text('Two players, one board',
                      style: TextStyle(
                          color: ChessDesign.ink.withValues(alpha: .65),
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ]),
          ),
          SizedBox(
              width: 50,
              child: Image.asset(
                  'assets/images/games/chess/pieces_v2/white_king.png')),
          Transform.translate(
            offset: const Offset(-8, 0),
            child: SizedBox(
                width: 50,
                child: Image.asset(
                    'assets/images/games/chess/pieces_v2/black_king.png')),
          ),
        ]),
      );
}
