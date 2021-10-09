import 'package:another_brother/printer_info.dart';
import 'package:another_brother/type_b_commands.dart';
import 'package:another_brother/type_b_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutterprintersetupsample/models/printer_settings_model.dart';
import 'package:flutterprintersetupsample/pages/printing/printer_settings_card.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

void main() {
  
  PrinterSettingsModel printerSettings = PrinterSettingsModel();
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: printerSettings)
      ],
  child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Another_Brother: Print Config Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
              return PrinterConfigurationPage();
            }));
          }, icon: Icon(Icons.settings))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Don't forget to grant permissions to your app in Settings.", textAlign: TextAlign.center,),
            ),
            SingleChildScrollView(child: Image(image: AssetImage('assets/images/brother_hack.png')))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          // Call print
          _print(context);
        },
        tooltip: 'Print',
        child: Icon(Icons.print),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> _print(BuildContext context) async {

    ui.Image imageToPrint = await BrotherUtils.loadImage('assets/images/brother_hack.png');

    PrinterSettingsModel printerSettingsModel = context.read();

    if (printerSettingsModel.configuredPrinterModel is TbModel) {
      ATbLabelName configuredPaper = printerSettingsModel.tbPrinterInfo.labelName;
      TbPrinter printer = TbPrinter();
      await printer.setPrinterInfo(printerSettingsModel.tbPrinterInfo);
      bool success = false;
      success = await printer.startCommunication();
      success = success && await printer.setup(
          width: configuredPaper.getWidth(),
          height: configuredPaper.getHeight());
      success = success && await printer.clearBuffer();
      success =
          success && await printer.downloadImage(imageToPrint);
      success = success && await printer.printLabel();
      TbPrinterStatus printerStatus = await printer.printerStatus();
      // Delete all files downloaded to the printer memory
      success = success && await printer.sendTbCommand(TbCommandDeleteFile());
      success = success && await printer.endCommunication(timeoutMillis: 5000);
      // TODO On Error show toast.
      if (!success) {
        _showSnack(context,
            "Print filed with error code: ${printerStatus.getStatusValue()}",
            duration: Duration(seconds: 2));
      }


    }
    else {
      Printer printer = new Printer();
      printer.setPrinterInfo(printerSettingsModel.printerInfo);
      PrinterStatus status = await printer.printImage(imageToPrint);

      if (status.errorCode != ErrorCode.ERROR_NONE) {
        // Show toast with error.
        _showSnack(context,
            "Print filed with error code: ${status.errorCode.getName()}",
            duration: Duration(seconds: 2));
      }
    }
  }

  void _showSnack(BuildContext context, String content, {Duration duration = const Duration(seconds: 1)}) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: duration,
          content: Container(
            padding: EdgeInsets.all(8.0),
            child: Text(content),
          ),
        ));
  }
}

class PrinterConfigurationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings Sample"),
      ),
      body: PrinterSettingsCard(),
    );
  }

}