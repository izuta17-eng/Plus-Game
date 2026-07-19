import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/game_repository.dart';
import '../../shared/widgets/game_widgets.dart';
import '../../shared/widgets/state_widgets.dart';

class TrendScreen extends ConsumerWidget {
  const TrendScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(gamesProvider)
      .when(
        loading: () => const LoadingView(),
        error: (e, s) => ErrorView(message: '$e'),
        data: (games) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('トレンド', style: Theme.of(context).textTheme.displaySmall),
            for (final tag in ['急上昇', '人気継続', '新作', 'インディー', '海外'])
              Section(
                title: tag,
                child: Column(
                  children: games
                      .where((g) => g.tags.contains(tag))
                      .take(3)
                      .map((g) => GameCard(game: g))
                      .toList(),
                ),
              ),
          ],
        ),
      );
}
