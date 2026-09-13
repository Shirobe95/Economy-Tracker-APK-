# Reglas preparadas para cuando se active la minificacion en
# android/app/build.gradle.kts. Hoy no se aplican.

# Drift y sqlite3 acceden a clases por reflexion en tiempo de ejecucion.
-keep class com.example.sqlite3_flutter_libs.** { *; }
-keep class org.sqlite.** { *; }

# Flutter conserva sus propios puntos de entrada.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
