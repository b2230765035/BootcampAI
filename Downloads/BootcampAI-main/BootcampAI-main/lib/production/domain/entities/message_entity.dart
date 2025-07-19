class MessageEntity {
  String messageContent;
  String username;
  int roomId;
  DateTime dateTime;

  MessageEntity({
    this.messageContent = "",
    this.username = "",
    this.roomId = -1,
    DateTime? dateTime,
  }) : dateTime = dateTime ?? DateTime.timestamp();
}
