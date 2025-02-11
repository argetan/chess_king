import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'difficulty_selection.dart';
import 'chess_board.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash.dart'; // 스플래시 화면 추가

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess King',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // 스플래시 화면을 홈으로 설정
      routes: {
        '/chess_board': (context) => ChessBoardScreen(),
      },
    );
  }
}
