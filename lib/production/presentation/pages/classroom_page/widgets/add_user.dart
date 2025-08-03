import 'package:bootcamp175/config/material/colors/main_colors.dart';
import 'package:bootcamp175/config/material/icons/main_icons.dart';
import 'package:bootcamp175/config/material/themes/text_themes.dart';
import 'package:bootcamp175/core/extensions/sizes.dart';
import 'package:bootcamp175/production/presentation/bloc/classroom_bloc/classroom_bloc.dart';
import 'package:bootcamp175/production/presentation/bloc/user_bloc/user_bloc_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AddUser extends StatefulWidget {
  String roomName;
  AddUser({required this.roomName, super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  @override
  Widget build(BuildContext context) {
    double width = context.getWidth();
    double height = context.getHeigth();
    return BlocConsumer<ClassroomBloc, ClassroomState>(
      listener: (context, state) {
        if (state is SendInvitationDone) {
          BlocProvider.of<ClassroomBloc>(context).add(
            GetClassroomDataOfUser(
              roomName: widget.roomName,
              user: BlocProvider.of<UserBlocBloc>(context).state.data,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is GetClassroomDataOfUserDone ||
            state is SearchUsersLoading ||
            state is SearchUsersDone ||
            state is SendInvitationLoading ||
            state is SendInvitationDone ||
            state is SendInvitationError) {
          if (state.data["foundUser"].role == "Student") {
            return Text("");
          } else if (state.data["foundUser"].role == "Teacher") {
            return OutlinedButton(
              onPressed: () async {
                TextEditingController form = TextEditingController();
                BlocProvider.of<ClassroomBloc>(
                  context,
                ).state.data["searchUsers"] = [];
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Colors.blue[200],
                      title: Center(
                        child: Text(
                          "Kullanıcı Ekle",
                          style: GoogleFonts.montserratAlternates(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                            decorationThickness: 0,
                            letterSpacing: 0.75,
                          ),
                        ),
                      ),
                      content: Container(
                        height: height * 2 / 5,
                        width: width,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: form,
                              style: GoogleFonts.montserratAlternates(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none,
                                decorationThickness: 0,
                                letterSpacing: 0.75,
                              ),
                              decoration: InputDecoration(
                                hintStyle: CustomTextStyles.secondaryStyle,
                                hintText: "kullanıcı_adı",
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  BlocProvider.of<ClassroomBloc>(
                                    context,
                                  ).add(SearchUsers(username: value));
                                }
                              },
                            ),
                            BlocBuilder<ClassroomBloc, ClassroomState>(
                              builder: (context, state) {
                                if (state is SearchUsersLoading) {
                                  return Text("Kullanıcılar Yükleniyor");
                                } else if (state is SearchUsersDone) {
                                  return Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minWidth: MediaQuery.of(
                                            context,
                                          ).size.width,
                                        ),

                                        child: DataTable(
                                          headingTextStyle: CustomTextStyles
                                              .secondaryStyleBold,

                                          columns: const [
                                            DataColumn(label: Text("Resim")),
                                            DataColumn(
                                              label: Text("Kullanıcı Adı"),
                                            ),
                                            DataColumn(label: Text("Durum")),
                                          ],
                                          rows: state.data["searchUsers"].map<DataRow>((
                                            user,
                                          ) {
                                            bool alreadyInvited = false;
                                            bool alreadyAccepted = false;
                                            bool alreadyRejected = false;

                                            for (var pendingInvite
                                                in state
                                                    .data["roomData"]
                                                    .pendingUsers) {
                                              if (pendingInvite["invitedUser"] ==
                                                      user.username &&
                                                  pendingInvite["status"] ==
                                                      "pending") {
                                                alreadyInvited = true;
                                              }
                                            }

                                            for (var users
                                                in state
                                                    .data["roomData"]
                                                    .currentUsers) {
                                              if (users.username ==
                                                  user.username) {
                                                alreadyAccepted = true;
                                              }
                                            }

                                            for (var users
                                                in state
                                                    .data["roomData"]
                                                    .rejectedUsers) {
                                              if (users["username"] ==
                                                  user.username) {
                                                alreadyRejected = true;
                                              }
                                            }

                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  MainIcons.profileIcon4,
                                                ),
                                                DataCell(
                                                  Text(
                                                    user.username,
                                                    style: CustomTextStyles
                                                        .secondaryStyle,
                                                  ),
                                                ),
                                                DataCell(
                                                  OutlinedButton(
                                                    style: OutlinedButton.styleFrom(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 4,
                                                          ),
                                                    ),
                                                    onPressed:
                                                        alreadyInvited ||
                                                            alreadyAccepted
                                                        ? null
                                                        : () {
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
                                                                    user,
                                                              ),
                                                            );
                                                          },
                                                    child: Text(
                                                      alreadyInvited
                                                          ? "Davet Edildi"
                                                          : alreadyAccepted
                                                          ? "Sınıfa Kayıtlı"
                                                          : alreadyRejected
                                                          ? "Davet Reddedildi\nTekrar Davet Gönder"
                                                          : "Davet Gönder",
                                                      style: alreadyInvited
                                                          ? CustomTextStyles
                                                                .secondaryStyleOrange
                                                          : alreadyAccepted
                                                          ? CustomTextStyles
                                                                .secondaryStyleGreen
                                                          : alreadyRejected
                                                          ? CustomTextStyles
                                                                .secondaryStyleRed
                                                          : CustomTextStyles
                                                                .secondaryStyle,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (state is SearchUsersError) {
                                  return Text(
                                    "Bu İsime Sahip Kullanıcı Bulunamadı",
                                  );
                                }
                                return Text("");
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
        } else {
          return Text("");
        }
      },
    );
  }
}
