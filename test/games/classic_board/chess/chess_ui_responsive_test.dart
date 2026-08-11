import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gameverse/games/classic_board/chess/controllers/game_controller.dart';
import 'package:gameverse/games/classic_board/chess/screens/game_screen.dart';
import 'package:gameverse/games/classic_board/chess/screens/how_to_play_screen.dart';
import 'package:gameverse/games/classic_board/chess/screens/mode_selection_screen.dart';
import 'package:gameverse/games/classic_board/chess/services/ai_service.dart';
import 'package:gameverse/games/classic_board/chess/services/sound_service.dart';
import 'package:gameverse/games/classic_board/chess/services/storage_service.dart';
import 'package:gameverse/games/classic_board/chess/theme/chess_design.dart';
import 'package:gameverse/games/classic_board/chess/widgets/game_options_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() => Get.reset());

  const phoneSizes = [
    Size(320, 568),
    Size(360, 800),
    Size(390, 844),
    Size(430, 932),
  ];

  for (final size in phoneSizes) {
    testWidgets(
        'mode selection has no overflow at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      _registerGame();
      await tester
          .pumpWidget(const GetMaterialApp(home: ChessModeSelectionScreen()));
      await tester.pump();
      expect(find.text('PLAY VS AI'), findsOneWidget);
      expect(find.text('TWO PLAYERS'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });

    testWidgets(
        'how-to screen has no overflow at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        const GetMaterialApp(home: ChessHowToPlayScreen()),
      );
      await tester.pump();
      expect(find.text('HOW TO PLAY'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'AI setup dialog fits at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(body: GameOptionsDialog(mode: ChessGameMode.ai)),
        ),
      );
      await tester.pump();
      expect(find.text('PICK A DIFFICULTY'), findsOneWidget);
      expect(find.text('EASY'), findsOneWidget);
      expect(find.text('MEDIUM'), findsOneWidget);
      expect(find.text('HARD'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'game board has no overflow at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      _registerGame();
      await tester.pumpWidget(const GetMaterialApp(home: ChessGameScreen()));
      await tester.pump();
      expect(find.text('LOCAL MATCH'), findsOneWidget);
      expect(find.text('WHITE TO MOVE'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });
  }

  test('every Chess board theme has a distinct palette', () {
    const ids = ['classic', 'modern', 'forest', 'royal', 'ocean', 'sunset'];
    final signatures = ids.map((id) {
      final theme = ChessBoardPalette.fromId(id);
      return '${theme.light.toARGB32()}-${theme.dark.toARGB32()}-${theme.frame.toARGB32()}';
    }).toSet();
    expect(signatures, hasLength(ids.length));
  });

  test('new Chess sound pack is complete and legacy pack is removed', () {
    const expected = [
      'chess_ui.wav',
      'chess_move.wav',
      'chess_capture.wav',
      'chess_check.wav',
      'chess_win.wav',
      'chess_promote.wav',
      'chess_tick.wav',
      'chess_error.wav',
    ];
    for (final file in expected) {
      expect(File('assets/chess/sounds_v2/$file').existsSync(), isTrue,
          reason: '$file must ship with the app');
    }
    expect(Directory('assets/chess/sounds').existsSync(), isFalse);
  });
}

void _registerGame() {
  final storage = Get.put<ChessStorageService>(_TestStorage());
  final sound = Get.put<ChessSoundService>(_SilentSound());
  Get.put(ChessAIService());
  Get.put(ChessGameController(storage, sound));
}

class _TestStorage extends ChessStorageService {
  @override
  // Test double intentionally skips plugin-backed initialization.
  // ignore: must_call_super
  void onInit() {}
  @override
  String? loadSerializedGameState() => null;
  @override
  bool get showLegalMoves => true;
  @override
  bool get showLastMove => true;
  @override
  String get boardTheme => 'royal';
  @override
  bool get timerEnabled => false;
  @override
  int get timePerPlayer => 10;
  @override
  int get aiDifficulty => 2;
  @override
  Future<void> saveSerializedGameState(String serializedState) async {}
  @override
  Future<void> updateGameStats({required String result}) async {}
  @override
  Future<void> updateShowLegalMoves(bool value) async {}
  @override
  Future<void> updateShowLastMove(bool value) async {}
  @override
  set boardTheme(String value) {}
}

class _SilentSound extends ChessSoundService {
  @override
  // Test double intentionally skips native audio initialization.
  // ignore: must_call_super
  void onInit() {}
  @override
  Future<void> playGameStartSound() async {}
  @override
  Future<void> playMoveSound() async {}
  @override
  Future<void> playCaptureSound() async {}
  @override
  Future<void> playCheckSound() async {}
  @override
  Future<void> playCheckmateSound() async {}
  @override
  Future<void> playGameEndSound() async {}
  @override
  Future<void> playMenuSelectionSound() async {}
  @override
  Future<void> playClockTickSound() async {}
  @override
  Future<void> playTimeUpSound() async {}
  @override
  Future<void> playSelectSound() async {}
  @override
  Future<void> playDeselectSound() async {}
  @override
  Future<void> playErrorSound() async {}
}
