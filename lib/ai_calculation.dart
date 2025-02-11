import 'package:chess/chess.dart' as chess;

class ChessAI {
  final chess.Chess board;
  final chess.Color aiPlayer;
  final int maxDepth;

  ChessAI(this.board, this.aiPlayer, this.maxDepth);

  Map<String, String>? calculateAIMove() {
    var result = _alphaBeta(board, aiPlayer, 0, maxDepth, double.negativeInfinity, double.infinity);
    if (result.move == null) {
      return null;
    } else {
      return {
        'from': result.move!.fromAlgebraic,
        'to': result.move!.toAlgebraic
      };
    }
  }

  _MoveAndValue _alphaBeta(chess.Chess board, chess.Color player, int depth, int maxDepth, double alpha, double beta) {
    if (depth == maxDepth) {
      return _MoveAndValue(null, _evaluateBoard(board));
    }

    chess.Move? bestMove;
    if (player == aiPlayer) {
      double maxEval = double.negativeInfinity;
      for (var move in board.generate_moves()) {
        board.make_move(move);
        var eval = _alphaBeta(board, _opponent(player), depth + 1, maxDepth, alpha, beta).value;
        board.undo_move();
        if (eval > maxEval) {
          maxEval = eval;
          bestMove = move;
        }
        alpha = alpha > eval ? alpha : eval;
        if (beta <= alpha) {
          break;
        }
      }
      return _MoveAndValue(bestMove, maxEval);
    } else {
      double minEval = double.infinity;
      for (var move in board.generate_moves()) {
        board.make_move(move);
        var eval = _alphaBeta(board, _opponent(player), depth + 1, maxDepth, alpha, beta).value;
        board.undo_move();
        if (eval < minEval) {
          minEval = eval;
          bestMove = move;
        }
        beta = beta < eval ? beta : eval;
        if (beta <= alpha) {
          break;
        }
      }
      return _MoveAndValue(bestMove, minEval);
    }
  }

  chess.Color _opponent(chess.Color player) {
    return player == chess.Color.WHITE ? chess.Color.BLACK : chess.Color.WHITE;
  }

  double _evaluateBoard(chess.Chess board) {
    double score = 0;
    board.board.asMap().forEach((index, piece) {
      if (piece != null) {
        score += _pieceValue(piece);
      }
    });
    return score;
  }

  double _pieceValue(chess.Piece piece) {
    switch (piece.type) {
      case chess.PieceType.PAWN:
        return piece.color == aiPlayer ? 1 : -1;
      case chess.PieceType.KNIGHT:
        return piece.color == aiPlayer ? 3 : -3;
      case chess.PieceType.BISHOP:
        return piece.color == aiPlayer ? 3 : -3;
      case chess.PieceType.ROOK:
        return piece.color == aiPlayer ? 5 : -5;
      case chess.PieceType.QUEEN:
        return piece.color == aiPlayer ? 9 : -9;
      case chess.PieceType.KING:
        return piece.color == aiPlayer ? 100 : -100;
      default:
        return 0;
    }
  }
}

class _MoveAndValue {
  final chess.Move? move;
  final double value;

  _MoveAndValue(this.move, this.value);
}
