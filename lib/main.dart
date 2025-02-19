import 'package:flutter/material.dart';
import 'package:dmrtd/dmrtd.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'dart:developer';

void beginToScan() async {
  // this function begin to scanning and prints scan results
  final nfc = NfcProvider(); // initializing nfc scanner
  try {
  // beginning to scan
  await nfc.connect(iosAlertMessage: "Hold your iPhone near Passport");
  final passport = Passport(nfc);
  // setting message for ios. Not required for android
  nfc.setIosAlertMessage("Reading EF.CardAccess…");
  // final cardAccess = await passport.readEfCardAccess();
  nfc.setIosAlertMessage("Initiating session…");
  // running scan function

  // !!!!!!!!NOTE!!!!!!!: put here your passport number, DOB and passport expiration (its required to read chip data)
  final bacKeySeed = DBAKey(
  "AB3232233", // change this to user passport's serial number
  DateTime(1998, DateTime.august, 17), // change this to birth date
  DateTime(2037, DateTime.april, 21)); // change this to passport's validate date  // starting session
  // starting session
  await passport.startSession(bacKeySeed);
  nfc.setIosAlertMessage("Reading EF.COM…");
  // reading EFCOM
  final efcom = await passport.readEfCOM();
  nfc.setIosAlertMessage("Reading Data Groups…");
  EfDG1? dg1;
  // reading EfDG1
  if (efcom.dgTags.contains(EfDG1.TAG)) {
    dg1 = await passport.readEfDG1();
  }
  EfDG2? dg2;
  // reading EfDG2
  if (efcom.dgTags.contains(EfDG2.TAG)) {
    dg2 = await passport.readEfDG2();
  }
  // EfDG15? dg15;
  // // reading EfDG2
  // if (efcom.dgTags.contains(EfDG15.TAG)) {
  //   dg15 = await passport.readEfDG15();
  // }
  // You can read other data groups similarly
  nfc.setIosAlertMessage("Reading EF.SOD…");
  final sod = await passport.readEfSOD();
  // You can print or display the data groups as you wish
  print("data-1: ${dg1?.mrz.country}");
  print("data-2: ${dg1?.mrz.dateOfBirth}");
  print("data-3: ${dg1?.mrz.documentNumber}");
  print("data-4: ${dg1?.mrz.firstName}");
  print("data-5: ${dg1?.mrz.optionalData}");
  print("dg1: ${base64Encode(dg1!.toBytes())}");
  // print("dg15: ${base64Encode(dg15!.toBytes())}");
  log("sod: ${base64Encode(sod.toBytes())}");
  } catch (e) {
    print("$e");
  // Handle errors
  } finally {
    // disconnection NFC at the end
    await nfc.disconnect();
  }
 }

void main() {
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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
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

  void _incrementCounter() {
    beginToScan();
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
