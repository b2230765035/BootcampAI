import 'package:bootcamp175/config/material/icons/main_icons.dart';
import 'package:bootcamp175/config/material/themes/text_themes.dart';
import 'package:bootcamp175/core/extensions/sizes.dart';
import 'package:bootcamp175/production/presentation/bloc/classroom_bloc/classroom_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentUsers extends StatefulWidget {
  const CurrentUsers({super.key});

  @override
  State<CurrentUsers> createState() => _CurrentUsersState();
}

class _CurrentUsersState extends State<CurrentUsers> {
  @override
  Widget build(BuildContext context) {
    double width = context.getWidth();
    double height = context.getHeigth();
    return BlocBuilder<ClassroomBloc, ClassroomState>(
      builder: (context, state) {
        if (state is GetClassroomDataOfUserDone ||
            state is SearchUsersLoading ||
            state is SearchUsersDone ||
            state is SearchUsersError) {
          return OutlinedButton(
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Center(child: Text("Üyeler")),
                    content: Container(
                      height: height / 3,
                      width: 400,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text("Resim")),
                            DataColumn(label: Text("Kullanıcı Adı")),
                            DataColumn(label: Text("Rol")),
                          ],
                          rows: state.data["roomData"].currentUsers
                              .map<DataRow>((user) {
                                return DataRow(
                                  cells: [
                                    DataCell(MainIcons.profileIcon4),
                                    DataCell(
                                      Text(
                                        user.username,
                                        style: CustomTextStyles.secondaryStyle,
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        user.role,
                                        style: CustomTextStyles.secondaryStyle,
                                      ),
                                    ),
                                  ],
                                );
                              })
                              .toList(),
                        ),
                      ),
                    ),
                    actions: [],
                  );
                },
              );
            },
            child: Text("Kullanıcılar", style: CustomTextStyles.messageStyle2),
          );
        } else {
          return OutlinedButton(
            onPressed: () {},
            child: Text("Kullanıcılar", style: CustomTextStyles.messageStyle2),
          );
        }
      },
    );
  }
}
