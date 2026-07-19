import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/game_repository.dart';
import '../../core/domain/game.dart';
import '../../shared/widgets/game_widgets.dart';
import '../../shared/widgets/state_widgets.dart';
import '../external_feed/presentation/external_feed_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(gamesProvider)
      .when(
        loading: () => const LoadingView(),
        error: (e, s) => ErrorView(message: '$e'),
        data: (games) {
          final today = games.first;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                '今日はこれ遊ぼう。',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 20),
              Section(
                title: '今日の1本',
                child: GameCard(
                  game: today,
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      FilledButton(
                        onPressed: () => context.go('/game/' + today.id),
                        child: const Text('詳細を見る'),
                      ),
                      OutlinedButton(
                        onPressed: () => ref
                            .read(libraryProvider.notifier)
                            .setStatus(today.id, LibraryStatus.playLater),
                        child: const Text('あとで遊ぶ'),
                      ),
                      OutlinedButton(
                        onPressed: () => ref
                            .read(libraryProvider.notifier)
                            .setStatus(today.id, LibraryStatus.favorite),
                        child: const Text('お気に入り'),
                      ),
                    ],
                  ),
                ),
              ),
              const ExternalFeedSection(),
              Section(
                title: '開催中イベント',
                child: GameCard(game: games[1]),
              ),
              Section(
                title: '今日急上昇',
                child: GameCard(game: games[2]),
              ),
              Section(
                title: 'セール中',
                child: GameCard(game: games[3]),
              ),
              Section(
                title: '今週発売',
                child: GameCard(game: games[4]),
              ),
              Section(
                title: 'あなたへのおすすめ',
                child: Column(
                  children: games
                      .skip(5)
                      .take(4)
                      .map((g) => GameCard(game: g))
                      .toList(),
                ),
              ),
            ],
          );
        },
      );
}
