import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:test_point/app/shell/sidebar/sidebar_actions.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/modules/import/import.dart';
import 'package:test_point/modules/requests/requests.dart';

/// Shown when the workspace has no collections yet.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  static const double _cardMaxWidth = 260;
  static const double _cardMaxHeight = 176;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Welcome to Test Point',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Send your first API request in seconds with a lightweight, distraction-free client.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: (_cardMaxWidth * 3) + (AppSpacing.lg * 2),
              ),
              child: Row(
                spacing: AppSpacing.lg,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _WelcomeActionCard(
                      maxWidth: _cardMaxWidth,
                      maxHeight: _cardMaxHeight,
                      icon: Icons.send_outlined,
                      badge: 'Ctrl+N',
                      title: 'New request',
                      description:
                          'Start testing an endpoint with GET, POST, or GraphQL.',
                      onTap: () {
                        ref.read(requestTabsProvider.notifier).openNew();
                        context.go(requestPath);
                      },
                    ),
                  ),
                  Expanded(
                    child: _WelcomeActionCard(
                      maxWidth: _cardMaxWidth,
                      maxHeight: _cardMaxHeight,
                      icon: Icons.folder_outlined,
                      badge: 'Group',
                      title: 'New collection',
                      description:
                          'Organize requests, pre-request scripts, and test assertions.',
                      onTap: () => CollectionActions(context, ref).create(),
                    ),
                  ),
                  Expanded(
                    child: _WelcomeActionCard(
                      maxWidth: _cardMaxWidth,
                      maxHeight: _cardMaxHeight,
                      icon: Icons.import_export_outlined,
                      badge: 'Import',
                      title: 'cURL / Postman',
                      description:
                          'From raw cURL, OpenAPI v3, Swagger, or Postman dump.',
                      onTap: () => showImportDialog(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeActionCard extends StatelessWidget {
  const _WelcomeActionCard({
    required this.maxWidth,
    required this.maxHeight,
    required this.icon,
    required this.badge,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final double maxWidth;
  final double maxHeight;
  final IconData icon;
  final String badge;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ),
      child: SizedBox(
        width: double.infinity,
        height: maxHeight,
        child: Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.outline,
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          icon,
                          color: theme.colorScheme.onPrimary,
                          size: 25,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: theme.colorScheme.outline,
                            width: 0.7,
                          ),
                        ),
                        child: Text(
                          badge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: muted,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
