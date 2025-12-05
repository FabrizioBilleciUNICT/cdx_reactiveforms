import 'dart:async';
import 'dart:convert';
import 'package:cdx_core/core/services/app/iapp_service.dart';
import 'package:cdx_core/core/services/app/ievent_service.dart';
import 'package:cdx_core/core/services/app/imedia_service.dart';
import 'package:cdx_core/core/services/app/itheme_service.dart';
import 'package:get_it/get_it.dart';
import 'package:cdx_reactiveforms/controllers/form_controller.dart';
import 'package:cdx_reactiveforms/forms/array.dart';
import 'package:cdx_reactiveforms/forms/boolean.dart';
import 'package:cdx_reactiveforms/forms/checkbox.dart';
import 'package:cdx_reactiveforms/forms/date.dart';
import 'package:cdx_reactiveforms/forms/dropdown.dart';
import 'package:cdx_reactiveforms/forms/email.dart';
import 'package:cdx_reactiveforms/forms/multiline.dart';
import 'package:cdx_reactiveforms/forms/multiselect.dart';
import 'package:cdx_reactiveforms/forms/nested.dart';
import 'package:cdx_reactiveforms/forms/numeric.dart';
import 'package:cdx_reactiveforms/forms/password.dart';
import 'package:cdx_reactiveforms/forms/radio.dart';
import 'package:cdx_reactiveforms/forms/text.dart';
import 'package:cdx_reactiveforms/models/dropdown_item.dart';
import 'package:cdx_reactiveforms/ui/layout_simple.dart';
import 'package:cdx_core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'services/app_services.dart';

void main() {
  _initializeServices();
  runApp(const MyApp());
}

void _initializeServices() {
  GetIt.I.registerSingleton<IEventService>(EventService());
  GetIt.I.registerSingleton<IMediaService>(MediaService());
  GetIt.I.registerSingleton<IThemeService>(AppThemeService());
  GetIt.I.registerSingleton<IAppService>(
    AppService(
      mappings: AppMappings(),
      components: AppComponents(),
      constants: AppConstants(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CDX Reactive Forms Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const FormsExamplePage(),
    );
  }
}

class FormsExamplePage extends StatefulWidget {
  const FormsExamplePage({super.key});

  @override
  State<FormsExamplePage> createState() => _FormsExamplePageState();
}

class _FormsExamplePageState extends State<FormsExamplePage> {
  late FormController _formController;
  final StreamController<List<DropdownItem<String>>> _countryStreamController =
      StreamController<List<DropdownItem<String>>>.broadcast();
  final StreamController<List<DropdownItem<String>>> _hobbyStreamController =
      StreamController<List<DropdownItem<String>>>.broadcast();
  final StreamController<List<DropdownItem<String>>> _genderStreamController =
      StreamController<List<DropdownItem<String>>>.broadcast();
  UserModel? _savedUserModel;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    // Emit stream data after form is created so subscription can catch it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStreams();
    });
  }

  void _initializeStreams() {
    _countryStreamController.add([
      DropdownItem(title: 'Italy', value: 'IT'),
      DropdownItem(title: 'France', value: 'FR'),
      DropdownItem(title: 'Germany', value: 'DE'),
      DropdownItem(title: 'Spain', value: 'ES'),
      DropdownItem(title: 'United Kingdom', value: 'UK'),
    ]);

    _hobbyStreamController.add([
      DropdownItem(title: 'Reading', value: 'reading'),
      DropdownItem(title: 'Sports', value: 'sports'),
      DropdownItem(title: 'Music', value: 'music'),
      DropdownItem(title: 'Travel', value: 'travel'),
      DropdownItem(title: 'Cooking', value: 'cooking'),
      DropdownItem(title: 'Photography', value: 'photography'),
    ]);

    _genderStreamController.add([
      DropdownItem(title: 'Male', value: 'male'),
      DropdownItem(title: 'Female', value: 'female'),
      DropdownItem(title: 'Other', value: 'other'),
      DropdownItem(title: 'Prefer not to say', value: 'prefer_not_to_say'),
    ]);
  }

  void _initializeForm() {
    final addressForm = NestedForm(
      hint: 'Address Information',
      label: 'Address',
      innerForms: {
        'street': TextForm<String>(
          hint: 'Street Address',
          label: 'Street',
          initialValue: null,
          isRequired: true,
        ),
        'city': TextForm<String>(
          hint: 'City',
          label: 'City',
          initialValue: null,
          isRequired: true,
        ),
        'zipCode': TextForm<String>(
          hint: 'ZIP Code',
          label: 'ZIP Code',
          initialValue: null,
          isRequired: true,
        ),
      },
    );

    _formController = FormController({
      'textField': TextForm<String>(
        hint: 'Enter your name',
        label: 'Full Name',
        initialValue: null,
        isRequired: true,
      ),
      'multilineField': MultilineForm<String>(
        hint: 'Enter your bio or description',
        label: 'Bio',
        initialValue: null,
        isRequired: false,
        minLines: 3,
        maxLines: 6,
      ),
      'emailField': EmailForm(
        hint: 'Enter your email',
        label: 'Email',
        initialValue: null,
        messageError: 'Please enter a valid email address',
        isRequired: true,
      ),
      'passwordField': PasswordForm(
        hint: 'Enter your password',
        label: 'Password',
        initialValue: null,
        messageError: 'Password must be at least 8 characters',
        isRequired: true,
      ),
      'intNumberField': IntNumberForm(
        hint: 'Enter your age',
        label: 'Age',
        initialValue: null,
        isRequired: true,
        minValue: 0,
        maxValue: 120,
      ),
      'doubleNumberField': DoubleNumberForm(
        hint: 'Enter your weight (kg)',
        label: 'Weight',
        initialValue: null,
        isRequired: false,
        minValue: 0.0,
        maxValue: 300.0,
      ),
      'dateField': DateForm(
        hint: 'Select your birth date',
        label: 'Birth Date',
        initialValue: null,
        outputFormat: 'dd/MM/yyyy',
        isRequired: true,
        minDate: DateTime(1900),
        maxDate: DateTime.now(),
      ),
      'booleanField': BooleanForm(
        hint: 'I agree to the terms and conditions',
        label: 'Terms & Conditions',
        initialValue: false,
        isRequired: true,
      ),
      'checkboxField': CheckboxForm(
        hint: 'I want to receive newsletter updates',
        label: 'Newsletter',
        initialValue: false,
        isRequired: false,
      ),
      'radioField': RadioForm<String>(
        hint: 'Select your gender',
        label: 'Gender',
        initialValue: null,
        optionsStream: _genderStreamController.stream,
        isRequired: true,
      ),
      'dropdownField': DropdownForm<String>(
        hint: 'Select your country',
        label: 'Country',
        initialValue: null,
        optionsStream: _countryStreamController.stream,
        isRequired: true,
      ),
      'multiselectField': SelectableForm<String>(
        hint: 'Select your hobbies',
        label: 'Hobbies',
        initialValue: [],
        optionsStream: _hobbyStreamController.stream,
        isRequired: true,
        minSize: 1,
        maxSize: 5,
      ),
      'address': addressForm,
      'phoneNumbers': ArrayForm(
        hint: 'Phone Numbers',
        label: 'Phone Numbers',
        itemFormFactory: () => {
          'type': TextForm<String>(
            hint: 'Type (e.g., Mobile, Home)',
            label: 'Type',
            initialValue: null,
            isRequired: true,
          ),
          'number': TextForm<String>(
            hint: 'Phone Number',
            label: 'Number',
            initialValue: null,
            isRequired: true,
          ),
        },
        isRequired: false,
        minItems: 0,
        maxItems: 5,
        initialValue: null,
      ),
    });
  }

  @override
  void dispose() {
    _formController.dispose();
    _countryStreamController.close();
    _hobbyStreamController.close();
    _genderStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CDX Reactive Forms Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'All Form Types Example',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This example demonstrates all available form types including nested forms.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildFormFields(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 24),
            _buildFormStatus(),
            const SizedBox(height: 24),
            _buildSavedModelOutput(),
            const SizedBox(height: 24),
            _buildFormValues(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    final delegate = SimpleFormLayout();
    return delegate.buildFormFields(
      context,
      _formController.forms,
      (context, form) {
        final errorBuilder = delegate.error(form);
        return form.build(context, errorBuilder);
      },
    );
  }

  void _loadExampleData() {
    final exampleUser = UserModel.getExample();
    _populateFormFromModel(exampleUser);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Example data loaded'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _clearForm() {
    _formController.clearAll();
    _savedUserModel = null;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form cleared')),
    );
  }

  void _saveForm() {
    final isValid = _formController.validateAll(showErrors: true);
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix validation errors before saving'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _savedUserModel = _createModelFromForm();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  UserModel _createModelFromForm() {
    final values = _formController.getValues();
    // getValues() should return JSON-ready values directly, no transformations needed
    return UserModel.fromJson(values);
  }

  void _populateFormFromModel(UserModel model) {
    final forms = _formController.forms;

    (forms['textField'] as TextForm<String>?)?.changeValue(model.fullName ?? '');
    (forms['multilineField'] as MultilineForm<String>?)?.changeValue(model.bio ?? '');
    (forms['emailField'] as EmailForm?)?.changeValue(model.email ?? '');
    (forms['passwordField'] as PasswordForm?)?.changeValue(model.password ?? '');
    (forms['intNumberField'] as IntNumberForm?)?.changeValue(model.age?.toString() ?? '');
    (forms['doubleNumberField'] as DoubleNumberForm?)?.changeValue(model.weight?.toString() ?? '');
    
    if (model.birthDate != null) {
      final dateForm = forms['dateField'] as DateForm?;
      if (dateForm != null) {
        final dateString = model.birthDate!.format(dateForm.outputFormat);
        dateForm.changeValue(dateString);
      }
    }
    
    (forms['booleanField'] as BooleanForm?)?.changeValue(model.termsAccepted);
    (forms['checkboxField'] as CheckboxForm?)?.changeValue(model.newsletter);
    (forms['radioField'] as RadioForm<String>?)?.changeValue(model.gender);
    (forms['dropdownField'] as DropdownForm<String>?)?.changeValue(model.country);
    (forms['multiselectField'] as SelectableForm<String>?)?.changeValue(model.hobbies);

    if (model.address != null) {
      final addressForm = forms['address'] as NestedForm?;
      if (addressForm != null) {
        final addressForms = addressForm.innerController.forms;
        (addressForms['street'] as TextForm<String>?)?.changeValue(model.address!.street ?? '');
        (addressForms['city'] as TextForm<String>?)?.changeValue(model.address!.city ?? '');
        (addressForms['zipCode'] as TextForm<String>?)?.changeValue(model.address!.zipCode ?? '');
      }
    }

    if (model.phoneNumbers.isNotEmpty) {
      final phoneNumbersForm = forms['phoneNumbers'] as ArrayForm?;
      if (phoneNumbersForm != null) {
        final phoneNumbersData = model.phoneNumbers
            .map((phone) => phone.toJson())
            .toList();
        phoneNumbersForm.changeValue(phoneNumbersData);
      }
    }
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _saveForm,
          icon: const Icon(Icons.save),
          label: const Text('Save Form (Create Model)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _loadExampleData,
                icon: const Icon(Icons.upload_file),
                label: const Text('Load Example'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _clearForm,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear All'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            final isValid = _formController.validateAll(showErrors: true);
            if (isValid) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Form is valid!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Form has validation errors'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Validate Form'),
        ),
      ],
    );
  }

  Widget _buildFormStatus() {
    return ValueListenableBuilder<bool>(
      valueListenable: _formController.isValid,
      builder: (context, isValid, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isValid ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isValid ? Colors.green : Colors.red,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.error,
                color: isValid ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                isValid ? 'Form is Valid' : 'Form has Errors',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isValid ? Colors.green.shade900 : Colors.red.shade900,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedModelOutput() {
    if (_savedUserModel == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'No saved model. Click "Save Form" to create a model from form values.',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      );
    }

    return ExpansionTile(
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          const Text('Saved UserModel (Post-Salvataggio)'),
        ],
      ),
      initiallyExpanded: true,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Model Instance:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              SelectableText(
                _savedUserModel.toString(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              const SizedBox(height: 16),
              const Text(
                'JSON (toJson):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              SelectableText(
                _formatJson(_savedUserModel!.toJson()),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pretty JSON:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              SelectableText(
                const JsonEncoder.withIndent('  ').convert(_savedUserModel!.toJson()),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormValues() {
    return ExpansionTile(
      title: const Text('Form Values (Raw JSON)'),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            _formatJson(_formController.getValues()),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }

  String _formatJson(Map<String, dynamic> json) {
    final buffer = StringBuffer();
    _formatJsonRecursive(json, buffer, 0);
    return buffer.toString();
  }

  void _formatJsonRecursive(dynamic value, StringBuffer buffer, int indent) {
    if (value is Map) {
      buffer.writeln('{');
      final entries = value.entries.toList();
      for (var i = 0; i < entries.length; i++) {
        final entry = entries[i];
        buffer.write('  ' * (indent + 1));
        buffer.write('"${entry.key}": ');
        _formatJsonRecursive(entry.value, buffer, indent + 1);
        if (i < entries.length - 1) buffer.write(',');
        buffer.writeln();
      }
      buffer.write('  ' * indent);
      buffer.write('}');
    } else if (value is List) {
      buffer.write('[');
      for (var i = 0; i < value.length; i++) {
        _formatJsonRecursive(value[i], buffer, indent);
        if (i < value.length - 1) buffer.write(', ');
      }
      buffer.write(']');
    } else if (value is String) {
      buffer.write('"$value"');
    } else if (value == null) {
      buffer.write('null');
    } else {
      buffer.write(value.toString());
    }
  }
}

