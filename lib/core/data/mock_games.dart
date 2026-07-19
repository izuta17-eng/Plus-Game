import '../domain/game.dart';

final mockGames = List<Game>.generate(30, (i) {
  final genres = [
    ['探索', 'パズル'],
    ['RPG', '戦略', '育成'],
    ['アクション', 'ローグライト'],
    ['シミュレーション', 'クラフト'],
    ['アドベンチャー', 'ミステリー'],
  ][i % 5];
  final platforms = [
    ['PC', 'Switch系'],
    ['PC', 'モバイル'],
    ['PlayBox', 'PC'],
    ['Cloud', 'PC', 'Mobile'],
  ][i % 4];
  final cats = ['大会', 'アップデート', 'DLC', 'セール', '公式配信', 'ベータ', 'メンテナンス'];
  return Game(
    id: 'game_$i',
    title: '星庭プロトコル ${i + 1}',
    genres: genres,
    platforms: platforms,
    releaseDate: DateTime(2026, (i % 12) + 1, (i % 27) + 1),
    developer: 'North Atelier ${i % 6 + 1}',
    publisher: 'Blue Harbor Works ${i % 4 + 1}',
    summary: '静かな世界観と短いプレイ区切りを重視した架空タイトルです。画像に頼らず、今日の気分から遊び方を選べます。',
    todayStatus: ['週末イベント開催中', '新章が追加', '短時間チャレンジが人気', 'セール対象'][i % 4],
    trendScore: 62 + (i * 7) % 38,
    recommendScore: 70 + (i * 5) % 30,
    recommendReason: [
      '30分で達成感がある',
      '協力プレイの予定を立てやすい',
      '今週のイベント報酬が軽め',
      '初回復帰に向いた導線',
    ][i % 4],
    trendReason: ['配信企画で注目', '大型更新後も評価が安定', '新作枠で口コミ増加', '海外コミュニティで話題'][i % 4],
    events: [
      GameEvent(
        title: '${cats[i % cats.length]}: 星灯り週間',
        category: cats[i % cats.length],
        period: ['今日', '今週', '今月'][i % 3],
      ),
    ],
    tags: ['急上昇', '人気継続', '新作', 'インディー', '海外'],
  );
});
