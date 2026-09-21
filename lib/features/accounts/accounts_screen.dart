import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/widgets/feature_placeholder.dart';
import '../../core/widgets/finance_card.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/section_header.dart';
import '../../data/account_repository.dart';
import 'reconcile_dialog.dart';
import '../movements/quick_create_dialogs.dart';

/// Cuentas y su saldo real (UI-13).
class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balances = ref.watch(accountBalancesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cuentas')),
      body: balances.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (rows) {
          if (rows.isEmpty) {
            return Center(
              child: EmptyState(
                message: 'Todavia no tienes ninguna cuenta.',
                icon: Icons.account_balance_wallet_outlined,
                action: FilledButton(
                  onPressed: () => showCreateAccountDialog(context, ref),
                  child: const Text('Crear cuenta'),
                ),
              ),
            );
          }

          final live = rows.where((a) => !a.account.isArchived).toList();
          final archived = rows.where((a) => a.account.isArchived).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.space4,
              0,
              AppTokens.space4,
              96,
            ),
            children: [
              for (final entry in live)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTokens.space3),
                  child: _AccountCard(entry: entry),
                ),
              if (archived.isNotEmpty) ...[
                const SizedBox(height: AppTokens.space4),
                const SectionHeader('Archivadas'),
                const SizedBox(height: AppTokens.space2),
                for (final entry in archived)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.space2),
                    child: _AccountCard(entry: entry),
                  ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCreateAccountDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nueva cuenta'),
      ),
    );
  }
}

class _AccountCard extends ConsumerWidget {
  const _AccountCard({required this.entry});

  final AccountBalance entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archived = entry.account.isArchived;

    return FinanceCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.account.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (entry.balance == null)
                  const Text(
                    'Saldo no disponible',
                    style: TextStyle(color: AppTokens.textMuted),
                  )
                else
                  MoneyText(
                    entry.balance!,
                    currency: entry.account.currency,
                    style: Theme.of(context).textTheme.headlineMedium,
                    color: entry.balance! < 0
                        ? AppTokens.negative
                        : AppTokens.textPrimary,
                  ),
              ],
            ),
          ),
          if (!archived && entry.balance != null)
            IconButton(
              tooltip: 'Cuadrar con el banco',
              icon: const Icon(Icons.balance_outlined),
              onPressed: () => showReconcileDialog(context, ref, entry.account),
            ),
          IconButton(
            tooltip: archived ? 'Reactivar' : 'Archivar',
            icon: Icon(
              archived ? Icons.unarchive_outlined : Icons.archive_outlined,
            ),
            onPressed: () => ref
                .read(accountRepositoryProvider)
                .setAccountArchived(entry.account.id, !archived),
          ),
        ],
      ),
    );
  }
}
