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

  void _submitMessage() {
    final enteredMessage = _newMessageController.text;
    if (enteredMessage.trim().isEmpty) {
      return;
    }

    // send to Firebase

    _newMessageController.clear();
    
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