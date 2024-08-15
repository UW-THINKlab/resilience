import 'package:flutter/material.dart';
import 'package:support_sphere/presentation/pages/landing_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/constants/color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:support_sphere/utils/config.dart';

void main() {
  try {
    Config.initSupabase();
  } catch (e) {
    // TODO: Log error
    print(e);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App title
      title: AppStrings.appName,
      
      // Theme configuration
      theme: _buildTheme(
        Brightness.light,
      ),

      // Landing page
      home: const Landing(),

      // Localizations configuration (i18n)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
      ],
    );
  }

  ThemeData _buildTheme(brightness) {
    var baseTheme = ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        seedColor: ColorConstants.seed,
        brightness: Brightness.light,
      ),
      // This is the theme of your application.
      //
      // TRY THIS: Try running your application with "flutter run". You'll see
      // the application has a purple toolbar. Then, without quitting the app,
      // try changing the seedColor in the colorScheme below to Colors.green
      // and then invoke "hot reload" (save your changes or press the "hot
      // reload" button in a Flutter-supported IDE, or press "r" if you used
      // the command line to start the app).
      //
      // Notice that the counter didn't reset back to zero; the application
      // state is not lost during the reload. To reset the state, use hot
      // restart instead.
      //
      // This works for code too, not just values: Most code changes can be
      // tested with just a hot reload.
      useMaterial3: true,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme),
    );
  }
}
