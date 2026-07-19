import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/game_repository.dart';
import '../../shared/widgets/game_widgets.dart';
import '../../shared/widgets/state_widgets.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String q = '', genre = 'すべて', platform = 'すべて';
  @override
  Widget build(BuildContext context) => ref
      .watch(gamesProvider)
      .when(
        loading: () => const LoadingView(),
        error: (e, s) => ErrorView(message: '$e'),
        data: (games) {
          final genres = [
            'すべて',
            ...{for (final g in games) ...g.genres},
          ];
          final platforms = [
            'すべて',
            ...{for (final g in games) ...g.platforms},
          ];
          final results = games
              .where(
                (g) =>
                    g.title.contains(q) &&
                    (genre == 'すべて' || g.genres.contains(genre)) &&
                    (platform == 'すべて' || g.platforms.contains(platform)),
              )
              .toList();
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('検索', style: Theme.of(context).textTheme.displaySmall),
              TextField(
                decoration: const InputDecoration(labelText: 'タイトル検索'),
                onChanged: (v) => setState(() => q = v),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  DropdownButton(
                    value: genre,
                    items: genres
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => genre = v!),
                  ),
                  DropdownButton(
                    value: platform,
                    items: platforms
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => platform = v!),
                  ),
                ],
              ),
              if (results.isEmpty)
                const EmptyView(message: '条件に合うゲームがありません')
              else
                ...results.map((g) => GameCard(game: g)),
            ],
          );
        },
      );
}
