import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_strings.dart';

enum AnswerType {
  yes(Color(0xFF2E7D32), Color(0xFFE8F5E9)),
  no(Color(0xFFC62828), Color(0xFFFFEBEE)),
  neutral(Color(0xFF455A64), Color(0xFFECEFF1));

  const AnswerType(this.textColor, this.backgroundColor);

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

  String label(AppStrings strings) {
    switch (this) {
      case AnswerType.yes:
        return strings.answerYes;
      case AnswerType.no:
        return strings.answerNo;
      case AnswerType.neutral:
        return strings.answerNeutral;
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

  static const List<String> _assetNames = <String>[
    '00_the_fool',
    '01_the_magician',
    '02_the_high_priestess',
    '03_the_empress',
    '04_the_emperor',
    '05_the_hierophant',
    '06_the_lovers',
    '07_chariot',
    '08_strength',
    '09_the_hermit',
    '10_wheel_of_fortune',
    '11_justice',
    '12_the_hanged_man',
    '13_death',
    '14_temperance',
    '15_the_devil',
    '16_the_tower',
    '17_the_star',
    '18_the_moon',
    '19_the_sun',
    '20_judgement',
    '21_the_world',
  ];

  String get imageAssetPath {
    if (id < 0 || id >= _assetNames.length) {
      return 'assets/imgs/taro_back_2.png';
    }
    return 'assets/imgs/${_assetNames[id]}.webp';
  }

  factory TarotCard.fromJson(Map<String, dynamic> json) {
    final fallback = AppStrings.fromLocale(const Locale('en'));

    return TarotCard(
      id: json['id'] is int ? json['id'] as int : -1,
      name:
          (json['name'] as String?)?.trim().isNotEmpty == true
              ? json['name'] as String
              : fallback.fallbackCardName,
      directAnswer:
          (json['direct_answer'] as String?)?.trim().isNotEmpty == true
              ? json['direct_answer'] as String
              : fallback.missingDirectAnswer,
      flowReading:
          (json['flow_reading'] as String?)?.trim().isNotEmpty == true
              ? json['flow_reading'] as String
              : fallback.missingFlowReading,
      choiceOption:
          (json['choice_option'] as String?)?.trim().isNotEmpty == true
              ? json['choice_option'] as String
              : fallback.missingChoiceOption,
      answerType: AnswerType.fromRaw(
        (json['answer_type'] as String?) ?? 'neutral',
      ),
    );
  }
}

class TarotRepository {
  static Future<List<TarotCard>> loadCards(Locale locale) async {
    final strings = AppStrings.fromLocale(locale);

    try {
      final raw = await rootBundle.loadString(_assetPathForLocale(locale));
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const FormatException('JSON root must be a list.');
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(TarotCard.fromJson)
          .toList();
    } catch (e) {
      throw Exception('${strings.failedToLoadCards}: $e');
    }
  }

  static String _assetPathForLocale(Locale locale) {
    switch (locale.languageCode.toLowerCase()) {
      case 'ko':
        return 'assets/taro_reading_kr.json';
      case 'ja':
        return 'assets/taro_reading_jp.json';
      case 'en':
      default:
        return 'assets/taro_reading_en.json';
    }
  }
}
