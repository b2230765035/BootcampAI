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
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as pw;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:eyedid_flutter/eyedid_flutter.dart';
import 'package:eyedid_flutter/gaze_tracker_options.dart';
import 'package:eyedid_flutter/eyedid_flutter_initialized_result.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_metrics.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final ValueNotifier<Offset> _gazePositionNotifier = ValueNotifier(
    Offset.zero,
  );
  final ValueNotifier<Color> _gazeColorNotifier = ValueNotifier(Colors.red);
  final ValueNotifier<Offset> _calibrationNextPointNotifier = ValueNotifier(
    Offset.zero,
  );
  final ValueNotifier<double> _calibrationProgressNotifier = ValueNotifier(0.0);
  final ValueNotifier<bool> _isCalibrationModeNotifier = ValueNotifier(false);
  final ValueNotifier<String> _trackingBtnTextNotifier = ValueNotifier(
    "Etütü Başlat",
  );
  final ValueNotifier<bool> _isTrackingNotifier = ValueNotifier(false);
  final ValueNotifier<double> _studySecondsNotifier = ValueNotifier(0);
  final ValueNotifier<double> _screenTimeNotifier = ValueNotifier(0);

  EyedidFlutter _eyedidFlutterPlugin = EyedidFlutter();
  bool _hasCameraPermission = false;
  var _isInitialied = false;
  var _version = 'Unknown';
  var _stateString = "IDLE";
  var _hasCameraPermissionString = "NO_GRANTED";
  var _trackingBtnText = "Etütü Başlat";
  var _showingGaze = false;
  var _isCaliMode = false;
  bool _isTracking = false;

  MaterialColor _gazeColor = Colors.red;
  static const String _licenseKey =
      "dev_z26l60eeow95l9cz3q1c8p5wfsnx87ip8d0yshm0"; // todo: input your license key

  StreamSubscription<dynamic>? _trackingEventSubscription;
  StreamSubscription<dynamic>? _dropEventSubscription;
  StreamSubscription<dynamic>? _statusEventSubscription;
  StreamSubscription<dynamic>? _calibrationEventSubscription;

  final PdfViewerController _pdfController = PdfViewerController();
  Timer? _studyTimer;
  ValueNotifier<Map<int, Map<String, dynamic>>> _pageDatas = ValueNotifier({});
  final ValueNotifier<int?> _visibleSegmentIndex = ValueNotifier(null);
  final ValueNotifier<String> _visibleSegmentText = ValueNotifier("");

  final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.5-flash',
  );

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
    _studyTimer?.cancel();
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
        //_eyedidFlutterPlugin.startTracking();
      } else if (result.message == InitializedResult.isAlreadyAttempting ||
          result.message == InitializedResult.gazeTrackerAlreadyInitialized) {
        enable = true;
        listenEvents();
        //final isTracking = await _eyedidFlutterPlugin.isTracking();
        //if (isTracking) {
        //  showGaze = true;
        //}
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
          _isTracking = true;
          _gazePositionNotifier.value = Offset(
            info.gazeInfo.gaze.x,
            info.gazeInfo.gaze.y,
          );
          _gazeColorNotifier.value = Colors.green;
        } else {
          _isTracking = false;
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
          _stateString = "Etütü Başlat";
          _showingGaze = true;
        });
      } else {
        setState(() {
          _stateString = "Etütü Bitir : ${info.errorType?.name}";
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

  void _trackingBtnPressed(double widgetHeight, String pdfUrl) {
    if (_isInitialied) {
      if (_trackingBtnTextNotifier.value == "Etütü Başlat") {
        try {
          _eyedidFlutterPlugin.startTracking();
          _trackingBtnTextNotifier.value = "Etütü Bitir";
          _isTrackingNotifier.value = true;
          startStudy(widgetHeight, pdfUrl);
        } on PlatformException catch (e) {
          setState(() {
            _stateString = "Occur PlatformException (${e.message})";
          });
        }
      } else {
        try {
          _eyedidFlutterPlugin.stopTracking();
          _trackingBtnTextNotifier.value = "Etütü Başlat";
          _isTrackingNotifier.value = false;
          stopStudy();
        } on PlatformException catch (e) {
          setState(() {
            _stateString = "Occur PlatformException (${e.message})";
          });
        }
      }
    }
  }

  void _calibrationBtnPressed() async {
    if (_isInitialied) {
      try {
        await _eyedidFlutterPlugin.isTracking()
            ? ""
            : await _eyedidFlutterPlugin.startTracking();
        _isTrackingNotifier.value = true;
        _isTracking = true;
        await _eyedidFlutterPlugin.startCalibration(
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

  int getSegmentFromY(double widgetHeight) {
    double segmentHeight = widgetHeight / 4;
    return (_gazePositionNotifier.value.dy / segmentHeight).floor() +
        1; // Segment 1-4
  }

  Future<String> getSegmentTextFromCurrentPage(
    double widgetHeight,
    double y,
    String pdfUrl,
  ) async {
    final response = await http.get(Uri.parse(pdfUrl));
    if (response.statusCode != 200) {
      throw Exception("PDF dosyası alınamadı.");
    }

    final pdfDoc = pw.PdfDocument(inputBytes: response.bodyBytes);
    final pageNumber = _pdfController.pageNumber;

    // Segment hesapla
    double segmentHeight = widgetHeight / 4;
    int segmentIndex = (y / segmentHeight).floor(); // 0-3 arası
    double top = segmentIndex * segmentHeight;
    double bottom = top + segmentHeight;

    // sayfa boyutunu al
    final page = pdfDoc.pages[pageNumber - 1];
    final pageSize = page.size;

    // PDF sayfasında segmentin oranlarını hesapla
    double segmentTopRatio = top / widgetHeight;
    double segmentBottomRatio = bottom / widgetHeight;

    // PDF sayfasındaki mutlak y konumlarını hesapla
    double pdfTop = pageSize.height * segmentTopRatio;
    double pdfBottom = pageSize.height * segmentBottomRatio;

    // PdfTextExtractor ile metin çıkar
    final extractedTextLines = pw.PdfTextExtractor(pdfDoc).extractTextLines(
      startPageIndex: pageNumber - 1,
      endPageIndex: pageNumber - 1,
    );

    List<String> segmentTexts = [];

    for (final line in extractedTextLines) {
      if (line.bounds.top >= pdfTop && line.bounds.bottom <= pdfBottom) {
        segmentTexts.add(line.text);
      }
    }

    return segmentTexts.join(' ');
  }

  void stopStudy() {
    _studyTimer?.cancel();
    _studySecondsNotifier.value = 0;
    _pageDatas.value = {};
  }

  void startStudy(double widgetHeight, String pdfUrl) {
    _studyTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      _studySecondsNotifier.value += 1;
      if (!_isTracking) {
        _screenTimeNotifier.value += 1;
        return;
      }

      int segment = getSegmentFromY(widgetHeight);
      int pageNumber = _pdfController.pageNumber;

      // Derin kopyalama gerekebilir çünkü Map referans tipi
      final currentPageData = Map<int, Map<String, dynamic>>.from(
        _pageDatas.value,
      );

      // Sayfa yoksa oluştur
      currentPageData[pageNumber] ??= {
        "status": <int, bool>{},
        "data": <int, String>{},
        "counter": <int, int>{},
      };

      // Sayaç arttır
      currentPageData[pageNumber]!["counter"][segment] =
          (currentPageData[pageNumber]!["counter"][segment] ?? 0) + 1;

      // Eğer sayaç eşik değere ulaştıysa ve segment henüz işlenmediyse
      if (currentPageData[pageNumber]!["counter"][segment] >= 10 &&
          !(currentPageData[pageNumber]!["status"][segment] ?? false)) {
        currentPageData[pageNumber]!["status"][segment] = true;

        try {
          String generatedData = await getSegmentTextFromCurrentPage(
            widgetHeight,
            _gazePositionNotifier.value.dy,
            pdfUrl,
          );

          Content prompt = Content.text(
            '''Search the topic given in the next sence, make it easier to understand, provide good information about it and the repsonse have to be in "Turkish" ,length of the response should be smaller than 5 sentence if possible, if its not a content you should search or you can search
           or doesn't make sene just return me with "yetersiz veri veya anlamsız metin". Topic => $generatedData''',
          );

          ChatSession chat = model.startChat();
          final response = await chat.sendMessage(prompt);

          currentPageData[pageNumber]!["data"][segment] = response.text;
        } catch (e, stacktrace) {
          log("Hata oluştu: $e");
          log("Stacktrace: $stacktrace");
        }
      }

      // Sayfa verisini güncelle
      _pageDatas.value = currentPageData;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = context.getWidth();
    double height = context.getHeigth();

    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,

          child: BlocBuilder<ClassroomBloc, ClassroomState>(
            builder: (context, state) {
              return DataTable(
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
                  DataColumn(label: Text("Not İsmi")),
                  DataColumn(label: Text("Yükleyen Kişi")),
                  DataColumn(label: Text("Aksiyonlar")),
                  DataColumn(label: Text("Yüklenme Tarihi")),
                ],
                rows: BlocProvider.of<ClassroomBloc>(context).state.data["roomData"].notes.reversed.map<DataRow>((
                  homework,
                ) {
                  DateTime dt = homework["uploadedAt"].toDate();
                  String formatted =
                      "${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} – ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                  return DataRow(
                    cells: [
                      DataCell(Text(homework["noteName"])),
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
                                                      } else {
                                                        return SfPdfViewer.network(
                                                          homework["fileUrl"],
                                                          controller:
                                                              _pdfController,
                                                          scrollDirection:
                                                              PdfScrollDirection
                                                                  .horizontal,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                  IgnorePointer(
                                                    // Kullanıcı etkileşimini engeller
                                                    child: Column(
                                                      children: List.generate(4, (
                                                        index,
                                                      ) {
                                                        return Expanded(
                                                          child: Container(
                                                            height:
                                                                dialogHeight /
                                                                4,
                                                            color: Colors.red
                                                                .withOpacity(
                                                                  0.05,
                                                                ), // İsteğe bağlı renk
                                                            child: Center(
                                                              child: Text(''),
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                    ),
                                                  ),
                                                  ValueListenableBuilder(
                                                    valueListenable:
                                                        _studySecondsNotifier,
                                                    builder: (context, value, _) {
                                                      return Positioned(
                                                        top: 16,
                                                        right: 16,
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical: 8,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                      0.6,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                              child: Text(
                                                                'Süre: $value s',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                            ValueListenableBuilder(
                                                              valueListenable:
                                                                  _screenTimeNotifier,
                                                              builder:
                                                                  (
                                                                    context,
                                                                    value2,
                                                                    child,
                                                                  ) {
                                                                    return Container(
                                                                      padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            8,
                                                                      ),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(
                                                                              0.6,
                                                                            ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12,
                                                                            ),
                                                                      ),
                                                                      child: Text(
                                                                        'Performans: ${value == 0 ? 0 : ((value - value2) / value * 100).floor()}%',
                                                                        style: TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),

                                                  ValueListenableBuilder<
                                                    Map<
                                                      int,
                                                      Map<String, dynamic>
                                                    >
                                                  >(
                                                    valueListenable: _pageDatas,
                                                    builder: (context, value, _) {
                                                      final int pageNumber =
                                                          _pdfController
                                                              .pageNumber;
                                                      final page =
                                                          value[pageNumber];
                                                      final statusMap =
                                                          page != null &&
                                                              page["status"] !=
                                                                  null
                                                          ? Map<int, bool>.from(
                                                              page["status"],
                                                            )
                                                          : {};

                                                      final dataMap =
                                                          page != null &&
                                                              page["data"] !=
                                                                  null
                                                          ? Map<
                                                              int,
                                                              String
                                                            >.from(page["data"])
                                                          : {};

                                                      return Positioned(
                                                        top: 60,
                                                        right: 0,
                                                        child: Container(
                                                          width: 200,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: List.generate(4, (
                                                              index,
                                                            ) {
                                                              final segmentIndex =
                                                                  index + 1;
                                                              final isCompleted =
                                                                  statusMap[segmentIndex] ??
                                                                  false;

                                                              return OutlinedButton(
                                                                style: OutlinedButton.styleFrom(
                                                                  backgroundColor:
                                                                      isCompleted
                                                                      ? Colors
                                                                            .green
                                                                      : Colors
                                                                            .red,

                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        4,
                                                                      ),
                                                                  minimumSize:
                                                                      Size(
                                                                        32,
                                                                        32,
                                                                      ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          16,
                                                                        ),
                                                                  ),
                                                                  side: BorderSide(
                                                                    color: MainColors
                                                                        .primaryTextColor,
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                                onPressed: () {
                                                                  if (isCompleted) {
                                                                    final text =
                                                                        dataMap[segmentIndex];

                                                                    _visibleSegmentIndex
                                                                            .value =
                                                                        segmentIndex;
                                                                    _visibleSegmentText
                                                                            .value =
                                                                        text;
                                                                  }
                                                                },

                                                                child: Text(
                                                                  "$segmentIndex",
                                                                ),
                                                              );
                                                            }),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  ValueListenableBuilder<int?>(
                                                    valueListenable:
                                                        _visibleSegmentIndex,
                                                    builder: (context, visibleSegment, _) {
                                                      if (visibleSegment ==
                                                          null) {
                                                        return SizedBox.shrink();
                                                      }

                                                      return ValueListenableBuilder<
                                                        String
                                                      >(
                                                        valueListenable:
                                                            _visibleSegmentText,
                                                        builder: (context, text, _) {
                                                          return Positioned(
                                                            top: 80,
                                                            right: 0,
                                                            child: Container(
                                                              margin:
                                                                  EdgeInsets.only(
                                                                    top: 8,
                                                                  ),
                                                              width: 200,
                                                              height:
                                                                  MediaQuery.of(
                                                                        context,
                                                                      )
                                                                      .size
                                                                      .height *
                                                                  0.5,
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                          16.0,
                                                                        ),
                                                                    child: SingleChildScrollView(
                                                                      child: Text(
                                                                        text,
                                                                        style: CustomTextStyles
                                                                            .messageStyle1,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    top: 4,
                                                                    right: 4,
                                                                    child: GestureDetector(
                                                                      onTap: () {
                                                                        _visibleSegmentIndex.value =
                                                                            null;
                                                                        _visibleSegmentText.value =
                                                                            "";
                                                                      },
                                                                      child: Icon(
                                                                        Icons
                                                                            .close,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),

                                                  Positioned(
                                                    right: 5,
                                                    bottom: 5,
                                                    child: ValueListenableBuilder<bool>(
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
                                                              if (_isInitialied)
                                                                ValueListenableBuilder<
                                                                  String
                                                                >(
                                                                  valueListenable:
                                                                      _trackingBtnTextNotifier,
                                                                  builder:
                                                                      (
                                                                        context,
                                                                        btnText,
                                                                        _,
                                                                      ) {
                                                                        return ElevatedButton(
                                                                          onPressed: () {
                                                                            _trackingBtnPressed(
                                                                              dialogHeight,
                                                                              homework["fileUrl"],
                                                                            );
                                                                          },
                                                                          child: Text(
                                                                            btnText,
                                                                          ),
                                                                        );
                                                                      },
                                                                ),

                                                              ElevatedButton(
                                                                onPressed:
                                                                    _calibrationBtnPressed,
                                                                child: const Text(
                                                                  "Kalibrasyonu Başlat",
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
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
                                                                    gazePos.dx -
                                                                    10,
                                                                top:
                                                                    gazePos.dy -
                                                                    10,
                                                                child: Container(
                                                                  width: 20,
                                                                  height: 20,
                                                                  decoration: BoxDecoration(
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
                                                                left:
                                                                    safeDx - 10,
                                                                top:
                                                                    safeDy - 10,
                                                                child: const Icon(
                                                                  Icons.adjust,
                                                                  size: 30,
                                                                  color: Colors
                                                                      .orange,
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
                                                                    value:
                                                                        progress,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .grey
                                                                            .shade300,
                                                                    color: Colors
                                                                        .orange,
                                                                    strokeWidth:
                                                                        4,
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
                                Icons.remove_red_eye,
                                color: MainColors.primaryTextColor,
                                size: 18,
                              ), // ikon da küçültülebilir
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
                              onPressed: () {},
                              child: Icon(
                                Icons.download,
                                color: MainColors.primaryTextColor,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text(formatted)),
                    ],
                  );
                }).toList(),
              );
            },
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
                        title: const Text("Not Yükle"),
                        content: SizedBox(
                          height: 250,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _homeworkNameController,
                                decoration: const InputDecoration(
                                  labelText: "Not İsmi",
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
                                    pdfType: "note",
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
            child: const Text("Not Yükle"),
          ),
        ),
      ],
    );
  }
}
