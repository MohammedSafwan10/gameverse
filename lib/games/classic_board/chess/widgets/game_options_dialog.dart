import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import 'package:gameverse/theme/app_theme.dart';

class GameOptionsDialog extends StatelessWidget {
  final ChessGameMode mode;

  const GameOptionsDialog({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final timerEnabled = false.obs;
    final selectedTime = 10.obs;
    final selectedDifficulty = 2.obs;
    final primaryAccent = const Color(0xFF00D2FF); // Electric Cyan
    final secondaryAccent = const Color(0xFF9D50BB); // Soft Purple

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 0,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.1), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Premium Header
              Stack(
                children: [
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryAccent.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: AppTheme.glassmorphicDecoration(
                            backgroundColor:
                                primaryAccent.withValues(alpha: 0.1),
                            borderColor: primaryAccent.withValues(alpha: 0.3),
                            borderRadius: 20,
                            hasShadow: false,
                          ),
                          child: Icon(Icons.settings_input_component_rounded,
                              color: primaryAccent, size: 36),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'GAME SETUP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 40,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [primaryAccent, secondaryAccent]),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section: Match Type
                      _buildLabel('CHOOSE MODE'),
                      const SizedBox(height: 12),
                      Obx(() => _buildModeToggle(
                            context,
                            title: 'Timed Match',
                            isEnabled: timerEnabled.value,
                            icon: Icons.timer_rounded,
                            onChanged: (v) => timerEnabled.value = v,
                            accentColor: primaryAccent,
                          )),

                      Obx(() => AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: timerEnabled.value
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: _buildTimeSelector(
                                        context, selectedTime, primaryAccent),
                                  )
                                : const SizedBox.shrink(),
                          )),

                      if (mode == ChessGameMode.ai) ...[
                        const SizedBox(height: 28),
                        _buildLabel('AI DIFFICULTY'),
                        const SizedBox(height: 12),
                        Obx(() =>
                            _buildDifficultyGrid(context, selectedDifficulty)),
                      ],

                      const SizedBox(height: 40),

                      // Footer Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildButton(
                              label: 'BACK',
                              onPressed: () => Get.back(),
                              isOutlined: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildButton(
                              label: 'START',
                              onPressed: () => Get.back(result: {
                                'timerEnabled': timerEnabled.value,
                                'timePerPlayer': selectedTime.value,
                                'difficulty': selectedDifficulty.value,
                              }),
                              backgroundColor: primaryAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.4),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildModeToggle(
    BuildContext context, {
    required String title,
    required bool isEnabled,
    required IconData icon,
    required Function(bool) onChanged,
    required Color accentColor,
  }) {
    return InkWell(
      onTap: () => onChanged(!isEnabled),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isEnabled
              ? accentColor.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEnabled
                ? accentColor.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isEnabled ? accentColor : Colors.white24, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isEnabled ? Colors.white : Colors.white60,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: isEnabled,
                onChanged: onChanged,
                activeThumbColor: accentColor,
                activeTrackColor: accentColor.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(
      BuildContext context, RxInt selected, Color accentColor) {
    final times = [5, 10, 15, 30];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 14, color: Colors.white38),
              const SizedBox(width: 8),
              const Text('MINUTES PER PLAYER',
                  style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: times.map((t) {
              final isSelected = selected.value == t;
              return Expanded(
                child: GestureDetector(
                  onTap: () => selected.value = t,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accentColor
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: accentColor.withValues(alpha: 0.3),
                                  blurRadius: 10)
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$t',
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF0F172A)
                              : Colors.white70,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyGrid(BuildContext context, RxInt selected) {
    final levels = [
      (
        1,
        'EASY',
        Icons.face_6_rounded,
        const Color(0xFF2ECC71)
      ), // Emerald Green
      (2, 'PRO', Icons.workspace_premium_rounded, Colors.blueAccent),
      (3, 'ELITE', Icons.auto_awesome_rounded, Colors.purpleAccent),
    ];

    return Row(
      children: levels.map((l) {
        final isSelected = selected.value == l.$1;
        final color = l.$4;
        return Expanded(
          child: GestureDetector(
            onTap: () => selected.value = l.$1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected ? color : Colors.white.withValues(alpha: 0.08),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(l.$3,
                      color: isSelected ? color : Colors.white24, size: 28),
                  const SizedBox(height: 10),
                  Text(
                    l.$2,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: isSelected ? color : Colors.white24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButton(
      {required String label,
      required VoidCallback onPressed,
      bool isOutlined = false,
      Color? backgroundColor}) {
    return isOutlined
        ? OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 13)),
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: Colors.white,
              elevation: 10,
              shadowColor: backgroundColor?.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 13)),
          );
  }
}
