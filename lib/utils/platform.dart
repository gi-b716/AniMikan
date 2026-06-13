import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

bool isDesktop() =>
    !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
