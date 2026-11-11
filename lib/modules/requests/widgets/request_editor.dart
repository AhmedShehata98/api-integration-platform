import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/modules/requests/providers/request_providers.dart';
import 'package:test_point/modules/requests/widgets/auth_tab.dart';
import 'package:test_point/modules/requests/widgets/body_tab.dart';
import 'package:test_point/modules/requests/widgets/key_value_table.dart';
import 'package:test_point/modules/requests/widgets/request_bar.dart';

/// Request builder: URL bar plus the Params / Headers / Auth / Body tabs.
class RequestEditor extends ConsumerWidget {
  const RequestEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(requestDraftProvider);
    final notifier = ref.read(requestDraftProvider.notifier);

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const RequestBar(),
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Params'),
              Tab(text: 'Headers'),
              Tab(text: 'Auth'),
              Tab(text: 'Body'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                KeyValueTable(
                  items: draft.params,
                  onChanged: notifier.setParams,
                ),
                KeyValueTable(
                  items: draft.headers,
                  onChanged: notifier.setHeaders,
                ),
                AuthTab(auth: draft.auth, onChanged: notifier.setAuth),
                BodyTab(body: draft.body, onChanged: notifier.setBody),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
