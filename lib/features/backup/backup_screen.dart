import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/utils/dates.dart';
import '../../core/widgets/finance_card.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/section_header.dart';
import '../../data/backup_service.dart';

/// Copia de seguridad y restauracion (UI del corte K).
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _working = false;
  String? _message;
  bool _messageIsError = false;

  void _report(String message, {bool isError = false}) {
    if (!mounted) return;
    setState(() {
      _working = false;
      _message = message;
      _messageIsError = isError;
    });
  }

  /// Nombre del archivo del dia, con extension.
  ///
  /// La extension importa mas de lo que parece: compartir por mensajeria
  /// puede devolver el archivo renombrado y sin ella, y entonces ni el
  /// selector de archivos ni la propia aplicacion lo reconocen como copia.
  String get _fileName {
    final today = Dates.today();
    final stamp =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    return 'economy-tracker-$stamp.json';
  }

  /// Guarda la copia donde diga la persona, sin pasar por compartir.
  ///
  /// Es la via segura: el archivo queda en el movil con su nombre y su
  /// extension, y se puede volver a elegir para restaurar. Compartir por
  /// mensajeria es comodo pero puede devolver el archivo mutilado.
  Future<void> _save() async {
    if (_working) return;
    setState(() {
      _working = true;
      _message = null;
    });

    try {
      final content = await ref.read(backupServiceProvider).export();
      // UTF-8 explicito, que es lo que espera el restaurador.
      final bytes = Uint8List.fromList(utf8.encode(content));

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar copia de Economy Tracker',
        fileName: _fileName,
        type: FileType.any,
        bytes: bytes,
      );

      if (path == null) {
        _report('Guardado cancelado.');
        return;
      }

      // En movil, `saveFile` ya ha escrito el archivo a traves del sistema y
      // lo que devuelve es un identificador de documento, no una ruta:
      // algo como `/document/raw:/storage/emulated/0/Download/...`. Abrirlo
      // como `File` falla con PathNotFoundException aunque la copia este
      // perfectamente guardada. En escritorio si devuelve una ruta real y es
      // la aplicacion quien tiene que escribir.
      if (!Platform.isAndroid && !Platform.isIOS) {
        await File(path).writeAsBytes(bytes);
      }

      _report('Copia guardada como $_fileName.');
    } catch (error) {
      _report('No se ha podido guardar: $error', isError: true);
    }
  }

  Future<void> _export() async {
    if (_working) return;
    setState(() {
      _working = true;
      _message = null;
    });

    try {
      final content = await ref.read(backupServiceProvider).export();

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$_fileName');
      await file.writeAsString(content);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          fileNameOverrides: [_fileName],
          subject: 'Copia de Economy Tracker',
        ),
      );
      _report('Copia compartida. Comprueba que llega con su nombre entero.');
    } catch (error) {
      _report('No se ha podido exportar: $error', isError: true);
    }
  }

  Future<void> _restore() async {
    if (_working) return;

    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) return;

      final file = picked.files.single;
      // `readAsString` ya decodifica UTF-8; los bytes en memoria hay que
      // decodificarlos a mano, y ahi estaba el fallo de los acentos.
      final content = file.bytes != null
          ? BackupService.decodeBytes(file.bytes!)
          : BackupService.decodeBytes(await File(file.path!).readAsBytes());

      final service = ref.read(backupServiceProvider);
      final preview = service.preview(content);

      if (!mounted) return;
      final confirmed = await _confirmRestore(preview);
      if (confirmed != true) return;

      setState(() {
        _working = true;
        _message = null;
      });
      await service.restore(content);
      _report('Copia restaurada: ${preview.totalRows} registros.');
    } on BackupError catch (error) {
      _report(error.message, isError: true);
    } catch (error) {
      _report('No se ha podido restaurar: $error', isError: true);
    }
  }

  /// Antes de restaurar se enseña exactamente qué va a entrar y qué se
  /// pierde: la operación borra los datos actuales y no se deshace.
  Future<bool?> _confirmRestore(BackupPreview preview) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar esta copia'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Copia del ${formatDay(preview.exportedAt)}.',
                style: const TextStyle(color: AppTokens.textSecondary),
              ),
              const SizedBox(height: AppTokens.space4),
              for (final entry in preview.counts.entries)
                if (entry.value > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(_labelFor(entry.key))),
                        Text(
                          '${entry.value}',
                          style: const TextStyle(color: AppTokens.accentBright),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: AppTokens.space4),
              const Text(
                'Todo lo que tengas ahora en la aplicacion se borrara y se '
                'sustituira por esto. No se puede deshacer.',
                style: TextStyle(color: AppTokens.negative),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTokens.negative),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  static String _labelFor(String table) => switch (table) {
    'accounts' => 'Cuentas',
    'categories' => 'Categorias',
    'clients' => 'Clientes',
    'projects' => 'Proyectos',
    'salary_sources' => 'Fuentes salariales',
    'savings_goals' => 'Objetivos',
    'recurring_rules' => 'Reglas recurrentes',
    'transactions' => 'Movimientos',
    _ => table,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Copia de seguridad')),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.space4),
        children: [
          const FinanceCard(
            accent: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RoundIcon(Icons.backup_outlined, color: AppTokens.accent),
                    SizedBox(width: AppTokens.space4),
                    Expanded(
                      child: Text(
                        'Tus datos solo existen en este movil',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTokens.space3),
                Text(
                  'No hay servidor ni sincronizacion. Si desinstalas la '
                  'aplicacion, pierdes el telefono o lo cambias, la copia es '
                  'lo unico que puede devolverte el historial.',
                  style: TextStyle(color: AppTokens.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space5),
          FilledButton.icon(
            onPressed: _working ? null : _save,
            icon: const Icon(Icons.download_outlined),
            label: const Text('Guardar copia en el movil'),
          ),
          const SizedBox(height: AppTokens.space3),
          OutlinedButton.icon(
            onPressed: _working ? null : _export,
            icon: const Icon(Icons.ios_share_outlined),
            label: const Text('Compartir copia'),
          ),
          const SizedBox(height: AppTokens.space3),
          OutlinedButton.icon(
            onPressed: _working ? null : _restore,
            icon: const Icon(Icons.settings_backup_restore_outlined),
            label: const Text('Restaurar desde un archivo'),
          ),
          if (_working) ...[
            const SizedBox(height: AppTokens.space4),
            const LinearProgressIndicator(),
          ],
          if (_message != null) ...[
            const SizedBox(height: AppTokens.space4),
            Container(
              padding: const EdgeInsets.all(AppTokens.space3),
              decoration: BoxDecoration(
                color: _messageIsError
                    ? AppTokens.negativeSurface
                    : AppTokens.positiveSurface,
                borderRadius: BorderRadius.circular(AppTokens.radiusControl),
              ),
              child: Text(
                _message!,
                style: TextStyle(
                  color: _messageIsError
                      ? AppTokens.negative
                      : AppTokens.positive,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppTokens.space5),
          const SectionHeader('Como funciona'),
          const SizedBox(height: AppTokens.space2),
          const FinanceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'La copia es un archivo JSON con todo: cuentas, movimientos, '
                  'clientes, proyectos, salarios, objetivos y reglas.',
                  style: TextStyle(color: AppTokens.textSecondary),
                ),
                SizedBox(height: AppTokens.space3),
                Text(
                  'Es texto legible a proposito. Si algun dia la aplicacion no '
                  'arranca, tus datos se siguen pudiendo leer y recuperar a '
                  'mano.',
                  style: TextStyle(color: AppTokens.textSecondary),
                ),
                SizedBox(height: AppTokens.space3),
                Text(
                  'No esta cifrado: cualquiera que abra el archivo vera tus '
                  'finanzas. Guardalo donde guardarias un extracto bancario.',
                  style: TextStyle(color: AppTokens.pending),
                ),
                SizedBox(height: AppTokens.space3),
                Text(
                  'Si la compartes por mensajeria, comprueba que el archivo '
                  'llega terminado en .json. Algunas aplicaciones lo renombran '
                  'y le quitan la extension, y entonces no se puede volver a '
                  'elegir para restaurar. Guardarla en el movil no tiene ese '
                  'problema.',
                  style: TextStyle(color: AppTokens.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
