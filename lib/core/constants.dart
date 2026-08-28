/// Words/phrases counted as filler when they appear in a transcript.
/// Longer phrases are checked before single words so "you know" isn't
/// double counted as "you" + "know".
const List<String> fillerPhrases = [
  'you know',
  'sort of',
  'kind of',
  'i mean',
  'um',
  'umm',
  'uh',
  'uhh',
  'ah',
  'er',
  'erm',
  'like',
  'actually',
  'basically',
  'literally',
  'so',
  'well',
  'right',
];

/// Words too common/short to flag as "clutch" repeats even if they recur often.
const Set<String> clutchWordStopList = {
  'the', 'a', 'an', 'i', 'to', 'is', 'it', 'and', 'of', 'in', 'that', 'you',
  'was', 'for', 'on', 'with', 'as', 'my', 'me', 'be', 'are', 'this',
};

/// Minimum gap between two recognized speech chunks to count as a "long pause".
const Duration longPauseThreshold = Duration(seconds: 2);

/// Target daily practice length.
const Duration targetSessionLength = Duration(seconds: 60);

/// A word must repeat at least this many times in one session to be a "clutch word".
const int clutchWordMinCount = 3;
