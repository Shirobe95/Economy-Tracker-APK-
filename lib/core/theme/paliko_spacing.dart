/// Escala de espaciado y radios del sistema PALIKO.
///
/// Una única escala de 4 px evita márgenes arbitrarios y mantiene el ritmo
/// vertical constante entre pantallas.
abstract final class PalikoSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Margen lateral estándar de las pantallas.
  static const double screenPadding = lg;

  /// Separación vertical entre bloques de contenido.
  static const double sectionGap = xl;
}

/// Radios de esquina. Los paneles son discretos: nada de esquinas muy redondas.
abstract final class PalikoRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}
