import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'dart:math' show Point;

enum CellState { empty, player1, player2 }

enum GameStatus { playing, draw, player1Won, player2Won }

@immutable
class Board extends Equatable {
  static const int rows = 6;
  static const int cols = 7;
  final List<List<CellState>> cells;
  final GameStatus status;
  final List<Point<int>> winningCells;

  Board({
    required List<List<CellState>> cells,
    this.status = GameStatus.playing,
    List<Point<int>> winningCells = const [],
  })  : cells = _copyCells(cells),
        winningCells = List<Point<int>>.unmodifiable(winningCells);

  static List<List<CellState>> _copyCells(List<List<CellState>> cells) {
    return List<List<CellState>>.unmodifiable(
      cells.map((row) => List<CellState>.unmodifiable(row)),
    );
  }

  factory Board.empty() {
    return Board(
      cells: List.generate(
        rows,
        (_) => List.filled(cols, CellState.empty),
      ),
    );
  }

  bool get isFull =>
      cells.every((row) => row.every((cell) => cell != CellState.empty));

  bool isValidMove(int col) {
    return col >= 0 && col < cols && cells[0][col] == CellState.empty;
  }

  int getLowestEmptyRow(int col) {
    for (int row = rows - 1; row >= 0; row--) {
      if (cells[row][col] == CellState.empty) return row;
    }
    return -1;
  }

  Board copyWith({
    List<List<CellState>>? cells,
    GameStatus? status,
    List<Point<int>>? winningCells,
  }) {
    return Board(
      cells: cells ?? this.cells,
      status: status ?? this.status,
      winningCells: winningCells ?? this.winningCells,
    );
  }

  @override
  List<Object?> get props => [cells, status, winningCells];
}
