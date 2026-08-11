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

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * .88;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        constraints: BoxConstraints(maxWidth: 420, maxHeight: maxHeight),
        decoration: ChessDesign.ivoryPanel(radius: 30),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 52,
                height: 6,
                decoration: BoxDecoration(
                    color: ChessDesign.ivoryDeep,
                    borderRadius: BorderRadius.circular(9))),
            const SizedBox(height: 14),
            Text(
                widget.mode == ChessGameMode.ai ? 'VS AI SETUP' : 'LOCAL MATCH',
                style: const TextStyle(
                    color: ChessDesign.navy,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8)),
            const SizedBox(height: 5),
            Text('Tune the match before your first move',
                style: TextStyle(
                    color: ChessDesign.ink.withValues(alpha: .62),
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
            if (widget.mode == ChessGameMode.ai) ...[
              const SizedBox(height: 22),
              const _SectionTitle('PICK A DIFFICULTY'),
              const SizedBox(height: 10),
              Row(children: [
                _Difficulty(
                    value: 1,
                    selected: difficulty,
                    label: 'EASY',
                    caption: 'Learning',
                    icon: Icons.sentiment_satisfied_rounded,
                    color: ChessDesign.teal,
                    onTap: _setDifficulty),
                const SizedBox(width: 8),
                _Difficulty(
                    value: 2,
                    selected: difficulty,
                    label: 'MEDIUM',
                    caption: 'Balanced',
                    icon: Icons.psychology_rounded,
                    color: ChessDesign.blue,
                    onTap: _setDifficulty),
                const SizedBox(width: 8),
                _Difficulty(
                    value: 3,
                    selected: difficulty,
                    label: 'HARD',
                    caption: 'Sharp',
                    icon: Icons.local_fire_department_rounded,
                    color: ChessDesign.orange,
                    onTap: _setDifficulty),
              ]),
            ],
            const SizedBox(height: 22),
            const _SectionTitle('MATCH CLOCK'),
            const SizedBox(height: 9),
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => setState(() => timed = !timed),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                    color: timed
                        ? const Color(0xFFFFE7D9)
                        : const Color(0xFFF0E8D7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color:
                            timed ? ChessDesign.orange : ChessDesign.ivoryDeep,
                        width: 1.5)),
                child: Row(children: [
                  Icon(Icons.timer_rounded,
                      color: timed ? ChessDesign.orange : ChessDesign.ink),
                  const SizedBox(width: 10),
                  const Expanded(
                      child: Text('Timed game',
                          style: TextStyle(
                              color: ChessDesign.ink,
                              fontWeight: FontWeight.w900))),
                  Switch.adaptive(
                      value: timed,
                      onChanged: (value) => setState(() => timed = value),
                      activeTrackColor: ChessDesign.orange),
                ]),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              child: timed
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                          children: [5, 10, 15, 30]
                              .map((value) => Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    child: ChoiceChip(
                                      label: Text('$value min'),
                                      selected: minutes == value,
                                      onSelected: (_) =>
                                          setState(() => minutes = value),
                                      selectedColor: ChessDesign.navy,
                                      backgroundColor: const Color(0xFFF0E8D7),
                                      labelStyle: TextStyle(
                                          color: minutes == value
                                              ? Colors.white
                                              : ChessDesign.ink,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900),
                                      side: BorderSide.none,
                                    ),
                                  )))
                              .toList()),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: Get.back,
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          foregroundColor: ChessDesign.navy,
                          side: const BorderSide(
                              color: ChessDesign.navy, width: 2),
                          shape: const StadiumBorder()),
                      child: const Text('CANCEL',
                          style: TextStyle(fontWeight: FontWeight.w900)))),
              const SizedBox(width: 10),
              Expanded(
                  child: FilledButton(
                      onPressed: () => Get.back(result: {
                            'timerEnabled': timed,
                            'timePerPlayer': minutes,
                            'difficulty': difficulty
                          }),
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          backgroundColor: ChessDesign.orange,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder()),
                      child: const Text('PLAY',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, letterSpacing: 1)))),
            ]),
          ]),
        ),
      ),
    );
  }

  void _setDifficulty(int value) => setState(() => difficulty = value);
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
              letterSpacing: 1.25)));
}

class _Difficulty extends StatelessWidget {
  const _Difficulty(
      {required this.value,
      required this.selected,
      required this.label,
      required this.caption,
      required this.icon,
      required this.color,
      required this.onTap});
  final int value;
  final int selected;
  final String label;
  final String caption;
  final IconData icon;
  final Color color;
  final ValueChanged<int> onTap;
  @override
  Widget build(BuildContext context) {
    final active = value == selected;
    return Expanded(
        child: InkWell(
      onTap: () => onTap(value),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
        decoration: BoxDecoration(
            color: active ? color : const Color(0xFFF0E8D7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: active ? color : ChessDesign.ivoryDeep, width: 2)),
        child: Column(children: [
          Icon(icon, color: active ? Colors.white : color, size: 26),
          const SizedBox(height: 7),
          Text(label,
              style: TextStyle(
                  color: active ? Colors.white : ChessDesign.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(caption,
              style: TextStyle(
                  color: active
                      ? Colors.white.withValues(alpha: .82)
                      : ChessDesign.ink.withValues(alpha: .55),
                  fontSize: 9,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
    ));
  }
}
