import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/widgets/feature_placeholder.dart';
import '../../core/database/app_database.dart';
import '../../core/widgets/finance_card.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/section_header.dart';
import '../../data/project_repository.dart';

/// Lista de clientes (UI-06).
class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientsProvider);
    final summaries = ref.watch(activeProjectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes y proyectos')),
      body: clients.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (rows) {
          if (rows.isEmpty) {
            return Center(
              child: EmptyState(
                message:
                    'Todavia no hay clientes.\nUn cobro siempre pertenece a un '
                    'proyecto, y un proyecto a un cliente.',
                icon: Icons.folder_shared_outlined,
                action: FilledButton(
                  onPressed: () => context.push('/proyectos/clientes/nuevo'),
                  child: const Text('Crear cliente'),
                ),
              ),
            );
          }

          final projects = summaries.value ?? const <ProjectSummary>[];

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.space4,
              0,
              AppTokens.space4,
              96,
            ),
            children: [
              for (final client in rows)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTokens.space3),
                  child: _ClientCard(
                    name: client.name,
                    contact: client.contact,
                    projectCount: projects
                        .where((p) => p.client.id == client.id)
                        .length,
                    onTap: () =>
                        context.push('/proyectos/clientes/${client.id}'),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/proyectos/clientes/nuevo'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo cliente'),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({
    required this.name,
    required this.contact,
    required this.projectCount,
    required this.onTap,
  });

  final String name;
  final String? contact;
  final int projectCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTokens.accentSurface,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              name.isEmpty ? '?' : name.characters.first.toUpperCase(),
              style: const TextStyle(
                color: AppTokens.accentBright,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: AppTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  projectCount == 0
                      ? 'Sin proyectos'
                      : projectCount == 1
                      ? '1 proyecto'
                      : '$projectCount proyectos',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (contact != null)
                  Text(
                    contact!,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppTokens.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTokens.textMuted),
        ],
      ),
    );
  }
}

/// Ficha de un cliente con sus proyectos (UI-07).
class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.clientId});

  final int clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientProvider(clientId));
    final projects = ref.watch(clientProjectsProvider(clientId));

    return Scaffold(
      appBar: AppBar(
        title: Text(client.value?.name ?? 'Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar cliente',
            onPressed: () =>
                context.push('/proyectos/clientes/$clientId/editar'),
          ),
        ],
      ),
      body: projects.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (rows) {
          final collected = rows.fold<int>(0, (a, p) => a + p.collected);
          final pending = rows.fold<int>(0, (a, p) => a + p.pending);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.space4,
              0,
              AppTokens.space4,
              96,
            ),
            children: [
              FinanceCard(
                accent: true,
                child: Row(
                  children: [
                    Expanded(
                      child: _Total(label: 'Cobrado', amount: collected),
                    ),
                    Container(width: 1, height: 44, color: AppTokens.border),
                    Expanded(
                      child: _Total(
                        label: 'Pendiente',
                        amount: pending,
                        color: AppTokens.pending,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.space5),
              const SectionHeader('Proyectos'),
              const SizedBox(height: AppTokens.space2),
              if (rows.isEmpty)
                const EmptyState(
                  message: 'Este cliente no tiene proyectos todavia.',
                  icon: Icons.work_outline,
                )
              else
                for (final summary in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.space2),
                    child: _ProjectCard(summary: summary),
                  ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/proyectos/clientes/$clientId/proyectos/nuevo'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo proyecto'),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({
    required this.label,
    required this.amount,
    this.color = AppTokens.positive,
  });

  final String label;
  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 2),
          MoneyText(
            amount,
            compact: true,
            color: color,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.summary});

  final ProjectSummary summary;

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      onTap: () => context.push('/proyectos/detalle/${summary.project.id}'),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.project.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  summary.project.isActive ? 'Activo' : 'Archivado',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: summary.project.isActive
                        ? AppTokens.positive
                        : AppTokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
          MoneyText(
            summary.collected,
            compact: true,
            color: AppTokens.positive,
          ),
          const SizedBox(width: AppTokens.space2),
          const Icon(Icons.chevron_right, color: AppTokens.textMuted),
        ],
      ),
    );
  }
}

final clientProvider = StreamProvider.family<Client?, int>(
  (ref, id) => ref.watch(projectRepositoryProvider).watchClient(id),
);

final clientProjectsProvider = StreamProvider.family<List<ProjectSummary>, int>(
  (ref, clientId) =>
      ref.watch(projectRepositoryProvider).watchSummaries(clientId: clientId),
);
