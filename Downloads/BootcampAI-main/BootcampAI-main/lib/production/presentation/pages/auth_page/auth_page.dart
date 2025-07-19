import 'package:bootcamp175/config/material/colors/main_colors.dart';
import 'package:bootcamp175/config/material/paddings/main_paddings.dart';
import 'package:bootcamp175/config/material/themes/text_themes.dart';
import 'package:bootcamp175/config/variables/doubles/main_doubles.dart';
import 'package:bootcamp175/config/variables/strings/auth_strings.dart';
import 'package:bootcamp175/core/extensions/sizes.dart';
import 'package:bootcamp175/production/presentation/bloc/user_bloc/user_bloc_bloc.dart';
import 'package:bootcamp175/production/presentation/pages/auth_page/widgets/login_form.dart';
import 'package:bootcamp175/production/presentation/pages/auth_page/widgets/register_form.dart';
import 'package:bootcamp175/production/presentation/widgets/loading_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoginPage = true;

  @override
  void initState() {
    BlocProvider.of<UserBlocBloc>(context).add(const IsAuthenticatedRequest());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double phoneWidth = context.getWidth();
    double phoneHeigth = context.getHeigth();
    return Scaffold(
      body: BlocConsumer<UserBlocBloc, UserBlocState>(
        listener: (context, state) {
          BuildContext dialogContext = context;
          switch (state) {
            //Checking first if user already authenticated. If so navigate.
            case IsAuthenticatedLoading():
              showDialog(
                context: context,
                builder: (context) {
                  dialogContext = context;
                  return const LoadingDialog();
                },
              );
              break;
            case IsAuthenticatedDone():
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
              Navigator.of(context).pushReplacementNamed("/main");
              break;
            case IsAuthenticatedError():
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            //User Login-Register Request
            case UserBlocLoading():
              showDialog(
                context: context,
                builder: (context) {
                  dialogContext = context;
                  return const LoadingDialog();
                },
              );
              break;
            case UserBlocDone():
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
              Navigator.of(context).pushReplacementNamed("/main");
              break;
            case UserBlocError():
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Failed"),
                    content: Text(state.error!),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
              break;
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  height: phoneHeigth,
                  width: phoneWidth,
                  decoration: BoxDecoration(gradient: SideColors.authGradient),
                  child: Padding(
                    padding: MainPaddings.padding3,
                    child: Column(
                      children: [
                        Container(
                          width: IconSizes.authIconSize,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(90)),
                          ),
                          child: Image.asset(AuthStrings.logoUrl),
                        ),
                        SizedBox(height: MarginSizes.loginMargin2),
                        Text(
                          AuthStrings.logoName,
                          style: CustomTextStyles.primaryHeaderStyleLogin,
                        ),
                        SizedBox(height: MarginSizes.loginMargin1),
                        Text(
                          AuthStrings.logoSubText,
                          style: CustomTextStyles.primaryHeaderStyle,
                        ),
                        Container(
                          width: AuthPageSizes.authFormSize,
                          height: 1,
                          margin: const EdgeInsets.fromLTRB(0, 25, 0, 40),
                          color: MainColors.primaryTextColor,
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          transitionBuilder: (child, animation) {
                            const begin = Offset(4.0, 0.0);
                            const end = Offset.zero;
                            final tween = Tween(begin: begin, end: end);
                            final offsetAnimation = animation.drive(tween);
                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                          child: _isLoginPage
                              ? const LoginForm()
                              : const RegisterForm(),
                        ),
                        Container(
                          width: AuthPageSizes.authFormSize,
                          height: 1,
                          margin: const EdgeInsets.fromLTRB(0, 25, 0, 10),
                          color: MainColors.primaryTextColor,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AuthStrings.goToPage,
                              style: CustomTextStyles.secondaryStyleLogin2,
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLoginPage = !_isLoginPage;
                                });
                              },
                              child: Text(
                                _isLoginPage
                                    ? AuthStrings.goToRegisterPage
                                    : AuthStrings.goToLoginPage,
                                style: CustomTextStyles.secondaryStyleLogin1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
