import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPushNotifications() async { 
    // this function is needed because flutter didn't expects that
    // initState() will be an async function, but at the same time
    // we need to await for requestPermission()
    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission();
    // you could receive a future (look into the lesson about it)
    // with all the notifications settings, witch we do not need here

    // we get the address of this device to identify it
    // with this token you can send notifications to this device
    // via FCM
    final token = await fcm.getToken();
    // you could send this token (via HTTP or Firestore SDK) to a backend

    // debug
    print('Token: $token');

    // for this app, that have a single chat room, we will use a different approach
    // we will subscribe the device to a "topic", and send messages to this topic
    // this way, all devices subscribed to this topic will receive the message
    fcm.subscribeToTopic('chat');

  }
  
  // we setup push notifications here because 
  // only authenticated users can send messages
  @override
  void initState() {
    super.initState();

    // this method will only run once, so is the perfect place to seup
    // ask for permission to send notifications
    setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Chat'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.exit_to_app, 
              color: Theme.of(context).colorScheme.primary
              ),
          )],
      ),
      body: const Column(
        children: [
          Expanded( // will let the child widget to get as much space as it can get
            child: ChatMessages()
            ),
          NewMessage(),
        ],
      ),
    );
  }
}