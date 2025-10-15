import 'package:equatable/equatable.dart';

class Position extends Equatable {
  final int x;
  final int y;

  const Position(this.x, this.y);

  @override
  List<Object> get props => [x, y];
}

class Block extends Equatable {
  final int value;
  final Position position;
  final bool isNew;
  final bool isMerged;

  const Block({
    required this.value,
    required this.position,
    this.isNew = false,
    this.isMerged = false,
  });

  Block copyWith({
    int? value,
    Position? position,
    bool? isNew,
    bool? isMerged,
  }) {
    return Block(
      value: value ?? this.value,
      position: position ?? this.position,
      isNew: isNew ?? this.isNew,
      isMerged: isMerged ?? this.isMerged,
    );
  }

  @override
  List<Object> get props => [value, position, isNew, isMerged];
}
