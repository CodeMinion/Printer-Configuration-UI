
import 'package:another_brother/printer_info.dart';
import 'package:another_brother/type_b_printer.dart';

class PrintModelData {
  final AModel _model;
  final String _assetKey;

  PrintModelData._(this._model, this._assetKey);

  factory PrintModelData({required AModel model, String? assetKey}) {
    return PrintModelData._(model, assetKey ?? "");
  }

  AModel get model => _model;
  String get imageAssetKey => _assetKey;

  static final RJ_GO = PrintModelData(model: TbModel(displayName: "RJ-Go"), assetKey: "assets/images/rj_3035_b.jpg");

}