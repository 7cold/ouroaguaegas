import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ouroaguaegas/ui/root.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ycljgeebzdhdobaysjjo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InljbGpnZWViemRoZG9iYXlzampvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAxNzA5NDMsImV4cCI6MjA1NTc0Njk0M30.SJ7_LFQWdh4e4rAYbJ-cAG93hO6yyXBjk5-7fyKLNRE',
  );

  initializeDateFormatting();

  await GetStorage.init();
  runApp(const MyApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        title: "Ouro Agua e Gas",
        opaqueRoute: true,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        darkTheme: ThemeData(
          useMaterial3: true,
          dividerColor: Colors.transparent,
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.lime,
        ),
        theme: ThemeData(
          dividerColor: Colors.transparent,
          brightness: Brightness.light,
          colorSchemeSeed: Colors.lime,
          useMaterial3: true,
        ),
        home: Root(),
      ),
    );
  }
}
