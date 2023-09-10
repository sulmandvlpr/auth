//Chat Screen show chat  this Screen Shows After User Login/SignUp
//or also Work as main screen when user already login

import 'package:authblock/widgets/chat_messages.dart';
import 'package:authblock/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//we show that screen when user login
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Chat'),
        actions: [
          IconButton(
            onPressed: () {
              //with that signout on FirebaseSDK we are automatically go out from content screen  to auth screen
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.exit_to_app,
                color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
      body:
          //center replace with messages
          Column(
        children: const [
          //show messages List
          //ChatScreen Widget warp with  Expanded caus we want to give this widget full hight as possilble
          Expanded(child: ChatScreen()),
          //show UI to enter new message e.g. send button, text enterd filed
          NewMessage(),
        ],
      ),
    );
  }
}
