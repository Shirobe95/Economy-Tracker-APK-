import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/widgets/finance_card.dart';
import '../../core/widgets/section_header.dart';

/// Ajustes y accesos a las secciones secundarias (UI-16).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.space4),
        children: [
          const SectionHeader('Secciones'),
          const SizedBox(height: AppTokens.space2),
          _Entry(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Cuentas',
            subtitle: 'Saldos, alta y archivo de cuentas',
            route: '/cuentas',
          ),
          _Entry(
            icon: Icons.folder_shared_outlined,
            title: 'Clientes y proyectos',
            subtitle: 'Proyectos y cobros',
            route: '/proyectos',
          ),
          _Entry(
            icon: Icons.badge_outlined,
            title: 'Salarios',
            subtitle: 'Fuentes salariales y nominas',
            route: '/salarios',
          ),
          _Entry(
            icon: Icons.adjust_rounded,
            title: 'Objetivos',
            subtitle: 'Metas de ahorro',
            route: '/objetivos',
          ),
          _Entry(
            icon: Icons.calendar_month_outlined,
            title: 'Calendario',
            subtitle: 'Pagos y cobros del mes',
            route: '/calendario',
          ),
          _Entry(
            icon: Icons.receipt_long_outlined,
            title: 'Todos los movimientos',
            subtitle: 'Buscar en todo el historial',
            route: '/movimientos',
          ),
          _Entry(
            icon: Icons.insights_outlined,
            title: 'Informes',
            subtitle: 'En que se va el dinero, mes a mes',
            route: '/informes',
          ),
          const SizedBox(height: AppTokens.space5),
          const SectionHeader('Datos y seguridad'),
          const SizedBox(height: AppTokens.space2),
          _Entry(
            icon: Icons.backup_outlined,
            title: 'Copia de seguridad',
            subtitle: 'Exportar y restaurar tus datos',
            route: '/ajustes/copia',
          ),
          _Entry(
            icon: Icons.lock_outline,
            title: 'Bloqueo',
            subtitle: 'Pedir un PIN al abrir la aplicacion',
            route: '/ajustes/bloqueo',
          ),
          const SizedBox(height: AppTokens.space4),
          const FinanceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Todo se guarda solo en este telefono.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: AppTokens.space2),
                Text(
                  'No hay cuenta de usuario, servidor ni sincronizacion. Los '
                  'datos viven en una base local privada de la aplicacion, y '
                  'desaparecen si la desinstalas: haz copias.',
                  style: TextStyle(color: AppTokens.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.space2),
      child: FinanceCard(
        onTap: () => context.push(route),
        padding: const EdgeInsets.all(AppTokens.space3),
        child: Row(
          children: [
            Icon(icon, color: AppTokens.accentBright),
            const SizedBox(width: AppTokens.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTokens.textMuted),
          ],
        ),
      ),
    );
  }
}
