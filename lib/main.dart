import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarot Days',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFC9DE),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFE4F1),
          foregroundColor: Color(0xFF5A4A53),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: const Color(0xFF4A3E45),
            backgroundColor: const Color(0xFFFFEAF4),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openPage(BuildContext context, int pageNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingPage(pageNumber: pageNumber),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('당신은 어떠한 답을 원하시나요? 🔮')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _openPage(context, 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD9E8),
              ),
              child: const Text('1. 명확한 답 (Yes or No)'),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => _openPage(context, 2),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDDF4EC),
              ),
              child: const Text('2. 흐름을 알고 싶어요! (하나의 카드리딩)'),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => _openPage(context, 3),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE3E6FF),
              ),
              child: const Text('3. 선택지 중 무엇이 좋을까요? (3가지 선택)'),
            ),
          ],
        ),
      ),
    );
  }
}

class ReadingPage extends StatelessWidget {
  const ReadingPage({super.key, required this.pageNumber});

  final int pageNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('페이지 $pageNumber')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '새로운 페이지 $pageNumber',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF5A4A53),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('이전 화면으로 돌아가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
