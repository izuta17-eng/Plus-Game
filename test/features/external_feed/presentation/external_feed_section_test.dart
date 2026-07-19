import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plus_game/features/external_feed/data/external_feed_repository.dart';
import 'package:plus_game/features/external_feed/domain/external_feed_item.dart';
import 'package:plus_game/features/external_feed/presentation/external_feed_section.dart';

void main() {
  final item = ExternalFeedItem(
    title: '外部リンクテスト',
    channel: '公式チャンネル',
    publishedAt: DateTime.utc(2026, 7, 20),
    url: Uri.parse('https://www.youtube.com/watch?v=test'),
    source: ExternalFeedSource.youtube,
  );

  testWidgets('shows source and update time in the home feed section', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          externalFeedProvider.overrideWith(
            (ref) async => ExternalFeed(
              updatedAt: DateTime.utc(2026, 7, 20, 1),
              items: [item],
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: ExternalFeedSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('配信・動画の新着'), findsOneWidget);
    expect(find.text('外部リンクテスト'), findsOneWidget);
    expect(find.text('YouTube'), findsOneWidget);
    expect(find.textContaining('出典:'), findsOneWidget);
    expect(find.textContaining('更新:'), findsOneWidget);
  });

  testWidgets('opens the allowlisted external URL from a feed card', (
    tester,
  ) async {
    Uri? openedUrl;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExternalFeedCard(
            item: item,
            onLaunch: (url) async {
              openedUrl = url;
              return true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('外部リンクテスト'));
    await tester.pump();

    expect(openedUrl, item.url);
  });
}
