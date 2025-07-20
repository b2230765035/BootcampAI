import 'package:bootcamp175/config/material/colors/main_colors.dart';
import 'package:bootcamp175/config/material/icons/main_icons.dart';
import 'package:bootcamp175/config/material/themes/text_themes.dart';
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
    // TODO: implement initState
    BlocProvider.of<ClassroomBloc>(context).add(GetAllJoinedClassroom());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          case CreateClassroomDone():
            BlocProvider.of<ClassroomBloc>(
              context,
            ).add(GetAllJoinedClassroom());

            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
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
                if (state is GetAllJoinedClassroomError) {
                  return Positioned(
                    top: 20,
                    left: 10,
                    child: Text("Kayılı Sınıf Bulunamadı"),
                  );
                } else if (state is GetAllJoinedClassroomLoading) {
                  return Positioned(
                    top: 20,
                    left: 10,
                    child: Text("Sınıflar Yükleniyor"),
                  );
                } else if (state is GetAllJoinedClassroomDone) {
                  return ListView.builder(
                    itemCount: state.data.length,
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
                                    state.data[state.data.length - index - 1],
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
                                    state.data[state.data.length - index - 1],
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
                  return Positioned(
                    top: 20,
                    left: 10,
                    child: Text("Başka state"),
                  );
                }
              },
            ),

            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () {
                  //open the invitations popup
                },
                icon: MainIcons.bellIcon,
                color: MainColors.bgColor1,
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
