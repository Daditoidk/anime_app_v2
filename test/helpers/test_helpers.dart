import 'package:anime_discovery_app_v2/repositories/anime_repository.dart';
import 'package:anime_discovery_app_v2/services/api/anime_api_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockAnimeRepository extends Mock implements AnimeRepository {}

class MockAnimeApiService extends Mock implements AnimeApiServices {}

ProviderContainer createTestContainer({List<Override> overrides = const []}) {
  return ProviderContainer(overrides: overrides);
}

Future<void> waitForDebounce() =>
    Future<void>.delayed(const Duration(milliseconds: 350));

Future<void> waitShort() =>
    Future<void>.delayed(const Duration(milliseconds: 100));

class Listener<T> {
  final List<T> states = [];
  void call(T? previous, T next) {
    states.add(next);
  }
}
