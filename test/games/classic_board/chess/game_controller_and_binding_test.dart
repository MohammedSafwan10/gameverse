import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_piece.dart';
import 'package:gameverse/games/classic_board/chess/models/piece_types/pawn.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  test('captured piece list can represent duplicate piece types', () {
    final capturedPieces = <String>[];
    final boardCapturedPieces = [
      Pawn(color: PieceColor.black, position: 'a5'),
      Pawn(color: PieceColor.black, position: 'b5'),
    ];

    for (final piece in boardCapturedPieces.skip(capturedPieces.length)) {
      capturedPieces.add(piece.imagePath.split('/').last.split('.').first);
    }

    expect(capturedPieces, ['black_pawn', 'black_pawn']);
  });
}
