import 'package:bootcamp175/config/material/colors/main_colors.dart';
import 'package:bootcamp175/config/material/icons/main_icons.dart';
import 'package:bootcamp175/config/material/themes/text_themes.dart';
import 'package:bootcamp175/config/variables/doubles/main_doubles.dart';
import 'package:bootcamp175/core/extensions/sizes.dart';
import 'package:bootcamp175/production/presentation/bloc/user_bloc/user_bloc_bloc.dart';
import 'package:bootcamp175/production/presentation/pages/main_page/socials_widgets/classes_page.dart';
import 'package:bootcamp175/production/presentation/pages/main_page/socials_widgets/friends_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  int _currentIndexBottomNavbar = 0;

  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: _currentIndex);

    super.initState();
    BlocProvider.of<UserBlocBloc>(context).add(
      GetUserProfilePictureRequest(
        username: BlocProvider.of<UserBlocBloc>(context).state.data.username,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double phoneHeight = context.getHeigth();
    double phoneWidth = context.getWidth();
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: MainColors.bgColor1,
        iconSize: IconSizes.iconSizeS,
        selectedIconTheme: IconThemeData(color: MainColors.primaryTextColor),
        unselectedIconTheme: IconThemeData(
          color: MainColors.secondaryTextColor,
        ),
        currentIndex: _currentIndexBottomNavbar,
        items: [
          BottomNavigationBarItem(icon: MainIcons.mainIcon, label: ""),
          BottomNavigationBarItem(icon: MainIcons.questionIcon, label: ""),
          BottomNavigationBarItem(icon: MainIcons.profileIcon4, label: ""),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: phoneHeight * 0.35,
                width: phoneWidth,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/images/gradient4.png"),
                  ),
                ),
                child: Wrap(
                  spacing: 15,
                  direction: Axis.vertical,
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      BlocProvider.of<UserBlocBloc>(
                        context,
                      ).state.data!.username,
                      style: CustomTextStyles.primaryHeaderStyle,
                    ),
                    Text(
                      "3 minutes old",
                      style: CustomTextStyles.secondaryStyle,
                    ),
                    BlocBuilder<UserBlocBloc, UserBlocState>(
                      builder: (context, state) {
                        if (state is ProfilePictureDone) {
                          return SizedBox(
                            width: 150,
                            height: 130,
                            child: CircleAvatar(
                              backgroundImage: MemoryImage(state.image),
                            ),
                          );
                        } else {
                          return SizedBox(
                            width: 150,
                            height: 130,
                            child: CircleAvatar(
                              backgroundColor: MainColors.bgColor3,
                              child: MainIcons.profileIcon3,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              Container(
                color: MainColors.bgColor1,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            child: TextButton(
                              child: Center(
                                child: Text(
                                  "Sınıflar",
                                  style: CustomTextStyles.primaryHeaderStyle2,
                                ),
                              ),
                              onPressed: () {
                                _controller.animateToPage(
                                  0,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              child: Center(
                                child: Text(
                                  "Arkadaşlar",
                                  style: CustomTextStyles.primaryHeaderStyle2,
                                ),
                              ),
                              onPressed: () {
                                _controller.animateToPage(
                                  1,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: phoneWidth,
                      height: 30,
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 200),
                            left: _currentIndex == 0
                                ? (phoneWidth / 4) - 15
                                : (phoneWidth * 3 / 4) - 15,
                            child: Container(
                              width: 30,
                              height: 2,
                              decoration: BoxDecoration(
                                color: MainColors.accentColor,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(219, 238, 167, 0.8),
                                    blurRadius: 7,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (int newIndex) {
                    setState(() {
                      _currentIndex = newIndex;
                    });
                  },
                  children: const [ClassesPage(), FriendsPage()],
                ),
              ),
            ],
          ),
          Positioned(
            top: 50,
            right: 5,
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
    );
  }
}


/*
BlocListener<UserBlocBloc, UserBlocState>(
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

 */