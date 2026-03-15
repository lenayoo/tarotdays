import 'dart:math';

import 'package:flutter/material.dart';

import 'app_strings.dart';
import 'tarot_data.dart';

void main() {
  runApp(const MyApp());
}

enum ReadingType { directAnswer, flow, choice }

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
    final strings = AppStrings.of(context);

    return Scaffold(
      body: _TarotMoodBackground(
        palette: _TarotMoodPalettes.home,
        showBackButton: false,
        topContentOffset: 0,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'TAROT DAYS',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF8E5870),
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  strings.homeHeadline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF623C55),
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.homeDescription,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF866B78),
                    height: 1.45,
                  ),
                ),
                const Spacer(flex: 2),
                _HomeReadingCard(
                  indexLabel: '01',
                  title: strings.directAnswerMenuTitle,
                  subtitle: strings.directAnswerMenuSubtitle,
                  description: strings.directAnswerMenuDescription,
                  accentColor: const Color(0xFFB85F7C),
                  panelColor: const Color(0xFFFFF4F8),
                  icon: Icons.auto_awesome_rounded,
                  onTap: () => _openPage(context, ReadingType.directAnswer),
                ),
                const SizedBox(height: 12),
                _HomeReadingCard(
                  indexLabel: '02',
                  title: strings.flowMenuTitle,
                  subtitle: strings.flowMenuSubtitle,
                  description: strings.flowMenuDescription,
                  accentColor: const Color(0xFF8A4E73),
                  panelColor: const Color(0xFFFFF2F9),
                  icon: Icons.nights_stay_rounded,
                  onTap: () => _openPage(context, ReadingType.flow),
                ),
                const SizedBox(height: 12),
                _HomeReadingCard(
                  indexLabel: '03',
                  title: strings.choiceMenuTitle,
                  subtitle: strings.choiceMenuSubtitle,
                  description: strings.choiceMenuDescription,
                  accentColor: const Color(0xFF5668AC),
                  panelColor: const Color(0xFFF3F6FF),
                  icon: Icons.stacked_line_chart_rounded,
                  onTap: () => _openPage(context, ReadingType.choice),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeReadingCard extends StatelessWidget {
  const _HomeReadingCard({
    required this.indexLabel,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.accentColor,
    required this.panelColor,
    required this.icon,
    required this.onTap,
  });

  final String indexLabel;
  final String title;
  final String subtitle;
  final String description;
  final Color accentColor;
  final Color panelColor;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: panelColor.withValues(alpha: 0.80),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.82),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2235374E),
                  blurRadius: 24,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        indexLabel,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF493843),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: accentColor.withValues(alpha: 0.88),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6E6268),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: accentColor.withValues(alpha: 0.88),
                ),
              ],
            ),
          ),
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
    final locale = Localizations.localeOf(context);
    final strings = AppStrings.of(context);

    return FutureBuilder<List<TarotCard>>(
      future: TarotRepository.loadCards(locale),
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
          return _ErrorPage(message: strings.emptyCardData);
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
        normalized.contains('positive') ||
        normalized.contains('very positive') ||
        normalized.contains('긍정') ||
        normalized.contains('승리') ||
        normalized.contains('성공') ||
        normalized.contains('はい') ||
        normalized.contains('良い') ||
        normalized.contains('好転') ||
        normalized.contains('成功')) {
      return AnswerType.yes;
    }
    if (normalized.contains('no') ||
        normalized.contains('negative') ||
        normalized.contains('caution') ||
        normalized.contains('보류') ||
        normalized.contains('부정') ||
        normalized.contains('주의') ||
        normalized.contains('いいえ') ||
        normalized.contains('注意') ||
        normalized.contains('延期')) {
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
    final strings = AppStrings.of(context);
    final yesCard = _yesCard;
    final noCard = _noCard;
    if (yesCard == null || noCard == null) {
      return _ErrorPage(message: strings.cardDataNotFound);
    }

    if (!_isResultVisible) {
      return Scaffold(
        body: _TarotMoodBackground(
          palette: _TarotMoodPalettes.directAnswer,
          child: _TarotDeckSelection(
            title:
                _firstSelectedCardIndex == null
                    ? strings.directFirstPickPrompt
                    : strings.directSecondPickPrompt,
            cardBackAssetPath: 'assets/imgs/taro_back_2.png',
            disabledCardIndices:
                _firstSelectedCardIndex == null
                    ? const <int>{}
                    : <int>{_firstSelectedCardIndex!},
            onCardTap: _onDeckCardTap,
            titleColor: const Color(0xFF6E3E55),
            compactHeader: true,
            scrollable: false,
          ),
        ),
      );
    }

    return Scaffold(
      body: _TarotMoodBackground(
        palette: _TarotMoodPalettes.directAnswer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8FA).withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.75),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26375A46),
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Text(
                  strings.directResultHeadline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF6E3E55),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                strings.directMoodLabel,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF91717E),
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DirectAnswerSection(
                        title: strings.directYesCaseTitle,
                        card: yesCard,
                        accentColor: const Color(0xFF5D8A72),
                        panelColor: const Color(0xFFF4FBF6),
                      ),
                      const SizedBox(height: 14),
                      _DirectAnswerSection(
                        title: strings.directNoCaseTitle,
                        card: noCard,
                        accentColor: const Color(0xFFB45B74),
                        panelColor: const Color(0xFFFFF5F8),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _resetToFirstStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEDF2),
                  foregroundColor: const Color(0xFF6E3E55),
                ),
                child: Text(strings.redrawTwoCards),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectAnswerSection extends StatelessWidget {
  const _DirectAnswerSection({
    required this.title,
    required this.card,
    required this.accentColor,
    required this.panelColor,
  });

  final String title;
  final TarotCard card;
  final Color accentColor;
  final Color panelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panelColor.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24342A32),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            card.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4E3C46),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: card.answerType.backgroundColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              card.answerType.label(AppStrings.of(context)),
              style: TextStyle(
                color: card.answerType.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            card.directAnswer,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.58,
              color: const Color(0xFF4A3E45),
            ),
          ),
        ],
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
    final strings = AppStrings.of(context);
    final card = _card;
    if (card == null) {
      return _ErrorPage(message: strings.drawCardFailed);
    }

    if (!_isResultVisible) {
      return Scaffold(
        body: _TarotMoodBackground(
          palette: _TarotMoodPalettes.flow,
          child: _TarotDeckSelection(
            cardBackAssetPath: 'assets/imgs/taro_back_3.png',
            onCardTap: (_) => _showResult(),
            title: strings.flowPickPrompt,
            titleColor: const Color(0xFF6F3556),
            compactHeader: true,
            scrollable: false,
          ),
        ),
      );
    }

    return Scaffold(
      body: _TarotMoodBackground(
        palette: _TarotMoodPalettes.flow,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF3F8).withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.75),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26A63C77),
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      card.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF6F3556),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strings.flowMoodLabel,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF9A6A86),
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBFD).withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: const Color(0xFFFFFFFF).withValues(alpha: 0.78),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1FB43A7B),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      card.flowReading,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.65,
                        color: const Color(0xFF543847),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE6F2),
                  foregroundColor: const Color(0xFF6F3556),
                ),
                child: Text(strings.redrawCard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarotMoodBackground extends StatefulWidget {
  const _TarotMoodBackground({
    required this.child,
    required this.palette,
    this.showBackButton = true,
    this.topContentOffset = 56,
  });

  final Widget child;
  final _TarotMoodPalette palette;
  final bool showBackButton;
  final double topContentOffset;

  @override
  State<_TarotMoodBackground> createState() => _TarotMoodBackgroundState();
}

class _TarotMoodBackgroundState extends State<_TarotMoodBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final tick = _controller.value * pi * 2;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.palette.gradientColors,
              stops: [0.0, 0.32, 0.72, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.75, -0.85),
                      radius: 0.95,
                      colors: [
                        Colors.white.withValues(
                          alpha: widget.palette.glowAlphaTop,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.85, 0.65),
                      radius: 1.05,
                      colors: [
                        widget.palette.glowColorBottom.withValues(
                          alpha: widget.palette.glowAlphaBottom,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              for (final sparkle in widget.palette.sparkles)
                _FloatingSparkle(
                  spec: sparkle,
                  tick: tick,
                  centerColor: widget.palette.sparkleCenterColor,
                ),
              Padding(
                padding: EdgeInsets.only(
                  top: topInset + widget.topContentOffset,
                ),
                child: widget.child,
              ),
              if (widget.showBackButton)
                Positioned(
                  top: topInset + 8,
                  left: 12,
                  child: _FlowBackButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tintColor: widget.palette.backButtonTint,
                    backgroundColor: widget.palette.backButtonBackground,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FlowBackButton extends StatelessWidget {
  const _FlowBackButton({
    required this.onPressed,
    required this.tintColor,
    required this.backgroundColor,
  });

  final VoidCallback onPressed;
  final Color tintColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor.withValues(alpha: 0.62),
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: tintColor,
          ),
        ),
      ),
    );
  }
}

class _SparkleSpec {
  const _SparkleSpec({
    required this.left,
    required this.top,
    required this.size,
    required this.opacity,
    required this.phase,
  });

  final double left;
  final double top;
  final double size;
  final double opacity;
  final double phase;
}

class _FloatingSparkle extends StatelessWidget {
  const _FloatingSparkle({
    required this.spec,
    required this.tick,
    required this.centerColor,
  });

  final _SparkleSpec spec;
  final double tick;
  final Color centerColor;

  @override
  Widget build(BuildContext context) {
    final driftY = sin(tick + spec.phase) * 10;
    final driftX = cos((tick * 0.7) + spec.phase) * 4;
    final pulse = ((sin((tick * 1.3) + spec.phase) + 1) / 2);
    final scale = 0.72 + (pulse * 0.52);
    final alpha = (0.28 + (pulse * spec.opacity)).clamp(0.0, 1.0);

    return Positioned(
      left: MediaQuery.sizeOf(context).width * spec.left + driftX,
      top: MediaQuery.sizeOf(context).height * spec.top + driftY,
      child: Opacity(
        opacity: alpha,
        child: Transform.scale(
          scale: scale,
          child: SizedBox(
            width: spec.size,
            height: spec.size,
            child: CustomPaint(
              painter: _SparklePainter(centerColor: centerColor),
            ),
          ),
        ),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter({required this.centerColor});

  final Color centerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint =
        Paint()
          ..color = const Color(0xFFFFFFFF)
          ..style = PaintingStyle.fill;

    final path =
        Path()
          ..moveTo(center.dx, 0)
          ..lineTo(
            center.dx + size.width * 0.14,
            center.dy - size.height * 0.14,
          )
          ..lineTo(size.width, center.dy)
          ..lineTo(
            center.dx + size.width * 0.14,
            center.dy + size.height * 0.14,
          )
          ..lineTo(center.dx, size.height)
          ..lineTo(
            center.dx - size.width * 0.14,
            center.dy + size.height * 0.14,
          )
          ..lineTo(0, center.dy)
          ..lineTo(
            center.dx - size.width * 0.14,
            center.dy - size.height * 0.14,
          )
          ..close();

    canvas.drawShadow(path, const Color(0x66FFFFFF), 6, false);
    canvas.drawPath(path, paint);
    canvas.drawCircle(center, size.width * 0.10, Paint()..color = centerColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
      final strings = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.choiceSnackBar)),
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
    final strings = AppStrings.of(context);
    if (widget.cards.length < 3) {
      return _ErrorPage(message: strings.choiceError);
    }

    final choices = [
      strings.choiceAPrefix,
      strings.choiceBPrefix,
      strings.choiceCPrefix,
    ];

    if (!_isResultVisible) {
      return Scaffold(
        body: _TarotMoodBackground(
          palette: _TarotMoodPalettes.choice,
          child: _TarotDeckSelection(
            cardBackAssetPath: 'assets/imgs/taro_back_4.png',
            onCardTap: (_) => _showResult(),
            title: strings.choicePickPrompt,
            titleColor: const Color(0xFF46558D),
            compactHeader: true,
            scrollable: false,
          ),
        ),
      );
    }

    return Scaffold(
      body: _TarotMoodBackground(
        palette: _TarotMoodPalettes.choice,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FF).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.78),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x263F4F88),
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Text(
                  strings.choiceResultHeadline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF46558D),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                strings.choiceMoodLabel,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF7380A5),
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int i = 0; i < _drawnCards.length; i++)
                        _ChoiceResultCard(
                          index: i + 1,
                          title: choices[i],
                          card: _drawnCards[i],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _startReading,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEEF1FF),
                  foregroundColor: const Color(0xFF46558D),
                ),
                child: Text(strings.redrawCard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceResultCard extends StatelessWidget {
  const _ChoiceResultCard({
    required this.index,
    required this.title,
    required this.card,
  });

  final int index;
  final String title;
  final TarotCard card;

  @override
  Widget build(BuildContext context) {
    final accentColors = <Color>[
      const Color(0xFF6072C4),
      const Color(0xFF7B62B6),
      const Color(0xFF4D8EA4),
    ];
    final panelColors = <Color>[
      const Color(0xFFF7F8FF),
      const Color(0xFFFAF7FF),
      const Color(0xFFF2FBFF),
    ];
    final accent = accentColors[(index - 1) % accentColors.length];
    final panel = panelColors[(index - 1) % panelColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panel.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22374976),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index. $title',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.of(context).cardLabel(card.name),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF4B5675),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            card.choiceOption,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.56,
              color: const Color(0xFF48516A),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarotMoodPalette {
  const _TarotMoodPalette({
    required this.gradientColors,
    required this.sparkles,
    required this.sparkleCenterColor,
    required this.backButtonTint,
    required this.backButtonBackground,
    required this.glowColorBottom,
    required this.glowAlphaTop,
    required this.glowAlphaBottom,
  });

  final List<Color> gradientColors;
  final List<_SparkleSpec> sparkles;
  final Color sparkleCenterColor;
  final Color backButtonTint;
  final Color backButtonBackground;
  final Color glowColorBottom;
  final double glowAlphaTop;
  final double glowAlphaBottom;
}

class _TarotMoodPalettes {
  static const _sharedSparkles = <_SparkleSpec>[
    _SparkleSpec(left: 0.06, top: 0.04, size: 16, opacity: 0.86, phase: 0.3),
    _SparkleSpec(left: 0.22, top: 0.06, size: 10, opacity: 0.58, phase: 2.0),
    _SparkleSpec(left: 0.66, top: 0.05, size: 12, opacity: 0.64, phase: 1.1),
    _SparkleSpec(left: 0.90, top: 0.08, size: 18, opacity: 0.82, phase: 2.6),
    _SparkleSpec(left: 0.10, top: 0.12, size: 18, opacity: 0.90, phase: 0.0),
    _SparkleSpec(left: 0.82, top: 0.14, size: 12, opacity: 0.70, phase: 0.9),
    _SparkleSpec(left: 0.18, top: 0.28, size: 10, opacity: 0.58, phase: 1.8),
    _SparkleSpec(left: 0.72, top: 0.34, size: 16, opacity: 0.76, phase: 2.4),
    _SparkleSpec(left: 0.88, top: 0.48, size: 14, opacity: 0.62, phase: 0.5),
    _SparkleSpec(left: 0.08, top: 0.58, size: 20, opacity: 0.82, phase: 1.2),
    _SparkleSpec(left: 0.30, top: 0.70, size: 12, opacity: 0.74, phase: 2.9),
    _SparkleSpec(left: 0.16, top: 0.73, size: 10, opacity: 0.64, phase: 0.7),
    _SparkleSpec(left: 0.42, top: 0.75, size: 14, opacity: 0.78, phase: 2.3),
    _SparkleSpec(left: 0.64, top: 0.71, size: 11, opacity: 0.68, phase: 1.5),
    _SparkleSpec(left: 0.90, top: 0.74, size: 16, opacity: 0.84, phase: 2.8),
    _SparkleSpec(left: 0.78, top: 0.76, size: 18, opacity: 0.88, phase: 1.6),
    _SparkleSpec(left: 0.48, top: 0.84, size: 10, opacity: 0.60, phase: 2.1),
    _SparkleSpec(left: 0.24, top: 0.86, size: 12, opacity: 0.70, phase: 0.9),
    _SparkleSpec(left: 0.58, top: 0.88, size: 15, opacity: 0.76, phase: 1.9),
    _SparkleSpec(left: 0.82, top: 0.90, size: 11, opacity: 0.62, phase: 2.5),
  ];

  static const directAnswer = _TarotMoodPalette(
    gradientColors: [
      Color(0xFFFFF5F3),
      Color(0xFFF7E2E7),
      Color(0xFFDDEDDD),
      Color(0xFFFFF3F7),
    ],
    sparkles: _sharedSparkles,
    sparkleCenterColor: Color(0xFFFFD9E6),
    backButtonTint: Color(0xFF6E3E55),
    backButtonBackground: Color(0xFFFFFAFC),
    glowColorBottom: Color(0xFFF2FFF7),
    glowAlphaTop: 0.52,
    glowAlphaBottom: 0.40,
  );

  static const flow = _TarotMoodPalette(
    gradientColors: [
      Color(0xFFFFF1F7),
      Color(0xFFFFD9EB),
      Color(0xFFF7B8D8),
      Color(0xFFFFE8F3),
    ],
    sparkles: _sharedSparkles,
    sparkleCenterColor: Color(0xFFFFD4EB),
    backButtonTint: Color(0xFF7A4362),
    backButtonBackground: Color(0xFFFFF6FB),
    glowColorBottom: Color(0xFFFFF7FB),
    glowAlphaTop: 0.55,
    glowAlphaBottom: 0.36,
  );

  static const choice = _TarotMoodPalette(
    gradientColors: [
      Color(0xFFF4F6FF),
      Color(0xFFE2E5FF),
      Color(0xFFD7F0FF),
      Color(0xFFF7F4FF),
    ],
    sparkles: _sharedSparkles,
    sparkleCenterColor: Color(0xFFD9DEFF),
    backButtonTint: Color(0xFF46558D),
    backButtonBackground: Color(0xFFF8F9FF),
    glowColorBottom: Color(0xFFF7FBFF),
    glowAlphaTop: 0.50,
    glowAlphaBottom: 0.42,
  );

  static const home = _TarotMoodPalette(
    gradientColors: [
      Color(0xFFFFF6FA),
      Color(0xFFFBE3EF),
      Color(0xFFF1E7FF),
      Color(0xFFE8F4FF),
    ],
    sparkles: _sharedSparkles,
    sparkleCenterColor: Color(0xFFFFE2F0),
    backButtonTint: Color(0xFF6E3E55),
    backButtonBackground: Color(0xFFFFFAFC),
    glowColorBottom: Color(0xFFF5F8FF),
    glowAlphaTop: 0.58,
    glowAlphaBottom: 0.44,
  );
}

class _TarotDeckSelection extends StatelessWidget {
  const _TarotDeckSelection({
    required this.onCardTap,
    required this.cardBackAssetPath,
    this.title = '',
    this.disabledCardIndices = const <int>{},
    this.titleColor = const Color(0xFF2D2430),
    this.compactHeader = false,
    this.scrollable = true,
  });

  final ValueChanged<int> onCardTap;
  final String cardBackAssetPath;
  final String title;
  final Set<int> disabledCardIndices;
  final Color titleColor;
  final bool compactHeader;
  final bool scrollable;

  static const List<int> _rowPattern = <int>[5, 5, 5, 5, 2];

  @override
  Widget build(BuildContext context) {
    final resolvedTitle =
        title.isEmpty ? AppStrings.of(context).defaultDeckTitle : title;
    final allCardIndices = List<int>.generate(22, (i) => i);
    var cursor = 0;

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Transform.translate(
            offset: Offset(0, compactHeader ? -50 : 0),
            child: Padding(
              padding: EdgeInsets.only(bottom: compactHeader ? 10 : 20),
              child: Column(
                children: [
                  Text(
                    resolvedTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compactHeader ? 18.5 : 16,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 8.0;
                  const rowSpacing = 10.0;
                  const cardAspectRatio = 84 / 50;
                  final maxColumns = _rowPattern.reduce(max);
                  final widthBasedCardWidth =
                      (constraints.maxWidth - (maxColumns - 1) * spacing) /
                      maxColumns;
                  final heightBasedCardHeight =
                      (constraints.maxHeight -
                          (_rowPattern.length - 1) * rowSpacing) /
                      _rowPattern.length;
                  final heightBasedCardWidth =
                      heightBasedCardHeight / cardAspectRatio;
                  final cardWidth = min(
                    widthBasedCardWidth,
                    heightBasedCardWidth,
                  );
                  final cardHeight = cardWidth * cardAspectRatio;

                  cursor = 0;
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int row = 0; row < _rowPattern.length; row++) ...[
                          ...() {
                            final rowCount = _rowPattern[row];
                            final rowIndices = allCardIndices.sublist(
                              cursor,
                              cursor + rowCount,
                            );
                            cursor += rowCount;

                            return [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (
                                    int i = 0;
                                    i < rowIndices.length;
                                    i++
                                  ) ...[
                                    if (i != 0) const SizedBox(width: spacing),
                                    GestureDetector(
                                      onTap:
                                          disabledCardIndices.contains(
                                                rowIndices[i],
                                              )
                                              ? null
                                              : () => onCardTap(rowIndices[i]),
                                      child: Opacity(
                                        opacity:
                                            disabledCardIndices.contains(
                                                  rowIndices[i],
                                                )
                                                ? 0.35
                                                : 1,
                                        child: Container(
                                          width: cardWidth,
                                          height: cardHeight,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color(0x332C0F20),
                                                blurRadius: 10,
                                                offset: Offset(0, 6),
                                              ),
                                              BoxShadow(
                                                color: Color(0x1AFFFFFF),
                                                blurRadius: 3,
                                                offset: Offset(-1, -1),
                                              ),
                                            ],
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: Image.asset(
                                            cardBackAssetPath,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ];
                          }(),
                          if (row != _rowPattern.length - 1)
                            const SizedBox(height: rowSpacing),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );

    if (scrollable) {
      content = SingleChildScrollView(
        child: SizedBox(height: 760, child: content),
      );
    }

    return SafeArea(child: content);
  }
}

class _ErrorPage extends StatelessWidget {
  const _ErrorPage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.of(context).errorTitle)),
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
