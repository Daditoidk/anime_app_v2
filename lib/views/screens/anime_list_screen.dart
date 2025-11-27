import 'package:anime_discovery_app_v2/models/states/anime_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/anime_list_viewmodel.dart';
import '../widgets/anime_card.dart';
import '../widgets/error_view.dart';

class AnimeListScreen extends ConsumerWidget {
  const AnimeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(animeListViewmodelProvider);
    final viewModel = ref.read(animeListViewmodelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular Anime'),
      ),
      body: _buildBody(state, viewModel),
    );
  }

  Widget _buildBody(AnimeListState state, AnimeListViewmodel viewModel) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError && state.animes.isEmpty) {
      return ErrorView(
        message: state.errorMessage!,
        onRetry: viewModel.retry,
      );
    }

    if (state.isEmpty) {
      return const Center(child: Text('No anime found'));
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: state.animes.length,
        itemBuilder: (context, index) {
          final anime = state.animes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AnimeCard(
              anime: anime,
              onTap: () {
                // TODO: Navigate to detail
              },
            ),
          );
        },
      ),
    );
  }
}