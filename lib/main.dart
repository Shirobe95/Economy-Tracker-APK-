import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'core/theme/paliko_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(PalikoTheme.systemOverlayStyle);
  runApp(const EconomyTrackerApp());
}
