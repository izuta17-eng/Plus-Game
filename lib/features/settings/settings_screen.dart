import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/game_repository.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final hardware = {'PC': true, 'モバイル': false, 'Cloud': true, 'PlayBox': false};
  final genres = {'探索': true, 'RPG': true, '戦略': false, 'インディー': true};
  final notices = {'大会': false, 'アップデート': true, 'セール': true, '公式配信': false};
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text('設定', style: Theme.of(context).textTheme.displaySmall),
      Text('所持ハード', style: Theme.of(context).textTheme.titleLarge),
      ...hardware.keys.map(
        (k) => SwitchListTile(
          title: Text(k),
          value: hardware[k]!,
          onChanged: (v) => setState(() => hardware[k] = v),
        ),
      ),
      Text('好きなジャンル', style: Theme.of(context).textTheme.titleLarge),
      ...genres.keys.map(
        (k) => CheckboxListTile(
          title: Text(k),
          value: genres[k],
          onChanged: (v) => setState(() => genres[k] = v!),
        ),
      ),
      Text('テーマ', style: Theme.of(context).textTheme.titleLarge),
      SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'light', label: Text('ライト')),
          ButtonSegment(value: 'dark', label: Text('ダーク')),
          ButtonSegment(value: 'system', label: Text('システム')),
        ],
        selected: {ref.watch(themeModeProvider)},
        onSelectionChanged: (s) =>
            ref.read(themeModeProvider.notifier).set(s.first),
      ),
      Text('通知カテゴリ', style: Theme.of(context).textTheme.titleLarge),
      ...notices.keys.map(
        (k) => SwitchListTile(
          title: Text(k),
          value: notices[k]!,
          onChanged: (v) => setState(() => notices[k] = v),
        ),
      ),
    ],
  );
}
