import 'package:anime_discovery_app_v2/core/constants/api_constants.dart';
import 'package:anime_discovery_app_v2/main.dart' as app;
import 'package:anime_discovery_app_v2/views/widgets/anime_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Anime Search Feature', () {
    testWidgets('should display search results when searching for an anime', (
      tester,
    ) async {
      app.main();

      await tester.pump();
      await tester.pumpAndSettle();

      // Find and tap search icon
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key(KeyConstants.animeSearchTextField)),
        'Boku no',
      );

      await waitForDebounce();
      await tester.pumpAndSettle();

      expect(find.textContaining('Boku no'), findsWidgets);
    });

    testWidgets('should clear search and return to popular', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Search something
      await tester.tap(find.byKey(const Key(KeyConstants.searchButton)));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key(KeyConstants.animeSearchTextField)),
        'Boku no',
      );
      await waitForDebounce();
      await tester.pumpAndSettle();

      // Clear search
      await tester.tap(find.byKey(const Key(KeyConstants.clearButton)));
      await tester.pumpAndSettle();

      // Should show empty search state
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(AnimeCard), findsNothing);

      // Clear search
      await tester.tap(find.byKey(const Key(KeyConstants.backButton)));
      await tester.pumpAndSettle();

      // Should return to popular list
      expect(find.text('Popular Anime'), findsOneWidget);
    });
  });
}
