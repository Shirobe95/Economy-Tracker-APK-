import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/utils/money.dart';
import '../../data/forecast_engine.dart';

/// Grafico de linea de la proyeccion de saldo.
///
/// Se dibuja a mano en vez de traer una libreria de graficos: es una sola
/// serie y asi el estilo sale del mismo sistema visual que el resto.
class ForecastChart extends StatelessWidget {
  const ForecastChart({
    super.key,
    required this.points,
    required this.startingBalance,
    this.height = 200,
  });

  final List<ForecastPoint> points;
  final int startingBalance;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final values = [startingBalance, ...points.map((p) => p.balance)];
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          child: Row(
            children: [
              SizedBox(
                width: 64,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _axisLabel(context, maxValue),
                    _axisLabel(context, (maxValue + minValue) ~/ 2),
                    _axisLabel(context, minValue),
                  ],
                ),
              ),
              const SizedBox(width: AppTokens.space2),
              Expanded(
                child: CustomPaint(
                  painter: _ForecastPainter(values: values),
                  size: Size.infinite,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space2),
        Padding(
          padding: const EdgeInsets.only(left: 72),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hoy', style: Theme.of(context).textTheme.bodySmall),
              Text(
                '${points.length} m',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _axisLabel(BuildContext context, int value) => Text(
    Money.formatCompact(value),
    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
    overflow: TextOverflow.ellipsis,
  );
}

class _ForecastPainter extends CustomPainter {
  const _ForecastPainter({required this.values});

  final List<int> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.width <= 0 || size.height <= 0) return;

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    // Un rango nulo dejaria la linea pegada a un borde: se reparte a media
    // altura en ese caso.
    final range = maxValue - minValue;

    double yOf(int value) {
      if (range == 0) return size.height / 2;
      return size.height * (1 - (value - minValue) / range);
    }

    final step = size.width / (values.length - 1);
    final offsets = [
      for (var i = 0; i < values.length; i++) Offset(i * step, yOf(values[i])),
    ];

    // Rejilla horizontal discreta.
    final grid = Paint()
      ..color = AppTokens.border
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final y = size.height * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final offset in offsets.skip(1)) {
      path.lineTo(offset.dx, offset.dy);
    }

    // Relleno degradado bajo la linea.
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x5529B8F0), Color(0x0029B8F0)],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = AppTokens.accentBright
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );

    // Punto final destacado, como en el mockup.
    canvas.drawCircle(offsets.last, 5, Paint()..color = AppTokens.background);
    canvas.drawCircle(
      offsets.last,
      5,
      Paint()
        ..color = AppTokens.accentBright
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_ForecastPainter oldDelegate) =>
      oldDelegate.values != values;
}
