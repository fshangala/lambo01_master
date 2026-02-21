import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lambo01_master/pages/browser_page.dart';
import 'package:lambo01_master/pages/home_page.dart';
import 'package:lambo01_master/pages/settings_page.dart';
import 'package:lambo01_master/pages/slave_browser_page.dart';
import 'package:lambo01_master/pages/slave_home_page.dart';
import 'package:lambo01_master/viewmodels/app_viewmodel.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    final availableVersion = await WebViewEnvironment.getAvailableVersion();
    assert(availableVersion != null, 'WebView2 is not available on this system.');
  }

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppViewmodel())
      ], 
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final appViewmodel = Provider.of<AppViewmodel>(context, listen: true);

    final routes = {
      '/': (context) => appViewmodel.role == 'master' ? const HomePage() : const SlaveHomePage(),
      '/settings': (context) => const SettingsPage(),
      '/browser': (context) => appViewmodel.role == 'master' ? const BrowserPage() : const SlaveBrowserPage(),
    };
    
    return MaterialApp(
      title: 'Lambo01 ${appViewmodel.role}',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: routes,
    );
  }
}
