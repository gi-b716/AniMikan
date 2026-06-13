import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

bool isDesktop() =>
    defaultTargetPlatform == TargetPlatform.windows ||
    defaultTargetPlatform == TargetPlatform.linux ||
    defaultTargetPlatform == TargetPlatform.macOS;
