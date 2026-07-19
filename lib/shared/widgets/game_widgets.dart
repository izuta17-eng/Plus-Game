import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/domain/game.dart';

class GenreStrip extends StatelessWidget {
  const GenreStrip({super.key, required this.genres});
  final List<String> genres;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (final g in genres)
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(g, textAlign: TextAlign.center),
          ),
        ),
    ],
  );
}

class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.game, this.trailing});
  final Game game;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => context.go('/game/${game.id}'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(game.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            GenreStrip(genres: game.genres),
            const SizedBox(height: 10),
            Text(game.platforms.join(' / ')),
            Text('おすすめ ${game.recommendScore}  トレンド ${game.trendScore}'),
            Text(game.recommendReason),
            ?trailing,
          ],
        ),
      ),
    ),
  );
}

class Section extends StatelessWidget {
  const Section({super.key, required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}
