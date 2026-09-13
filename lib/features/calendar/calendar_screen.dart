import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/app_database.dart';
import '../../core/database/enums.dart';
import '../../core/utils/dates.dart';
import '../../core/widgets/feature_placeholder.dart';
import '../../core/widgets/finance_card.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/section_header.dart';
import '../../data/recurrence_schedule.dart';
import '../dashboard/dashboard_screen.dart';
import '../expenses/expenses_screen.dart';
import '../movements/movement_list_tile.dart';

/// Calendario de pagos y cobros del mes (UI-10).
///
/// Junta los movimientos ya anotados con las fechas que tocan segun las
/// reglas recurrentes. Las segundas se marcan como previstas: existen en el
/// calendario, no en la base.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _month = Dates.monthStart(Dates.today());
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final movements = ref.watch(monthlyMovementsProvider(_month));
    final rules = ref.watch(allRulesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendario')),
      body: movements.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (rows) {
          final live = rows
              .where((m) => m.status != MovementStatus.cancelado)
              .toList();
          final scheduled = _scheduledDays(rules.value ?? const []);

          final byDay = <int, List<Transaction>>{};
          for (final movement in live) {
            byDay
                .putIfAbsent(movement.expectedDate.day, () => [])
                .add(movement);
          }

          final selected = _selectedDay;
          final selectedMovements = selected == null
              ? const <Transaction>[]
              : (byDay[selected.day] ?? const <Transaction>[]);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.space4,
              0,
              AppTokens.space4,
              AppTokens.space5,
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: MonthSelector(
                  month: _month,
                  onChanged: (value) => setState(() {
                    _month = value;
                    _selectedDay = null;
                  }),
                ),
              ),
              const SizedBox(height: AppTokens.space4),
              FinanceCard(
                child: _MonthGrid(
                  month: _month,
                  withMovements: byDay.keys.toSet(),
                  withRules: scheduled,
                  selectedDay: selected?.day,
                  onDaySelected: (day) => setState(
                    () => _selectedDay = DateTime.utc(
                      _month.year,
                      _month.month,
                      day,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.space5),
              SectionHeader(
                selected == null
                    ? 'Movimientos del mes'
                    : 'Dia ${formatDay(selected)}',
              ),
              const SizedBox(height: AppTokens.space2),
              if (selected == null)
                if (live.isEmpty)
                  const EmptyState(
                    message: 'No hay movimientos previstos este mes.',
                    icon: Icons.event_available_outlined,
                  )
                else
                  for (final movement in live)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppTokens.space2),
                      child: MovementListTile(
                        movement: movement,
                        mixedDirections: true,
                      ),
                    )
              else if (selectedMovements.isEmpty)
                const EmptyState(
                  message: 'Nada anotado en este dia.',
                  icon: Icons.event_busy_outlined,
                )
              else
                for (final movement in selectedMovements)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.space2),
                    child: MovementListTile(
                      movement: movement,
                      mixedDirections: true,
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  /// Dias del mes en los que toca alguna regla recurrente.
  Set<int> _scheduledDays(List<RecurringRule> rules) {
    final from = _month;
    final to = Dates.nextMonthStart(_month);
    final days = <int>{};

    for (final rule in rules) {
      if (!rule.isActive) continue;
      final schedule = RecurrenceSchedule.fromRule(rule);
      for (final date in schedule.between(from: from, to: to)) {
        days.add(date.day);
      }
    }
    return days;
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.withMovements,
    required this.withRules,
    required this.selectedDay,
    required this.onDaySelected,
  });

  final DateTime month;
  final Set<int> withMovements;
  final Set<int> withRules;
  final int? selectedDay;
  final ValueChanged<int> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = Dates.daysInMonth(month.year, month.month);
    // El primer dia de la rejilla es el lunes de la semana del dia 1.
    final leading = DateTime.utc(month.year, month.month).weekday - 1;
    final today = Dates.today();

    return Column(
      children: [
        Row(
          children: [
            for (final label in ['L', 'M', 'X', 'J', 'V', 'S', 'D'])
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTokens.space2),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: leading + daysInMonth,
          itemBuilder: (context, index) {
            if (index < leading) return const SizedBox.shrink();
            final day = index - leading + 1;
            final isToday =
                today.year == month.year &&
                today.month == month.month &&
                today.day == day;

            return _DayCell(
              day: day,
              isToday: isToday,
              isSelected: selectedDay == day,
              hasMovements: withMovements.contains(day),
              hasRules: withRules.contains(day),
              onTap: () => onDaySelected(day),
            );
          },
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.hasMovements,
    required this.hasRules,
    required this.onTap,
  });

  final int day;
  final bool isToday;
  final bool isSelected;
  final bool hasMovements;
  final bool hasRules;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppTokens.accent : Colors.transparent,
              border: isToday && !isSelected
                  ? Border.all(color: AppTokens.accentBright)
                  : null,
            ),
            child: Text(
              '$day',
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : hasMovements
                    ? AppTokens.textPrimary
                    : AppTokens.textSecondary,
                fontWeight: hasMovements ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasMovements) const _Dot(color: AppTokens.accentBright),
                if (hasRules) const _Dot(color: AppTokens.pending),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
