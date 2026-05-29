import 'dart:io';

import 'package:calculator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:show_fps/show_fps.dart';
import 'core/theme/app_theme.dart';
import 'features/calculator/bloc/calculator_bloc.dart';
import 'features/calculator/presentation/screens/calculator_screen.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final showFps =
        Platform.environment['SHOW_FPS'] == 'true' ||
        const String.fromEnvironment('SHOW_FPS') == 'true';
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: showFps
          ? (context, child) {
              return ShowFPS(visible: showFps, showChart: false, child: child!);
            }
          : null,
      home: BlocProvider(
        create: (context) => CalculatorBloc(),
        child: const CalculatorScreen(),
      ),
    );
  }
}
