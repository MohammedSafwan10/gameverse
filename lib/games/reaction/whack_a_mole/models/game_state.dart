import 'game_types.dart';

class GameState {
  final List<MoleType?> moles;
  final List<bool> isActive;
  final List<double> moleProgress;

  const GameState({
    required this.moles,
    required this.isActive,
    required this.moleProgress,
  });

  factory GameState.initial() {
    return GameState(
      moles: List.filled(9, null),
      isActive: List.filled(9, false),
      moleProgress: List.filled(9, 0.0),
    );
  }

  GameState copyWith({
    List<MoleType?>? moles,
    List<bool>? isActive,
    List<double>? moleProgress,
  }) {
    return GameState(
      moles: moles ?? this.moles,
      isActive: isActive ?? this.isActive,
      moleProgress: moleProgress ?? this.moleProgress,
    );
  }
}
