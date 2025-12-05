import 'package:flutter/material.dart';
import '../models/iform.dart';
import '../models/disposable.dart';
import '../models/inested_form.dart';
import '../models/iarray_form.dart';

class FormController<T> {
  final Map<String, IForm> _formMap;

  Map<String, IForm> get forms => Map.unmodifiable(_formMap);

  final ValueNotifier<bool> isValid = ValueNotifier<bool>(false);

  FormController(this._formMap) {
    _initListeners();
    _updateValidStatus();
  }

  void _initListeners() {
    for (var form in _formMap.values) {
      form.valueNotifier.addListener(_updateValidStatus);
    }
  }

  void _updateValidStatus() {
    bool overallValid = true;
    for (var form in _formMap.values) {
      if (!_isValid(form)) {
        overallValid = false;
        break;
      }
    }
    // Only update if value actually changed to avoid unnecessary rebuilds
    if (isValid.value != overallValid) {
      isValid.value = overallValid;
    }
  }

  void showErrors() {
    for (var form in _formMap.values) {
      form.showError(true);
      _showErrorsRecursive(form);
    }
  }

  void _showErrorsRecursive(IForm form) {
    if (form is INestedForm) {
      form.innerController.showErrors();
    } else if (form is IArrayForm) {
      for (var controller in form.itemControllers) {
        controller.showErrors();
      }
    }
  }

  bool validateAll({bool showErrors = false}) {
    bool overallValid = true;
    for (var entry in _formMap.entries) {
      final form = entry.value;
      // Explicitly validate nested and array forms to update their internal isValid status
      if (form is INestedForm) {
        form.innerController.validateAll(showErrors: showErrors);
      } else if (form is IArrayForm) {
        for (var controller in form.itemControllers) {
          controller.validateAll(showErrors: showErrors);
        }
      }
      
      if (!_isValid(form)) {
        overallValid = false;
        if (showErrors) {
          form.errorNotifier.value = form.errorMessage(form.currentValue());
          form.showError(true);
        }
      }
    }
    // Only update if value actually changed to avoid unnecessary rebuilds
    if (isValid.value != overallValid) {
      isValid.value = overallValid;
    }
    return overallValid;
  }

  Map<String, dynamic> getValues() {
    final Map<String, dynamic> values = {};
    for (var entry in _formMap.entries) {
      values[entry.key] = entry.value.inputTransform(entry.value.currentValue());
    }
    return values;
  }

  bool _isValid(IForm form) => form.validate(form.currentValue());

  void clearAll() {
    for (var form in _formMap.values) {
      form.clear();
    }
  }

  void resetAll() {
    for (var form in _formMap.values) {
      form.reset();
    }
  }

  void addForm(String key, IForm form) {
    // Remove old form if exists
    final oldForm = _formMap[key];
    if (oldForm != null) {
      oldForm.valueNotifier.removeListener(_updateValidStatus);
      // Dispose old form if it has resources
      if (oldForm is Disposable) {
        (oldForm as Disposable).dispose();
      }
    }
    
    _formMap[key] = form;
    form.valueNotifier.addListener(_updateValidStatus);
    _updateValidStatus();
  }

  void replaceForms(Map<String, IForm> newForms) {
    for (var form in _formMap.values) {
      form.valueNotifier.removeListener(_updateValidStatus);
      // Dispose old forms that have resources
      if (form is Disposable) {
        (form as Disposable).dispose();
      }
    }
    _formMap.clear();
    _formMap.addAll(newForms);
    _initListeners();
    _updateValidStatus();
  }

  void removeForm(String key) {
    final IForm? form = _formMap.remove(key);
    if (form != null) {
      form.valueNotifier.removeListener(_updateValidStatus);
      _updateValidStatus();
    }
  }

  void dispose() {
    for (var form in _formMap.values) {
      form.valueNotifier.removeListener(_updateValidStatus);
      // Dispose forms that have resources (streams, subscriptions, etc.)
      if (form is Disposable) {
        (form as Disposable).dispose();
      }
    }
    isValid.dispose();
  }
}
