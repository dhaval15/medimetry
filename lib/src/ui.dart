import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeago;
import 'states.dart';
import 'models.dart';
import 'actions.dart' as Actions;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<HomeState>(context).dispatchAsync(Actions.loadUsers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).canvasColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.black87,
            ),
            onPressed: () {
              Provider.of<HomeState>(context).dispatchAsync(Actions.loadUsers);
            },
          ),
        ],
      ),
      body: Container(
        child: Consumer<HomeState>(
          builder: (context, state) => state.users != null
              ? state.users.length != 0
                  ? ListView.separated(
                      separatorBuilder: (context, int) => Divider(),
                      itemCount: state.users.length,
                      itemBuilder: (context, index) =>
                          UserTile(user: state.users[index]),
                    )
                  : Text('Empty')
              : Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final User user;

  const UserTile({Key key, this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user.name),
      leading: UserAvatar(user: user),
      onTap: () {
        Provider.of<ChatState>(context).mutate((state) => state.copyWith(
              user: user,
              chats: [],
              drafts: [],
            ));
        Navigator.of(context).pushNamed('chat', arguments: user);
      },
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    loadState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ChatState>(
          builder: (context, state) => Text(
            state.user?.name ?? '...',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        leading: Consumer<ChatState>(
          builder: (context, state) => GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: EdgeInsets.all(8),
              child: UserAvatar(user: state.user),
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).canvasColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.black87,
            ),
            onPressed: loadState,
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(bottom: 4),
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: Container(
                child: Consumer<ChatState>(
                  builder: (context, state) => state.all != null
                      ? state.all.length != 0
                          ? ListView.builder(
                              reverse: true,
                              itemCount: state.all.length,
                              itemBuilder: (context, index) => ChatTile(
                                  chat: state.all.reversed.toList()[index]),
                            )
                          : Center(child: Text('Empty'))
                      : Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Flexible(
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter Message'),
                      ),
                    ),
                  ),
                  flex: 1,
                ),
                FloatingActionButton(
                  child: Icon(Icons.send),
                  onPressed: () async {
                    Provider.of<ChatState>(context)
                        .dispatch((state) => state.copyWith(drafts: [
                              ...state.drafts,
                              Draft(
                                  userId: state.user.id,
                                  message: controller.text,
                                  timeStamp: DateTime.now()),
                            ]));
                    controller.text = '';
                    await Provider.of<ChatState>(context)
                        .dispatchAsync(Actions.sendMessage);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void loadState() async {
    await Provider.of<ChatState>(context).dispatchAsync(Actions.loadChats);
    await Provider.of<ChatState>(context).dispatchAsync(Actions.loadDrafts);
  }
}

class ChatTile extends StatelessWidget {
  final Chat chat;

  const ChatTile({Key key, this.chat}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(
        left: 64,
        top: 8,
        bottom: 8,
        right: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            chat.message,
            textAlign: TextAlign.start,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 8),
          chat is Chat
              ? Text(
                  timeago.format(
                      chat.updatedAt.add(Duration(hours: 5, minutes: 30))),
                  style: TextStyle(color: Colors.white.withAlpha(150)),
                )
              : Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.white.withAlpha(150),
                ),
        ],
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final User user;

  const UserAvatar({Key key, this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        height: 36,
        width: 36,
        child: user?.image != null
            ? CachedNetworkImage(
                imageUrl: user.image,
                fit: BoxFit.cover,
                placeholder: (context, _) => CircleAvatar(
                  backgroundColor: Colors.black.withAlpha(50),
                ),
                errorWidget: (context, _a, _b) => CircleAvatar(
                  backgroundColor: Colors.red.withAlpha(50),
                ),
              )
            : null,
      ),
    );
  }
}
