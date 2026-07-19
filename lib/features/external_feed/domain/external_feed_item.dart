enum ExternalFeedSource { youtube, twitch }

class ExternalFeedItem {
  const ExternalFeedItem({
    required this.title,
    required this.channel,
    required this.publishedAt,
    required this.url,
    required this.source,
  });

  final String title;
  final String channel;
  final DateTime publishedAt;
  final Uri url;
  final ExternalFeedSource source;

  factory ExternalFeedItem.fromJson(Map<String, dynamic> json) {
    final title = _requiredText(json, 'title');
    final channel = _requiredText(json, 'channel');
    final publishedAt = DateTime.tryParse(_requiredText(json, 'publishedAt'));
    final url = Uri.tryParse(_requiredText(json, 'url'));
    if (publishedAt == null) {
      throw const FormatException('publishedAt must be an ISO-8601 timestamp');
    }
    if (url == null || url.scheme != 'https') {
      throw const FormatException('External feed URLs must use HTTPS');
    }
    final host = url.host.toLowerCase();
    final source = switch (host) {
      'youtube.com' || 'www.youtube.com' || 'youtu.be' =>
        ExternalFeedSource.youtube,
      'twitch.tv' || 'www.twitch.tv' => ExternalFeedSource.twitch,
      _ => throw const FormatException('External feed host is not allowed'),
    };
    return ExternalFeedItem(
      title: title,
      channel: channel,
      publishedAt: publishedAt.toUtc(),
      url: url,
      source: source,
    );
  }

  String get sourceLabel => switch (source) {
    ExternalFeedSource.youtube => 'YouTube',
    ExternalFeedSource.twitch => 'Twitch',
  };

  static String _requiredText(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$key must be a non-empty string');
    }
    return value.trim();
  }
}

class ExternalFeed {
  const ExternalFeed({required this.updatedAt, required this.items});

  final DateTime? updatedAt;
  final List<ExternalFeedItem> items;

  factory ExternalFeed.fromJson(Map<String, dynamic> json) {
    final rawUpdatedAt = json['updatedAt'];
    if (rawUpdatedAt != null && rawUpdatedAt is! String) {
      throw const FormatException('updatedAt must be an ISO-8601 timestamp');
    }
    final updatedAt = rawUpdatedAt == null
        ? null
        : DateTime.tryParse(rawUpdatedAt)?.toUtc();
    if (rawUpdatedAt != null && updatedAt == null) {
      throw const FormatException('updatedAt must be an ISO-8601 timestamp');
    }
    final rawItems = json['items'];
    if (rawItems is! List<dynamic>) {
      throw const FormatException('items must be a JSON list');
    }
    final items = <ExternalFeedItem>[];
    for (final item in rawItems) {
      if (item is! Map) {
        throw const FormatException('Each feed item must be a JSON object');
      }
      items.add(ExternalFeedItem.fromJson(Map<String, dynamic>.from(item)));
    }
    return ExternalFeed(updatedAt: updatedAt, items: items);
  }
}
