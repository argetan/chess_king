import 'package:flutter/material.dart';
import 'chess_board.dart'; // ChessBoardScreen
import 'setting_screen.dart'; // Settings
import 'package:google_mobile_ads/google_mobile_ads.dart';

class DifficultySelectionScreen extends StatefulWidget {
  @override
  _DifficultySelectionScreenState createState() =>
      _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState extends State<DifficultySelectionScreen> {
  late BannerAd _topBannerAd;
  late BannerAd _bottomBannerAd;
  bool _isTopBannerAdReady = false;
  bool _isBottomBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadTopBannerAd();
    _loadBottomBannerAd();
  }

  void _loadTopBannerAd({bool useTestAdUnit = false}) {
    final String realAdUnitId = 'ca-app-pub-3078351111408385/2293400157';
    final String testAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // 테스트 배너 광고 ID

    final String adUnitId = useTestAdUnit ? testAdUnitId : realAdUnitId;

    _topBannerAd = BannerAd(
      adUnitId: adUnitId,
      request: AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isTopBannerAdReady = true;
          });
          print('Top BannerAd loaded successfully with ID: $adUnitId');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Top BannerAd failed to load with ID: $adUnitId. Error: $error');
          ad.dispose();

          // 실제 광고가 실패하면 테스트 광고로 재시도
          if (!useTestAdUnit) {
            print('Retrying Top BannerAd with test ad unit ID...');
            _loadTopBannerAd(useTestAdUnit: true);
          }
        },
      ),
    );

    _topBannerAd.load();
  }

  void _loadBottomBannerAd({bool useTestAdUnit = false}) {
    final String realAdUnitId = 'ca-app-pub-3078351111408385/2293400157'; // 실제 광고
    final String testAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // 테스트 배너 광고 ID

    final String adUnitId = useTestAdUnit ? testAdUnitId : realAdUnitId;

    _bottomBannerAd = BannerAd(
      adUnitId: adUnitId,
      request: AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBottomBannerAdReady = true;
          });
          print('Bottom BannerAd loaded successfully with ID: $adUnitId');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Bottom BannerAd failed to load with ID: $adUnitId. Error: $error');
          ad.dispose();

          // 실제 광고가 실패하면 테스트 광고로 재시도
          if (!useTestAdUnit) {
            print('Retrying Bottom BannerAd with test ad unit ID...');
            _loadBottomBannerAd(useTestAdUnit: true);
          }
        },
      ),
    );

    _bottomBannerAd.load();
  }

  @override
  void dispose() {
    _topBannerAd.dispose();
    _bottomBannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a difficulty level'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            iconSize: 40.0,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Color(0xF42D2B29), // 짙은 남색 배경
        child: Stack(
          children: [
            Column(
              children: [
                if (_isTopBannerAdReady)
                  Container(
                    height: _topBannerAd.size.height.toDouble(),
                    width: MediaQuery.of(context).size.width,
                    child: AdWidget(ad: _topBannerAd),
                  ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDifficultyButton('Novice', Difficulty.novice),
                          SizedBox(height: 35), // 간격 조정
                          _buildDifficultyButton('Beginner', Difficulty.beginner),
                          SizedBox(height: 35), // 간격 조정
                          _buildDifficultyButton('Skilled', Difficulty.skilled),
                          SizedBox(height: 35), // 간격 조정
                          _buildDifficultyButton('Intermediate', Difficulty.intermediate),
                          SizedBox(height: 35), // 간격 조정
                          // _buildDifficultyButton('Advanced', Difficulty.advanced),
                          // SizedBox(height: 25), // 간격 조정
                          // _buildDifficultyButton('Expert', Difficulty.expert),
                          // SizedBox(height: 25), // 간격 조정
                          _buildDifficultyButton('1 vs 1', Difficulty.twoPlayer),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isBottomBannerAdReady)
                  Container(
                    height: _bottomBannerAd.size.height.toDouble(),
                    width: MediaQuery.of(context).size.width,
                    child: AdWidget(ad: _bottomBannerAd),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton _buildDifficultyButton(String text, Difficulty difficulty) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChessBoardScreen(
              difficulty: difficulty,
            ),
          ),
        );
      },
      child: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0x51FFFFFF), // 버튼 배경 색상
        foregroundColor: Color(0xEAFFFFFF), // 버튼 텍스트 색상
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        minimumSize: Size(300, 70), // 버튼 최소 크기 지정
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // 둥글게 처리
        ),
        elevation: 5, // 그림자 효과
      ),
    );
  }
}
