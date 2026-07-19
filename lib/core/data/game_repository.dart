import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/game.dart';
import 'mock_games.dart';

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => GameRepository(),
);
final gamesProvider = FutureProvider<List<Game>>(
  (ref) => ref.watch(gameRepositoryProvider).fetchGames(),
);
final gameProvider = FutureProvider.family<Game, String>(
  (ref, id) async =>
      (await ref.watch(gamesProvider.future)).firstWhere((g) => g.id == id),
);
final libraryProvider =
    NotifierProvider<LibraryNotifier, Map<String, LibraryStatus>>(
      LibraryNotifier.new,
    );
final themeModeProvider = NotifierProvider<ThemeModeNotifier, String>(
  ThemeModeNotifier.new,
);

class GameRepository {
  Future<List<Game>> fetchGames() async => mockGames;
}

class LibraryNotifier extends Notifier<Map<String, LibraryStatus>> {
  @override
  Map<String, LibraryStatus> build() => {};
  void setStatus(String id, LibraryStatus status) =>
      state = {...state, id: status};
  void remove(String id) {
    final next = {...state}..remove(id);
    state = next;
  }
}

class ThemeModeNotifier extends Notifier<String> {
  @override
  String build() => 'system';
  void set(String v) => state = v;
}
