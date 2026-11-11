import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/app/shell/sidebar/sidebar_filter.dart';
import 'package:test_point/modules/collections/collections.dart';
import 'package:test_point/modules/requests/requests.dart';

Collection _col(String id, String name) =>
    Collection(id: id, workspaceId: 'ws', name: name);

SavedRequest _req(
  String id,
  String collectionId,
  String name, {
  String url = '',
}) => SavedRequest(
  id: id,
  collectionId: collectionId,
  name: name,
  draft: HttpRequestDraft(url: url),
);

void main() {
  final collections = [_col('c1', 'Users API'), _col('c2', 'Billing')];
  final requests = [
    _req('r1', 'c1', 'List users', url: 'https://a.test/users'),
    _req('r2', 'c1', 'Create user'),
    _req('r3', 'c2', 'List invoices', url: 'https://a.test/invoices'),
  ];

  List<String> names(List<SidebarGroup> groups) => [
    for (final g in groups)
      '${g.collection.name}: ${g.requests.map((r) => r.id).join(',')}',
  ];

  test('no filter keeps everything, grouped by collection', () {
    expect(names(filterSidebar(collections, requests, '')), [
      'Users API: r1,r2',
      'Billing: r3',
    ]);
  });

  test('keeps empty collections when not filtering', () {
    expect(names(filterSidebar([_col('c9', 'Empty')], requests, '  ')), [
      'Empty: ',
    ]);
  });

  test('a collection name match shows all its requests', () {
    expect(names(filterSidebar(collections, requests, 'billing')), [
      'Billing: r3',
    ]);
  });

  test('a request name match shows only the matching requests', () {
    expect(names(filterSidebar(collections, requests, 'CREATE')), [
      'Users API: r2',
    ]);
  });

  test('also matches the request URL', () {
    expect(names(filterSidebar(collections, requests, 'invoices')), [
      'Billing: r3',
    ]);
  });

  test('no match gives no groups', () {
    expect(filterSidebar(collections, requests, 'zzz'), isEmpty);
  });
}
