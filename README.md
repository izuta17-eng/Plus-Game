# +Game

+Game は「今日はこれ遊ぼう。」をタグラインにした、今日遊ぶゲームを決めるゲームコンシェルジュのFlutter MVPです。ランキングや実在ゲーム画像に依存せず、架空ゲームのテキスト情報とオリジナルジャンルカードで構成しています。

## セットアップ

```bash
flutter pub get
```

## 起動方法

```bash
flutter run
flutter run -d chrome
```

iOS、Android、Webを対象に作成しています。

## 構成説明

- `lib/app`: ルーティング、テーマ、アプリシェル
- `lib/core`: ドメインモデル、Repository、モックデータ、Riverpod状態
- `lib/features`: Home、Search、Game Detail、Trend、Events、Library、Settings
- `lib/shared`: ローディング、空状態、エラー状態、ゲームカードなどの再利用Widget
- `test`: ウィジェットテスト

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

## 今後のバックエンド接続方針

1. `GameRepository`を抽象化し、モック実装とAPI実装を差し替え可能にする。
2. API DTOからドメインモデルへのMapperを追加し、UIはドメインモデルだけに依存させる。
3. 認証、同期、通知設定はFeature単位でRepositoryを分離する。
4. 画像や権利物を扱う場合はライセンス確認済みのメタデータのみを使用する。
