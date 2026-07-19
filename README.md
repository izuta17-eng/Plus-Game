# +Game

+Game は「今日はこれ遊ぼう。」をタグラインにした、今日遊ぶゲームを決めるゲームコンシェルジュのFlutter MVPです。ランキングや実在ゲーム画像に依存せず、架空ゲームのテキスト情報とオリジナルジャンルカードで構成しています。

## セットアップ

    flutter pub get

## 起動方法

    flutter run
    flutter run -d chrome

iOS、Android、Webを対象に作成しています。

## 構成説明

- lib/app: ルーティング、テーマ、アプリシェル
- lib/core: ドメインモデル、Repository、モックデータ、Riverpod状態
- lib/features: Home、Search、Game Detail、Trend、Events、Library、Settings、External Feed
- lib/shared: ローディング、空状態、エラー状態、ゲームカードなどの再利用Widget
- assets/data/external_feed.json: アプリが読むテキスト限定の外部情報スナップショット
- scripts/fetch_external_feed.py: 外部公開情報の取得スクリプト（Python標準ライブラリのみ）
- test: Repository単体テスト、ウィジェットテスト

## 実装済み機能

- Material 3、ライト/ダーク/システムテーマ
- GoRouterによる画面遷移とボトムナビゲーション
- Riverpod Repository経由の30件以上の架空ゲームデータ表示
- Homeの今日の1本、イベント、急上昇、セール、発売、おすすめ
- Searchのタイトル、ジャンル、プラットフォーム即時フィルター
- Game Detailの詳細情報、イベント、スコア、ライブラリ状態変更
- Trendの急上昇、人気継続、新作、インディー、海外
- Eventsの期間別、カテゴリ別イベント表示
- Libraryのプレイ中、プレイ済み、あとで遊ぶ、お気に入り、削除
- Settingsの所持ハード、好きなジャンル、テーマ、通知カテゴリモック設定
- Homeの「配信・動画の新着」でYouTube公式チャンネルとTwitch公開配信を表示

## 外部情報フィード

GitHub Actionsが30分ごと、およびmain更新時に次の情報を取得してWeb版を再ビルドします。Homeには公開日時が新しい順で最大8件を表示します。

- YouTube: Nintendo、PlayStation Japan、スクウェア・エニックス、Xboxの公式Atom feed
- Twitch: Helix APIからlanguage=jaの配信中ストリーム

保存するのはタイトル、チャンネル名、公開日時、HTTPS URLだけです。画像、ロゴ、動画本文、説明文、視聴数、スコアは取得・保存しません。重複URLを除去し、各ソースは最大8件です。リンク先はYouTubeとTwitchのHTTPSホストに限定しています。

YouTubeはAPIキー不要です。Twitchを有効化する場合だけ、リポジトリのActions secretsへ次を設定します。

- TWITCH_CLIENT_ID
- TWITCH_CLIENT_SECRET

どちらかが未設定ならTwitch取得をスキップします。デプロイ時は現在公開中のJSONを最初に復元するため、外部サービスが一時的に失敗した場合は、そのソースの直前の公開データをfallbackとして使用します。初回公開やPull Request検証でfallbackが無い場合は失敗したソースを省略し、全ソースが空ならアプリに空状態を表示します。

手動更新:

    python3 scripts/fetch_external_feed.py

## CIとWeb公開

.github/workflows/deploy-pages.ymlはPull Requestでformat、analyze、test、Web buildを検証します。mainへのpush、定期実行、手動実行では、検証成功後だけGitHub Pagesへ公開します。デプロイjobだけにpagesとid-tokenの書き込み権限を付与しています。

## 今後のバックエンド接続方針

1. GameRepositoryを抽象化し、モック実装とAPI実装を差し替え可能にする。
2. API DTOからドメインモデルへのMapperを追加し、UIはドメインモデルだけに依存させる。
3. 認証、同期、通知設定はFeature単位でRepositoryを分離する。
4. 画像や権利物を扱う場合はライセンス確認済みのメタデータのみを使用する。
5. 外部情報の保存期間、削除方針、利用規約確認をバックエンド接続前に明文化する。
