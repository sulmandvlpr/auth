//shows List [] of chat messages
//loads all send messages in list
//setup push notification
import 'package:authblock/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

//stless cuase we dont update chat list we jsut load and display chat list without any change or update list

//init State to initlize fmc method one time when we laod class so Stateful widget
class ChatMessages extends StatefulWidget {
  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  void setupPushNotification() async {
    //create FirebaseMessaging Object
    final fcm = FirebaseMessaging.instance;
//requst permission method
    final notificationSettings = await fcm.requestPermission();
//get token give us token which is address of device on whcih your app is running
    final token = await fcm.getToken();
//4th  we can send this device token to backend (firebase skd) with help of http request in database
    // print(token);
//manually process
//to send to multiple subscriber of same topic
    fcm.subscribeToTopic('Chat');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupPushNotification();
  }

//we dont want the auth for ever mesg thats why we create auth varible here
  final authenticatedUser = FirebaseAuth.instance.currentUser!;

//for push notification we need 3 things
  @override
  Widget build(BuildContext context) {
    //here FireStore listen to change in the data when we added a new chat
    //it will automatically notfiy our app
    //and it will trigger builder method again so we
    //update ui when new doucment added to this collection

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('cratedAt', descending: true)
            .snapshots(),
        builder:
            //chatSnapshots will be end an object that give us access
            // to that data wich is loaded form backend
            (ctx, chatSnapshots) {
          if (chatSnapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          //we might have a state where we don't have messages
          if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
            return const Center(
              child: Text('NO Messages Found'),
            );
          }
          if (chatSnapshots.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

//if we have data
          final loadedMessage = chatSnapshots.data!.docs;
          return ListView.builder(
              padding: const EdgeInsets.only(bottom: 40, right: 13, left: 13),
              reverse: true,
              itemCount: loadedMessage.length,
              itemBuilder: (context, index) {
                //  Text(loadedMessage[index].data()['text'])
                //insted of Text I want to show message_bubble
                final chatMessage = loadedMessage[index].data();
//data() here give us documet which  has message and other details

//output message and next message and check if the next messag availble
//to checck next message we get current message index and perform 1 addition to get the next msg
//index +1 is index of next mesaage
//and if this index is still smaller then loadmesssage List boundries this mean leadedMessges list have more messges available in list
//and the inded+1 is still smaller then that in this case we increament  by one  if not then show null
                final nextChatMessage = index + 1 < loadedMessage.length
                    ? loadedMessage[index + 1].data()
                    : null;
                //now we have next chat message

                //next we gona do to get current message user name
                //in our docs every chat have user name key
                final currentMessageUserId = chatMessage['userid'];
//now we check the next message is still from same user
//for next message user id we have nextChatMessage variable check if it not null show nextChatMessage username or other case it will null
                final nextMessageUserId =
                    nextChatMessage != null ? nextChatMessage['userid'] : null;

//check if the next user is same
                final nextUserIsSame =
                    nextMessageUserId == currentMessageUserId;

                if (nextUserIsSame) {
                  return MessageBubble.next(
                      message: chatMessage['text'],
                      isMe: authenticatedUser.uid == currentMessageUserId);
                } else {
                  return MessageBubble.first(
                      userImage: chatMessage['userImage'],
                      username: chatMessage['username'],
                      message: chatMessage['text'],
                      isMe: authenticatedUser.uid == currentMessageUserId);
                }
              });
        });
  }
}
