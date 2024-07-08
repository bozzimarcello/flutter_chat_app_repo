import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<StatefulWidget> createState(){
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final _newMessageController = TextEditingController();

  @override
  void dispose() { //there is a lesson about dispose of TextEditingControllers
    _newMessageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _newMessageController.text;
    if (enteredMessage.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus(); // to close the keyboard
    _newMessageController.clear();

    final user = FirebaseAuth.instance.currentUser!;

    final userData = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

    // send to Firebase
    FirebaseFirestore.instance.collection('chat').add({ // firestore will set an id for us
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'], // there is a lesson about retrieve data from maps
      'userImage': userData.data()!['image_url'],
      });
    
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right:1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _newMessageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            icon: const Icon(Icons.send),
            onPressed: _submitMessage,
          ),
        ],
      ),
    );
  }
}