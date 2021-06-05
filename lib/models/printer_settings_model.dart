
import 'package:another_brother/printer_info.dart';
import 'package:another_brother/type_b_printer.dart';
import 'package:flutterprintersetupsample/utils/easy_notifier.dart';

class PrinterSettingsModel extends EasyNotifier {

  // Printing
  AModel configuredPrinterModel = Model.PT_P910BT;
  PrinterInfo _printInfo = PrinterInfo()..printerModel = Model.PT_P910BT..isAutoCut = true;
  PrinterInfo get printerInfo => _printInfo;
  set printerInfo(PrinterInfo printerInfo) => notify(() {_printInfo = printerInfo;});

  // Printing TypeB
  TbPrinterInfo _tbPrintInfo = TbPrinterInfo()..printerModel = TbModel.RJ_2055WB;
  TbPrinterInfo get tbPrinterInfo => _tbPrintInfo;
  set tbPrinterInfo(TbPrinterInfo printerInfo) => notify(() {_tbPrintInfo = printerInfo;});

}