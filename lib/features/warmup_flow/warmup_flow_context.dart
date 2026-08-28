/// Carries the prompt pool/track identity through the multi-screen warmup
/// recording flow (prep -> speech -> transcribe -> transcript -> insights -> end).
class WarmupFlowContext {
  final String trackLabel;
  final List<String> promptPool;
  final String promptText;

  const WarmupFlowContext({
    required this.trackLabel,
    required this.promptPool,
    required this.promptText,
  });

  String get headerLabel => '$trackLabel WARMUP';

  WarmupFlowContext withPrompt(String prompt) => WarmupFlowContext(
        trackLabel: trackLabel,
        promptPool: promptPool,
        promptText: prompt,
      );
}
