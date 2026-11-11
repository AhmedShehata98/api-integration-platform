import 'package:test_point/modules/collections/collections.dart';
import 'package:test_point/modules/requests/requests.dart';

/// A collection and the requests of it that should be shown.
class SidebarGroup {
  const SidebarGroup(this.collection, this.requests);

  final Collection collection;
  final List<SavedRequest> requests;
}

/// Groups [requests] under their collections and applies the filter [query]
/// (case-insensitive). A collection is kept if its name matches (with all its
/// requests) or if any of its requests match (only those).
List<SidebarGroup> filterSidebar(
  List<Collection> collections,
  List<SavedRequest> requests,
  String query,
) {
  final needle = query.trim().toLowerCase();
  bool matches(String text) => text.toLowerCase().contains(needle);

  final groups = <SidebarGroup>[];
  for (final collection in collections) {
    final own = [
      for (final r in requests)
        if (r.collectionId == collection.id) r,
    ];
    if (needle.isEmpty || matches(collection.name)) {
      groups.add(SidebarGroup(collection, own));
      continue;
    }
    final hits = own.where((r) => matches(r.name) || matches(r.draft.url));
    if (hits.isNotEmpty) groups.add(SidebarGroup(collection, hits.toList()));
  }
  return groups;
}
