import 'package:flutter_utils/database.dart';

import 'models.dart';
import 'package:sembast/sembast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

const USERS_API = 'https://assignment.medimetry.in/api/v1/users/get';
const CHATS_API = 'https://assignment.medimetry.in/api/v1/users/{userId}/chats';
const SEND_MESSAGE_API = 'https://assignment.medimetry.in/api/v1/users/chat';

Future<List<User>> fetchUsers(
    {Database client, StoreRef<int, dynamic> storeRef}) async {
  try {
    final response = await http.get(USERS_API);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      if (data['success'] != null && data['success'] == 1) {
        List records = data['users'];
        List<User> users = [];
        for (final record in records) {
          await insertUser(client, storeRef, record);
          users.add(User.fromJson(record));
        }
        return users;
      }
    }
  } catch (e) {}
  return getUsers(client, storeRef);
}

Future<List<Chat>> fetchChats(int userId,
    {Database client, StoreRef<int, dynamic> storeRef}) async {
  try {
    final response =
        await http.get(CHATS_API.replaceFirst('{userId}', '$userId'));

    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      if (data['success'] != null && data['success'] == 1) {
        List records = data['chats'];
        List<Chat> chats = [];
        for (final record in records) {
          await insertChat(client, storeRef, record);
          chats.add(Chat.fromJson(record));
        }
        return records.map((record) => Chat.fromJson(record)).toList();
      }
    }
  } catch (SocketException) {}
  List list = await getChats(client, storeRef, userId);
  print(list);
  return list;
}

Future sendMessage(Draft draft,
    {Database client, StoreRef<int, dynamic> storeRef}) async {
  bool isSuccessful;
  try {
    final response = await http.post(
      SEND_MESSAGE_API,
      body: {
        'id': draft.userId.toString(),
        'message': draft.message,
      },
    );
    isSuccessful = response.statusCode == 200 &&
        convert.jsonDecode(response.body)['success'] == 1;
  } catch (SocketException) {
    isSuccessful = false;
  }
  if (isSuccessful) {
    return Chat(
        message: draft.message,
        updatedAt: DateTime.now(),
        userId: draft.userId);
  } else {
    insertDraft(client, storeRef, draft.toJson());
    return draft;
  }
}

Future<List> fetchDrafts(int userId,
    {Database client, StoreRef<int, dynamic> storeRef}) async {
  final records = await storeRef.find(
    client,
    finder: Finder(
      filter: Filter.custom((record) => record.value['user_id'] == userId),
    ),
  );
  List list = [];
  for (final record in records) {
    final draft = Draft.fromJson(record.value);
    final chat = await sendMessage(draft, client: client, storeRef: storeRef);
    if (chat is Chat) await removeDraft(client, storeRef, record.value);
    list.add(chat);
  }
  return list;
}

Future insertUser(
    Database client, StoreRef<int, dynamic> storeRef, dynamic user) {
  return storeRef.record(user['id']).put(client, user);
}

Future<List<User>> getUsers(
    Database client, StoreRef<int, dynamic> storeRef) async {
  final records = await storeRef.find(client);
  return records.map((record) => User.fromJson(record.value)).toList();
}

Future<List<Chat>> getChats(
    Database client, StoreRef<int, dynamic> storeRef, int userId) async {
  final records = await storeRef.find(client,
      finder: Finder(
          filter:
              Filter.custom((record) => record.value['user_id'] == userId)));
  return records.map((record) => Chat.fromJson(record.value)).toList();
}

Future insertChat(
    Database client, StoreRef<int, dynamic> storeRef, dynamic chat) {
  return storeRef.record(chat['id']).put(client, chat);
}

Future insertDraft(
    Database client, StoreRef<int, dynamic> storeRef, dynamic draft) {
  return storeRef.record(draft['time_stamp']).put(client, draft);
}

Future removeDraft(
    Database client, StoreRef<int, dynamic> storeRef, dynamic draft) {
  return storeRef.record(draft['time_stamp']).delete(client);
}
