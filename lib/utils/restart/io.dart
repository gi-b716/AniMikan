import 'dart:io';

Future<void> restartApp() async {
  await Process.start(
    Platform.resolvedExecutable,
    const <String>[],
    mode: ProcessStartMode.detached,
  );
  exit(0);
}
