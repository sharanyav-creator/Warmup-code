import '../../core/constants.dart';
import '../../data/models/analysis_result.dart';

/// A chunk of recognized speech with the timestamp it arrived at,
/// used to approximate gaps/pauses between bursts of speech.
class SpeechChunk {
  final String text;
  final DateTime timestamp;

  const SpeechChunk({required this.text, required this.timestamp});
}

/// Longest-phrase-first filler matching so "you know" isn't also counted as
/// bare "know", and sorted so multi-word phrases are checked before single words.
final List<String> _sortedFillerPhrases = List<String>.from(fillerPhrases)
  ..sort((a, b) => b.split(' ').length.compareTo(a.split(' ').length));

List<String> _tokenize(String text) {
  final cleaned = text.toLowerCase().replaceAll(RegExp(r"[^a-z0-9'\s]"), ' ');
  return cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
}

AnalysisResult analyzeSession({
  required String transcript,
  required List<SpeechChunk> chunks,
  required Duration sessionDuration,
}) {
  final tokens = _tokenize(transcript);
  final wordCount = tokens.length;
  final durationSeconds = sessionDuration.inMilliseconds / 1000.0;
  final wordsPerMinute =
      durationSeconds <= 0 ? 0.0 : wordCount / (durationSeconds / 60);

  final fillerBreakdown = <String, int>{};
  final matchedIndices = <bool>[for (var _ in tokens) false];

  for (final phrase in _sortedFillerPhrases) {
    final phraseWords = phrase.split(' ');
    for (var i = 0; i <= tokens.length - phraseWords.length; i++) {
      if (matchedIndices[i]) continue;
      var isMatch = true;
      for (var j = 0; j < phraseWords.length; j++) {
        if (matchedIndices[i + j] || tokens[i + j] != phraseWords[j]) {
          isMatch = false;
          break;
        }
      }
      if (isMatch) {
        fillerBreakdown[phrase] = (fillerBreakdown[phrase] ?? 0) + 1;
        for (var j = 0; j < phraseWords.length; j++) {
          matchedIndices[i + j] = true;
        }
      }
    }
  }
  final fillerCount = fillerBreakdown.values.fold(0, (a, b) => a + b);

  final wordFrequency = <String, int>{};
  for (var i = 0; i < tokens.length; i++) {
    if (matchedIndices[i]) continue;
    final word = tokens[i];
    if (clutchWordStopList.contains(word) || word.length < 3) continue;
    wordFrequency[word] = (wordFrequency[word] ?? 0) + 1;
  }
  final clutchWords = wordFrequency.entries
      .where((e) => e.value >= clutchWordMinCount)
      .map((e) => ClutchWord(word: e.key, count: e.value))
      .toList()
    ..sort((a, b) => b.count.compareTo(a.count));

  var longPauseCount = 0;
  for (var i = 1; i < chunks.length; i++) {
    final gap = chunks[i].timestamp.difference(chunks[i - 1].timestamp);
    if (gap >= longPauseThreshold) longPauseCount++;
  }

  // Stutters/false starts: the same word repeated back-to-back, e.g. "I, I, I mean".
  var fumbleCount = 0;
  for (var i = 1; i < tokens.length; i++) {
    if (tokens[i] == tokens[i - 1]) fumbleCount++;
  }

  final score = _computeScore(
    wordCount: wordCount,
    fillerCount: fillerCount,
    clutchWordCount: clutchWords.length,
    longPauseCount: longPauseCount,
    fumbleCount: fumbleCount,
    wordsPerMinute: wordsPerMinute,
  );

  return AnalysisResult(
    transcript: transcript,
    wordCount: wordCount,
    durationSeconds: durationSeconds,
    wordsPerMinute: wordsPerMinute,
    fillerCount: fillerCount,
    fillerBreakdown: fillerBreakdown,
    clutchWords: clutchWords,
    longPauseCount: longPauseCount,
    score: score,
    fumbleCount: fumbleCount,
  );
}

int _computeScore({
  required int wordCount,
  required int fillerCount,
  required int clutchWordCount,
  required int longPauseCount,
  required int fumbleCount,
  required double wordsPerMinute,
}) {
  if (wordCount == 0) return 0;

  double score = 100;

  final fillerRatio = fillerCount / wordCount;
  score -= (fillerRatio * 100).clamp(0, 40);

  score -= (clutchWordCount * 5).clamp(0, 20);

  score -= (longPauseCount * 4).clamp(0, 20);

  score -= (fumbleCount * 3).clamp(0, 15);

  const idealMin = 110.0, idealMax = 160.0;
  if (wordsPerMinute < idealMin) {
    score -= ((idealMin - wordsPerMinute) / idealMin * 20).clamp(0, 20);
  } else if (wordsPerMinute > idealMax) {
    score -= ((wordsPerMinute - idealMax) / idealMax * 20).clamp(0, 20);
  }

  return score.clamp(0, 100).round();
}
