import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/game_repository.dart';
import '../../core/domain/game.dart';
import '../../shared/widgets/game_widgets.dart';
import '../../shared/widgets/state_widgets.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(gamesProvider)
      .when(
        loading: () => const LoadingView(),
        error: (e, s) => ErrorView(message: '$e'),
        data: (games) {
          final lib = ref.watch(libraryProvider);
          Widget section(String title, LibraryStatus s) {
            final list = games.where((g) => lib[g.id] == s).toList();
            return Section(
              title: title,
              child: list.isEmpty
                  ? const Text('まだありません')
                  : Column(
                      children: list
                          .map(
                            (g) => GameCard(
                              game: g,
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  DropdownButton<LibraryStatus>(
                                    value: s,
                                    items: LibraryStatus.values
                                        .map(
                                          (v) => DropdownMenuItem(
                                            value: v,
                                            child: Text(v.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) => ref
                                        .read(libraryProvider.notifier)
                                        .setStatus(g.id, v!),
                                  ),
                                  TextButton(
                                    onPressed: () => ref
                                        .read(libraryProvider.notifier)
                                        .remove(g.id),
                                    child: const Text('削除'),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('ライブラリ', style: Theme.of(context).textTheme.displaySmall),
              section('プレイ中', LibraryStatus.playing),
              section('プレイ済み', LibraryStatus.completed),
              section('あとで遊ぶ', LibraryStatus.playLater),
              section('お気に入り', LibraryStatus.favorite),
            ],
          );
        },
      );
}
