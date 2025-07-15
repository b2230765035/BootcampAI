import 'package:bootcamp175/production/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    super.dateTime,
    super.messageContent,
    super.roomId,
    super.username,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    messageContent: json["messageContent"],
    roomId: json["roomId"],
    username: json["username"],
    dateTime: json["dateTime"],
  );

  Map<String, dynamic> toJson() => {
    "messageContent": messageContent,
    "roomId": roomId,
    "username": username,
    "dateTime": dateTime,
  };
}
