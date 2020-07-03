class User {
  final int id;
  final String name;
  final int age;
  final String gender;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Chat> chats = [];

  User({
    this.id,
    this.name,
    this.age,
    this.gender,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        age: json['age'],
        gender: json['gender'],
        image: json['image'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  void addChat(Chat chat) {
    chats.add(chat);
  }

  void addChatList(List<Chat> chats) {
    chats.addAll(chats);
  }
}

class Chat {
  final int id;
  final int userId;
  final String message;
  final DateTime deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Chat({
    this.id,
    this.userId,
    this.message,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        id: json['id'],
        userId: json['user_id'],
        message: json['message'],
        deletedAt: (json['deleted_at'] as String)?.toDate(),
        createdAt: (json['created_at'] as String)?.toDate(),
        updatedAt: (json['updated_at'] as String)?.toDate(),
      );
}

class Draft {
  final int userId;
  final String message;
  final DateTime timeStamp;

  Draft({this.userId, this.message, this.timeStamp});

  factory Draft.fromJson(dynamic json) => Draft(
        userId: json['user_id'],
        message: json['message'],
        timeStamp: DateTime.fromMillisecondsSinceEpoch(json['time_stamp']),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'message': message,
        'time_stamp': timeStamp.millisecondsSinceEpoch,
      };
}

extension StringX on String {
  DateTime toDate() => DateTime.parse(this);
}
