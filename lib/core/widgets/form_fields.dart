import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_tokens.dart';
import '../utils/dates.dart';
import '../utils/money.dart';

/// Campo de importe en euros.
///
/// Admite coma o punto decimal. No acepta separadores de miles ni mas de dos
/// decimales: convertir "1.234" adivinando si son mil o uno con decimales
/// seria adivinar con dinero.
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
    this.label = 'Importe',
    this.allowNegative = false,
    this.autofocus = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;

  /// Solo para saldos iniciales, donde un negativo es legitimo.
  final bool allowNegative;
  final bool autofocus;
  final VoidCallback? onSubmitted;

  /// Valida el texto actual y devuelve el mensaje de error, o `null`.
  static String? validate(String value, {bool allowNegative = false}) {
    if (value.trim().isEmpty) return 'Escribe un importe.';
    final cents = Money.tryParse(value);
    if (cents == null) {
      return 'Importe no valido. Usa como mucho dos decimales.';
    }
    if (!allowNegative && cents <= 0) {
      return 'El importe debe ser mayor que cero.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.numberWithOptions(
        decimal: true,
        signed: allowNegative,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          allowNegative ? RegExp(r'[0-9,.\-]') : RegExp(r'[0-9,.]'),
        ),
      ],
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => onSubmitted?.call(),
      decoration: InputDecoration(
        labelText: label,
        suffixText: '€',
        suffixStyle: const TextStyle(color: AppTokens.textSecondary),
      ),
      validator: (value) => validate(value ?? '', allowNegative: allowNegative),
    );
  }
}

/// Selector de fecha con el formato corto en espanol.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.helper,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? helper;

  Future<void> _pick(BuildContext context) async {
    final initial = value ?? Dates.today();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.utc(2000),
      lastDate: DateTime.utc(2100),
    );
    if (picked != null) onChanged(Dates.day(picked));
  }

  @override
  Widget build(BuildContext context) {
    final text = value == null ? 'Sin fecha' : formatDay(value!);
    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(AppTokens.radiusControl),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: AppTokens.textSecondary,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: value == null ? AppTokens.textMuted : AppTokens.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Fecha en formato `03 sep 2026`.
String formatDay(DateTime value) {
  const months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  final day = value.day.toString().padLeft(2, '0');
  return '$day ${months[value.month - 1]} ${value.year}';
}

/// Nombre del mes con ano: `Septiembre 2026`.
String formatMonth(DateTime value) {
  const months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];
  return '${months[value.month - 1]} ${value.year}';
}

/// Desplegable con el estilo de los campos del formulario.
class OptionField<T> extends StatelessWidget {
  const OptionField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      dropdownColor: AppTokens.surfaceElevated,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}

/// Fila de chips de filtro, como los de UI-03.
class FilterChips<T> extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.labelOf,
  });

  final List<T> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final String Function(T) labelOf;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(right: AppTokens.space2),
              child: ChoiceChip(
                label: Text(labelOf(option)),
                selected: option == selected,
                onSelected: (_) => onSelected(option),
                showCheckmark: false,
              ),
            ),
        ],
      ),
    );
  }
}

/// Selector de mes con flechas, como la cabecera de UI-03.
class MonthSelector extends StatelessWidget {
  const MonthSelector({
    super.key,
    required this.month,
    required this.onChanged,
  });

  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusControl),
        border: Border.all(color: AppTokens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () =>
                onChanged(DateTime.utc(month.year, month.month - 1)),
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Mes anterior',
          ),
          Text(
            formatMonth(month),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            onPressed: () =>
                onChanged(DateTime.utc(month.year, month.month + 1)),
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Mes siguiente',
          ),
        ],
      ),
    );
  }
}
