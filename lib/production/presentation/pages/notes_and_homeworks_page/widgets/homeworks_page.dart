import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:bootcamp175/config/material/colors/main_colors.dart';
import 'package:bootcamp175/config/material/themes/text_themes.dart';
import 'package:bootcamp175/config/variables/doubles/main_doubles.dart';
import 'package:bootcamp175/core/extensions/sizes.dart';
import 'package:bootcamp175/production/presentation/bloc/classroom_bloc/classroom_bloc.dart';
import 'package:eyedid_flutter/constants/eyedid_flutter_calibration_option.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_calibration.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_drop.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_status.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:eyedid_flutter/eyedid_flutter.dart';
import 'package:eyedid_flutter/gaze_tracker_options.dart';
import 'package:eyedid_flutter/eyedid_flutter_initialized_result.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_metrics.dart';

class HomeworksPage extends StatefulWidget {
  const HomeworksPage({super.key});

  @override
  State<HomeworksPage> createState() => _HomeworksPageState();
}

class _HomeworksPageState extends State<HomeworksPage> {
  final ValueNotifier<Offset> _gazePositionNotifier = ValueNotifier(
    Offset.zero,
  );
  final ValueNotifier<Color> _gazeColorNotifier = ValueNotifier(Colors.red);
  final ValueNotifier<Offset> _calibrationNextPointNotifier = ValueNotifier(
    Offset.zero,
  );
  final ValueNotifier<double> _calibrationProgressNotifier = ValueNotifier(0.0);
  final ValueNotifier<bool> _isCalibrationModeNotifier = ValueNotifier(false);

  EyedidFlutter _eyedidFlutterPlugin = EyedidFlutter();
  bool _hasCameraPermission = false;
  var _isInitialied = false;
  var _version = 'Unknown';
  var _stateString = "IDLE";
  var _hasCameraPermissionString = "NO_GRANTED";
  var _trackingBtnText = "STOP TRACKING";
  var _showingGaze = false;
  var _isCaliMode = false;
  MaterialColor _gazeColor = Colors.red;
  static const String _licenseKey =
      "dev_z26l60eeow95l9cz3q1c8p5wfsnx87ip8d0yshm0"; // todo: input your license key

  StreamSubscription<dynamic>? _trackingEventSubscription;
  StreamSubscription<dynamic>? _dropEventSubscription;
  StreamSubscription<dynamic>? _statusEventSubscription;
  StreamSubscription<dynamic>? _calibrationEventSubscription;

  double _x = 0.0, _y = 0.0;
  var _nextX = 0.0, _nextY = 0.0, _calibrationProgress = 0.0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    _trackingEventSubscription?.cancel();
    _dropEventSubscription?.cancel();
    _statusEventSubscription?.cancel();
    _calibrationEventSubscription?.cancel();
    super.dispose();
  }

  Future<void> checkCameraPermission() async {
    _hasCameraPermission = await _eyedidFlutterPlugin.checkCameraPermission();

    if (!_hasCameraPermission) {
      _hasCameraPermission = await _eyedidFlutterPlugin
          .requestCameraPermission();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _hasCameraPermissionString = _hasCameraPermission ? "granted" : "denied";
    });
  }

  Future<void> initPlatformState() async {
    await checkCameraPermission();
    if (_hasCameraPermission) {
      String platformVersion;
      try {
        platformVersion = await _eyedidFlutterPlugin.getPlatformVersion();
      } on PlatformException catch (error) {
        print(error);
        platformVersion = 'Failed to get platform version.';
      }

      if (!mounted) return;
      initEyedidPlugin();
      setState(() {
        _version = platformVersion;
      });
    }
  }

  Future<void> initEyedidPlugin() async {
    String requestInitGazeTracker = "failed Request";
    try {
      final options = GazeTrackerOptionsBuilder()
          .setPreset(CameraPreset.vga640x480)
          .setUseGazeFilter(true)
          .setUseBlink(false)
          .setUseUserStatus(false)
          .build();
      final result = await _eyedidFlutterPlugin.initGazeTracker(
        licenseKey: _licenseKey,
        options: options,
      );
      var enable = false;
      var showGaze = false;
      if (result.result) {
        enable = true;
        listenEvents();
        _eyedidFlutterPlugin.startTracking();
      } else if (result.message == InitializedResult.isAlreadyAttempting ||
          result.message == InitializedResult.gazeTrackerAlreadyInitialized) {
        enable = true;
        listenEvents();
        final isTracking = await _eyedidFlutterPlugin.isTracking();
        if (isTracking) {
          showGaze = true;
        }
      }

      setState(() {
        _isInitialied = enable;
        _stateString = "${result.result} : (${result.message})";
        _showingGaze = showGaze;
      });
    } on PlatformException catch (e) {
      requestInitGazeTracker = "Occur PlatformException (${e.message})";
      setState(() {
        _stateString = requestInitGazeTracker;
      });
    }
  }

  void listenEvents() {
    _trackingEventSubscription?.cancel();
    _dropEventSubscription?.cancel();
    _statusEventSubscription?.cancel();
    _calibrationEventSubscription?.cancel();

    // Gaze tracking eventi
    _trackingEventSubscription = _eyedidFlutterPlugin.getTrackingEvent().listen(
      (event) {
        final info = MetricsInfo(event);
        if (info.gazeInfo.trackingState == TrackingState.success) {
          _gazePositionNotifier.value = Offset(
            info.gazeInfo.gaze.x,
            info.gazeInfo.gaze.y,
          );
          _gazeColorNotifier.value = Colors.green;
        } else {
          _gazeColorNotifier.value = Colors.red;
        }
      },
    );

    // Drop event (kullanmadığın için sadece loglama var)
    _dropEventSubscription = _eyedidFlutterPlugin.getDropEvent().listen((
      event,
    ) {
      final info = DropInfo(event);
      debugPrint("Dropped at timestamp: ${info.timestamp}");
    });

    // Status event
    _statusEventSubscription = _eyedidFlutterPlugin.getStatusEvent().listen((
      event,
    ) {
      final info = StatusInfo(event);
      if (info.type == StatusType.start) {
        setState(() {
          _stateString = "start Tracking";
          _showingGaze = true;
        });
      } else {
        setState(() {
          _stateString = "stop Tracking : ${info.errorType?.name}";
          _showingGaze = false;
        });
      }
    });

    // Calibration event
    _calibrationEventSubscription = _eyedidFlutterPlugin
        .getCalibrationEvent()
        .listen((event) {
          final info = CalibrationInfo(event);
          if (info.type == CalibrationType.nextPoint) {
            _calibrationNextPointNotifier.value = Offset(
              info.next!.x,
              info.next!.y,
            );
            _calibrationProgressNotifier.value = 0.0;
            Future.delayed(const Duration(milliseconds: 500), () {
              _eyedidFlutterPlugin.startCollectSamples();
            });
          } else if (info.type == CalibrationType.progress) {
            _calibrationProgressNotifier.value = info.progress!;
          } else if (info.type == CalibrationType.finished) {
            _isCalibrationModeNotifier.value = false;
          } else if (info.type == CalibrationType.canceled) {
            _isCalibrationModeNotifier.value = false;
          }
        });
  }

  void _trackingBtnPressed() {
    if (_isInitialied) {
      if (_trackingBtnText == "START TRACKING") {
        try {
          _eyedidFlutterPlugin.startTracking();
          _trackingBtnText = "STOP TRACKING";
        } on PlatformException catch (e) {
          setState(() {
            _stateString = "Occur PlatformException (${e.message})";
          });
        }
      } else {
        try {
          _eyedidFlutterPlugin.stopTracking();
          _trackingBtnText = "START TRACKING";
        } on PlatformException catch (e) {
          setState(() {
            _stateString = "Occur PlatformException (${e.message})";
          });
        }
      }
      setState(() {
        _trackingBtnText = _trackingBtnText;
      });
    }
  }

  void _calibrationBtnPressed() {
    if (_isInitialied) {
      try {
        _eyedidFlutterPlugin.startCalibration(
          CalibrationMode.five,
          usePreviousCalibration: true,
        );
        _isCalibrationModeNotifier.value = true;
      } on PlatformException catch (e) {
        setState(() {
          _stateString = "Occur PlatformException (${e.message})";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = context.getWidth();
    double height = context.getHeigth();

    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,

          child: DataTable(
            headingRowColor: WidgetStatePropertyAll(MainColors.accentColor),
            headingTextStyle: CustomTextStyles.primaryStyle2,
            dataTextStyle: CustomTextStyles.messageStyle2,
            dataRowColor: WidgetStatePropertyAll(MainColors.accentColor2),
            headingRowHeight: 55,
            border: TableBorder.all(
              borderRadius: BorderRadius.all(Radius.circular(1)),
              color: MainColors.bgColor3,
            ),
            columns: <DataColumn>[
              DataColumn(label: Text("Ödev İsmi")),
              DataColumn(label: Text("Yükleyen Kişi")),
              DataColumn(label: Text("Aksiyonlar")),
              DataColumn(label: Text("Yüklenme Tarihi")),
            ],
            rows: BlocProvider.of<ClassroomBloc>(context).state.data["roomData"].homeworks.reversed.map<DataRow>((
              homework,
            ) {
              DateTime dt = homework["uploadedAt"].toDate();
              String formatted =
                  "${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} – ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
              return DataRow(
                cells: [
                  DataCell(Text(homework["homeworkName"])),
                  DataCell(Text(homework["uploadOwner"])),
                  DataCell(
                    Row(
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.all(4),
                            minimumSize: Size(32, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(
                              color: MainColors.primaryTextColor,
                              width: 1,
                            ),
                          ),
                          onPressed: () {},
                          child: Icon(
                            Icons.remove_red_eye,
                            color: MainColors.primaryTextColor,
                            size: 18,
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.all(4),
                            minimumSize: Size(32, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(
                              color: MainColors.primaryTextColor,
                              width: 1,
                            ),
                          ),
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setState) => Dialog(
                                    insetPadding: EdgeInsets.all(16),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final dialogWidth =
                                            constraints.maxWidth;
                                        final dialogHeight =
                                            constraints.maxHeight;
                                        return Container(
                                          width: dialogWidth,
                                          height: dialogHeight,
                                          child: Stack(
                                            children: [
                                              ValueListenableBuilder<bool>(
                                                valueListenable:
                                                    _isCalibrationModeNotifier,
                                                builder: (context, isCali, _) {
                                                  if (isCali) {
                                                    return const SizedBox.shrink();
                                                  }
                                                  return Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          'Eyedid SDK version: $_version',
                                                        ),
                                                        Text(
                                                          'App has CameraPermission: $_hasCameraPermissionString',
                                                        ),
                                                        Text(
                                                          'Eyedid initState : $_stateString',
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        if (_isInitialied)
                                                          ElevatedButton(
                                                            onPressed:
                                                                _trackingBtnPressed,
                                                            child: Text(
                                                              _trackingBtnText,
                                                            ),
                                                          ),
                                                        if (_isInitialied &&
                                                            _showingGaze)
                                                          ElevatedButton(
                                                            onPressed:
                                                                _calibrationBtnPressed,
                                                            child: const Text(
                                                              "START CALIBRATION",
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),

                                              // Gaze noktası
                                              ValueListenableBuilder<bool>(
                                                valueListenable:
                                                    _isCalibrationModeNotifier,
                                                builder: (context, isCali, _) {
                                                  if (isCali) {
                                                    return const SizedBox.shrink();
                                                  }
                                                  return ValueListenableBuilder<
                                                    Offset
                                                  >(
                                                    valueListenable:
                                                        _gazePositionNotifier,
                                                    builder: (context, gazePos, _) {
                                                      return ValueListenableBuilder<
                                                        Color
                                                      >(
                                                        valueListenable:
                                                            _gazeColorNotifier,
                                                        builder: (context, gazeColor, _) {
                                                          return Positioned(
                                                            left:
                                                                gazePos.dx - 10,
                                                            top:
                                                                gazePos.dy - 10,
                                                            child: Container(
                                                              width: 20,
                                                              height: 20,
                                                              decoration:
                                                                  BoxDecoration(
                                                                    color:
                                                                        gazeColor,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                              ),

                                              // Kalibrasyon gösterimi
                                              ValueListenableBuilder<bool>(
                                                valueListenable:
                                                    _isCalibrationModeNotifier,
                                                builder: (context, isCali, _) {
                                                  if (!isCali) {
                                                    return const SizedBox.shrink();
                                                  }

                                                  return Stack(
                                                    children: [
                                                      ValueListenableBuilder<
                                                        Offset
                                                      >(
                                                        valueListenable:
                                                            _calibrationNextPointNotifier,
                                                        builder: (context, nextPoint, _) {
                                                          final safeDx =
                                                              nextPoint.dx.clamp(
                                                                15.0,
                                                                dialogWidth -
                                                                    15.0,
                                                              );
                                                          final safeDy =
                                                              nextPoint.dy.clamp(
                                                                15.0,
                                                                dialogHeight -
                                                                    15.0,
                                                              );
                                                          return Positioned(
                                                            left: safeDx - 10,
                                                            top: safeDy - 10,
                                                            child: const Icon(
                                                              Icons.adjust,
                                                              size: 30,
                                                              color:
                                                                  Colors.orange,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      ValueListenableBuilder<
                                                        double
                                                      >(
                                                        valueListenable:
                                                            _calibrationProgressNotifier,
                                                        builder: (context, progress, _) {
                                                          return Positioned(
                                                            left:
                                                                MediaQuery.of(
                                                                      context,
                                                                    ).size.width /
                                                                    2 -
                                                                15,
                                                            bottom: 20,
                                                            child: SizedBox(
                                                              width: 30,
                                                              height: 30,
                                                              child: CircularProgressIndicator(
                                                                value: progress,
                                                                backgroundColor:
                                                                    Colors
                                                                        .grey
                                                                        .shade300,
                                                                color: Colors
                                                                    .orange,
                                                                strokeWidth: 4,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Icon(
                            Icons.download,
                            color: MainColors.primaryTextColor,
                            size: 18,
                          ), // ikon da küçültülebilir
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(formatted)),
                ],
              );
            }).toList(),
          ),
        ),
        Positioned(
          bottom: 40,
          right: 15,
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Colors.deepPurpleAccent.shade100,
              ),
            ),
            onPressed: () async {
              TextEditingController _homeworkNameController =
                  TextEditingController();
              File? _selectedFile;
              String? _selectedFileName;

              await showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setStateDialog) {
                      Future<void> pickPDFFile() async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf'],
                            );

                        if (result != null &&
                            result.files.single.path != null) {
                          setStateDialog(() {
                            _selectedFile = File(result.files.single.path!);
                            _selectedFileName = result.files.single.name;
                          });
                        }
                      }

                      return AlertDialog(
                        title: const Text("Ödev Ekle"),
                        content: SizedBox(
                          height: 250,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _homeworkNameController,
                                decoration: const InputDecoration(
                                  labelText: "Ödev İsmi",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: pickPDFFile,
                                child: const Text("PDF Dosyası Seç"),
                              ),
                              if (_selectedFileName != null) ...[
                                const SizedBox(height: 8),
                                Text("Seçilen dosya: $_selectedFileName"),
                              ],
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              if (_selectedFile != null &&
                                  _selectedFileName != null &&
                                  _homeworkNameController.text.isNotEmpty &&
                                  _homeworkNameController.text != "") {
                                BlocProvider.of<ClassroomBloc>(context).add(
                                  UploadPDF(
                                    fileName: _selectedFileName!,
                                    file: _selectedFile!,
                                    objectiveName: _homeworkNameController.text,
                                    roomName: BlocProvider.of<ClassroomBloc>(
                                      context,
                                    ).state.data["roomData"].roomName,
                                    pdfType: "homework",
                                    uploadOwner: BlocProvider.of<ClassroomBloc>(
                                      context,
                                    ).state.data["foundUser"].username,
                                  ),
                                );
                              }

                              Navigator.of(context).pop();
                            },
                            child: const Text("Ekle"),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
            child: const Text("Ödev Ekle"),
          ),
        ),
      ],
    );
  }
}
