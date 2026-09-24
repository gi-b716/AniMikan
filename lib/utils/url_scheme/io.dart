import 'dart:io';

import 'package:animikan/config.dart';

const _desktopFile = 'io.github.gib716.animikan.desktop';

Future<void> registerUrlScheme() async {
  if (!Platform.isLinux) return;

  final home = Platform.environment['HOME'];
  final dataHome = Platform.environment['XDG_DATA_HOME'];
  final root = (dataHome != null && dataHome.isNotEmpty)
      ? dataHome
      : (home == null || home.isEmpty ? null : '$home/.local/share');
  if (root == null) return;

  final directory = Directory('$root/applications');
  final entry = File('${directory.path}/$_desktopFile');
  final contents =
      '[Desktop Entry]\n'
      'Type=Application\n'
      'Name=AniMikan\n'
      'Exec=${Platform.resolvedExecutable} %u\n'
      'Terminal=false\n'
      'Categories=AudioVideo;\n'
      'MimeType=x-scheme-handler/${BangumiConst.scheme};\n';

  try {
    if (entry.existsSync() && entry.readAsStringSync() == contents) return;
    await directory.create(recursive: true);
    await entry.writeAsString(contents);
  } catch (_) {
    // A missing or read-only home directory is not worth failing a launch over.
    return;
  }

  await _quietly('update-desktop-database', [directory.path]);
  await _quietly('xdg-mime', [
    'default',
    _desktopFile,
    'x-scheme-handler/${BangumiConst.scheme}',
  ]);
}

Future<void> _quietly(String command, List<String> arguments) async {
  try {
    await Process.run(command, arguments);
  } on ProcessException {
    // pass
  }
}
