import 'package:bootcamp175/production/presentation/bloc/user_bloc_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<UserBlocBloc, UserBlocState>(
        listener: (context, state) {
          if (state is UserBlocLogout) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil("/auth", (Route<dynamic> route) => false);
          }
        },
        child: Center(
          child: Container(
            child: TextButton(
              onPressed: () {
                BlocProvider.of<UserBlocBloc>(
                  context,
                ).add(const LogoutRequest());
              },
              child: Text("Çıkış Yap"),
            ),
          ),
        ),
      ),
    );
  }
}
