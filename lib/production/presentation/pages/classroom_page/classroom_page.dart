import 'package:bootcamp175/config/material/colors/main_colors.dart';
import 'package:bootcamp175/config/material/icons/main_icons.dart';
import 'package:bootcamp175/config/material/themes/text_themes.dart';
import 'package:bootcamp175/config/variables/doubles/main_doubles.dart';
import 'package:bootcamp175/core/extensions/sizes.dart';
import 'package:bootcamp175/production/data/models/user_public_profile_model.dart';
import 'package:bootcamp175/production/presentation/bloc/classroom_bloc/classroom_bloc.dart';
import 'package:bootcamp175/production/presentation/bloc/user_bloc/user_bloc_bloc.dart';
import 'package:bootcamp175/production/presentation/pages/classroom_page/widgets/add_user.dart';
import 'package:bootcamp175/production/presentation/pages/classroom_page/widgets/current_users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClassroomPage extends StatefulWidget {
  String roomName;
  ClassroomPage({required this.roomName, super.key});

  @override
  State<ClassroomPage> createState() => _ClassroomPageState();
}

class _ClassroomPageState extends State<ClassroomPage> {
  @override
  void initState() {
    BlocProvider.of<ClassroomBloc>(context).add(
      GetClassroomDataOfUser(
        roomName: widget.roomName,
        user: BlocProvider.of<UserBlocBloc>(context).state.data,
      ),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = context.getWidth();
    double height = context.getHeigth();
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: width,
          height: height,
          color: MainColors.bgColor3,
          child: Stack(
            children: [
              Positioned(
                top: 20,
                left: 10,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed("/main");
                  },
                  icon: MainIcons.leftArrow,
                  iconSize: IconSizes.iconSizeS,
                  color: MainColors.accentColor,
                ),
              ),
              Positioned(
                top: 20,
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    SizedBox(
                      width: width,
                      child: Center(
                        child: Text(
                          widget.roomName,
                          style: CustomTextStyles.primaryHeaderStyle,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: BlocBuilder<ClassroomBloc, ClassroomState>(
                        builder: (context, state) {
                          if (state is GetClassroomDataOfUserDone ||
                              state is SearchUsersLoading ||
                              state is SearchUsersDone ||
                              state is SendInvitationLoading ||
                              state is SendInvitationDone ||
                              state is SendInvitationError) {
                            return Center(
                              child: Text(
                                "Rol : ${state.data["foundUser"].role == "Teacher" ? "Öğretmen" : "Öğrenci"}",
                                style: CustomTextStyles.primaryHeaderStyle,
                              ),
                            );
                          } else {
                            return Center(
                              child: Text(
                                "Rol : Student",
                                style: CustomTextStyles.primaryHeaderStyle,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 100),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed("/notes_and_homeworks");
                      },

                      child: Text(
                        "Ödevler ve Ders Notları",
                        style: CustomTextStyles.messageStyle2,
                      ),
                    ),
                    SizedBox(height: 50),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {},
                          child: Text(
                            "Canlı Sohbet",
                            style: CustomTextStyles.messageStyle2,
                          ),
                        ),
                        SizedBox(width: 50),
                        CurrentUsers(),
                      ],
                    ),
                    SizedBox(height: 50),
                    AddUser(roomName: widget.roomName),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                right: 10,
                child: IconButton(
                  onPressed: () {},
                  icon: MainIcons.settingsIcon,
                  iconSize: IconSizes.iconSizeS,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
