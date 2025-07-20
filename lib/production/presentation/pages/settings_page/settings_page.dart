import 'package:bootcamp175/production/presentation/bloc/user_bloc/user_bloc_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
