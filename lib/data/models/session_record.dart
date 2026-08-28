import 'dart:convert';

/// A single completed practice session, persisted locally.
class SessionRecord {
  final int? id;
  final DateTime createdAt;
  final String promptText;
  final String transcript;
  final int wordCount;
  final double durationSeconds;
  final double wordsPerMinute;
  final int fillerCount;
  final Map<String, int> fillerBreakdown;
  final int clutchWordCount;
  final int longPauseCount;
  final int score;

  const SessionRecord({
    this.id,
    required this.createdAt,
    required this.promptText,
    required this.transcript,
    required this.wordCount,
    required this.durationSeconds,
    required this.wordsPerMinute,
    required this.fillerCount,
    required this.fillerBreakdown,
    required this.clutchWordCount,
    required this.longPauseCount,
    required this.score,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'promptText': promptText,
      'transcript': transcript,
      'wordCount': wordCount,
      'durationSeconds': durationSeconds,
      'wordsPerMinute': wordsPerMinute,
      'fillerCount': fillerCount,
      'fillerBreakdown': jsonEncode(fillerBreakdown),
      'clutchWordCount': clutchWordCount,
      'longPauseCount': longPauseCount,
      'score': score,
    };
  }

  factory SessionRecord.fromMap(Map<String, dynamic> map) {
    return SessionRecord(
      id: map['id'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      promptText: map['promptText'] as String,
      transcript: map['transcript'] as String,
      wordCount: map['wordCount'] as int,
      durationSeconds: (map['durationSeconds'] as num).toDouble(),
      wordsPerMinute: (map['wordsPerMinute'] as num).toDouble(),
      fillerCount: map['fillerCount'] as int,
      fillerBreakdown: Map<String, int>.from(
        jsonDecode(map['fillerBreakdown'] as String) as Map,
      ),
      clutchWordCount: map['clutchWordCount'] as int,
      longPauseCount: map['longPauseCount'] as int,
      score: map['score'] as int,
    );
  }
}
