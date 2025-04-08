
import 'package:cdx_components/injector.dart';
import 'package:cdx_components/utils/extensions.dart';
import 'package:cdx_components/utils/numeric_range_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ArrayMapping<K> {
  final dynamic itemToInput;
  final dynamic outputToForm;

  ArrayMapping({
    this.itemToInput,
    this.outputToForm,
  });
}

class ObjectMapping {
  final Function(dynamic)? itemToInput;
  final Function(dynamic)? outputToForm;

  ObjectMapping({
    this.itemToInput,
    this.outputToForm,
  });
}


