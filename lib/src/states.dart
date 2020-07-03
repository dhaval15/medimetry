import 'package:medimetry/src/models.dart';
import 'package:sembast/sembast.dart';

class HomeState {
  final List<User> users;
  final Database client;
  final StoreRef<int, dynamic> userStore;
  HomeState({this.users, this.client, this.userStore});

  HomeState copyWith({
    List<User> users,
    Database client,
    StoreRef storeRef,
  }) =>
      HomeState(
        users: users ?? this.users,
        client: client ?? this.client,
        userStore: storeRef ?? this.userStore,
      );
}

class ChatState {
  final User user;
  final List<Chat> chats;
  final List<Draft> drafts;
  final Database client;
  final StoreRef<int, dynamic> chatStore;
  final StoreRef<int, dynamic> draftStore;

  List get all => chats != null ? [...chats, ...drafts] : null;

  ChatState({
    this.user,
    this.chats,
    this.drafts = const [],
    this.client,
    this.chatStore,
    this.draftStore,
  });

  ChatState copyWith({
    User user,
    List<Chat> chats,
    List<Draft> drafts,
    Database client,
    StoreRef chatStore,
    StoreRef draftStore,
  }) =>
      ChatState(
        user: user ?? this.user,
        chats: chats ?? this.chats,
        drafts: drafts ?? this.drafts,
        client: client ?? this.client,
        chatStore: chatStore ?? this.chatStore,
        draftStore: draftStore ?? this.draftStore,
      );
}

