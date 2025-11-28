import 'package:anime_discovery_app_v2/core/constants/api_constants.dart';
import 'package:anime_discovery_app_v2/models/states/anime_list_state.dart';
import 'package:anime_discovery_app_v2/models/states/anime_search_state.dart';
import 'package:anime_discovery_app_v2/viewmodels/anime_search_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/anime_list_viewmodel.dart';
import '../widgets/anime_card.dart';
import '../widgets/error_view.dart';

class AnimeListScreen extends ConsumerStatefulWidget {
  const AnimeListScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnimeListScreenState();
}

class _AnimeListScreenState extends ConsumerState<AnimeListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(animeListViewmodelProvider);
    final viewModel = ref.read(animeListViewmodelProvider.notifier);
    final searchState = ref.watch(animeSearchViewmodelProvider);
    final searchViewModel = ref.read(animeSearchViewmodelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title:
            searchState.isActive
                ? TextField(
                  key: const Key(KeyConstants.animeSearchTextField),
                  autofocus: true,
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search Anime...',
                    border: InputBorder.none,
                  ),
                  onChanged: searchViewModel.onQueryChanged,
                )
                : Text('Popular Anime'),
        actions: [
          searchState.isActive
              ? IconButton(
                key: const Key(KeyConstants.clearButton),
                icon: const Icon(Icons.close),
                onPressed: () {
                  searchViewModel.clearSearch();
                  _searchController.clear();
                },
              )
              : IconButton(
                key: const Key(KeyConstants.searchButton),
                icon: const Icon(Icons.search),
                onPressed: () {
                  searchViewModel.activateSearch();
                  _searchController.clear();
                },
              ),
        ],
        leading:
            searchState.isActive
                ? BackButton(
                  key: const Key(KeyConstants.backButton),
                  onPressed: searchViewModel.deactivateSearch,
                )
                : null,
      ),
      body:
          searchState.isActive
              ? _buildSearchBody(searchState, searchViewModel)
              : _buildBody(state, viewModel),
    );
  }

  Widget _buildBody(AnimeListState state, AnimeListViewmodel viewModel) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError && state.animes.isEmpty) {
      return ErrorView(message: state.errorMessage!, onRetry: viewModel.retry);
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

  Widget _buildSearchBody(
    AnimeSearchState state,
    AnimeSearchViewmodel viewModel,
  ) {
    if (state.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError && state.results.isEmpty) {
      return ErrorView(message: state.errorMessage!, onRetry: viewModel.retry);
    }

    if (state.showNoResults) {
      return const Center(child: Text('No anime found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final anime = state.results[index];
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
    );
  }
}
