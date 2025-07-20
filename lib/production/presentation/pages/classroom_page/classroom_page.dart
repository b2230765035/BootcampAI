import 'package:bootcamp175/config/material/colors/main_colors.dart';
import 'package:bootcamp175/config/material/icons/main_icons.dart';
import 'package:bootcamp175/config/material/themes/text_themes.dart';
import 'package:bootcamp175/config/variables/doubles/main_doubles.dart';
import 'package:bootcamp175/core/extensions/sizes.dart';
import 'package:bootcamp175/production/data/models/user_public_profile_model.dart';
import 'package:bootcamp175/production/presentation/bloc/classroom_bloc/classroom_bloc.dart';
import 'package:bootcamp175/production/presentation/bloc/user_bloc/user_bloc_bloc.dart';
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
      body: Container(
        width: width,
        height: height,
        color: MainColors.bgColor3,
        child: Stack(
          children: [
            Positioned(
              top: 50,
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
              top: 50,
              child: Column(
                children: [
                  SizedBox(height: 50),
                  SizedBox(
                    width: context.getWidth(),
                    child: Center(
                      child: Text(
                        widget.roomName,
                        style: CustomTextStyles.primaryHeaderStyle,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: context.getWidth(),
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
                              "Rol : ${state.data["foundUser"].role}",
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
                    onPressed: () {},

                    child: Text(
                      "Ödevler",
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
                      OutlinedButton(
                        onPressed: () {},
                        child: Text(
                          "Kullanıcılar",
                          style: CustomTextStyles.messageStyle2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  BlocBuilder<ClassroomBloc, ClassroomState>(
                    builder: (context, state) {
                      if (state is GetClassroomDataOfUserDone ||
                          state is SearchUsersLoading ||
                          state is SearchUsersDone ||
                          state is SendInvitationLoading ||
                          state is SendInvitationDone ||
                          state is SendInvitationError) {
                        return OutlinedButton(
                          onPressed: () async {
                            TextEditingController form =
                                TextEditingController();
                            BlocProvider.of<ClassroomBloc>(
                              context,
                            ).state.data["searchUsers"] = "";
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Kullanıcı Ekle"),
                                  content: Container(
                                    height: height / 3,
                                    width: 400,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: form,
                                          decoration: InputDecoration(
                                            labelText: "Kullanıcı Adı",
                                          ),
                                          onChanged: (value) {
                                            if (value.isNotEmpty) {
                                              BlocProvider.of<ClassroomBloc>(
                                                context,
                                              ).add(
                                                SearchUsers(username: value),
                                              );
                                            }
                                          },
                                        ),
                                        BlocBuilder<
                                          ClassroomBloc,
                                          ClassroomState
                                        >(
                                          builder: (context, state) {
                                            if (state is SearchUsersLoading) {
                                              return Text(
                                                "Kullanıcılar Yükleniyor",
                                              );
                                            } else if (state
                                                is SearchUsersDone) {
                                              return Container(
                                                height: height / 3 - 100,
                                                width: 350,

                                                child: ListView.builder(
                                                  itemCount: state
                                                      .data["searchUsers"]
                                                      .length,
                                                  itemBuilder: (context, index) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8.0,
                                                          ),
                                                      child: Container(
                                                        width: 300,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            MainIcons
                                                                .profileIcon4,
                                                            Text(
                                                              "${state.data["searchUsers"][index].username}",
                                                              style: CustomTextStyles
                                                                  .secondaryStyle,
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                BlocProvider.of<ClassroomBloc>(
                                                                  context,
                                                                ).add(
                                                                  SendInvitation(
                                                                    roomName: widget
                                                                        .roomName,
                                                                    requestOwner:
                                                                        BlocProvider.of<
                                                                              UserBlocBloc
                                                                            >(context)
                                                                            .state
                                                                            .data,
                                                                    requestUser:
                                                                        state
                                                                            .data["searchUsers"][index],
                                                                  ),
                                                                );
                                                              },
                                                              child: Text(
                                                                "Davet Gönder",
                                                                style: CustomTextStyles
                                                                    .secondaryStyle,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            } else if (state
                                                is SearchUsersError) {
                                              return Text(
                                                "Bu İsime Sahip Kullanıcı Bulunamadı",
                                              );
                                            }
                                            return Text("Kullanıcılar");
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Kapat"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },

                          child: Text(
                            "Kullanıcı Ekle",
                            style: CustomTextStyles.messageStyle2,
                          ),
                        );
                      } else {
                        return Text("");
                      }
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              top: 50,
              right: 10,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).popAndPushNamed("/settings");
                },
                icon: MainIcons.settingsIcon,
                iconSize: IconSizes.iconSizeS,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
