import 'package:bootcamp175/config/material/colors/main_colors.dart';
import 'package:bootcamp175/config/material/icons/main_icons.dart';
import 'package:bootcamp175/config/material/themes/text_themes.dart';
import 'package:bootcamp175/config/variables/doubles/main_doubles.dart';
import 'package:bootcamp175/core/extensions/sizes.dart';
import 'package:bootcamp175/production/presentation/pages/notes_and_homeworks_page/widgets/homeworks_page.dart';
import 'package:bootcamp175/production/presentation/pages/notes_and_homeworks_page/widgets/notes_page.dart';
import 'package:flutter/material.dart';

class NotesAndHomeworksPage extends StatefulWidget {
  const NotesAndHomeworksPage({super.key});

  @override
  State<NotesAndHomeworksPage> createState() => _NotesAndHomeworksPageState();
}

class _NotesAndHomeworksPageState extends State<NotesAndHomeworksPage> {
  int _currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: _currentIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double phoneHeight = context.getHeigth();
    double phoneWidth = context.getWidth();
    return Scaffold(
      body: Container(
        color: MainColors.bgColor1,
        child: Stack(
          children: [
            SafeArea(
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
                                "Ödevler",
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
                                "Ders Notları",
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
                  Expanded(
                    child: PageView(
                      controller: _controller,
                      onPageChanged: (int newIndex) {
                        setState(() {
                          _currentIndex = newIndex;
                        });
                      },
                      children: const [NotesPage(), HomeworksPage()],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 50,
              left: 5,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: MainIcons.leftArrow,
                iconSize: IconSizes.iconSizeS,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
