
import 'package:flutter/material.dart';

import '../models/iform.dart';

/// Controller reattivo dei form, che gestisce una mappa di IForm.
/// Permette di validare, recuperare i valori, resettare e pulire tutti i form.
class FormController<T> {
  /// Mappa chiave/form
  final Map<String, IForm> _formMap;

  Map<String, IForm> get forms => _formMap;

  /// Notifica se tutti i campi sono validi.
  final ValueNotifier<bool> isValid = ValueNotifier<bool>(false);

  /// Costruisce il controller a partire da una mappa di form.
  FormController(this._formMap) {
    _initListeners();
    _updateValidStatus(); // inizializza lo stato valido
  }

  /// Inizializza i listener per ciascun form per tenere traccia dei cambiamenti.
  void _initListeners() {
    for (var form in _formMap.values) {
      form.errorNotifier.addListener(_updateValidStatus);
    }
  }

  /// Aggiorna lo stato complessivo di validità, valutando ogni form.
  void _updateValidStatus() {
    bool overallValid = true;
    for (var form in _formMap.values) {
      print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA ${_formMap.keys}");
      // Utilizza currentValue() per recuperare il valore corrente del campo
      // e validate() per controllare la validità.
      if (!_isValid(form)) {
        overallValid = false;
        break;
      }
    }
    isValid.value = overallValid;
  }

  /// Valida tutti i form.
  ///
  /// Se [showErrors] è true, si può implementare un comportamento per "forzare" la visualizzazione degli errori
  /// (ad es. settando manualmente l'errorNotifier) a seconda della strategia scelta.
  bool validateAll({bool showErrors = false}) {
    bool overallValid = true;
    _formMap.forEach((key, form) {
      if (!_isValid(form)) {
        overallValid = false;
        if (showErrors) {
          // A seconda dell’implementazione di IForm, si potrebbe forzare la visualizzazione
          // dell'errore in questo modo oppure utilizzare ulteriori callback.
          form.errorNotifier.value = form.errorMessage(form.currentValue());
        }
      }
    });
    isValid.value = overallValid;
    return overallValid;
  }

  /// Restituisce una mappa con le chiavi e i valori correnti dei form.
  Map<String, dynamic> getValues() {
    final Map<String, dynamic> values = {};
    _formMap.forEach((key, form) {
      values[key] = form.inputTransform(form.currentValue());
    });
    return values;
  }

  bool _isValid(IForm form) => form.validate(form.currentValue());

  /// Pulisce (clear) tutti i campi del form.
  void clearAll() {
    _formMap.forEach((key, form) {
      form.clear();
    });
  }

  /// Resetta tutti i campi del form al valore iniziale.
  void resetAll() {
    _formMap.forEach((key, form) {
      form.reset();
    });
  }

  /// Permette di aggiungere un nuovo form alla mappa.
  void addForm(String key, IForm form) {
    _formMap[key] = form;
    form.errorNotifier.addListener(_updateValidStatus);
    _updateValidStatus();
  }

  void reset(Map<String, IForm> values) {
    resetAll();
    values.forEach((key, form) {
      _formMap[key] = form;
      form.errorNotifier.addListener(_updateValidStatus);
    });
    _updateValidStatus();
  }

  /// Permette di rimuovere un form dalla mappa.
  void removeForm(String key) {
    final IForm? form = _formMap.remove(key);
    if (form != null) {
      form.errorNotifier.removeListener(_updateValidStatus);
      _updateValidStatus();
    }
  }

  /// Libera le risorse (es. listener) utilizzate dal controller.
  void dispose() {
    for (var form in _formMap.values) {
      form.errorNotifier.removeListener(_updateValidStatus);
    }
    isValid.dispose();
  }
}
