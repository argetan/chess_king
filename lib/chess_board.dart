import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;
import 'chess_piece.dart';
import 'ai_calculation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 난이도 enum 정의
enum Difficulty {
  novice,
  beginner,
  skilled,
  intermediate,
  // advanced,
  // expert,
  twoPlayer,
}

class ChessBoardScreen extends StatefulWidget {
  final Difficulty? difficulty; // enum 타입으로 변경
  final bool isTwoPlayer;

  ChessBoardScreen({this.difficulty, this.isTwoPlayer = false});

  @override
  _ChessBoardScreenState createState() => _ChessBoardScreenState();
}

class _ChessBoardScreenState extends State<ChessBoardScreen> {
  chess.Chess _chess = chess.Chess();
  String? _selectedSquare;
  List<String> _legalMoves = [];
  bool _isAITurn = false;
  bool _showThinkingMessage = false;
  late DateTime _startTime;
  Duration _thinkingDuration = Duration.zero;
  List<Map<String, dynamic>> _moveHistory = [];
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  String _playerColor = 'white';

  double _boardTop = 50.0;
  double _boardLeft = 0.0;
  String _backgroundImagePath = 'assets/background_chess.jpg';

  double _imageTop = 10.0; // 기본 이미지 위치
  double _imageLeft = 110.0; // 기본 이미지 위치
  double _imageWidth = 230.0; // 기본 이미지 크기
  double _imageHeight = 230.0; // 기본 이미지 크기
  // 초기값을 빈 문자열로 설정
  String _additionalImagePath = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadPlayerColor();
    _loadInterstitialAd();
    _setAdditionalImage();
    _startTimer();
  }

  void _setAdditionalImage() {
    switch (widget.difficulty) {
      case Difficulty.novice:
        _additionalImagePath = 'assets/images/novice.png';
        break;
      case Difficulty.beginner:
        _additionalImagePath = 'assets/images/beginner.png';
        break;
      case Difficulty.skilled:
        _additionalImagePath = 'assets/images/skilled.png';
        break;
      case Difficulty.intermediate:
        _additionalImagePath = 'assets/images/intermediate.png';
        break;
      // case Difficulty.advanced:
      //   _additionalImagePath = 'assets/images/advanced.png';
      //   break;
      // case Difficulty.expert:
      //   _additionalImagePath = 'assets/images/expert.png';
      //   break;
      case Difficulty.twoPlayer:
        _additionalImagePath = ''; // 두 플레이어일 경우 이미지를 표시하지 않음
        break;
      case null:
        _additionalImagePath = ''; // null인 경우도 이미지를 표시하지 않음
        break;
      // default:
      //   _additionalImagePath = 'assets/images/1_vs_1.png';
    }
  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _boardTop = prefs.getDouble('boardTop') ?? 50.0;
    });
  }

  _loadPlayerColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _playerColor = prefs.getString('selectedColor') ?? 'white';
      if (_playerColor == 'black' && !widget.isTwoPlayer) {
        _isAITurn = true;
        _makeAIMove();
      }
    });
  }

  void _loadInterstitialAd({bool useTestAdUnit = false}) {
    // 실제 광고 ID와 테스트 광고 ID
    final String realAdUnitId = 'ca-app-pub-3078351111408385/3421713217';
    final String testAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

    // 사용할 광고 ID를 결정
    final String adUnitId = useTestAdUnit ? testAdUnitId : realAdUnitId;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          print('InterstitialAd loaded successfully with ID: $adUnitId');
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load with ID: $adUnitId. Error: $error');
          _isInterstitialAdReady = false;

          // 실제 광고가 실패했을 경우 테스트 광고 ID로 다시 호출
          if (!useTestAdUnit) {
            print('Retrying with test ad unit ID...');
            _loadInterstitialAd(useTestAdUnit: true); // 테스트 광고로 재시도
          }
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_isInterstitialAdReady) {
      _interstitialAd?.show();
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: Color(0xE006060E), // 배경색을 까만색으로 변경
            ),
            Positioned(
              top: 240,
              left: _boardLeft,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                child: Column(
                  children: _buildBoard(),
                ),
              ),
            ),
            Positioned(
              top: _imageTop,
              left: _imageLeft,
              child: Image.asset(
                _additionalImagePath,
                width: _imageWidth,
                height: _imageHeight,
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: Text('Additional image not found'));
                },
              ),
            ),
            if (_showThinkingMessage)
              Center(
                child: Text(
                  "AI is thinking...",
                  style: TextStyle(fontSize: 24, color: Colors.red),
                ),
              ),
            Positioned(
              bottom: 20.0,
              left: 20.0,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      _showInterstitialAd();
                      setState(() {
                        _chess.reset();
                        _selectedSquare = null;
                        _legalMoves.clear();
                        _isAITurn = false;
                        _showThinkingMessage = false;
                        _moveHistory.clear();
                        if (_playerColor == 'black' && !widget.isTwoPlayer) {
                          _isAITurn = true;
                          _makeAIMove();
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.undo, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        // 두 번의 undo를 실행하여 한 쌍의 턴을 되돌림
                        if (_moveHistory.isNotEmpty) {
                          _chess.undo(); // 흑 기물 이동 취소
                          _moveHistory.removeLast();
                        }
                        if (_moveHistory.isNotEmpty) {
                          _chess.undo(); // 백 기물 이동 취소
                          _moveHistory.removeLast();
                        }
                        _isAITurn = false;
                        _showThinkingMessage = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBoard() {
    List<Widget> rows = [];
    for (int i = 0; i < 8; i++) {
      List<Widget> row = [];
      for (int j = 0; j < 8; j++) {
        row.add(_buildSquare(i, j));
      }
      rows.add(Row(children: row));
    }
    return rows;
  }

  Widget _buildSquare(int row, int col) {
    String squareName = '${String.fromCharCode(97 + col)}${8 - row}';
    chess.Piece? piece = _chess.get(squareName);
    Color color = (row + col) % 2 == 0 ? Colors.white : Colors.grey;

    bool isSelected = squareName == _selectedSquare;
    bool isLegalMove = _legalMoves.contains(squareName);
    Color borderColor = isSelected ? Colors.red : Colors.transparent;

    return GestureDetector(
      onTap: () {
        if (!_isAITurn && _isPlayerTurn()) {
          setState(() {
            if (_selectedSquare == squareName) {
              // 기물을 다시 클릭하면 선택 취소
              _selectedSquare = null;
              _legalMoves.clear();
            } else if (_selectedSquare == null) {
              if (piece != null && piece.color == _chess.turn) {
                _selectSquare(squareName);
              }
            } else {
              if (_legalMoves.contains(squareName)) {
                _makeMove(_selectedSquare!, squareName);
              } else {
                _selectedSquare = null;
                _legalMoves.clear();
              }
            }
          });
        }
      },
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 8,
            height: MediaQuery.of(context).size.width / 8,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Center(
              child: piece != null ? ChessPiece(piece: piece) : null,
            ),
          ),
          if (isLegalMove)
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isPlayerTurn() {
    return _playerColor == 'white'
        ? _chess.turn == chess.Color.WHITE
        : _chess.turn == chess.Color.BLACK;
  }

  void _selectSquare(String square) {
    setState(() {
      _selectedSquare = square;
      _legalMoves = _chess
          .generate_moves({'square': square})
          .map<String>((move) => move.toAlgebraic)
          .toList();
    });
  }

  void _makeMove(String from, String to) {
    // 폰이 프로모션 칸에 도달했는지 여부 판단
    bool promotionNeeded = _chess.get(from)?.type == chess.PieceType.PAWN &&
        (to[1] == '8' || to[1] == '1');

    if (!promotionNeeded) {
      // 승진이 필요하지 않으면 일반 이동 처리
      _chess.move({'from': from, 'to': to});
    }

    _moveHistory.add({'from': from, 'to': to});

    setState(() {
      _selectedSquare = null;
      _legalMoves.clear();
    });

    if (promotionNeeded) {
      // 승진이 필요한 경우 승진 다이얼로그를 호출하고,
      // 승진 처리가 완료되면 후속 처리를 진행
      _showPromotionDialog(from, to).then((_) {
        _postMoveProcessing();
      });
    } else {
      // 승진이 필요하지 않으면 바로 후속 처리를 진행
      _postMoveProcessing();
    }
  }

  /// 이동 후, 체크메이트, 무승부, 또는 AI 이동을 처리하는 메서드
  void _postMoveProcessing() {
    if (_chess.in_checkmate) {
      _showGameOverMessage("Checkmate! Game Over.");
    } else if (_chess.in_draw) {
      _showGameOverMessage("It's a draw.");
    } else if (!widget.isTwoPlayer) {
      setState(() {
        _isAITurn = true;
      });
      Future.delayed(Duration(milliseconds: 500), () {
        _makeAIMove();
      });
    }
  }


  Future<void> _showPromotionDialog(String from, String to) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Promote Pawn"),
          content: const Text("Choose a piece to promote to:"),
          actions: [
            TextButton(
              child: const Text("Queen"),
              onPressed: () {
                _chess.move({'from': from, 'to': to, 'promotion': 'q'});
                Navigator.of(context).pop();
                setState(() {}); // UI 업데이트
              },
            ),
            TextButton(
              child: const Text("Rook"),
              onPressed: () {
                _chess.move({'from': from, 'to': to, 'promotion': 'r'});
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
            TextButton(
              child: const Text("Bishop"),
              onPressed: () {
                _chess.move({'from': from, 'to': to, 'promotion': 'b'});
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
            TextButton(
              child: const Text("Knight"),
              onPressed: () {
                _chess.move({'from': from, 'to': to, 'promotion': 'n'});
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  void _makeAIMove() {
    setState(() {
      _showThinkingMessage = true;
      _startTime = DateTime.now(); // 타이머 시작 시점 저장
    });

    int aiDepth;
    switch (widget.difficulty) {
      case Difficulty.novice:
        aiDepth = 1;
        break;
      case Difficulty.beginner:
        aiDepth = 2;
        break;
      case Difficulty.skilled:
        aiDepth = 3;
        break;
      case Difficulty.intermediate:
        aiDepth = 4;
        break;
      // case Difficulty.advanced:
      //   aiDepth = 5;
      //   break;
      // case Difficulty.expert:
      //   aiDepth = 6;
      //   break;
      case Difficulty.twoPlayer:
      default:
        aiDepth = 0; // AI를 사용하지 않는 경우
    }

    ChessAI ai = ChessAI(
        _chess,
        _playerColor == 'white' ? chess.Color.BLACK : chess.Color.WHITE,
        aiDepth);
    var aiMove = ai.calculateAIMove();
    if (aiMove != null) {
      _chess.move({'from': aiMove['from'], 'to': aiMove['to']});
    }

    setState(() {
      _showThinkingMessage = false;

      if (_chess.in_checkmate) {
        _showGameOverMessage("Checkmate! AI wins.");
      } else if (_chess.in_draw) {
        _showGameOverMessage("It's a draw.");
      }

      _isAITurn = false;
    });
  }

  void _showGameOverMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _chess.reset();
                  _selectedSquare = null;
                  _legalMoves.clear();
                  _isAITurn = false;
                  _showThinkingMessage = false;
                  _moveHistory.clear();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _startTimer() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_showThinkingMessage) {
        setState(() {
          _thinkingDuration = DateTime.now().difference(_startTime);
        });
        _startTimer();
      }
    });
  }
}
