import 'package:anime_discovery_app_v2/main.dart' as app;
import 'package:anime_discovery_app_v2/views/widgets/anime_card.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('Anime List Feature', () {
    testWidgets('should display popular niame list', (tester) async {
      app.main();

      //Wait for loading first state
      await tester.pump();
      await tester.pumpAndSettle();

      //Should find a list of animes
      expect(find.byType(ListView), findsOneWidget);

      //Should find at least one anime item
      expect(find.byType(AnimeCard), findsAtLeast(1));

      //The animeTile should have title and rating
      expect(find.textContaining('★'), findsWidgets);
    });
  });

  testWidgets('should show error state and retry', (tester) async {
    // TODO: Mock network failure
    // expect error widget
    // tap retry
    // expect list
  });
}
