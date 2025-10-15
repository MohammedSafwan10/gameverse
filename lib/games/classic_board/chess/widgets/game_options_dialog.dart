import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';

class GameOptionsDialog extends StatelessWidget {
  final ChessGameMode mode;

  const GameOptionsDialog({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timerEnabled = false.obs;
    final selectedTime = 10.obs;
    final selectedDifficulty = 2.obs;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Game Options',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Timer Settings
              Text(
                'Timer',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Obx(() => SwitchListTile(
                    value: timerEnabled.value,
                    onChanged: (value) => timerEnabled.value = value,
                    title: const Text('Enable Timer'),
                    contentPadding: EdgeInsets.zero,
                  )),
              Obx(() => timerEnabled.value
                  ? Column(
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Time per player: '),
                            const Spacer(),
                            DropdownButton<int>(
                              value: selectedTime.value,
                              items: [5, 10, 15, 20, 30]
                                  .map((minutes) => DropdownMenuItem(
                                        value: minutes,
                                        child: Text('$minutes min'),
                                      ))
                                  .toList(),
                              onChanged: (value) => selectedTime.value = value!,
                            ),
                          ],
                        ),
                      ],
                    )
                  : const SizedBox.shrink()),

              // AI Difficulty (only for AI mode)
              if (mode == ChessGameMode.ai) ...[
                const SizedBox(height: 24),
                Text(
                  'AI Difficulty',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Level: '),
                    const Spacer(),
                    Obx(() => DropdownButton<int>(
                          value: selectedDifficulty.value,
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Easy')),
                            DropdownMenuItem(value: 2, child: Text('Medium')),
                            DropdownMenuItem(value: 3, child: Text('Hard')),
                          ],
                          onChanged: (value) => selectedDifficulty.value = value!,
                        )),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => Get.back(result: {
                      'timerEnabled': timerEnabled.value,
                      'timePerPlayer': selectedTime.value,
                      'difficulty': selectedDifficulty.value,
                    }),
                    child: const Text('Start Game'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
