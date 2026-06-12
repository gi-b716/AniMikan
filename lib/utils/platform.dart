import 'dart:io' show Platform;

bool isDesktop() => Platform.isWindows || Platform.isLinux || Platform.isMacOS;
