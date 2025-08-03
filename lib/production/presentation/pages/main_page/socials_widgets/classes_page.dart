import 'package:bootcamp175/config/material/colors/main_colors.dart';
import 'package:bootcamp175/config/material/icons/main_icons.dart';
import 'package:bootcamp175/config/material/themes/text_themes.dart';
import 'package:bootcamp175/core/extensions/sizes.dart';
import 'package:bootcamp175/production/data/models/user_public_profile_model.dart';
import 'package:bootcamp175/production/presentation/bloc/classroom_bloc/classroom_bloc.dart';
import 'package:bootcamp175/production/presentation/bloc/user_bloc/user_bloc_bloc.dart';
import 'package:bootcamp175/production/presentation/widgets/loading_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClassesPage extends StatefulWidget {
  const ClassesPage({super.key});

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  @override
  void initState() {
    BlocProvider.of<ClassroomBloc>(context).add(GetAllJoinedClassroom());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = context.getWidth();
    double height = context.getHeigth();
    return BlocListener<ClassroomBloc, ClassroomState>(
      listener: (BuildContext context, ClassroomState state) {
        BuildContext dialogContext = context;
        switch (state) {
          case CreateClassroomLoading():
            showDialog(
              context: context,
              builder: (context) {
                dialogContext = context;
                return const LoadingDialog();
              },
            );
            break;
          case UserActionClassroomInviteLoading():
            showDialog(
              context: context,
              builder: (context) {
                dialogContext = context;
                return const LoadingDialog();
              },
            );
            break;
          case CreateClassroomDone():
            BlocProvider.of<ClassroomBloc>(
              context,
            ).add(GetAllJoinedClassroom());

            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
            break;
          case UserActionClassroomInviteDone():
            BlocProvider.of<ClassroomBloc>(
              context,
            ).add(GetAllJoinedClassroom());
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
            break;
          case UserActionClassroomInviteError():
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Hata"),
                  content: Text(state.error!),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Kapat'),
                    ),
                  ],
                );
              },
            );
            break;
          case CreateClassroomError():
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Hata"),
                  content: Text(state.error!),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Kapat'),
                    ),
                  ],
                );
              },
            );
            break;
        }
      },
      child: Container(
        color: MainColors.bgColor3,
        child: Stack(
          children: [
            BlocBuilder<ClassroomBloc, ClassroomState>(
              builder: (context, state) {
                if (state is GetAllJoinedClassroomDone &&
                    state.data["joinedClassrooms"].isEmpty) {
                  return Positioned(
                    top: 20,
                    left: 10,
                    child: Text(
                      "Kayıtlı Sınıf Bulunamadı",
                      style: CustomTextStyles.primaryStyle,
                    ),
                  );
                } else if (state is GetAllJoinedClassroomLoading) {
                  return Positioned(
                    top: 20,
                    left: 10,
                    child: Text(
                      "Sınıflar Yükleniyor",
                      style: CustomTextStyles.primaryStyle,
                    ),
                  );
                } else if (state is GetAllJoinedClassroomDone) {
                  return ListView.builder(
                    itemCount: state.data["joinedClassrooms"].length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsetsGeometry.all(5),
                        child: InkWell(
                          onTap: () {
                            //Navigate to Classroom using the name
                            Navigator.of(context).pushReplacementNamed(
                              "/classroom_main",
                              arguments: {
                                "roomName":
                                    state.data["joinedClassrooms"][state
                                            .data["joinedClassrooms"]
                                            .length -
                                        index -
                                        1],
                              },
                            );
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MainIcons.publicRoomIcon,
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.data["joinedClassrooms"][state
                                            .data["joinedClassrooms"]
                                            .length -
                                        index -
                                        1],
                                    style: CustomTextStyles.primaryStyle,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Kullanıcı Sayısı: 0/50",
                                    style: CustomTextStyles.secondaryStyle,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Text("");
                }
              },
            ),

            Positioned(
              top: 10,
              right: 10,
              child: BlocBuilder<ClassroomBloc, ClassroomState>(
                builder: (context, state) {
                  if (state is GetAllJoinedClassroomDone) {
                    bool unansweredInvite = false;
                    for (Map<String, String> pendingInvite
                        in state.data["userData"].receivedClassroomRequests) {
                      if (pendingInvite["status"] == "pending") {
                        unansweredInvite = true;
                      }
                    }
                    return IconButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Sınıf Davetleri"),
                              content: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  height: height / 3,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: DataTable(
                                      headingRowColor:
                                          WidgetStateColor.resolveWith(
                                            (states) => Colors.grey.shade200,
                                          ),
                                      columns: const [
                                        DataColumn(label: Text('Sınıf Adı')),
                                        DataColumn(label: Text('İstek Sahibi')),
                                        DataColumn(label: Text('Durum')),
                                      ],
                                      rows: List<DataRow>.generate(
                                        state
                                            .data["userData"]
                                            .receivedClassroomRequests
                                            .length,
                                        (index) {
                                          final request =
                                              state
                                                  .data["userData"]
                                                  .receivedClassroomRequests[state
                                                      .data["userData"]
                                                      .receivedClassroomRequests
                                                      .length -
                                                  index -
                                                  1];
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                Text(request["roomName"]),
                                              ),
                                              DataCell(
                                                Row(
                                                  children: [
                                                    MainIcons.profileIcon1,
                                                    Text(
                                                      request["requestOwner"],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                request["status"] == "pending"
                                                    ? Row(
                                                        children: [
                                                          OutlinedButton(
                                                            style: OutlinedButton.styleFrom(
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical: 4,
                                                                  ),
                                                            ),
                                                            onPressed: () {
                                                              BlocProvider.of<ClassroomBloc>(
                                                                context,
                                                              ).add(
                                                                UserAcceptClassroomInvite(
                                                                  roomName:
                                                                      request["roomName"],
                                                                  username:
                                                                      BlocProvider.of<
                                                                            ClassroomBloc
                                                                          >(context)
                                                                          .state
                                                                          .data["userData"]
                                                                          .username,
                                                                  requesOwnerUsername:
                                                                      request["requestOwner"],
                                                                ),
                                                              );
                                                            },

                                                            child: Text(
                                                              "Katıl",
                                                              style: CustomTextStyles
                                                                  .secondaryStyle,
                                                            ),
                                                          ),
                                                          SizedBox(width: 8),
                                                          OutlinedButton(
                                                            style: OutlinedButton.styleFrom(
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical: 4,
                                                                  ),
                                                            ),
                                                            onPressed: () {
                                                              BlocProvider.of<ClassroomBloc>(
                                                                context,
                                                              ).add(
                                                                UserRejectClassroomInvite(
                                                                  roomName:
                                                                      request["roomName"],
                                                                  username:
                                                                      BlocProvider.of<
                                                                            ClassroomBloc
                                                                          >(context)
                                                                          .state
                                                                          .data["userData"]
                                                                          .username,
                                                                  requesOwnerUsername:
                                                                      request["requestOwner"],
                                                                ),
                                                              );
                                                            },
                                                            child: Text(
                                                              "Reddet",
                                                              style: CustomTextStyles
                                                                  .secondaryStyle,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : request["status"] ==
                                                          "accepted"
                                                    ? Text(
                                                        "Kabul Edildi",
                                                        style: TextStyle(
                                                          color: Colors.green,
                                                        ),
                                                      )
                                                    : request["status"] ==
                                                          "rejected"
                                                    ? Text(
                                                        "Reddedildi",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      )
                                                    : Text(
                                                        request["status"] ??
                                                            "Bilinmiyor",
                                                      ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text("Kapat"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: unansweredInvite
                          ? MainIcons.bellIcon
                          : MainIcons.bellIconNoNotification,
                      color: MainColors.bgColor1,
                    );
                  } else {
                    return IconButton(
                      onPressed: () {
                        //open the invitations popup
                      },
                      icon: MainIcons.bellIconNoNotification,
                      color: MainColors.bgColor1,
                    );
                  }
                },
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    MainColors.accentColor,
                  ),
                ),
                onPressed: () async {
                  TextEditingController form = TextEditingController();
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Sınıf Oluştur"),
                        content: TextFormField(
                          controller: form,
                          decoration: InputDecoration(labelText: "Sınıf Adı"),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              if (form.text != "") {
                                UserPublicProfileModel user =
                                    UserPublicProfileModel(
                                      username: BlocProvider.of<UserBlocBloc>(
                                        context,
                                      ).state.data.username,
                                      hasProfilePhoto:
                                          BlocProvider.of<UserBlocBloc>(
                                            context,
                                          ).state.data.hasProfilePhoto,
                                    );
                                BlocProvider.of<ClassroomBloc>(context).add(
                                  CreateClassroom(
                                    user: user,
                                    roomName: form.text,
                                  ),
                                );
                              }
                            },
                            child: Text("Oluştur"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  "Sınıfı Oluştur",
                  style: CustomTextStyles.messageStyle2,
                ),
              ),
            ),
            //Skeleton loading eklenebilir
          ],
        ),
      ),
    );
  }
}
