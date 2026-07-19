import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/external_feed_item.dart';

const externalFeedAssetPath = 'assets/data/external_feed.json';

final externalFeedRepositoryProvider = Provider<ExternalFeedRepository>(
  (ref) => ExternalFeedRepository(),
);

final externalFeedProvider = FutureProvider<ExternalFeed>(
  (ref) => ref.watch(externalFeedRepositoryProvider).fetchLatest(),
);

class ExternalFeedRepository {
  ExternalFeedRepository({
    AssetBundle? assetBundle,
    this.assetPath = externalFeedAssetPath,
  }) : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;
  final String assetPath;

  Future<ExternalFeed> fetchLatest() async {
    final source = await _assetBundle.loadString(assetPath);
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('External feed root must be a JSON object');
    }
    final feed = ExternalFeed.fromJson(decoded);
    final seenUrls = <String>{};
    final items = feed.items
        .where((item) => seenUrls.add(item.url.toString()))
        .toList(growable: false)
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return ExternalFeed(updatedAt: feed.updatedAt, items: items);
  }
}
