import 'dart:io';

import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/core/usecase/usecase.dart';
import 'package:bootcamp175/production/data/repositories/room_repository.dart';

class UploadPDFUseCase
    implements
        UseCase6<DataState, String, File, String, String, String, String> {
  final RoomReposityory _roomRepository;

  UploadPDFUseCase(this._roomRepository);

  @override
  Future<DataState> call({
    required String param1,
    required File param2,
    required String param3,
    required String param4,
    required String param5,
    required String param6,
  }) async {
    DataState response = await _roomRepository.uploadPDF(
      fileName: param1,
      file: param2,
      objectiveName: param3,
      roomName: param4,
      pdfType: param5,
      uploadOwner: param6,
    );
    return response;
  }
}
