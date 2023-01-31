import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'browser.dart';
import 'components/bookmark_history/bookmark_history_page.dart';
import 'model/model.dart';
import 'scheme/scheme.dart';
import 'utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesUtil.initInstance();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with NavigatorObserver {
  late BuildContext providerContext;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  ThemeMode _getThemeMode(String value) {
    ThemeMode themeMode;

    switch (value) {
      case 'system':
        themeMode = ThemeMode.system;
        break;
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
        break;
    }
    return themeMode;
  }

  ThemeData _themeData(ColorScheme colorScheme) {
    ThemeUtil themeUtil = ThemeUtil.brightness(colorScheme.brightness);
    return ThemeData(
      colorScheme: colorScheme,
      scrollbarTheme: ScrollbarThemeData(
        radius: const Radius.circular(4),
        thumbColor: MaterialStateProperty.all(themeUtil.textInactivationColor),
      ),
      iconTheme: IconThemeData(
        size: 32,
        color: themeUtil.textPrimaryColor,
      ),
      useMaterial3: true,
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    BrowserModel browserModel = providerContext.read<BrowserModel>();
    if (browserModel.currentController != null && route.settings.name != null) {
      delayExec(() {
        try {
          browserModel.currentController!.resume();
        } catch (_) {}
      });
    }

    super.didPop(route, previousRoute);
  }

  @override
  Widget build(BuildContext context) {
    String? themeMode = PreferencesUtil.preferences.getString("themeMode");
    List<String>? searchRecords =
        PreferencesUtil.preferences.getStringList("searchRecords");
    String? historyRecords =
        PreferencesUtil.preferences.getString("historyRecords");

    String? bookMarks = PreferencesUtil.preferences.getString("bookMarks");

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Cache>(
          create: (_) => Cache(
            searchRecords: searchRecords,
            historyRecords: historyRecords,
            themeMode: themeMode,
            bookMarks: bookMarks,
          ),
        ),
        ChangeNotifierProvider<BrowserModel>(create: (_) => BrowserModel()),
        ChangeNotifierProvider<SettingModel>(create: (_) => SettingModel()),
        ChangeNotifierProvider<StatusModel>(create: (_) => StatusModel()),
      ],
      builder: (context, child) {
        providerContext = context;
        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            Scheme scheme =
                Scheme(lightDynamic: lightDynamic, darkDynamic: darkDynamic);

            return Consumer(builder: (_, Cache cache, __) {
              return MaterialApp(
                  navigatorObservers: [this],
                  navigatorKey: CommonUtil.navigatorKey,
                  theme: _themeData(scheme.getLightScheme()),
                  darkTheme: _themeData(scheme.getDarkScheme()),
                  themeMode: _getThemeMode(cache.themeMode),
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('zh', 'CN'),
                  ],
                  initialRoute: "/",
                  onGenerateRoute: (settings) {
                    Widget panel;
                    switch (settings.name) {
                      case '/':
                        panel = const Browser();
                        break;
                      case '/bookmark':
                        panel = const BookMarkHistoryPage(
                          initialIndex: 0,
                        );
                        break;
                      case '/history':
                        panel = const BookMarkHistoryPage(
                          initialIndex: 1,
                        );
                        break;
                      default:
                        panel = const Browser();
                        break;
                    }
                    return PageRouteBuilder(
                      settings: settings,
                      pageBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                      ) {
                        Tween<Offset> tween = Tween(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        );
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: panel,
                        );
                      },
                    );
                  });
            });
          },
        );
      },
    );
  }
}
