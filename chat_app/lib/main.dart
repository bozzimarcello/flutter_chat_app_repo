import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:chat_app/screens/splash.dart';
import 'package:chat_app/screens/auth.dart';
import 'package:chat_app/screens/chat.dart';

// C:\Users\Utente\AppData\Local\Pub\Cache\bin
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 63, 17, 177)),
      ),
      home: StreamBuilder( // see the lesson on FutureBuilder
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (ctx, snapshot) {
          // to avoid to show the login screen for a fraction of a second
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if(snapshot.hasData) {
            return const ChatScreen();
          }
          
          return const AuthScreen();
          
        }),
    );
  }
}