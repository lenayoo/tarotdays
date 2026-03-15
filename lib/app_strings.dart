import 'package:flutter/material.dart';

class AppStrings {
  const AppStrings._(this.languageCode);

  final String languageCode;

  static AppStrings of(BuildContext context) {
    return fromLocale(Localizations.localeOf(context));
  }

  static AppStrings fromLocale(Locale locale) {
    final code = locale.languageCode.toLowerCase();
    if (code == 'ko' || code == 'ja') {
      return AppStrings._(code);
    }
    return const AppStrings._('en');
  }

  bool get isKorean => languageCode == 'ko';
  bool get isJapanese => languageCode == 'ja';

  String get fallbackCardName {
    if (isKorean) return '이름 없는 카드';
    if (isJapanese) return '名前のないカード';
    return 'Unnamed Card';
  }

  String get missingDirectAnswer {
    if (isKorean) return '직접 답변 데이터가 없습니다.';
    if (isJapanese) return 'ダイレクトリーディングのデータがありません。';
    return 'Direct answer data is missing.';
  }

  String get missingFlowReading {
    if (isKorean) return '흐름 리딩 데이터가 없습니다.';
    if (isJapanese) return 'フローリーディングのデータがありません。';
    return 'Flow reading data is missing.';
  }

  String get missingChoiceOption {
    if (isKorean) return '선택지 리딩 데이터가 없습니다.';
    if (isJapanese) return '選択肢リーディングのデータがありません。';
    return 'Choice reading data is missing.';
  }

  String get failedToLoadCards {
    if (isKorean) return '카드 데이터를 불러오지 못했습니다.';
    if (isJapanese) return 'カードデータを読み込めませんでした。';
    return 'Failed to load card data.';
  }

  String get homeHeadline {
    if (isKorean) return '당신은 어떠한 답을 원하시나요?';
    if (isJapanese) return 'どんな答えを知りたいですか？';
    return 'What kind of answer are you looking for?';
  }

  String get homeDescription {
    if (isKorean) return '질문에 맞는 리딩을 고르면 오늘의 방향이 더 선명해집니다.';
    if (isJapanese) {
      return '質問に合ったリーディングを選ぶと、今日の流れがよりはっきり見えてきます。';
    }
    return 'Choose the reading that fits your question and today’s direction will feel clearer.';
  }

  String get directAnswerMenuTitle {
    if (isKorean) return '명확한 답';
    if (isJapanese) return 'はっきりした答え';
    return 'Clear Answer';
  }

  String get directAnswerMenuSubtitle => 'Yes or No';

  String get directAnswerMenuDescription {
    if (isKorean) return '두 장의 결을 비교해 빠르게 확답을 확인합니다.';
    if (isJapanese) return '2枚の流れを比べて、素早く答えを確かめます。';
    return 'Compare two paths and get a quick answer.';
  }

  String get flowMenuTitle {
    if (isKorean) return '흐름 리딩';
    if (isJapanese) return '流れのリーディング';
    return 'Flow Reading';
  }

  String get flowMenuSubtitle => 'Single Card Flow';

  String get flowMenuDescription {
    if (isKorean) return '현재 분위기와 다음 전개를 한 장으로 읽어냅니다.';
    if (isJapanese) return '今の空気感と次の展開を1枚で読み解きます。';
    return 'Read the current mood and next development with a single card.';
  }

  String get choiceMenuTitle {
    if (isKorean) return '선택지 비교';
    if (isJapanese) return '選択肢の比較';
    return 'Choice Comparison';
  }

  String get choiceMenuSubtitle => 'Three Ways';

  String get choiceMenuDescription {
    if (isKorean) return '세 방향의 흐름을 비교해 더 맞는 선택을 봅니다.';
    if (isJapanese) return '3つの方向の流れを比べて、より合う選択を見ていきます。';
    return 'Compare three directions and see which choice fits best.';
  }

  String get emptyCardData {
    if (isKorean) return '카드 데이터가 비어 있습니다.';
    if (isJapanese) return 'カードデータが空です。';
    return 'Card data is empty.';
  }

  String get cardDataNotFound {
    if (isKorean) return '카드 데이터를 찾지 못했습니다.';
    if (isJapanese) return 'カードデータが見つかりませんでした。';
    return 'Could not find card data.';
  }

  String get drawCardFailed {
    if (isKorean) return '카드를 뽑지 못했습니다.';
    if (isJapanese) return 'カードを引けませんでした。';
    return 'Could not draw a card.';
  }

  String get directFirstPickPrompt {
    if (isKorean) return '하나의 답을 생각하고 카드를 골라주세요.';
    if (isJapanese) return 'ひとつの答えを思い浮かべて、カードを選んでください。';
    return 'Think of one answer and choose a card.';
  }

  String get directSecondPickPrompt {
    if (isKorean) return '나머지 것의 답을 생각하고 카드를 골라주세요.';
    if (isJapanese) return 'もう一方の答えを思い浮かべて、カードを選んでください。';
    return 'Think of the other answer and choose a card.';
  }

  String get directResultHeadline {
    if (isKorean) return 'YES / NO의 결을 비교해보세요';
    if (isJapanese) return 'YES / NO の流れを比べてみましょう';
    return 'Compare the YES / NO paths';
  }

  String get directMoodLabel {
    if (isKorean) return '장밋빛 안개 · 부드러운 세이지의 대비';
    if (isJapanese) return 'ローズの靄 · やわらかなセージの対比';
    return 'rose haze · soft sage contrast';
  }

  String get directYesCaseTitle {
    if (isKorean) return '1) YES를 선택한 경우';
    if (isJapanese) return '1) YES を選んだ場合';
    return '1) If you choose YES';
  }

  String get directNoCaseTitle {
    if (isKorean) return '2) NO를 선택한 경우';
    if (isJapanese) return '2) NO を選んだ場合';
    return '2) If you choose NO';
  }

  String get redrawTwoCards {
    if (isKorean) return '두 카드 다시 뽑기';
    if (isJapanese) return '2枚を引き直す';
    return 'Draw Two New Cards';
  }

  String get flowPickPrompt {
    if (isKorean) return '지금의 흐름을 떠올리며 카드를 골라주세요.';
    if (isJapanese) return '今の流れを思い浮かべながら、カードを選んでください。';
    return 'Choose a card while thinking about your current flow.';
  }

  String get flowMoodLabel {
    if (isKorean) return '부드러운 핑크 그라데이션 · 떠다니는 반짝임';
    if (isJapanese) return 'やわらかなピンクのグラデーション · 浮かぶきらめき';
    return 'soft pink gradient · floating sparkles';
  }

  String get redrawCard {
    if (isKorean) return '다시 뽑기';
    if (isJapanese) return '引き直す';
    return 'Draw Again';
  }

  String get choiceSnackBar {
    if (isKorean) return '카드가 3장 미만이라 선택지 리딩을 할 수 없습니다.';
    if (isJapanese) return 'カードが3枚未満のため、選択肢リーディングはできません。';
    return 'Choice reading needs at least 3 cards.';
  }

  String get choiceError {
    if (isKorean) return '카드 데이터가 3장 미만이라 3가지 선택 리딩을 제공할 수 없습니다.';
    if (isJapanese) return 'カードデータが3枚未満のため、3択リーディングを提供できません。';
    return 'At least 3 cards are required for the three-choice reading.';
  }

  String get choiceAPrefix {
    if (isKorean) return 'A를 선택할 경우';
    if (isJapanese) return 'Aを選んだ場合';
    return 'If you choose A';
  }

  String get choiceBPrefix {
    if (isKorean) return 'B를 선택할 경우';
    if (isJapanese) return 'Bを選んだ場合';
    return 'If you choose B';
  }

  String get choiceCPrefix {
    if (isKorean) return 'C를 선택할 경우';
    if (isJapanese) return 'Cを選んだ場合';
    return 'If you choose C';
  }

  String get choicePickPrompt {
    if (isKorean) return '세 갈래 흐름 중 더 끌리는 방향을 골라주세요.';
    if (isJapanese) return '3つの流れの中から、より惹かれる方向を選んでください。';
    return 'Choose the direction that pulls you most among the three paths.';
  }

  String get choiceResultHeadline {
    if (isKorean) return '세 방향의 흐름을 비교해보세요';
    if (isJapanese) return '3つの流れを比べてみましょう';
    return 'Compare the flow of the three paths';
  }

  String get choiceMoodLabel {
    if (isKorean) return '푸른 안개 · 라일락 갈래 스프레드';
    if (isJapanese) return '青い霧 · ライラックの分岐スプレッド';
    return 'blue mist · lilac branching spread';
  }

  String cardLabel(String cardName) {
    if (isKorean) return '카드: $cardName';
    if (isJapanese) return 'カード: $cardName';
    return 'Card: $cardName';
  }

  String get defaultDeckTitle {
    if (isKorean) return '카드를 선택해 리딩을 시작하세요';
    if (isJapanese) return 'カードを選んでリーディングを始めてください';
    return 'Choose a card to begin the reading';
  }

  String get errorTitle {
    if (isKorean) return '오류';
    if (isJapanese) return 'エラー';
    return 'Error';
  }

  String get answerYes {
    if (isJapanese) return 'はい';
    return 'YES';
  }

  String get answerNo {
    if (isJapanese) return 'いいえ';
    return 'NO';
  }

  String get answerNeutral {
    if (isKorean) return '중립';
    if (isJapanese) return '中立';
    return 'NEUTRAL';
  }
}
