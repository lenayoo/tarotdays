import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_strings.dart';
import 'tarot_data.dart';

void main() {
  runApp(const MyApp());
}

enum ReadingType { directAnswer, flow, choice }

class _UserProfile {
  const _UserProfile({required this.name});

  final String name;
}

class _AppStorage {
  static const _userNameKey = 'user_name';
  static const _dailyLimitPerSection = 2;
  static const _disableDailyLimitForTesting = true;

  static Future<_UserProfile> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_userNameKey)?.trim();
    return _UserProfile(name: name ?? '');
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name.trim());
  }

  static Future<bool> canUseReading(ReadingType type) async {
    if (_disableDailyLimitForTesting) {
      return true;
    }
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_dailyKey(type, _todayKey())) ?? 0;
    return count < _dailyLimitPerSection;
  }

  static Future<void> consumeReading(ReadingType type) async {
    if (_disableDailyLimitForTesting) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final key = _dailyKey(type, _todayKey());
    final count = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, count + 1);
  }

  static String _todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  static String _dailyKey(ReadingType type, String dateKey) {
    return 'daily_${type.name}_$dateKey';
  }
}

extension on ReadingType {
  String sectionTitle(AppStrings strings) {
    switch (this) {
      case ReadingType.directAnswer:
        return strings.directAnswerMenuTitle;
      case ReadingType.flow:
        return strings.flowMenuTitle;
      case ReadingType.choice:
        return strings.choiceMenuTitle;
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
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
    );

    return MaterialApp(
      title: 'Tarot Days',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
        Locale('ja'),
      ],
      theme: _themeForLocale(const Locale('en'), baseTheme),
      builder: (context, child) {
        final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
        return Theme(
          data: _themeForLocale(locale, baseTheme),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomePage(),
    );
  }
}

ThemeData _themeForLocale(Locale locale, ThemeData baseTheme) {
  final code = locale.languageCode.toLowerCase();

  if (code == 'ko') {
    return baseTheme.copyWith(
      textTheme: GoogleFonts.gowunDodumTextTheme(baseTheme.textTheme),
      primaryTextTheme: GoogleFonts.gowunDodumTextTheme(
        baseTheme.primaryTextTheme,
      ),
    );
  }

  if (code == 'ja') {
    return baseTheme.copyWith(
      textTheme: GoogleFonts.mPlusRounded1cTextTheme(baseTheme.textTheme),
      primaryTextTheme: GoogleFonts.mPlusRounded1cTextTheme(
        baseTheme.primaryTextTheme,
      ),
    );
  }

  return baseTheme.copyWith(
    textTheme: GoogleFonts.nunitoTextTheme(baseTheme.textTheme),
    primaryTextTheme: GoogleFonts.nunitoTextTheme(baseTheme.primaryTextTheme),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _userName;
  bool _nameDialogOpened = false;

  void _openPage(BuildContext context, ReadingType type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReadingPage(type: type)),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _AppStorage.loadUserProfile();
    if (!mounted) {
      return;
    }
    setState(() {
      _userName = profile.name.isEmpty ? null : profile.name;
    });
    if ((_userName == null || _userName!.isEmpty) && !_nameDialogOpened) {
      _nameDialogOpened = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showNameDialog();
        }
      });
    }
  }

  Future<void> _showNameDialog() async {
    final strings = AppStrings.of(context);
    final controller = TextEditingController();
    String? errorText;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(strings.namePromptTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: strings.nameFieldHint,
                      errorText: errorText,
                    ),
                    onSubmitted: (_) async {
                      final name = controller.text.trim();
                      if (name.isEmpty) {
                        setModalState(() {
                          errorText = strings.nameRequired;
                        });
                        return;
                      }
                      await _AppStorage.saveUserName(name);
                      if (!mounted) {
                        return;
                      }
                      setState(() {
                        _userName = name;
                      });
                      if (!dialogContext.mounted) {
                        return;
                      }
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final name = controller.text.trim();
                    if (name.isEmpty) {
                      setModalState(() {
                        errorText = strings.nameRequired;
                      });
                      return;
                    }
                    await _AppStorage.saveUserName(name);
                    if (!mounted) {
                      return;
                    }
                    setState(() {
                      _userName = name;
                    });
                    if (!dialogContext.mounted) {
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(strings.saveName),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final headline =
        _userName == null || _userName!.isEmpty
            ? strings.homeHeadline
            : strings.personalizedHomeHeadline(_userName!);

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
                    color: const Color(0xFF7F88B6),
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  headline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF5C6692),
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    fontSize: 34,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.homeDescription,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8F98B4),
                    height: 1.45,
                    fontSize: 18,
                  ),
                ),
                const Spacer(flex: 2),
                _HomeReadingCard(
                  indexLabel: '01',
                  title: strings.directAnswerMenuTitle,
                  subtitle: strings.directAnswerMenuSubtitle,
                  description: strings.directAnswerMenuDescription,
                  accentColor: const Color(0xFF7D8EDD),
                  panelColor: const Color(0xFFFCFEFF),
                  artAssetPath: 'assets/imgs/taro_back_2.png',
                  onTap: () => _openPage(context, ReadingType.directAnswer),
                ),
                const SizedBox(height: 12),
                _HomeReadingCard(
                  indexLabel: '02',
                  title: strings.flowMenuTitle,
                  subtitle: strings.flowMenuSubtitle,
                  description: strings.flowMenuDescription,
                  accentColor: const Color(0xFF7A89C8),
                  panelColor: const Color(0xFFFBFDFF),
                  artAssetPath: 'assets/imgs/taro_back_3.png',
                  onTap: () => _openPage(context, ReadingType.flow),
                ),
                const SizedBox(height: 12),
                _HomeReadingCard(
                  indexLabel: '03',
                  title: strings.choiceMenuTitle,
                  subtitle: strings.choiceMenuSubtitle,
                  description: strings.choiceMenuDescription,
                  accentColor: const Color(0xFF6A82D9),
                  panelColor: const Color(0xFFF9FCFF),
                  artAssetPath: 'assets/imgs/taro_back_4.png',
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
    required this.artAssetPath,
    required this.onTap,
  });

  final String indexLabel;
  final String title;
  final String subtitle;
  final String description;
  final Color accentColor;
  final Color panelColor;
  final String artAssetPath;
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
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          overlayColor: WidgetStatePropertyAll<Color>(Colors.transparent),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: panelColor.withValues(alpha: 0.40),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.82),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x123E5378),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 74,
                  height: 92,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22342A32),
                        blurRadius: 12,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _CardBackPreview(
                    imageAssetPath: artAssetPath,
                    accentColor: accentColor,
                  ),
                ),
                const SizedBox(width: 30),
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
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF5A6487),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
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
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 22,
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

Future<void> _showDailyLimitDialog(
  BuildContext context,
  ReadingType type,
) async {
  final strings = AppStrings.of(context);
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(strings.dailyLimitTitle),
        content: Text(strings.dailyLimitMessage(type.sectionTitle(strings))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.limitConfirm),
          ),
        ],
      );
    },
  );
}

class DirectAnswerPage extends StatefulWidget {
  const DirectAnswerPage({super.key, required this.cards});

  final List<TarotCard> cards;

  @override
  State<DirectAnswerPage> createState() => _DirectAnswerPageState();
}

class _DirectAnswerPageState extends State<DirectAnswerPage> {
  bool _isResultVisible = false;
  bool _isDrawing = false;
  final List<int> _selectedCardIndices = <int>[];

  Future<void> _onDeckCardTap(int index) async {
    if (_selectedCardIndices.contains(index)) {
      return;
    }

    final nextIndices = [..._selectedCardIndices, index];
    setState(() {
      _selectedCardIndices.add(index);
    });

    if (nextIndices.length != 2) {
      return;
    }

    final canUse = await _AppStorage.canUseReading(ReadingType.directAnswer);
    if (!mounted) {
      return;
    }
    if (!canUse) {
      setState(() {
        _selectedCardIndices.removeLast();
      });
      await _showDailyLimitDialog(context, ReadingType.directAnswer);
      return;
    }

    setState(() {
      _isDrawing = true;
    });
    await _AppStorage.consumeReading(ReadingType.directAnswer);
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) {
      return;
    }
    setState(() {
      _isDrawing = false;
      _isResultVisible = true;
    });
  }

  void _resetToFirstStep() {
    setState(() {
      _isResultVisible = false;
      _isDrawing = false;
      _selectedCardIndices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    if (widget.cards.length < 2) {
      return _ErrorPage(message: strings.cardDataNotFound);
    }

    final selectedCards =
        _selectedCardIndices
            .where((index) => index >= 0 && index < widget.cards.length)
            .map((index) => widget.cards[index])
            .toList(growable: false);

    if (!_isResultVisible && !_isDrawing) {
      return Scaffold(
        body: _TarotMoodBackground(
          palette: _TarotMoodPalettes.directAnswer,
          child: _TarotDeckSelection(
            title:
                _selectedCardIndices.isEmpty
                    ? strings.directFirstPickPrompt
                    : strings.directSecondPickPrompt,
            cardBackAssetPath: 'assets/imgs/taro_back_2.png',
            disabledCardIndices: _selectedCardIndices.toSet(),
            onCardTap: _onDeckCardTap,
            titleColor: const Color(0xFF6E3E55),
            compactHeader: true,
            scrollable: false,
          ),
        ),
      );
    }

    if (_isDrawing) {
      return Scaffold(
        body: _TarotMoodBackground(
          palette: _TarotMoodPalettes.directAnswer,
          child: _CardDrawAnimation(totalCards: 2),
        ),
      );
    }

    return Scaffold(
      body: _TarotMoodBackground(
        palette: _TarotMoodPalettes.directAnswer,
        headerTitle: strings.directResultHeadline,
        headerTitleColor: const Color(0xFF6E3E55),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 6),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DirectAnswerSection(
                        title: strings.directYesCaseTitle,
                        card: selectedCards[0],
                        accentColor: const Color(0xFF5D8A72),
                        panelColor: const Color(0xFFF4FBF6),
                      ),
                      const SizedBox(height: 14),
                      _DirectAnswerSection(
                        title: strings.directNoCaseTitle,
                        card: selectedCards[1],
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
        color: panelColor.withValues(alpha: 0.72),
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
          Center(
            child: _TarotCardArtwork(
              imageAssetPath: card.imageAssetPath,
              height: 220,
            ),
          ),
          const SizedBox(height: 14),
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
  TarotCard? _selectedCard;
  bool _isResultVisible = false;
  bool _isDrawing = false;

  Future<void> _startFlowReading(int index) async {
    final canUse = await _AppStorage.canUseReading(ReadingType.flow);
    if (!mounted) {
      return;
    }
    if (!canUse) {
      await _showDailyLimitDialog(context, ReadingType.flow);
      return;
    }

    setState(() {
      _selectedCard = widget.cards[index];
      _isDrawing = true;
    });
    await _AppStorage.consumeReading(ReadingType.flow);
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) {
      return;
    }
    setState(() {
      _isDrawing = false;
      _isResultVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final card = _selectedCard;
    if (card == null) {
      if (_isResultVisible) {
        return _ErrorPage(message: strings.drawCardFailed);
      }
    }

    if (!_isResultVisible && !_isDrawing) {
      return Scaffold(
        body: _TarotMoodBackground(
          palette: _TarotMoodPalettes.flow,
          child: _TarotDeckSelection(
            cardBackAssetPath: 'assets/imgs/taro_back_3.png',
            onCardTap: _startFlowReading,
            title: strings.flowPickPrompt,
            titleColor: const Color(0xFF6F3556),
            compactHeader: true,
            scrollable: false,
          ),
        ),
      );
    }

    if (_isDrawing) {
      return Scaffold(
        body: _TarotMoodBackground(
          palette: _TarotMoodPalettes.flow,
          child: _CardDrawAnimation(totalCards: 1),
        ),
      );
    }

    return Scaffold(
      body: _TarotMoodBackground(
        palette: _TarotMoodPalettes.flow,
        headerTitle: card!.name,
        headerTitleColor: const Color(0xFF6F3556),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: _TarotCardArtwork(
                  imageAssetPath: card.imageAssetPath,
                  height: 250,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBFD).withValues(alpha: 0.68),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: const Color(0xFFFFFFFF).withValues(alpha: 0.82),
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
                onPressed: () {
                  setState(() {
                    _selectedCard = null;
                    _isDrawing = false;
                    _isResultVisible = false;
                  });
                },
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
    this.headerTitle,
    this.headerTitleColor,
  });

  final Widget child;
  final _TarotMoodPalette palette;
  final bool showBackButton;
  final double topContentOffset;
  final String? headerTitle;
  final Color? headerTitleColor;

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
              if (widget.headerTitle != null)
                Positioned(
                  top: topInset + 18,
                  left: 72,
                  right: 72,
                  child: Text(
                    widget.headerTitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color:
                          widget.headerTitleColor ??
                          widget.palette.backButtonTint,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
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

class _CardDrawAnimation extends StatefulWidget {
  const _CardDrawAnimation({required this.totalCards});

  final int totalCards;

  @override
  State<_CardDrawAnimation> createState() => _CardDrawAnimationState();
}

class _CardDrawAnimationState extends State<_CardDrawAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return SafeArea(
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      for (final cloud in _cloudSpecs)
                        Positioned(
                          left: cloud.baseX + sin((t * pi * 2) + cloud.phase) * cloud.dx,
                          top: cloud.baseY + cos((t * pi * 2) + cloud.phase) * cloud.dy,
                          child: Opacity(
                            opacity: cloud.opacity,
                            child: Icon(
                              Icons.cloud_rounded,
                              size: cloud.size,
                              color: Colors.white.withValues(alpha: 0.78),
                            ),
                          ),
                        ),
                      Transform.scale(
                        scale: 0.94 + (sin(t * pi * 2) * 0.05),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFFFFFFF).withValues(alpha: 0.92),
                                const Color(0xFFFFD8F0).withValues(alpha: 0.72),
                                const Color(0xFFA66EB6).withValues(alpha: 0.38),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFC7EA).withValues(alpha: 0.52),
                                blurRadius: 34,
                                spreadRadius: 6,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '🔮',
                            style: TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  strings.crystalBallLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF603B56),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    strings.drawingMessage(widget.totalCards),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF7E6675),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CloudSpec {
  const _CloudSpec({
    required this.baseX,
    required this.baseY,
    required this.size,
    required this.dx,
    required this.dy,
    required this.opacity,
    required this.phase,
  });

  final double baseX;
  final double baseY;
  final double size;
  final double dx;
  final double dy;
  final double opacity;
  final double phase;
}

const List<_CloudSpec> _cloudSpecs = <_CloudSpec>[
  _CloudSpec(baseX: 16, baseY: 30, size: 52, dx: 18, dy: 10, opacity: 0.62, phase: 0.1),
  _CloudSpec(baseX: 180, baseY: 26, size: 48, dx: 16, dy: 12, opacity: 0.58, phase: 1.3),
  _CloudSpec(baseX: 42, baseY: 160, size: 58, dx: 14, dy: 11, opacity: 0.64, phase: 2.1),
  _CloudSpec(baseX: 172, baseY: 168, size: 54, dx: 18, dy: 12, opacity: 0.56, phase: 2.8),
  _CloudSpec(baseX: 90, baseY: 8, size: 44, dx: 12, dy: 8, opacity: 0.48, phase: 0.7),
  _CloudSpec(baseX: 92, baseY: 206, size: 46, dx: 10, dy: 9, opacity: 0.52, phase: 1.9),
];

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
  final List<int> _selectedCardIndices = <int>[];
  bool _isResultVisible = false;
  bool _isDrawing = false;

  Future<void> _onChoiceCardTap(int index) async {
    if (_selectedCardIndices.contains(index)) {
      return;
    }

    final nextIndices = [..._selectedCardIndices, index];
    setState(() {
      _selectedCardIndices.add(index);
    });

    if (nextIndices.length != 3) {
      return;
    }

    final canUse = await _AppStorage.canUseReading(ReadingType.choice);
    if (!mounted) {
      return;
    }
    if (!canUse) {
      setState(() {
        _selectedCardIndices.removeLast();
      });
      await _showDailyLimitDialog(context, ReadingType.choice);
      return;
    }

    setState(() {
      _isDrawing = true;
    });
    await _AppStorage.consumeReading(ReadingType.choice);
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) {
      return;
    }
    setState(() {
      _isDrawing = false;
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
    final selectedCards =
        _selectedCardIndices
            .where((index) => index >= 0 && index < widget.cards.length)
            .map((index) => widget.cards[index])
            .toList(growable: false);

    if (!_isResultVisible && !_isDrawing) {
      return Scaffold(
        body: _TarotMoodBackground(
          palette: _TarotMoodPalettes.choice,
          child: _TarotDeckSelection(
            cardBackAssetPath: 'assets/imgs/taro_back_4.png',
            onCardTap: _onChoiceCardTap,
            title:
                _selectedCardIndices.isEmpty
                    ? strings.choicePickPrompt
                    : strings.choicePickProgress(_selectedCardIndices.length),
            disabledCardIndices: _selectedCardIndices.toSet(),
            titleColor: const Color(0xFF46558D),
            compactHeader: true,
            scrollable: false,
          ),
        ),
      );
    }

    if (_isDrawing) {
      return Scaffold(
        body: _TarotMoodBackground(
          palette: _TarotMoodPalettes.choice,
          child: _CardDrawAnimation(totalCards: 3),
        ),
      );
    }

    return Scaffold(
      body: _TarotMoodBackground(
        palette: _TarotMoodPalettes.choice,
        headerTitle: strings.choiceResultHeadline,
        headerTitleColor: const Color(0xFF46558D),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 6),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int i = 0; i < selectedCards.length; i++)
                        _ChoiceResultCard(
                          index: i + 1,
                          title: choices[i],
                          card: selectedCards[i],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedCardIndices.clear();
                    _isDrawing = false;
                    _isResultVisible = false;
                  });
                },
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
        color: panel.withValues(alpha: 0.72),
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
          Center(
            child: _TarotCardArtwork(
              imageAssetPath: card.imageAssetPath,
              height: 220,
            ),
          ),
          const SizedBox(height: 14),
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

class _CardBackPreview extends StatelessWidget {
  const _CardBackPreview({
    required this.imageAssetPath,
    required this.accentColor,
  });

  final String imageAssetPath;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 72,
        height: 86,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: const Offset(5, 4),
              child: Transform.rotate(
                angle: -0.12,
                child: _TarotCardArtwork(
                  imageAssetPath: imageAssetPath,
                  height: 68,
                  widthFactor: 0.72,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: accentColor.withValues(alpha: 0.28)),
              ),
              child: _TarotCardArtwork(
                imageAssetPath: imageAssetPath,
                height: 72,
                widthFactor: 0.72,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarotCardArtwork extends StatelessWidget {
  const _TarotCardArtwork({
    required this.imageAssetPath,
    this.height = 220,
    this.widthFactor = 0.62,
  });

  final String imageAssetPath;
  final double height;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      constraints: BoxConstraints(maxWidth: height * widthFactor),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33261325),
            blurRadius: 18,
            offset: Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(imageAssetPath, fit: BoxFit.cover),
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
      Color(0xFFFFFFFF),
      Color(0xFFF4F8FF),
      Color(0xFFF7F4FF),
      Color(0xFFFCFEFF),
    ],
    sparkles: _sharedSparkles,
    sparkleCenterColor: Color(0xFFF1F6FF),
    backButtonTint: Color(0xFF66739B),
    backButtonBackground: Color(0xFFFFFFFF),
    glowColorBottom: Color(0xFFF2F8FF),
    glowAlphaTop: 0.68,
    glowAlphaBottom: 0.28,
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
