class RaApiException implements Exception {
  const RaApiException(this.message, {this.statusCode, this.detail});

  final String message;
  final int? statusCode;
  final String? detail;

  @override
  String toString() => 'RaApiException($statusCode): $message';
}

class RaGameListEntry {
  const RaGameListEntry({
    required this.id,
    required this.title,
    required this.consoleId,
    required this.numAchievements,
    this.consoleName,
    this.imageIcon,
    this.points,
  });

  factory RaGameListEntry.fromJson(Map<String, dynamic> json) {
    return RaGameListEntry(
      id: json['ID'] as int,
      title: json['Title'] as String,
      consoleId: json['ConsoleID'] as int,
      consoleName: json['ConsoleName'] as String?,
      imageIcon: json['ImageIcon'] as String?,
      numAchievements: json['NumAchievements'] as int? ?? 0,
      points: json['Points'] as int? ?? 0,
    );
  }

  final int id;
  final String title;
  final int consoleId;
  final String? consoleName;
  final String? imageIcon;
  final int numAchievements;
  final int? points;

  String? get imageUrl => imageIcon != null
      ? 'https://media.retroachievements.org$imageIcon'
      : null;
}
