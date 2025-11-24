import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:reto_habitos/src/models/HabitosModel.dart';
import 'package:reto_habitos/src/views/createView.dart';
import 'package:reto_habitos/src/views/editView.dart';
import 'package:reto_habitos/src/views/loginView.dart';
import 'firebase_options.dart';
import 'package:go_router/go_router.dart';

import 'src/views/homepageView.dart';

class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthChangeNotifier _authNotifier;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _authNotifier = AuthChangeNotifier();

    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: _authNotifier,
      redirect: (BuildContext? context, GoRouterState state) {
        final user = FirebaseAuth.instance.currentUser;
        final isLoginLocation = state.uri.toString() == '/' || state.uri.toString() == '/login';

        if (user == null && !isLoginLocation) {
          return '/';
        }

        if (user != null && isLoginLocation) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (BuildContext context, GoRouterState state) => HomePage(),
        ),
        GoRoute(
          path: '/',
          name: 'login',
          builder: (BuildContext context, GoRouterState state) => LoginPage(),
        ),
        GoRoute(
          path: '/crear',
          name: 'crear',
          builder: (BuildContext context, GoRouterState state) => CrearHabitoPage(),
        ),
        GoRoute(
       path: '/editar/:id', 
       name: 'editar',
       builder: (BuildContext context, GoRouterState state) {
       final habito = state.extra as Habito; 
       return EditView(habito: habito);
  },
),

      ],
    );
  }

  @override
  void dispose() {
    _authNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'Todo - App',
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}