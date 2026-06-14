import 'package:flutter/foundation.dart';

/// Global notifier for programmatic tab switching.
/// 0 = Home (AI Setup), 1 = Focus, 2 = Analytics, 3 = Settings.
final ValueNotifier<int> activeTabNotifier = ValueNotifier(1);
