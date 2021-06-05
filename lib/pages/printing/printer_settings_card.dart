
import 'package:another_brother/custom_paper.dart';
import 'package:another_brother/label_info.dart';
import 'package:another_brother/type_b_printer.dart' as anotherBrotherTb;
import 'package:flutter/material.dart';
import 'package:flutterprintersetupsample/data/print_data.dart';
import 'package:flutterprintersetupsample/models/printer_model.dart';
import 'package:another_brother/printer_info.dart' as anotherBrother;
import 'package:flutterprintersetupsample/models/printer_settings_model.dart';
import 'package:provider/provider.dart';

class PrinterSettingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PrinterSettingsModel printerSettings = context.read();

    return ChangeNotifierProvider(
      create: (_) =>QrPrinterModel(),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(child: Text("Printer Settings".toUpperCase())),
          SizedBox(width:0, height:10),
          Text("Printer Model", textAlign: TextAlign.start,),
          SizedBox(width:0, height:10),
          PrinterModelSelectionWidget(),
          SizedBox(width:0, height:20),
          Text("Available Printers", textAlign: TextAlign.start,),
          SizedBox(width:0, height:10),
          Consumer<QrPrinterModel>(
              builder: (context, model, child) {
                return PrinterFinder(printerModel: printerSettings.configuredPrinterModel);
              }),
          SizedBox(width:0, height:16),
          Text("Select Paper", textAlign: TextAlign.start,),
          SizedBox(width:0, height:10),
          Consumer<QrPrinterModel>(
              builder: (context, model, child) {
                return PaperConfigurationWidget();
              }),
          SizedBox(width:0, height:16),

        ],
      ),
      ),
    );
  }
}

class PrinterModelSelectionWidget extends StatelessWidget {

  const PrinterModelSelectionWidget({Key? key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    PrinterSettingsModel printerSettings = context.read();
    print ("Creating printer list");
    List<PrintModelData> supportedModels = [
      PrintModelData(model: anotherBrother.Model.PT_P910BT, assetKey: "assets/images/pt_p910bt.jpg"),
      PrintModelData(model: anotherBrother.Model.QL_820NWB, assetKey: "assets/images/ql_820_nwb.jpg"),
      PrintModelData(model: anotherBrother.Model.QL_1110NWB, assetKey: "assets/images/ql_1110_nwb.jpg"),
      PrintModelData(model: anotherBrotherTb.TbModel.RJ_3035B, assetKey: "assets/images/rj_3035_b.jpg"),
      PrintModelData(model: anotherBrother.Model.RJ_4250WB, assetKey: "assets/images/rj_4250_wb.jpg"),
      //PrintModelData.RJ_GO,
    ];
    return Container(
      height: 100,
      child: ListView.builder(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
          itemCount: supportedModels.length,
          itemBuilder: (context, index) {
            PrintModelData data = supportedModels[index];
            bool selected = printerSettings.printerInfo.printerModel == data.model;
        return Consumer<PrinterSettingsModel>(
          builder: (context, appModel, child) {
            return PrinterModelCard(
                 imageKey: data.imageAssetKey,
                model: data.model);
          },
        );
      }),
    );

  }

}
class PrinterModelCard extends StatelessWidget {
  final String imageKey;
  final anotherBrother.AModel model;
  const PrinterModelCard({required this.imageKey, required this.model, Key? key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    PrinterSettingsModel printerSettings = context.read();
    bool selected = model  == printerSettings.configuredPrinterModel;//(model is anotherBrotherTb.TbModel && appModel.tbPrinterInfo.printerModel == model ) || (model is anotherBrother.Model && appModel.printerInfo.printerModel == model);
    QrPrinterModel qrPrinterModel = context.read();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (model is anotherBrother.Model) {
          anotherBrother.PrinterInfo currPrinterInfo = printerSettings.printerInfo;
          if (printerSettings.configuredPrinterModel != model) {
            currPrinterInfo.printerModel = model as anotherBrother.Model;
            // Reset paper when changing models.
            currPrinterInfo.labelNameIndex = -1;
            currPrinterInfo.binCustomPaper = null;
            printerSettings.printerInfo = currPrinterInfo;
            printerSettings.configuredPrinterModel = model;
            qrPrinterModel.reset();
          }
        }
        else if (model is anotherBrotherTb.TbModel) {
          anotherBrotherTb.TbPrinterInfo currPrinterInfo = printerSettings
              .tbPrinterInfo;
          if (printerSettings.configuredPrinterModel != model) {
            currPrinterInfo.printerModel = model as anotherBrotherTb.TbModel;
            currPrinterInfo.labelName =
                anotherBrotherTb.TbLabelName.Unsupported;
            printerSettings.tbPrinterInfo = currPrinterInfo;
            printerSettings.configuredPrinterModel = model;
            qrPrinterModel.reset();
          }
        }
      },
      child: Card(
        color: selected ? Colors.blue : Colors.black12,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(child: Image.asset(imageKey)),
          Text(model.getDisplayName(), style: selected ? TextStyle(color: Colors.white): TextStyle(color: Colors.black)),
        ],
      ),),
    );
  }

}

class FoundPrinterWidget extends StatelessWidget {

  final anotherBrother.ABrotherPrinter foundPrinter;

  const FoundPrinterWidget(this.foundPrinter, {Key? key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    PrinterSettingsModel printerSettings = context.read();
    bool isConfigured = false;

    IconData connectionIcon = Icons.bluetooth;
    if (foundPrinter is anotherBrother.NetPrinter) {
      connectionIcon = Icons.wifi;
      anotherBrother.NetPrinter netPrinter = foundPrinter as anotherBrother.NetPrinter;
      isConfigured = printerSettings.printerInfo.ipAddress == netPrinter.ipAddress;
    }
    else if (foundPrinter is anotherBrother.BluetoothPrinter) {
      anotherBrother.BluetoothPrinter btPrinter = foundPrinter as anotherBrother.BluetoothPrinter;
      connectionIcon = Icons.bluetooth;
      isConfigured = printerSettings.printerInfo.macAddress == btPrinter.macAddress;
    }
    else if (foundPrinter is anotherBrother.BLEPrinter) {
      anotherBrother.BLEPrinter blePrinter = foundPrinter as anotherBrother.BLEPrinter;
      connectionIcon = Icons.bluetooth_connected;
      isConfigured = printerSettings.printerInfo.getLocalName() == blePrinter.localName;

    }


    return Card(
      color: isConfigured ? Colors.blue : Colors.black12,
      child: Container(
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.white,
                child: Stack(
                    fit: StackFit.loose,
                    children: <Widget>[
                  Align(child: Icon(Icons.print, color: Colors.blue, size: 50,)),
                  Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4, top: 4),
                        child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                            child: Icon(connectionIcon, color: Colors.white, size: 15,)),
                      ))
                ]),
              ),
            ),
            Text(foundPrinter.getName().replaceFirst("Brother ", ""), style: isConfigured ? TextStyle(color: Colors.white) : TextStyle(color:Colors.black))
          ],
        ),
      ),
    );
  }

}
class PrinterFinder extends StatelessWidget {

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  final anotherBrother.AModel printerModel;
  PrinterFinder({required this.printerModel, Key? key}):super(key: key);

  List<anotherBrother.ABrotherPrinter> _foundPrinters = [];
  Stream<List<anotherBrother.ABrotherPrinter>> _printersStream = Stream<List<anotherBrother.ABrotherPrinter>>.empty();

  Stream<List<anotherBrother.ABrotherPrinter>> _findPrinters(anotherBrother.AModel selectedPrinterModel) async* {
    _foundPrinters = [];

    // TODO add model name
    List<String> selectedModels = [
      selectedPrinterModel.getName()
    ]; //selectedPrinterModels.fil

    if (selectedPrinterModel is anotherBrotherTb.ATbModel) {
      anotherBrotherTb.TbPrinter printer = anotherBrotherTb.TbPrinter();
      anotherBrotherTb.TbPrinterInfo printerInfo = anotherBrotherTb.TbPrinterInfo(
          port: anotherBrother.Port.BLUETOOTH);

      printer.setPrinterInfo(printerInfo..port = anotherBrother.Port.BLUETOOTH);
      List<anotherBrother.ABrotherPrinter> printers = await printer.getBluetoothPrinters(selectedModels);

      _foundPrinters.addAll(printers);
      yield _foundPrinters;
    }
    else {
      anotherBrother.Printer printer = anotherBrother.Printer();
      anotherBrother.PrinterInfo printerInfo = anotherBrother.PrinterInfo(
          port: anotherBrother.Port.NET);

      printer.setPrinterInfo(printerInfo);
      List<anotherBrother.ABrotherPrinter> printers = await printer
          .getNetPrinters(selectedModels);

      _foundPrinters.addAll(printers);
      if (_foundPrinters.isNotEmpty) {
        yield _foundPrinters;
      }

      printer.setPrinterInfo(printerInfo..port = anotherBrother.Port.BLUETOOTH);
      printers = await printer.getBluetoothPrinters(selectedModels);

      _foundPrinters.addAll(printers);
      yield _foundPrinters;
    }
  }


  @override
  Widget build(BuildContext context) {
    PrinterSettingsModel printerSettings = context.read();
    return Container(
      height: 80,
      width: double.infinity,
      child: StreamBuilder(
          stream: _findPrinters(printerModel),
          builder: (context,
              AsyncSnapshot<List<anotherBrother.ABrotherPrinter>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _searchingForPrinter(context, printerSettings);
            }

            if (snapshot.hasError) {
              return Text("Error loading printers.");
            }

            if (snapshot.hasData) {
              List<anotherBrother.ABrotherPrinter> foundPrinters = snapshot
                  .data!;

              if (foundPrinters.isEmpty) {
                return _noPrintersFound(context, printerSettings);
              }

              print("Printer Count: ${foundPrinters.length}");

              return ListView.builder(
                clipBehavior: Clip.none,
                scrollDirection: Axis.horizontal,
                  itemCount: foundPrinters.length + 1,
                  itemBuilder: (context, index) {
                    if(index == foundPrinters.length) {
                      return GestureDetector(
                        onTap: () {
                          _searchForPrinters(context);
                        },
                        child: Container(
                            width: 100,
                            child: Icon(Icons.refresh, color: Colors.blue, size: 50,)),
                      );
                    }
                    anotherBrother
                        .ABrotherPrinter printer = foundPrinters[index];
                    return GestureDetector(
                        onTap: () {
                          _configureSelectedPrinter(printerSettings, printer);
                        },
                        child: Consumer<PrinterSettingsModel>(
                            builder: (context, model, widget){
                              return FoundPrinterWidget(printer);
                            }));
                  });

            }

            return Text("We shouldn't see this");
          }),
    );
  }

  Future<void> _searchForPrinters(BuildContext context) async {
    QrPrinterModel qrPrinterModel = context.read();
    qrPrinterModel.reset();
  }

  void _configureSelectedPrinter(PrinterSettingsModel appModel, anotherBrother.ABrotherPrinter printer) {

    anotherBrother.PrinterInfo currPrintInfo = appModel.printerInfo;
    anotherBrotherTb.TbPrinterInfo currTbPrintInfo = appModel.tbPrinterInfo;

    currPrintInfo.macAddress = "";
    currPrintInfo.ipAddress = "";
    currPrintInfo.setLocalName("");

    currTbPrintInfo.btAddress = "";
    currTbPrintInfo.ipAddress = "";
    currTbPrintInfo.localName = "";

    if (printer is anotherBrother.BluetoothPrinter) {
      currPrintInfo.port = anotherBrother.Port.BLUETOOTH;
      currPrintInfo.macAddress = printer.macAddress;
      currTbPrintInfo.port = anotherBrother.Port.BLUETOOTH;
      currTbPrintInfo.btAddress = printer.macAddress;

    }
    else if (printer is anotherBrother.BLEPrinter) {
      currPrintInfo.port = anotherBrother.Port.BLE;
      currPrintInfo.setLocalName(printer.localName);
      currTbPrintInfo.port = anotherBrother.Port.BLE;
      currTbPrintInfo.localName = printer.localName;
    }
    else if (printer is anotherBrother.NetPrinter) {
      currPrintInfo.port = anotherBrother.Port.NET;
      currPrintInfo.ipAddress = printer.ipAddress;
      currTbPrintInfo.port = anotherBrother.Port.NET;
      currTbPrintInfo.ipAddress = printer.ipAddress;
    }

    // Update the configuration.
    appModel.printerInfo = currPrintInfo;
    appModel.tbPrinterInfo = currTbPrintInfo;
  }

  Widget _searchingForPrinter(BuildContext context, PrinterSettingsModel appModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Colors.blue,),
        SizedBox(width: 0, height: 10,),
        Text("Looking for printers")
      ],
    );
  }

  Widget _noPrintersFound(BuildContext context, PrinterSettingsModel model) {
    QrPrinterModel printerModel = context.read();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("No printers found"),
        SizedBox(width: 0, height:10),
        ElevatedButton(onPressed: (){
          printerModel.reset();
        }, child: Text("Search again"))
      ],
    );
  }
}

class PaperConfigurationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("Loading paper");
    PrinterSettingsModel printerSettingsModel = context.read();

    List<ALabelName> paperOptions = [];
    anotherBrother.AModel selectedPrinterModel = printerSettingsModel.configuredPrinterModel;//appModel.printerInfo.printerModel;
    if (selectedPrinterModel == anotherBrother.Model.QL_820NWB) {
      paperOptions.addAll(QL700.getValues());
      paperOptions.sort((labelA, labelB) => labelA.getName().compareTo(labelB.getName()));
    }
    else if (selectedPrinterModel == anotherBrother.Model.QL_1110NWB) {
      paperOptions.addAll(QL1100.getValues());
      paperOptions.sort((labelA, labelB) => labelA.getName().compareTo(labelB.getName()));
    }
    else if (selectedPrinterModel == anotherBrother.Model.RJ_4250WB) {
      paperOptions.addAll(BinPaper_RJ4250.getValues());
      paperOptions.sort((paperA, paperB) => paperA.getName().compareTo(paperB.getName()));
      ALabelName unsupported = paperOptions.removeLast();
      paperOptions.insert(0, unsupported);
    }
    else if (selectedPrinterModel == anotherBrother.Model.PT_P910BT) {
      // Find unsupported and put it first
      paperOptions.addAll(PT.getValues());
      paperOptions.sort((labelA, labelB) => labelA.getName().compareTo(labelB.getName()));
      ALabelName unsupported = paperOptions.firstWhere((element) => element == PT.UNSUPPORT);
      paperOptions.remove(unsupported);
      paperOptions.insert(0, unsupported);
    }
    else if (selectedPrinterModel ==  anotherBrotherTb.TbModel.RJ_3035B) {
      paperOptions.addAll(anotherBrotherTb.TbLabelName.getValues());
      paperOptions.add(anotherBrotherTb.TbLabelName(name:"W50H50", width: 50, height: 50));
      paperOptions.add(anotherBrotherTb.TbLabelName(name:"W72H72", width: 72, height: 72));
    }

    return Container(
        height: 80,
        child: ListView.builder(
          clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            itemCount: paperOptions.length,
            itemBuilder: (context, index) {
              ALabelName currPaper = paperOptions[index];
          return GestureDetector(
              onTap: () {
                anotherBrother.PrinterInfo currPrinterInfo = printerSettingsModel.printerInfo;
                if(selectedPrinterModel == anotherBrother.Model.RJ_4250WB) {
                 currPrinterInfo.binCustomPaper = currPaper as ACustomPaper;
                }
                else if (selectedPrinterModel == anotherBrotherTb.TbModel.RJ_3035B) {
                  anotherBrotherTb.TbPrinterInfo currTbPrinterInfo = printerSettingsModel.tbPrinterInfo;
                  currTbPrinterInfo.labelName = currPaper as anotherBrotherTb.TbLabelName;
                }
                else {
                  currPrinterInfo.labelNameIndex = _indexFromPaper(currPaper);
                }
                printerSettingsModel.printerInfo = currPrinterInfo;
              },
              child: Consumer<PrinterSettingsModel>(
                  builder: (context, model, child) {
                    return PrinterPaperWidget(paperOption: currPaper,);
                  }));
        }));
  }

  // TODO Update for new printer papers.
  int _indexFromPaper(ALabelName paper) {
    if (paper is QL700) {
      return QL700.ordinalFromID(paper.getId());
    }

    if (paper is QL1100) {
      return QL1100.ordinalFromID(paper.getId());
    }

    if (paper is PT) {
      return PT.ordinalFromID(paper.getId());
    }

    return -1;
  }

}


class PrinterPaperWidget extends StatelessWidget {

  static final kUnsupported = "UNSUPPORTED";
  static final kUnsupport = "UNSUPPORT";

  final ALabelName paperOption;
  const PrinterPaperWidget({required this.paperOption, Key? key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    PrinterSettingsModel printerSettings = context.read();
    bool isSelected = false;
    bool isBinPaper = false;
    IconData connectionIcon = Icons.code;
    String paperName = paperOption.getName();

    if (paperName.contains("-")) {
      paperName = paperName.split("-").last;
    }
    if (paperName == kUnsupport) {
      paperName = kUnsupported;
    }

    paperName = paperName.replaceFirst("_", "x");

    anotherBrother.PrinterInfo currPrinterInfo = printerSettings.printerInfo;
    if (paperOption is ACustomPaper) {
      ACustomPaper? currPaper = currPrinterInfo.getCustomPaper();
      isSelected = paperOption.getName() == currPaper?.getName();
      if (currPaper == null && paperOption.getName() == kUnsupported) {
        isSelected = true;
      }
    }
    else if (paperOption is anotherBrotherTb.ATbLabelName) {
      anotherBrotherTb.ATbLabelName currPaper = printerSettings.tbPrinterInfo.labelName;
      isSelected = currPaper.getName() == paperOption.getName();
    }
    else {
      ALabelName curLabelName = currPrinterInfo.printerModel.getLabelName(
          currPrinterInfo.labelNameIndex);
      isSelected = paperOption.getName() == curLabelName.getName();
    }

    return Card(
      color: isSelected ? Colors.blue : Colors.black12,
      child: Container(
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.white,
                child: Stack(
                    fit: StackFit.loose,
                    children: <Widget>[
                      Align(child: Icon(Icons.description, color: Colors.blue, size: 50,)),
                      isBinPaper ?
                      Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4, top: 4),
                            child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                                child: Icon(connectionIcon, color: Colors.white, size: 15,)),
                          )) : Container()
                    ]),
              ),
            ),
            Text(paperName , style: isSelected ? TextStyle(color: Colors.white) : TextStyle(color:Colors.black))
          ],
        ),
      ),
    );
  }
}

