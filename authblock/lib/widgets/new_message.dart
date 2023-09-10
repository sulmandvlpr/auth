//show the bottm message from to input message and send message button
//provide a signle new message

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});
  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  void _submitMessage() async {
    final enteredMessage = _messageController.text;
//now we take that eneted text value

//we are not sending empty message to firestore
    if (enteredMessage.trim().isEmpty) {
      return;
    }

//Close Open Keyborad after work done
    FocusScope.of(context).unfocus();
//clear the message once send
    _messageController.clear();

//send message to firestore

//to get user id from firebase we use Firebase auth
//.currentUser give access to currently login user
    final user = FirebaseAuth.instance.currentUser!;

//.get()method  will retrive data store in this doc in this collection
    final userData =
        await FirebaseFirestore.instance.collection('user').doc(user.uid).get();

    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      //user id whihc the user belong
      'user Id': user.uid,
      //.data() method on FireStore contains all the data of document
      //.data() return type is map to access the map key we use mapname['keyname']
      'user Name': userData.data()!['username'],
      'user Image': userData.data()!['image_url'],
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              enableSuggestions: true,
              decoration:
                  const InputDecoration(labelText: 'Send a new Message '),
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            icon: const Icon(Icons.send),
            //when on press hit i want to read enterd value and send vale to firebase
            onPressed: _submitMessage,
          ),
        ],
      ),
    );
  }
}
