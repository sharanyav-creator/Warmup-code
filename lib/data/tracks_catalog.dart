class TrackDef {
  final String id;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String trackLabel;
  final List<String> prompts;

  const TrackDef({
    required this.id,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.trackLabel,
    required this.prompts,
  });
}

const List<TrackDef> allTracksCatalog = [
  TrackDef(
    id: 'interviews',
    eyebrow: 'PRIMARY TRACK',
    title: 'Interview Track',
    subtitle: 'Behavioral and situational questions',
    trackLabel: 'INTERVIEWS',
    prompts: [
      'Tell me about a time you disagreed with a teammate.',
      "Describe a project that didn't go as planned.",
      'Walk me through a decision you regret.',
    ],
  ),
  TrackDef(
    id: 'everyday_conversation',
    eyebrow: 'RANDOM • IMPROMPTU',
    title: 'Everyday conversation',
    subtitle: 'Small talk that feels easy',
    trackLabel: 'EVERYDAY CONVERSATION',
    prompts: [
      'What did you do this weekend?',
      "What's a show you've been meaning to watch?",
      'Any good food recommendations lately?',
    ],
  ),
  TrackDef(
    id: 'storytelling',
    eyebrow: 'TECHNIQUE BASED',
    title: 'Storytelling',
    subtitle: 'Turn moments into memorable stories',
    trackLabel: 'STORYTELLING',
    prompts: [
      'Tell a story about a time you got lost.',
      'Describe the best surprise you ever had.',
      'Talk about a moment that changed your perspective.',
    ],
  ),
  TrackDef(
    id: 'public_speaking',
    eyebrow: 'TECHNIQUE BASED',
    title: 'Public Speaking',
    subtitle: 'Presentations, talks, and speeches',
    trackLabel: 'PUBLIC SPEAKING',
    prompts: [
      'Pitch an idea you believe in, in one minute.',
      'Explain a topic you know well to a beginner.',
      'Make the case for your favorite way to spend a weekend.',
    ],
  ),
  TrackDef(
    id: 'meetings_work',
    eyebrow: 'TECHNIQUE BASED',
    title: 'Meetings & work',
    subtitle: 'Speak up clearly in the room',
    trackLabel: 'MEETINGS & WORK',
    prompts: [
      'Give a one-minute status update on a project.',
      'Explain a blocker and what you need to unblock it.',
      'Summarize a decision and why you made it.',
    ],
  ),
];

const List<String> defaultActiveTrackIds = ['interviews', 'everyday_conversation', 'storytelling'];

TrackDef trackById(String id) => allTracksCatalog.firstWhere((t) => t.id == id);
