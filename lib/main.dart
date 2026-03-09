import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

enum ReadingType { directAnswer, flow, choice }

enum AnswerType {
  yes('YES', Color(0xFF2E7D32), Color(0xFFE8F5E9)),
  no('NO', Color(0xFFC62828), Color(0xFFFFEBEE)),
  neutral('중립', Color(0xFF455A64), Color(0xFFECEFF1));

  const AnswerType(this.label, this.textColor, this.backgroundColor);

  final String label;
  final Color textColor;
  final Color backgroundColor;

  static AnswerType fromRaw(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'yes':
        return AnswerType.yes;
      case 'no':
        return AnswerType.no;
      default:
        return AnswerType.neutral;
    }
  }
}

class TarotCard {
  const TarotCard({
    required this.id,
    required this.name,
    required this.directAnswer,
    required this.flowReading,
    required this.choiceOption,
    required this.answerType,
  });

  final int id;
  final String name;
  final String directAnswer;
  final String flowReading;
  final String choiceOption;
  final AnswerType answerType;

  factory TarotCard.fromJson(Map<String, dynamic> json) {
    return TarotCard(
      id: json['id'] is int ? json['id'] as int : -1,
      name:
          (json['name'] as String?)?.trim().isNotEmpty == true
              ? json['name'] as String
              : '이름 없는 카드',
      directAnswer:
          (json['direct_answer'] as String?)?.trim().isNotEmpty == true
              ? json['direct_answer'] as String
              : '직접 답변 데이터가 없습니다.',
      flowReading:
          (json['flow_reading'] as String?)?.trim().isNotEmpty == true
              ? json['flow_reading'] as String
              : '흐름 리딩 데이터가 없습니다.',
      choiceOption:
          (json['choice_option'] as String?)?.trim().isNotEmpty == true
              ? json['choice_option'] as String
              : '선택지 리딩 데이터가 없습니다.',
      answerType: AnswerType.fromRaw(
        (json['answer_type'] as String?) ?? 'neutral',
      ),
    );
  }
}

class TarotRepository {
  static Future<List<TarotCard>> loadCards() async {
    try {
      final raw = await rootBundle.loadString('assets/taro_reading.json');
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const FormatException('JSON root must be a list.');
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(TarotCard.fromJson)
          .toList();
    } catch (e) {
      throw Exception('카드 데이터를 불러오지 못했습니다: $e');
    }
  }
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

  void _openPage(BuildContext context, ReadingType type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReadingPage(type: type)),
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
              onPressed: () => _openPage(context, ReadingType.directAnswer),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD9E8),
              ),
              child: const Text('1. 명확한 답 (Yes or No)'),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => _openPage(context, ReadingType.flow),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDDF4EC),
              ),
              child: const Text('2. 흐름을 알고 싶어요! (하나의 카드리딩)'),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => _openPage(context, ReadingType.choice),
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
  const ReadingPage({super.key, required this.type});

  final ReadingType type;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TarotCard>>(
      future: TarotRepository.loadCards(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _ErrorPage(message: snapshot.error.toString());
        }

        final cards = snapshot.data ?? const <TarotCard>[];
        if (cards.isEmpty) {
          return const _ErrorPage(message: '카드 데이터가 비어 있습니다.');
        }

        switch (type) {
          case ReadingType.directAnswer:
            return DirectAnswerPage(cards: cards);
          case ReadingType.flow:
            return FlowReadingPage(cards: cards);
          case ReadingType.choice:
            return ChoiceReadingPage(cards: cards);
        }
      },
    );
  }
}

class DirectAnswerPage extends StatefulWidget {
  const DirectAnswerPage({super.key, required this.cards});

  final List<TarotCard> cards;

  @override
  State<DirectAnswerPage> createState() => _DirectAnswerPageState();
}

class _DirectAnswerPageState extends State<DirectAnswerPage> {
  final Random _random = Random();
  TarotCard? _yesCard;
  TarotCard? _noCard;
  bool _isResultVisible = false;
  int? _firstSelectedCardIndex;

  @override
  void initState() {
    super.initState();
    _pickCards();
  }

  AnswerType _inferFromText(String text) {
    final normalized = text.toLowerCase();
    if (normalized.contains('yes') ||
        normalized.contains('긍정') ||
        normalized.contains('승리') ||
        normalized.contains('성공')) {
      return AnswerType.yes;
    }
    if (normalized.contains('no') ||
        normalized.contains('보류') ||
        normalized.contains('부정') ||
        normalized.contains('주의')) {
      return AnswerType.no;
    }
    return AnswerType.neutral;
  }

  TarotCard? _pickOneByType(AnswerType type) {
    var candidates = widget.cards
        .where((card) => card.answerType == type)
        .toList(growable: false);

    if (candidates.isEmpty) {
      candidates = widget.cards
          .where((card) => _inferFromText(card.directAnswer) == type)
          .toList(growable: false);
    }

    if (candidates.isEmpty && widget.cards.isNotEmpty) {
      candidates = List<TarotCard>.from(widget.cards, growable: false);
    }

    if (candidates.isEmpty) {
      return null;
    }
    return candidates[_random.nextInt(candidates.length)];
  }

  void _pickCards() {
    setState(() {
      _yesCard = _pickOneByType(AnswerType.yes);
      _noCard = _pickOneByType(AnswerType.no);
    });
  }

  void _onDeckCardTap(int index) {
    if (_firstSelectedCardIndex == null) {
      setState(() {
        _firstSelectedCardIndex = index;
      });
      return;
    }

    if (_firstSelectedCardIndex == index) {
      return;
    }

    _pickCards();
    setState(() {
      _isResultVisible = true;
    });
  }

  void _resetToFirstStep() {
    setState(() {
      _isResultVisible = false;
      _firstSelectedCardIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final yesCard = _yesCard;
    final noCard = _noCard;
    if (yesCard == null || noCard == null) {
      return const _ErrorPage(message: '카드 데이터를 찾지 못했습니다.');
    }

    if (!_isResultVisible) {
      return Scaffold(
        appBar: AppBar(title: const Text('1. 명확한 답 (Yes/No)')),
        body: _TarotDeckSelection(
          title:
              _firstSelectedCardIndex == null
                  ? '하나의 답을 생각하고 카드를 골라주세요.'
                  : '나머지 것의 답을 생각하고 카드를 골라주세요.',
          subtitle:
              _firstSelectedCardIndex == null
                  ? '첫 번째 카드를 선택하면 다음 안내가 표시됩니다.'
                  : '첫 번째로 고른 카드를 제외하고 한 장을 더 선택하세요.',
          disabledCardIndices:
              _firstSelectedCardIndex == null
                  ? const <int>{}
                  : <int>{_firstSelectedCardIndex!},
          onCardTap: _onDeckCardTap,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('1. 명확한 답 (Yes/No)')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DirectAnswerSection(title: '1) YES를 선택한 경우', card: yesCard),
              const SizedBox(height: 14),
              _DirectAnswerSection(title: '2) NO를 선택한 경우', card: noCard),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _resetToFirstStep,
                child: const Text('두 카드 다시 뽑기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectAnswerSection extends StatelessWidget {
  const _DirectAnswerSection({required this.title, required this.card});

  final String title;
  final TarotCard card;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              card.name,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: card.answerType.backgroundColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                card.answerType.label,
                style: TextStyle(
                  color: card.answerType.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              card.directAnswer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: const Color(0xFF4A3E45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlowReadingPage extends StatefulWidget {
  const FlowReadingPage({super.key, required this.cards});

  final List<TarotCard> cards;

  @override
  State<FlowReadingPage> createState() => _FlowReadingPageState();
}

class _FlowReadingPageState extends State<FlowReadingPage> {
  final Random _random = Random();
  TarotCard? _card;
  bool _isResultVisible = false;

  @override
  void initState() {
    super.initState();
    _pickCard();
  }

  void _pickCard() {
    setState(() {
      _card = widget.cards[_random.nextInt(widget.cards.length)];
    });
  }

  void _showResult() {
    _pickCard();
    setState(() {
      _isResultVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = _card;
    if (card == null) {
      return const _ErrorPage(message: '카드를 뽑지 못했습니다.');
    }

    if (!_isResultVisible) {
      return Scaffold(
        appBar: AppBar(title: const Text('2. 흐름을 알고 싶어요')),
        body: _TarotDeckSelection(onCardTap: (_) => _showResult()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('2. 흐름을 알고 싶어요')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              card.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF5A4A53),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  card.flowReading,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: const Color(0xFF4A3E45),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _pickCard, child: const Text('다시 뽑기')),
          ],
        ),
      ),
    );
  }
}

class ChoiceReadingPage extends StatefulWidget {
  const ChoiceReadingPage({super.key, required this.cards});

  final List<TarotCard> cards;

  @override
  State<ChoiceReadingPage> createState() => _ChoiceReadingPageState();
}

class _ChoiceReadingPageState extends State<ChoiceReadingPage> {
  final Random _random = Random();
  List<TarotCard> _drawnCards = const <TarotCard>[];
  bool _isResultVisible = false;

  @override
  void initState() {
    super.initState();
    _startReading();
  }

  void _startReading() {
    if (widget.cards.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카드가 3장 미만이라 선택지 리딩을 할 수 없습니다.')),
      );
      return;
    }

    final pool = List<TarotCard>.from(widget.cards)..shuffle(_random);
    setState(() {
      _drawnCards = pool.take(3).toList();
    });
  }

  void _showResult() {
    _startReading();
    setState(() {
      _isResultVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.length < 3) {
      return const _ErrorPage(
        message: '카드 데이터가 3장 미만이라 3가지 선택 리딩을 제공할 수 없습니다.',
      );
    }

    const choices = ['A를 선택할 경우', 'B를 선택할 경우', 'C를 선택할 경우'];

    if (!_isResultVisible) {
      return Scaffold(
        appBar: AppBar(title: const Text('3. 선택지 중 무엇이 좋을까요?')),
        body: _TarotDeckSelection(onCardTap: (_) => _showResult()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('3. 선택지 중 무엇이 좋을까요?')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '세 가지 선택지에 대한 리딩입니다.\n각 항목을 비교해 가장 마음이 가는 방향을 선택하세요.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_drawnCards.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              for (int i = 0; i < _drawnCards.length; i++)
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${i + 1}. ${choices[i]}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '카드: ${_drawnCards[i].name}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF5A4A53),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _drawnCards[i].choiceOption,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: _startReading,
                child: const Text('다시 뽑기'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TarotDeckSelection extends StatelessWidget {
  const _TarotDeckSelection({
    required this.onCardTap,
    this.title = '카드를 선택해 리딩을 시작하세요',
    this.subtitle = '22장의 카드가 펼쳐졌습니다. 원하는 카드 하나를 탭하세요.',
    this.disabledCardIndices = const <int>{},
  });

  final ValueChanged<int> onCardTap;
  final String title;
  final String subtitle;
  final Set<int> disabledCardIndices;

  static const List<int> _rowPattern = <int>[6, 5, 6, 5];

  @override
  Widget build(BuildContext context) {
    final allCardIndices = List<int>.generate(22, (i) => i);
    var cursor = 0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            for (int row = 0; row < _rowPattern.length; row++) ...[
              ...() {
                final rowCount = _rowPattern[row];
                final rowIndices = allCardIndices.sublist(
                  cursor,
                  cursor + rowCount,
                );
                cursor += rowCount;

                return [
              Padding(
                padding: EdgeInsets.only(left: row.isOdd ? 18 : 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: [
                    for (final cardIndex in rowIndices)
                      GestureDetector(
                        onTap:
                            disabledCardIndices.contains(cardIndex)
                                ? null
                                : () => onCardTap(cardIndex),
                        child: Opacity(
                          opacity:
                              disabledCardIndices.contains(cardIndex)
                                  ? 0.35
                                  : 1,
                          child: Container(
                            width: 50,
                            height: 84,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x29000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              'assets/imgs/taro_card_back.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
                ];
              }(),
              if (row != _rowPattern.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorPage extends StatelessWidget {
  const _ErrorPage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오류')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
