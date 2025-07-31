import 'package:bootcamp175/production/presentation/bloc/classroom_bloc/classroom_bloc.dart';
import 'package:bootcamp175/production/presentation/bloc/user_bloc/user_bloc_bloc.dart';
import 'package:bootcamp175/production/presentation/pages/auth_page/auth_page.dart';
import 'package:bootcamp175/production/presentation/pages/classroom_page/classroom_page.dart';
import 'package:bootcamp175/production/presentation/pages/main_page/main_page.dart';
import 'package:bootcamp175/production/presentation/pages/notes_and_homeworks_page/notes_and_homeworks_page.dart';
import 'package:bootcamp175/production/presentation/pages/settings_page/settings_page.dart';
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
    return MaterialApp(
      builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider<UserBlocBloc>(create: (context) => UserBlocBloc()),
          BlocProvider<ClassroomBloc>(create: (context) => ClassroomBloc()),
        ],
        child: child!,
      ),
      initialRoute: "/auth",
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/auth') {
          return MaterialPageRoute(builder: (context) => const AuthPage());
        } else if (settings.name == '/main') {
          return MaterialPageRoute(builder: (context) => const MainPage());
        } else if (settings.name == "/settings") {
          return MaterialPageRoute(builder: (context) => const SettingsPage());
        } else if (settings.name == '/classroom_main') {
          final args = settings.arguments as Map<String, dynamic>;
          final roomName = args['roomName'];
          return MaterialPageRoute(
            builder: (context) => ClassroomPage(roomName: roomName),
          );
        } else if (settings.name == '/notes_and_homeworks') {
          return MaterialPageRoute(
            builder: (context) => const NotesAndHomeworksPage(),
          );
        }
        return null; // Add default case or return null
      },
      debugShowCheckedModeBanner: false,
      title: 'BootCamp175',
    );
  }
}
