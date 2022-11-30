import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pusher_beams/pusher_beams.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PusherBeams.instance.start(
      '57916be8-9ca3-47e1-ad6f-7867a68226a0');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  initState() {
    super.initState();

    initPusherBeams();
  }


  getTokenProvider()async{
    final BeamsAuthProvider beamsAuthProvider =  BeamsAuthProvider()
      ..authUrl = 'https://push-notification-zikora.herokuapp.com/single-device/pusher/beams-auth?user_id=834&authenticated_user_id=834'
      ..headers = {'Content-Type': 'application/json'}
      ..queryParams = {'page': '1'}
      ..credentials = 'omit'
    ;

    await PusherBeams.instance.setUserId(
        'user-id',
        beamsAuthProvider
        ,
            (error) => {
          if (error != null) {print(error)}else{
            print("Working")
          }

          // Success! Do something...
        });
  }

  initPusherBeams() async {
    // Let's see our current interests
    print(await PusherBeams.instance.getDeviceInterests());

    // This is not intented to use in web
    if (!kIsWeb) {
      await PusherBeams.instance
          .onInterestChanges((interests) => {print('Interests: $interests')});

      await PusherBeams.instance
          .onMessageReceivedInTheForeground(_onMessageReceivedInTheForeground);
    }
    await _checkForInitialMessage();
  }

  Future<void> _checkForInitialMessage() async {
    final initialMessage = await PusherBeams.instance.getInitialMessage();
    if (initialMessage != null) {
      _showAlert('Initial Message Is:', initialMessage.toString());
    }
  }

  void _onMessageReceivedInTheForeground(Map<Object?, Object?> data) {
    _showAlert(data["title"].toString(), data["body"].toString());
  }

  void _showAlert(String title, String message) {
    AlertDialog alert = AlertDialog(
        title: Text(title), content: Text(message), actions: const []);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getTokenProvider,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
