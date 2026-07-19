import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plus_game/features/external_feed/data/external_feed_repository.dart';
import 'package:plus_game/features/external_feed/domain/external_feed_item.dart';

class _StringAssetBundle extends CachingAssetBundle {
  _StringAssetBundle(this.value);

  final String value;

  @override
  Future<ByteData> load(String key) async {
    final bytes = Uint8List.fromList(utf8.encode(value));
    return ByteData.sublistView(bytes);
  }
}

void main() {
  group('ExternalFeedRepository', () {
    test('parses, deduplicates, and sorts text-only feed items', () async {
      final repository = ExternalFeedRepository(
        assetBundle: _StringAssetBundle(
          jsonEncode({
            'updatedAt': '2026-07-20T01:00:00Z',
            'items': [
              {
                'title': '動画のお知らせ',
                'channel': 'Nintendo 公式チャンネル',
                'publishedAt': '2026-07-19T01:00:00Z',
                'url': 'https://www.youtube.com/watch?v=video1',
              },
              {
                'title': '重複',
                'channel': 'Nintendo 公式チャンネル',
                'publishedAt': '2026-07-19T01:00:00Z',
                'url': 'https://www.youtube.com/watch?v=video1',
              },
              {
                'title': 'ライブ配信',
                'channel': 'sample_channel',
                'publishedAt': '2026-07-20T00:30:00Z',
                'url': 'https://www.twitch.tv/sample_channel',
              },
            ],
          }),
        ),
      );

      final feed = await repository.fetchLatest();

      expect(feed.items, hasLength(2));
      expect(feed.items.first.title, 'ライブ配信');
      expect(feed.items.first.source, ExternalFeedSource.twitch);
      expect(feed.items.last.source, ExternalFeedSource.youtube);
      expect(feed.updatedAt, DateTime.utc(2026, 7, 20, 1));
    });

    test('rejects hosts outside the HTTPS allowlist', () async {
      final repository = ExternalFeedRepository(
        assetBundle: _StringAssetBundle(
          jsonEncode({
            'updatedAt': null,
            'items': [
              {
                'title': '不正なリンク',
                'channel': 'unknown',
                'publishedAt': '2026-07-20T00:00:00Z',
                'url': 'https://example.com/video',
              },
            ],
          }),
        ),
      );

      expect(repository.fetchLatest(), throwsFormatException);
    });
  });
}
