class RhymeModel {
  final String id;
  final String title;
  final String classLevel; // Nursery, LKG, UKG, Class 1-4
  final String language; // English, Hindi
  final String emoji;
  final List<String> youtubeVideoIds; // Alternative YouTube video IDs
  final List<String>? lyrics;
  final List<String>? transliteratedLyrics;
  final List<int>? lineTimestamps;
  final int secondsPerLine; // Duration of each line highlighting

  const RhymeModel({
    required this.id,
    required this.title,
    required this.classLevel,
    required this.language,
    required this.emoji,
    required this.youtubeVideoIds,
    this.lyrics,
    this.transliteratedLyrics,
    this.lineTimestamps,
    this.secondsPerLine = 4,
  });
}
