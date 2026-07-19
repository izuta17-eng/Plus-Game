import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/data/game_repository.dart';
import '../../core/domain/game.dart';
import '../../shared/widgets/game_widgets.dart';
import '../../shared/widgets/state_widgets.dart';

class GameDetailScreen extends ConsumerWidget {
  const GameDetailScreen({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(gameProvider(id))
      .when(
        loading: () => const LoadingView(),
        error: (e, s) => ErrorView(message: '$e'),
        data: (g) {
          final status = ref.watch(libraryProvider)[id] ?? LibraryStatus.none;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(g.title, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 12),
              GenreStrip(genres: g.genres),
              Text('対応: ${g.platforms.join(' / ')}'),
              Text('発売日: ${DateFormat.yMMMd('ja').format(g.releaseDate)}'),
              Text('開発元: ${g.developer}'),
              Text('パブリッシャー: ${g.publisher}'),
              const Divider(),
              Text(g.summary),
              Section(title: '今日の状況', child: Text(g.todayStatus)),
              Section(
                title: 'トレンドスコア',
                child: Text('${g.trendScore} / ${g.trendReason}'),
              ),
              Section(
                title: '開催中イベント',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: g.events
                      .map((e) => Text('${e.period} ${e.category}: ${e.title}'))
                      .toList(),
                ),
              ),
              Section(title: 'おすすめ理由', child: Text(g.recommendReason)),
              DropdownButton<LibraryStatus>(
                value: status,
                items: LibraryStatus.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                    .toList(),
                onChanged: (v) =>
                    ref.read(libraryProvider.notifier).setStatus(id, v!),
              ),
              const Section(
                title: '関連ゲーム',
                child: Text('同ジャンルの作品を検索画面から探せます。'),
              ),
            ],
          );
        },
      );
}
