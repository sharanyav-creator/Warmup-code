import 'dart:math';

const List<String> dailyPrompts = [
  "Describe a small win you had this week.",
  "Explain your job to someone who's never heard of it.",
  "What's a decision you're glad you made?",
  "Pitch an idea you believe in, in one minute.",
  "Describe your morning routine like it's a story.",
  "What's something you changed your mind about recently?",
  "Introduce yourself as if this were a job interview.",
  "Describe a place you'd love to visit and why.",
  "Explain a topic you know well to a beginner.",
  "What's a challenge you're currently working through?",
  "Describe your ideal weekend from start to finish.",
  "What advice would you give your younger self?",
  "Talk about a book, show, or film that stuck with you.",
  "Describe a time you solved a tricky problem.",
  "What does a good day at work look like for you?",
];

/// Deterministic "prompt of the day" so it's stable across app opens on the same day.
String promptForDate(DateTime date) {
  final dayIndex = date.difference(DateTime(2026, 1, 1)).inDays;
  final index = dayIndex % dailyPrompts.length;
  return dailyPrompts[index < 0 ? index + dailyPrompts.length : index];
}

final Random _promptRandom = Random();

/// A random conversational prompt for "impromptu" practice sessions.
String randomPrompt() => dailyPrompts[_promptRandom.nextInt(dailyPrompts.length)];
