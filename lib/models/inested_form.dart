import 'package:cdx_reactiveforms/controllers/form_controller.dart';
import 'package:cdx_reactiveforms/models/iform.dart';

abstract interface class INestedForm implements IForm<Map<String, dynamic>, Map<String, dynamic>> {
  FormController get innerController;
}

