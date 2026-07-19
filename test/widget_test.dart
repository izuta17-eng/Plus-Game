import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plus_game/app/plus_game_app.dart';

void main() {
  testWidgets('shows concierge home', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PlusGameApp()));
  });
}
