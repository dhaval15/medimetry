import 'package:flutter/material.dart';
import 'package:flutter_utils/arch.dart';
import 'package:sembast/sembast.dart';
import 'states.dart';
import 'ui.dart';

class MediMetryApp extends StatelessWidget {
  final Database database;

  const MediMetryApp({Key key, this.database}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Provider(
      providers: {
        HomeState: () => HomeState(
              client: database,
              userStore: intMapStoreFactory.store('users'),
            ),
        ChatState: () => ChatState(
              client: database,
              chatStore: intMapStoreFactory.store('chats'),
              draftStore: intMapStoreFactory.store('drafts'),
            ),
      },
      child: MaterialApp(
        title: 'MediMetry',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: 'home',
        routes: {
          'home': (context) => HomeScreen(),
          'chat': (context) => ChatScreen(),
        },
      ),
    );
  }
}
