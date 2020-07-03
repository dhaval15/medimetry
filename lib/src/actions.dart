import 'dart:async';
import 'models.dart';
import 'states.dart';
import 'api.dart' as Api;

FutureOr<HomeState> loadUsers(HomeState state) async {
  final users =
      await Api.fetchUsers(client: state.client, storeRef: state.userStore);
  return state.copyWith(users: users);
}

FutureOr<ChatState> loadChats(ChatState state) async {
  final chats = await Api.fetchChats(state.user.id,
      client: state.client, storeRef: state.chatStore);
  return state.copyWith(chats: chats);
}

FutureOr<ChatState> loadDrafts(ChatState state) async {
  final chats = await Api.fetchDrafts(state.user.id,
      client: state.client, storeRef: state.draftStore);
  return state.copyWith(
    chats: [...state.chats, ...chats.where((chat) => chat is Chat)],
    drafts: chats.where((chat) => chat is Draft).toList().cast<Draft>(),
  );
}

FutureOr<ChatState> sendMessage(ChatState state) async {
  final draft = Draft(
    userId: state.user.id,
    message: state.drafts.last.message,
    timeStamp: state.drafts.last.timeStamp,
  );
  final chat = await Api.sendMessage(draft,
      client: state.client, storeRef: state.draftStore);
  if (chat is Draft)
    return state;
  else
    return state.copyWith(
      chats: [...state.chats, chat],
      drafts: List.from(state.drafts)..removeLast(),
    );
}
