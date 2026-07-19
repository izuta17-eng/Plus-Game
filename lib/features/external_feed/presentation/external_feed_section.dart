import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/widgets/game_widgets.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../data/external_feed_repository.dart';
import '../domain/external_feed_item.dart';

typedef ExternalUrlLauncher = Future<bool> Function(Uri uri);

class ExternalFeedSection extends ConsumerWidget {
  const ExternalFeedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(externalFeedProvider);
    return Section(
      title: '配信・動画の新着',
      child: feed.when(
        loading: () => const SizedBox(height: 120, child: LoadingView()),
        error: (error, stackTrace) => SizedBox(
          height: 140,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ErrorView(message: '外部フィード'),
              TextButton(
                onPressed: () => ref.invalidate(externalFeedProvider),
                child: const Text('再読み込み'),
              ),
            ],
          ),
        ),
        data: (value) {
          if (value.items.isEmpty) {
            return const SizedBox(
              height: 100,
              child: EmptyView(message: '新着情報はまだありません'),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in value.items.take(8))
                ExternalFeedCard(item: item),
              const SizedBox(height: 8),
              Text(
                '出典: YouTube公式チャンネル / Twitch公開配信',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (value.updatedAt case final updatedAt?)
                Text(
                  '更新: ' + _formatDateTime(updatedAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          );
        },
      ),
    );
  }
}

class ExternalFeedCard extends StatelessWidget {
  const ExternalFeedCard({super.key, required this.item, this.onLaunch});

  final ExternalFeedItem item;
  final ExternalUrlLauncher? onLaunch;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _open(context),
        child: Semantics(
          button: true,
          label: '外部サイトで開く: ' + item.title,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  item.source == ExternalFeedSource.youtube
                      ? Icons.play_circle_outline
                      : Icons.live_tv_outlined,
                  semanticLabel: item.sourceLabel,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Chip(
                            visualDensity: VisualDensity.compact,
                            label: Text(item.sourceLabel),
                          ),
                          Text(
                            item.channel,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '公開: ' + _formatDateTime(item.publishedAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.open_in_new, semanticLabel: '外部リンク'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final launch = onLaunch ?? _launchExternal;
    try {
      final opened = await launch(item.url);
      if (opened || !context.mounted) {
        return;
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('リンクを開けませんでした')));
  }

  static Future<bool> _launchExternal(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return local.year.toString() +
      '/' +
      twoDigits(local.month) +
      '/' +
      twoDigits(local.day) +
      ' ' +
      twoDigits(local.hour) +
      ':' +
      twoDigits(local.minute);
}
