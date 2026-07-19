#!/usr/bin/env python3
"""Build the small, text-only external feed consumed by the Flutter app.

Only selected official YouTube Atom feeds and Twitch Helix are contacted. A
failed source keeps its last successful entries from the restored JSON file.
"""

from __future__ import annotations

import json
import os
import sys
import tempfile
import unicodedata
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


OUTPUT_PATH = Path("assets/data/external_feed.json")
MAX_ITEMS_PER_SOURCE = 8
TIMEOUT_SECONDS = 15
YOUTUBE_FEED_HOSTS = frozenset({"www.youtube.com"})
YOUTUBE_ITEM_HOSTS = frozenset({"www.youtube.com", "youtube.com", "youtu.be"})
TWITCH_API_HOSTS = frozenset({"id.twitch.tv", "api.twitch.tv"})
TWITCH_ITEM_HOSTS = frozenset({"www.twitch.tv", "twitch.tv"})
TWITCH_EXCLUDED_CATEGORIES = frozenset(
    {
        "ASMR",
        "Art",
        "Food & Drink",
        "IRL",
        "Just Chatting",
        "Music",
        "Pools, Hot Tubs, and Beaches",
        "Talk Shows & Podcasts",
    }
)
CHANNELS = (
    ("UCkH3CcMfqww9RsZvPRPkAJA", "Nintendo 公式チャンネル"),
    ("UCaghC0OZwAdidMrbvxkcrPg", "PlayStation Japan"),
    ("UC6SmH9mR82nj28_NNg_rZvA", "スクウェア・エニックス"),
    ("UCjBp_7RuDBUYbd1LegWEJ8g", "Xbox"),
)
ATOM = {"atom": "http://www.w3.org/2005/Atom"}


class FeedError(RuntimeError):
    """Raised when a remote response violates the feed contract."""


class _AllowlistRedirectHandler(urllib.request.HTTPRedirectHandler):
    def __init__(self, allowed_hosts: frozenset[str]) -> None:
        self.allowed_hosts = allowed_hosts

    def redirect_request(
        self,
        request: urllib.request.Request,
        file_pointer: Any,
        code: int,
        message: str,
        headers: Any,
        new_url: str,
    ) -> urllib.request.Request | None:
        _validated_url(new_url, self.allowed_hosts)
        return super().redirect_request(
            request,
            file_pointer,
            code,
            message,
            headers,
            new_url,
        )


SOURCE_ERRORS = (
    FeedError,
    ET.ParseError,
    json.JSONDecodeError,
    UnicodeError,
    urllib.error.URLError,
    TimeoutError,
    OSError,
    ValueError,
)


def _validated_url(raw_url: str, allowed_hosts: frozenset[str]) -> str:
    parsed = urllib.parse.urlparse(raw_url)
    host = (parsed.hostname or "").lower()
    if parsed.scheme != "https" or host not in allowed_hosts:
        raise FeedError("URL is outside the HTTPS allowlist")
    if parsed.username or parsed.password:
        raise FeedError("URL credentials are not allowed")
    try:
        port = parsed.port
    except ValueError as error:
        raise FeedError("URL port is invalid") from error
    if port not in (None, 443):
        raise FeedError("Only the standard HTTPS port is allowed")
    return parsed.geturl()


def _request_bytes(
    url: str,
    *,
    allowed_hosts: frozenset[str],
    headers: dict[str, str] | None = None,
    data: bytes | None = None,
) -> bytes:
    safe_url = _validated_url(url, allowed_hosts)
    request_headers = {
        "Accept": "application/json, application/atom+xml, application/xml",
        "User-Agent": "Plus-Game-feed/1.0",
        **(headers or {}),
    }
    request = urllib.request.Request(
        safe_url,
        headers=request_headers,
        data=data,
        method="POST" if data is not None else "GET",
    )
    opener = urllib.request.build_opener(_AllowlistRedirectHandler(allowed_hosts))
    with opener.open(request, timeout=TIMEOUT_SECONDS) as response:
        _validated_url(response.geturl(), allowed_hosts)
        if response.status < 200 or response.status >= 300:
            raise FeedError("Remote source returned a non-success status")
        return response.read()


def _parse_timestamp(value: str) -> str:
    normalized = value.strip().replace("Z", "+00:00")
    parsed = datetime.fromisoformat(normalized)
    if parsed.tzinfo is None:
        raise FeedError("Timestamp must include a timezone")
    return parsed.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")


def _clean_text(value: Any, *, limit: int) -> str:
    if not isinstance(value, str):
        raise FeedError("Expected a text field")
    without_emoji = "".join(
        character
        for character in value
        if not (
            unicodedata.category(character) in {"Cc", "Cf"}
            or ord(character) == 0x20E3
            or 0x2300 <= ord(character) <= 0x23FF
            or 0x1F000 <= ord(character) <= 0x1FAFF
            or 0x2600 <= ord(character) <= 0x27BF
            or 0x2B00 <= ord(character) <= 0x2BFF
            or 0xE0020 <= ord(character) <= 0xE007F
            or ord(character) in {0x3030, 0x303D, 0x3297, 0x3299, 0xFE0F}
        )
    )
    cleaned = " ".join(without_emoji.split()).strip()
    if not cleaned:
        raise FeedError("Text fields must not be empty")
    return cleaned[:limit]


def fetch_youtube(channel_id: str, channel_name: str) -> list[dict[str, str]]:
    query = urllib.parse.urlencode({"channel_id": channel_id})
    url = "https://www.youtube.com/feeds/videos.xml?" + query
    payload = _request_bytes(url, allowed_hosts=YOUTUBE_FEED_HOSTS)
    root = ET.fromstring(payload)
    items: list[dict[str, str]] = []
    for entry in root.findall("atom:entry", ATOM):
        title_node = entry.find("atom:title", ATOM)
        published_node = entry.find("atom:published", ATOM)
        link_node = entry.find("atom:link[@rel='alternate']", ATOM)
        if title_node is None or published_node is None or link_node is None:
            continue
        href = link_node.attrib.get("href", "")
        try:
            items.append(
                {
                    "title": _clean_text(title_node.text, limit=180),
                    "channel": channel_name,
                    "publishedAt": _parse_timestamp(published_node.text or ""),
                    "url": _validated_url(href, YOUTUBE_ITEM_HOSTS),
                }
            )
        except (FeedError, ValueError):
            continue
        if len(items) >= MAX_ITEMS_PER_SOURCE:
            break
    if not items:
        raise FeedError("YouTube returned no usable feed entries")
    return items


def fetch_twitch(client_id: str, client_secret: str) -> list[dict[str, str]]:
    token_payload = urllib.parse.urlencode(
        {
            "client_id": client_id,
            "client_secret": client_secret,
            "grant_type": "client_credentials",
        }
    ).encode("utf-8")
    token_bytes = _request_bytes(
        "https://id.twitch.tv/oauth2/token",
        allowed_hosts=TWITCH_API_HOSTS,
        headers={"Content-Type": "application/x-www-form-urlencoded"},
        data=token_payload,
    )
    token_data = json.loads(token_bytes.decode("utf-8"))
    access_token = token_data.get("access_token")
    if not isinstance(access_token, str) or not access_token:
        raise FeedError("Twitch did not return an app access token")

    query = urllib.parse.urlencode(
        {"language": "ja", "first": str(MAX_ITEMS_PER_SOURCE)}
    )
    stream_bytes = _request_bytes(
        "https://api.twitch.tv/helix/streams?" + query,
        allowed_hosts=TWITCH_API_HOSTS,
        headers={
            "Authorization": "Bearer " + access_token,
            "Client-Id": client_id,
        },
    )
    stream_data = json.loads(stream_bytes.decode("utf-8"))
    raw_items = stream_data.get("data")
    if not isinstance(raw_items, list):
        raise FeedError("Twitch returned an unexpected response")

    items: list[dict[str, str]] = []
    for raw_item in raw_items:
        if not isinstance(raw_item, dict):
            continue
        try:
            login = _clean_text(raw_item.get("user_login"), limit=80)
            category = _clean_text(raw_item.get("game_name"), limit=100)
            if category in TWITCH_EXCLUDED_CATEGORIES:
                continue
            stream_title = _clean_text(raw_item.get("title"), limit=180)
            items.append(
                {
                    "title": _clean_text(
                        category + " | " + stream_title,
                        limit=180,
                    ),
                    "channel": _clean_text(raw_item.get("user_name"), limit=100),
                    "publishedAt": _parse_timestamp(
                        _clean_text(raw_item.get("started_at"), limit=40)
                    ),
                    "url": _validated_url(
                        "https://www.twitch.tv/" + urllib.parse.quote(login),
                        TWITCH_ITEM_HOSTS,
                    ),
                }
            )
        except (FeedError, ValueError):
            continue
    return items[:MAX_ITEMS_PER_SOURCE]


def _load_fallback(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (FileNotFoundError, json.JSONDecodeError, OSError):
        return {"updatedAt": None, "items": []}
    if not isinstance(data, dict) or not isinstance(data.get("items"), list):
        return {"updatedAt": None, "items": []}
    return data


def _fallback_items(
    fallback: dict[str, Any],
    *,
    channel: str | None = None,
    hosts: frozenset[str],
) -> list[dict[str, str]]:
    results: list[dict[str, str]] = []
    for raw_item in fallback.get("items", []):
        if not isinstance(raw_item, dict):
            continue
        if channel is not None and raw_item.get("channel") != channel:
            continue
        try:
            item = {
                "title": _clean_text(raw_item.get("title"), limit=180),
                "channel": _clean_text(raw_item.get("channel"), limit=100),
                "publishedAt": _parse_timestamp(
                    _clean_text(raw_item.get("publishedAt"), limit=40)
                ),
                "url": _validated_url(
                    _clean_text(raw_item.get("url"), limit=500), hosts
                ),
            }
        except (FeedError, ValueError):
            continue
        results.append(item)
    return results[:MAX_ITEMS_PER_SOURCE]


def _deduplicate(items: list[dict[str, str]]) -> list[dict[str, str]]:
    by_url: dict[str, dict[str, str]] = {}
    for item in items:
        by_url.setdefault(item["url"], item)
    return sorted(by_url.values(), key=lambda item: item["publishedAt"], reverse=True)


def _write_atomically(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    rendered = json.dumps(data, ensure_ascii=False, indent=2) + "\n"
    with tempfile.NamedTemporaryFile(
        "w", encoding="utf-8", dir=path.parent, delete=False
    ) as temporary:
        temporary.write(rendered)
        temporary_path = Path(temporary.name)
    temporary_path.replace(path)


def main() -> int:
    fallback = _load_fallback(OUTPUT_PATH)
    items: list[dict[str, str]] = []
    refreshed = False

    for channel_id, channel_name in CHANNELS:
        try:
            items.extend(fetch_youtube(channel_id, channel_name))
            refreshed = True
        except SOURCE_ERRORS as error:
            print(
                "YouTube fallback for " + channel_name + ": " + str(error),
                file=sys.stderr,
            )
            items.extend(
                _fallback_items(
                    fallback, channel=channel_name, hosts=YOUTUBE_ITEM_HOSTS
                )
            )

    client_id = os.environ.get("TWITCH_CLIENT_ID", "").strip()
    client_secret = os.environ.get("TWITCH_CLIENT_SECRET", "").strip()
    if client_id and client_secret:
        try:
            items.extend(fetch_twitch(client_id, client_secret))
            refreshed = True
        except SOURCE_ERRORS as error:
            print("Twitch fallback: " + str(error), file=sys.stderr)
            items.extend(_fallback_items(fallback, hosts=TWITCH_ITEM_HOSTS))
    else:
        print("Twitch credentials are not configured; skipping Twitch.", file=sys.stderr)

    items = _deduplicate(items)
    updated_at = fallback.get("updatedAt")
    if refreshed:
        updated_at = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    _write_atomically(
        OUTPUT_PATH,
        {
            "updatedAt": updated_at if isinstance(updated_at, str) else None,
            "items": items,
        },
    )
    print("Wrote " + str(len(items)) + " external feed items.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
