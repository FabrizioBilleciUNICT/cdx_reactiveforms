import 'package:cdx_reactiveforms/controllers/form_controller.dart';
import 'package:cdx_reactiveforms/models/iform.dart';

abstract interface class IArrayForm implements IForm<List<Map<String, dynamic>>, List<Map<String, dynamic>>> {
  List<FormController> get itemControllers;
}

