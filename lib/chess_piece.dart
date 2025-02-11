import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;

class ChessPiece extends StatelessWidget {
  final chess.Piece piece;

  ChessPiece({required this.piece});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _pieceImagePath(piece),
      width: 48,
      height: 48,
    );
  }

  String _pieceImagePath(chess.Piece piece) {
    String pieceType;
    switch (piece.type) {
      case chess.PieceType.BISHOP:
        pieceType = 'bishop';
        break;
      case chess.PieceType.KING:
        pieceType = 'king';
        break;
      case chess.PieceType.KNIGHT:
        pieceType = 'knight';
        break;
      case chess.PieceType.PAWN:
        pieceType = 'pawn';
        break;
      case chess.PieceType.QUEEN:
        pieceType = 'queen';
        break;
      case chess.PieceType.ROOK:
        pieceType = 'rook';
        break;
      default:
        pieceType = 'pawn';
        break;
    }
    String pieceColor = piece.color == chess.Color.WHITE ? 'white' : 'black';
    return 'assets/images/${pieceColor}_${pieceType}.png';
  }
}
