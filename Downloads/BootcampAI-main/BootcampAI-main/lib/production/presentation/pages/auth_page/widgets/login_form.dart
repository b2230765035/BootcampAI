import 'package:bootcamp175/config/material/colors/main_colors.dart';
import 'package:bootcamp175/config/material/themes/text_themes.dart';
import 'package:bootcamp175/config/variables/doubles/main_doubles.dart';
import 'package:bootcamp175/config/variables/strings/auth_strings.dart';
import 'package:bootcamp175/core/extensions/sizes.dart';
import 'package:bootcamp175/production/data/models/user_model.dart';
import 'package:bootcamp175/production/presentation/bloc/user_bloc/user_bloc_bloc.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _loginFormKey = GlobalKey<FormState>();

  final TextEditingController _emailControllerLogin = TextEditingController();

  final TextEditingController _passwordControllerLogin =
      TextEditingController();

  RegExp get _specialCharRegex => RegExp(r"^[\p{L}\p{N}]+$", unicode: true);

  late bool _passwordVisible;

  @override
  void initState() {
    _passwordVisible = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double phoneWidth = context.getWidth();
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          TextFormField(
            style: CustomTextStyles.primaryStyle,
            controller: _emailControllerLogin,
            validator: (value) {
              if (value != null) {
                if (value.isEmpty) {
                  return AuthStrings.errorText1;
                } else if (!EmailValidator.validate(value)) {
                  return AuthStrings.errorText4;
                }
              }
              return null;
            },
            scrollPadding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: InputDecoration(
              constraints: BoxConstraints(
                minWidth: AuthPageSizes.txtFormFieldWidth,
                maxWidth: AuthPageSizes.txtFormFieldWidth,
                maxHeight: AuthPageSizes.txtFormFieldMaxHeight,
                minHeight: AuthPageSizes.txtFormFieldMinHeight,
              ),
              hintStyle: CustomTextStyles.secondaryStyle,
              hintText: AuthStrings.txtFormField3Hint,
              border: const OutlineInputBorder(),
            ),
          ),
          SizedBox(height: MarginSizes.loginMargin2),
          TextFormField(
            obscureText: _passwordVisible,
            style: CustomTextStyles.primaryStyle,
            controller: _passwordControllerLogin,
            validator: (value) {
              if (value != null) {
                if (value.isEmpty) {
                  return AuthStrings.errorText1;
                } else if (value.length <= 6) {
                  return AuthStrings.errorText2;
                } else if (!_specialCharRegex.hasMatch(value)) {
                  return AuthStrings.errorText3;
                }
              }
              return null;
            },
            scrollPadding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: InputDecoration(
              constraints: BoxConstraints(
                minWidth: AuthPageSizes.txtFormFieldWidth,
                maxWidth: AuthPageSizes.txtFormFieldWidth,
                maxHeight: AuthPageSizes.txtFormFieldMaxHeight,
                minHeight: AuthPageSizes.txtFormFieldMinHeight,
              ),
              hintStyle: CustomTextStyles.secondaryStyle,
              hintText: AuthStrings.txtFormField2Hint,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: MainColors.secondaryTextColor,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: MarginSizes.loginMargin3),
          Container(
            width: phoneWidth,
            constraints: const BoxConstraints(maxWidth: 500),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(
                  MainColors.bgColor3,
                ),
              ),
              onPressed: () {
                if (_loginFormKey.currentState!.validate()) {
                  UserModel user = UserModel(mail: _emailControllerLogin.text);
                  BlocProvider.of<UserBlocBloc>(context).add(
                    LoginRequest(
                      user: user,
                      password: _passwordControllerLogin.text,
                    ),
                  );
                }
              },
              child: Text(
                AuthStrings.loginButtonText,
                style: CustomTextStyles.primaryStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
