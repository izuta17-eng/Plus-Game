import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/game_repository.dart';
import '../../shared/widgets/state_widgets.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(gamesProvider)
      .when(
        loading: () => const LoadingView(),
        error: (e, s) => ErrorView(message: '$e'),
        data: (games) {
          final cats = [
            '今日',
            '今週',
            '今月',
            '大会',
            'アップデート',
            'DLC',
            'セール',
            '公式配信',
            'ベータ',
            'メンテナンス',
          ];
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('イベント', style: Theme.of(context).textTheme.displaySmall),
              for (final c in cats)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      '$c: ${games.firstWhere((g) => g.events.any((e) => e.category == c || e.period == c), orElse: () => games.first).title}',
                    ),
                  ),
                ),
            ],
          );
        },
      );
}
