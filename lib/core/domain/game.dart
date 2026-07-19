enum LibraryStatus { none, playing, completed, playLater, favorite }

class GameEvent {
  const GameEvent({
    required this.title,
    required this.category,
    required this.period,
  });
  final String title;
  final String category;
  final String period;
}

class Game {
  const Game({
    required this.id,
    required this.title,
    required this.genres,
    required this.platforms,
    required this.releaseDate,
    required this.developer,
    required this.publisher,
    required this.summary,
    required this.todayStatus,
    required this.trendScore,
    required this.recommendScore,
    required this.recommendReason,
    required this.trendReason,
    required this.events,
    required this.tags,
  });
  final String id;
  final String title;
  final List<String> genres;
  final List<String> platforms;
  final DateTime releaseDate;
  final String developer;
  final String publisher;
  final String summary;
  final String todayStatus;
  final int trendScore;
  final int recommendScore;
  final String recommendReason;
  final String trendReason;
  final List<GameEvent> events;
  final List<String> tags;
}
