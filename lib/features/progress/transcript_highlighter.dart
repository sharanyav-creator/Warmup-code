import 'package:flutter/material.dart';

import '../../core/constants.dart';

final List<String> _sortedFillerPhrases = List<String>.from(fillerPhrases)
  ..sort((a, b) => b.split(' ').length.compareTo(a.split(' ').length));

final RegExp _wordPattern = RegExp(r"^[A-Za-z0-9']+$");
final RegExp _tokenPattern = RegExp(r"[A-Za-z0-9']+|[^A-Za-z0-9']+");

/// Builds highlighted spans for a transcript: filler words get an orange
/// background, back-to-back word repeats (fumbles/stutters) get a red
/// dashed underline. Mirrors the matching rules in analysis_engine.dart.
List<InlineSpan> buildTranscriptSpans(
  String transcript, {
  required TextStyle baseStyle,
  bool highlightFillers = true,
  bool highlightFumbles = true,
}) {
  final rawTokens = _tokenPattern.allMatches(transcript).map((m) => m.group(0)!).toList();

  final wordIndices = <int>[];
  final normalizedWords = <String>[];
  for (var i = 0; i < rawTokens.length; i++) {
    if (_wordPattern.hasMatch(rawTokens[i])) {
      wordIndices.add(i);
      normalizedWords.add(rawTokens[i].toLowerCase());
    }
  }

  final isFiller = List.filled(normalizedWords.length, false);
  final isFumble = List.filled(normalizedWords.length, false);

  for (final phrase in _sortedFillerPhrases) {
    final phraseWords = phrase.split(' ');
    for (var i = 0; i <= normalizedWords.length - phraseWords.length; i++) {
      if (isFiller[i]) continue;
      var match = true;
      for (var j = 0; j < phraseWords.length; j++) {
        if (isFiller[i + j] || normalizedWords[i + j] != phraseWords[j]) {
          match = false;
          break;
        }
      }
      if (match) {
        for (var j = 0; j < phraseWords.length; j++) {
          isFiller[i + j] = true;
        }
      }
    }
  }

  for (var i = 1; i < normalizedWords.length; i++) {
    if (normalizedWords[i] == normalizedWords[i - 1]) {
      isFumble[i] = true;
      isFumble[i - 1] = true;
    }
  }

  final spans = <InlineSpan>[];
  var wordPos = 0;
  for (var i = 0; i < rawTokens.length; i++) {
    if (wordPos < wordIndices.length && wordIndices[wordPos] == i) {
      final filler = isFiller[wordPos] && highlightFillers;
      final fumble = isFumble[wordPos] && highlightFumbles;
      spans.add(TextSpan(
        text: rawTokens[i],
        style: baseStyle.copyWith(
          backgroundColor: filler ? const Color(0x33FF5A36) : null,
          decoration: fumble ? TextDecoration.underline : null,
          decorationColor: fumble ? const Color(0xFFB22452) : null,
          decorationStyle: fumble ? TextDecorationStyle.dashed : null,
          decorationThickness: fumble ? 2 : null,
        ),
      ));
      wordPos++;
    } else {
      spans.add(TextSpan(text: rawTokens[i], style: baseStyle));
    }
  }
  return spans;
}
