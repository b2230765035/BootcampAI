import 'package:bootcamp175/production/presentation/bloc/user_bloc_bloc.dart';
import 'package:bootcamp175/production/presentation/pages/auth_page/auth_page.dart';
import 'package:bootcamp175/production/presentation/pages/main/main_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBlocBloc>(create: (context) => UserBlocBloc()),
      ],
      child: MaterialApp(
        initialRoute: "/auth",
        routes: {
          "/auth": (context) => const AuthPage(),
          "/main": (context) => const MainPage(),
        },
        debugShowCheckedModeBanner: false,
        title: 'BootCamp175',
      ),
    );
  }
}
