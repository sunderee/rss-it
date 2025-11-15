import 'package:flutter/material.dart';
import 'package:rss_it/domain/data/feed_collection.dart';
import 'package:rss_it/domain/data/feed_entity.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:rss_it/shared/di.dart';
import 'package:rss_it/shared/utilities/extensions.dart';
import 'package:rss_it/ui/components/bottom_sheet/add_feed_bottom_sheet.dart';
import 'package:rss_it/ui/components/bottom_sheet/manage_folders_bottom_sheet.dart';
import 'package:rss_it/ui/components/feed_card.dart';

final class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final class _HomeScreenState extends State<HomeScreen> {
  late final FeedNotifier _feedNotifier;

  @override
  void initState() {
    super.initState();
    _feedNotifier = locator.get<FeedNotifier>();
    _feedNotifier.getFeeds(forceRefresh: true);
  }

  void _openAddFeedSheet({int? folderID}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => AddFeedBottomSheet(initialFolderId: folderID),
    );
  }

  void _openFolderManager() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const ManageFoldersBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RSSit',
              style: context.theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Organize your feeds with folders',
              style: context.theme.textTheme.labelLarge?.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh feeds',
            onPressed: () => _feedNotifier.getFeeds(forceRefresh: true),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Manage folders',
            onPressed: _openFolderManager,
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddFeedSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Add feed'),
      ),
      body: SafeArea(
        child: _FeedDashboard(
          feedNotifier: _feedNotifier,
          onAddFeed: _openAddFeedSheet,
          onManageFolders: _openFolderManager,
        ),
      ),
    );
  }
}

final class _FeedDashboard extends StatelessWidget {
  final FeedNotifier feedNotifier;
  final void Function({int? folderID}) onAddFeed;
  final VoidCallback onManageFolders;

  const _FeedDashboard({
    required this.feedNotifier,
    required this.onAddFeed,
    required this.onManageFolders,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: feedNotifier,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final crossAxisCount = switch (maxWidth) {
              < 600 => 1,
              < 1024 => 2,
              _ => 3,
            };
            final horizontalPadding = switch (maxWidth) {
              < 600 => 16.0,
              < 1024 => 24.0,
              _ => 48.0,
            };

            if (feedNotifier.isLoading && feedNotifier.feedCollections.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final collections = feedNotifier.feedCollections;
            final hasAnyFeeds =
                collections.any((collection) => collection.feeds.isNotEmpty);
            final hasFolders = feedNotifier.folders.isNotEmpty;
            if (!hasAnyFeeds && !hasFolders) {
              return _EmptyFeedsContainer(onAddFeed: () => onAddFeed());
            }

            return RefreshIndicator(
              onRefresh: () => feedNotifier.getFeeds(forceRefresh: true),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 24,
                ),
                itemBuilder: (context, index) {
                  final collection = collections.elementAt(index);
                  return _FolderSection(
                    collection: collection,
                    crossAxisCount: crossAxisCount,
                    onAddFeed: () => onAddFeed(folderID: collection.folder?.id),
                    onManageFolders: onManageFolders,
                  );
                },
                separatorBuilder: (context, _) => const SizedBox(height: 24),
                itemCount: collections.length,
              ),
            );
          },
        );
      },
    );
  }
}

final class _FolderSection extends StatelessWidget {
  final FeedCollection collection;
  final int crossAxisCount;
  final VoidCallback onAddFeed;
  final VoidCallback onManageFolders;

  const _FolderSection({
    required this.collection,
    required this.crossAxisCount,
    required this.onAddFeed,
    required this.onManageFolders,
  });

  @override
  Widget build(BuildContext context) {
    final feeds = collection.sortedFeeds;
    final folderChipColor = collection.isFolder
        ? context.theme.colorScheme.secondaryContainer
        : context.theme.colorScheme.primaryContainer;

    return Card(
      elevation: 0,
      color: context.theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  collection.isFolder
                      ? Icons.folder_outlined
                      : Icons.inbox_outlined,
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    collection.folder?.name ?? 'Unsorted feeds',
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: folderChipColor,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${feeds.length} feed${feeds.length == 1 ? '' : 's'}',
                    style: context.theme.textTheme.labelLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (feeds.isEmpty)
              _EmptyFolderState(
                isFolder: collection.isFolder,
                onAddFeed: onAddFeed,
                onManageFolders: onManageFolders,
              )
            else
              _FeedGrid(
                feeds: feeds,
                crossAxisCount: crossAxisCount,
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onAddFeed,
                  icon: const Icon(Icons.add),
                  label: Text(
                    collection.isFolder ? 'Add feed to folder' : 'Add feed',
                  ),
                ),
                if (collection.isFolder)
                  OutlinedButton.icon(
                    onPressed: onManageFolders,
                    icon: const Icon(Icons.folder_manage_outlined),
                    label: const Text('Manage folders'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final class _FeedGrid extends StatelessWidget {
  final List<FeedEntity> feeds;
  final int crossAxisCount;

  const _FeedGrid({
    required this.feeds,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    if (crossAxisCount == 1) {
      return Column(
        children: [
          for (final feed in feeds)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FeedCard(feed: feed),
            ),
        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 160,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: feeds.length,
      itemBuilder: (context, index) {
        return FeedCard(feed: feeds[index]);
      },
    );
  }
}

final class _EmptyFolderState extends StatelessWidget {
  final bool isFolder;
  final VoidCallback onAddFeed;
  final VoidCallback onManageFolders;

  const _EmptyFolderState({
    required this.isFolder,
    required this.onAddFeed,
    required this.onManageFolders,
  });

  @override
  Widget build(BuildContext context) {
    final label = isFolder
        ? 'This folder does not contain any feeds yet.'
        : 'You have no uncategorized feeds.';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.tonalIcon(
                onPressed: onAddFeed,
                icon: const Icon(Icons.add),
                label: const Text('Add feed'),
              ),
              const SizedBox(width: 8),
              if (isFolder)
                TextButton(
                  onPressed: onManageFolders,
                  child: const Text('Rename or delete folder'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _EmptyFeedsContainer extends StatelessWidget {
  final VoidCallback onAddFeed;

  const _EmptyFeedsContainer({required this.onAddFeed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.rss_feed,
              size: 72,
              color: context.theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to RSSit!',
              textAlign: TextAlign.center,
              style: context.theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Create folders to separate work, hobbies, or personal interests '
              'and start subscribing to your favorite feeds.',
              textAlign: TextAlign.center,
              style: context.theme.textTheme.bodyLarge?.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAddFeed,
              icon: const Icon(Icons.add),
              label: const Text('Add your first feed'),
            ),
          ],
        ),
      ),
    );
  }
}
