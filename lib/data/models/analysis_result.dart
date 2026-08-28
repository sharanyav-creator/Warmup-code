class ClutchWord {
  final String word;
  final int count;

  const ClutchWord({required this.word, required this.count});
}

class AnalysisResult {
  final String transcript;
  final int wordCount;
  final double durationSeconds;
  final double wordsPerMinute;
  final int fillerCount;
  final Map<String, int> fillerBreakdown;
  final List<ClutchWord> clutchWords;
  final int longPauseCount;
  final int score;
  final int fumbleCount;

  const AnalysisResult({
    required this.transcript,
    required this.wordCount,
    required this.durationSeconds,
    required this.wordsPerMinute,
    required this.fillerCount,
    required this.fillerBreakdown,
    required this.clutchWords,
    required this.longPauseCount,
    required this.score,
    required this.fumbleCount,
  });

  double get fillerRatePerMinute =>
      durationSeconds <= 0 ? 0 : fillerCount / (durationSeconds / 60);
}
