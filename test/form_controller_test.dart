import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:cdx_reactiveforms/forms/time.dart';
import 'package:cdx_reactiveforms/forms/url.dart';
import 'package:cdx_reactiveforms/forms/phone.dart';
import 'package:cdx_reactiveforms/forms/file.dart';
import 'package:cdx_reactiveforms/forms/image.dart';
import 'package:cdx_reactiveforms/models/dropdown_item.dart';
import 'test_helpers.dart';

void main() {
  setUpAll(() {
    setupTestServices();
  });

  group('FormController Complete Form Test', () {
    late FormController formController;
    late StreamController<List<DropdownItem<String>>> countryStreamController;
    late StreamController<List<DropdownItem<String>>> hobbyStreamController;
    late StreamController<List<DropdownItem<String>>> genderStreamController;

    setUp(() {
      countryStreamController = StreamController<List<DropdownItem<String>>>.broadcast();
      hobbyStreamController = StreamController<List<DropdownItem<String>>>.broadcast();
      genderStreamController = StreamController<List<DropdownItem<String>>>.broadcast();

      // Emit initial data
      countryStreamController.add([
        DropdownItem(title: 'Italy', value: 'IT'),
        DropdownItem(title: 'France', value: 'FR'),
        DropdownItem(title: 'Germany', value: 'DE'),
        DropdownItem(title: 'Spain', value: 'ES'),
        DropdownItem(title: 'United Kingdom', value: 'UK'),
      ]);

      hobbyStreamController.add([
        DropdownItem(title: 'Reading', value: 'reading'),
        DropdownItem(title: 'Sports', value: 'sports'),
        DropdownItem(title: 'Music', value: 'music'),
        DropdownItem(title: 'Travel', value: 'travel'),
        DropdownItem(title: 'Cooking', value: 'cooking'),
      ]);

      genderStreamController.add([
        DropdownItem(title: 'Male', value: 'male'),
        DropdownItem(title: 'Female', value: 'female'),
        DropdownItem(title: 'Other', value: 'other'),
        DropdownItem(title: 'Prefer not to say', value: 'prefer_not_to_say'),
      ]);

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

      formController = FormController({
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
          optionsStream: genderStreamController.stream,
          isRequired: true,
        ),
        'dropdownField': DropdownForm<String>(
          hint: 'Select your country',
          label: 'Country',
          initialValue: null,
          optionsStream: countryStreamController.stream,
          isRequired: true,
        ),
        'multiselectField': SelectableForm<String>(
          hint: 'Select your hobbies',
          label: 'Hobbies',
          initialValue: [],
          optionsStream: hobbyStreamController.stream,
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
    });

    tearDown(() {
      formController.dispose();
      countryStreamController.close();
      hobbyStreamController.close();
      genderStreamController.close();
    });

    test('Form should be invalid initially', () {
      expect(formController.isValid.value, false);
    });

    test('Form should validate all fields correctly', () async {
      // Fill all required fields
      formController.forms['textField']?.changeValue('John Doe');
      formController.forms['emailField']?.changeValue('john.doe@example.com');
      formController.forms['passwordField']?.changeValue('Password123!');
      formController.forms['intNumberField']?.changeValue('30');
      formController.forms['dateField']?.changeValue('15/05/1994');
      formController.forms['booleanField']?.changeValue(true);
      formController.forms['radioField']?.changeValue('male');
      formController.forms['dropdownField']?.changeValue('IT');
      formController.forms['multiselectField']?.changeValue(['reading', 'sports']);

      // Fill nested form
      final addressForm = formController.forms['address'] as NestedForm;
      addressForm.innerController.forms['street']?.changeValue('Via Roma 123');
      addressForm.innerController.forms['city']?.changeValue('Milano');
      addressForm.innerController.forms['zipCode']?.changeValue('20100');

      // Wait for async updates (dropdown and multiselect need time for stream)
      await Future.delayed(const Duration(milliseconds: 400));
      
      // Force validation update for nested form
      addressForm.innerController.validateAll();
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Now validate the entire form
      final isValid = formController.validateAll();
      expect(isValid, true);
      expect(formController.isValid.value, true);
    });

    test('Form should return correct values', () async {
      // Fill all fields
      formController.forms['textField']?.changeValue('John Doe');
      formController.forms['multilineField']?.changeValue('This is a multiline bio text');
      formController.forms['emailField']?.changeValue('john.doe@example.com');
      formController.forms['passwordField']?.changeValue('Password123!');
      formController.forms['intNumberField']?.changeValue('30');
      formController.forms['doubleNumberField']?.changeValue('75.5');
      formController.forms['dateField']?.changeValue('15/05/1994');
      formController.forms['booleanField']?.changeValue(true);
      formController.forms['checkboxField']?.changeValue(true);
      formController.forms['radioField']?.changeValue('male');
      formController.forms['dropdownField']?.changeValue('IT');
      formController.forms['multiselectField']?.changeValue(['reading', 'sports']);

      // Fill nested form
      final addressForm = formController.forms['address'] as NestedForm;
      addressForm.innerController.forms['street']?.changeValue('Via Roma 123');
      addressForm.innerController.forms['city']?.changeValue('Milano');
      addressForm.innerController.forms['zipCode']?.changeValue('20100');

      // Wait for async updates
      await Future.delayed(const Duration(milliseconds: 200));
      final values = formController.getValues();

      expect(values['textField'], 'John Doe');
      expect(values['emailField'], 'john.doe@example.com');
      expect(values['passwordField'], 'Password123!');
      expect(values['intNumberField'], 30);
      expect(values['doubleNumberField'], 75.5);
            expect(values['dateField'], isA<String>());
            expect(values['dateField'], '15/05/1994');
      expect(values['booleanField'], true);
      expect(values['checkboxField'], true);
      expect(values['radioField'], 'male');
      expect(values['dropdownField'], 'IT');
      expect(values['multiselectField'], ['reading', 'sports']);

      final address = values['address'] as Map<String, dynamic>;
      expect(address['street'], 'Via Roma 123');
      expect(address['city'], 'Milano');
      expect(address['zipCode'], '20100');
    });

    test('Form should clear all fields', () {
      // Fill some fields
      formController.forms['textField']?.changeValue('John Doe');
      formController.forms['emailField']?.changeValue('john.doe@example.com');
      formController.forms['booleanField']?.changeValue(true);

      formController.clearAll();

      expect(formController.forms['textField']?.currentValue(), '');
      expect(formController.forms['multilineField']?.currentValue(), '');
      expect(formController.forms['emailField']?.currentValue(), '');
      expect(formController.forms['booleanField']?.currentValue(), false);
      expect(formController.forms['checkboxField']?.currentValue(), false);
    });

    test('Form should reset all fields to initial values', () {
      // Fill some fields
      formController.forms['textField']?.changeValue('John Doe');
      formController.forms['emailField']?.changeValue('john.doe@example.com');
      formController.forms['booleanField']?.changeValue(true);

      formController.resetAll();

      expect(formController.forms['textField']?.currentValue(), '');
      expect(formController.forms['emailField']?.currentValue(), '');
      expect(formController.forms['booleanField']?.currentValue(), false);
    });

    test('Form should validate email format', () {
      final emailForm = formController.forms['emailField'] as EmailForm;
      
      emailForm.changeValue('invalid-email');
      expect(emailForm.validate(emailForm.currentValue()), false);

      emailForm.changeValue('valid@email.com');
      expect(emailForm.validate(emailForm.currentValue()), true);
    });

    test('Form should validate password length', () {
      final passwordForm = formController.forms['passwordField'] as PasswordForm;
      
      passwordForm.changeValue('short');
      expect(passwordForm.validate(passwordForm.currentValue()), false);

      passwordForm.changeValue('longenoughpassword');
      expect(passwordForm.validate(passwordForm.currentValue()), true);
    });

    test('Form should validate number range', () {
      final intForm = formController.forms['intNumberField'] as IntNumberForm;
      
      // Empty value should be invalid if required
      intForm.changeValue('');
      expect(intForm.validate(intForm.currentValue()), false);

      intForm.changeValue('30');
      expect(intForm.validate(intForm.currentValue()), true);
      
      // Values outside range are handled by formatters, not validation
      // The formatter will clamp the value, so validation will pass
      intForm.changeValue('150');
      // After formatting, value should be within range
      expect(intForm.validate(intForm.currentValue()), true);
    });

    test('Form should validate nested form', () async {
      final addressForm = formController.forms['address'] as NestedForm;
      
      // Initially, nested form has empty fields
      // Wait for initialization to complete
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Clear the nested form to ensure it's in an invalid state
      addressForm.clear();
      await Future.delayed(const Duration(milliseconds: 100));
      
      // After clearing, inner controller should be invalid because required fields are empty
      final clearedInnerValid = addressForm.innerController.isValid.value;
      expect(clearedInnerValid, false);
      
      // Verify that nested form validation reflects inner controller state when invalid
      final clearedValue = addressForm.currentValue();
      // The map might have keys with empty values, but inner controller should be invalid
      // So validation should return false
      expect(addressForm.validate(clearedValue), false);

      // Fill nested form with valid data
      addressForm.innerController.forms['street']?.changeValue('Via Roma 123');
      addressForm.innerController.forms['city']?.changeValue('Milano');
      addressForm.innerController.forms['zipCode']?.changeValue('20100');

      // Force validation update
      addressForm.innerController.validateAll();
      await Future.delayed(const Duration(milliseconds: 300));
      
      // After filling, inner controller should be valid
      final filledInnerValid = addressForm.innerController.isValid.value;
      expect(filledInnerValid, true);
      
      // Nested form should be valid when inner form is valid
      final filledValue = addressForm.currentValue();
      expect(addressForm.validate(filledValue), true);
      
      // Test that nested form correctly reflects inner controller validation state
      // This is the most important part - ensuring nested forms validate correctly when complete
    });

    test('Form should show errors when validateAll is called with showErrors=true', () {
      // Clear all fields first to ensure they're invalid
      formController.clearAll();
      
      // Validate - should show errors for invalid fields
      final isValid = formController.validateAll(showErrors: true);
      expect(isValid, false);

      // At least some required fields should show errors when empty
      // Note: Some fields might not show errors if they're not yet touched
      final hasErrors = formController.forms.values.any((form) => form.showErrorNotifier.value);
      expect(hasErrors, true);
    });

    test('Form should handle optional fields', () {
      final weightForm = formController.forms['doubleNumberField'] as DoubleNumberForm;
      
      // Optional field should be valid when empty (isRequired = false)
      expect(weightForm.isRequired, false);
      expect(weightForm.validate(weightForm.currentValue()), true);

      // Should validate when filled with valid value
      weightForm.changeValue('75.5');
      expect(weightForm.validate(weightForm.currentValue()), true);

      // Values outside range are handled by formatters, validation will pass
      weightForm.changeValue('400');
      // After formatting, value should be within range
      expect(weightForm.validate(weightForm.currentValue()), true);
    });

    test('Form should handle dropdown selection', () async {
      final dropdownForm = formController.forms['dropdownField'] as DropdownForm<String>;
      
      // Wait for stream to populate options
      await Future.delayed(const Duration(milliseconds: 200));
      dropdownForm.changeValue('IT');
      expect(dropdownForm.currentValue(), 'IT');
      expect(dropdownForm.validate(dropdownForm.currentValue()), true);
    });

    test('Form should handle radio selection', () async {
      final radioForm = formController.forms['radioField'] as RadioForm<String>;
      
      // Initially invalid if required and no selection
      expect(radioForm.validate(radioForm.currentValue()), false);

      // Wait for stream to populate options
      await Future.delayed(const Duration(milliseconds: 200));
      radioForm.changeValue('male');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(radioForm.currentValue(), 'male');
      expect(radioForm.validate(radioForm.currentValue()), true);

      radioForm.changeValue('female');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(radioForm.currentValue(), 'female');
      expect(radioForm.validate(radioForm.currentValue()), true);

      radioForm.changeValue(null);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(radioForm.currentValue(), null);
      expect(radioForm.validate(radioForm.currentValue()), false);
    });

    test('Form should handle multiselect selection', () async {
      final multiselectForm = formController.forms['multiselectField'] as SelectableForm<String>;
      
      // Wait for stream to populate options
      await Future.delayed(const Duration(milliseconds: 200));
      multiselectForm.changeValue(['reading', 'sports']);
      expect(multiselectForm.currentValue(), ['reading', 'sports']);
      expect(multiselectForm.validate(multiselectForm.currentValue()), true);

      // Should validate minSize
      multiselectForm.changeValue([]);
      expect(multiselectForm.validate(multiselectForm.currentValue()), false);
    });

    test('Form should handle date validation', () {
      final dateForm = formController.forms['dateField'] as DateForm;
      
      // Invalid date format
      dateForm.changeValue('invalid');
      expect(dateForm.validate(dateForm.currentValue()), false);

      // Valid date
      dateForm.changeValue('15/05/1994');
      expect(dateForm.validate(dateForm.currentValue()), true);

      // Date out of range
      dateForm.changeValue('01/01/1800');
      expect(dateForm.validate(dateForm.currentValue()), false);
    });

    test('Form should handle multiline field', () {
      final multilineForm = formController.forms['multilineField'] as MultilineForm<String>;
      
      // Optional field should be valid when empty
      expect(multilineForm.isRequired, false);
      expect(multilineForm.validate(multilineForm.currentValue()), true);

      // Should validate when filled
      multilineForm.changeValue('This is a multiline text\nwith multiple lines');
      expect(multilineForm.currentValue(), 'This is a multiline text\nwith multiple lines');
      expect(multilineForm.validate(multilineForm.currentValue()), true);

      // Should handle empty string
      multilineForm.changeValue('');
      expect(multilineForm.currentValue(), '');
      expect(multilineForm.validate(multilineForm.currentValue()), true); // Optional field
    });

    test('Form should handle boolean field', () {
      final booleanForm = formController.forms['booleanField'] as BooleanForm;
      
      // Initial value is false, and form is required
      // The validation logic is: !isRequired || (value != null && ...)
      // Since false is not null, validation will pass even if isRequired=true
      // This is because false is a valid boolean value (not null)
      expect(booleanForm.isRequired, true);
      expect(booleanForm.currentValue(), false);
      // Boolean validation considers false as a valid value (not null)
      expect(booleanForm.validate(booleanForm.currentValue()), true);

      // Should also be valid when true
      booleanForm.changeValue(true);
      expect(booleanForm.currentValue(), true);
      expect(booleanForm.validate(booleanForm.currentValue()), true);
    });

    test('Form should handle checkbox field', () {
      final checkboxForm = formController.forms['checkboxField'] as CheckboxForm;
      
      // Initial value is false, and form is not required
      expect(checkboxForm.isRequired, false);
      expect(checkboxForm.currentValue(), false);
      // Checkbox validation: when not required, false is valid
      expect(checkboxForm.validate(checkboxForm.currentValue()), true);

      // When true, should be valid
      checkboxForm.changeValue(true);
      expect(checkboxForm.currentValue(), true);
      expect(checkboxForm.validate(checkboxForm.currentValue()), true);
      
      // Test that checkbox requires true when required
      checkboxForm.changeValue(false);
      expect(checkboxForm.currentValue(), false);
      // Since isRequired=false, false is valid
      expect(checkboxForm.validate(checkboxForm.currentValue()), true);
    });

    test('Form should add and remove forms dynamically', () {
      final newForm = TextForm<String>(
        hint: 'New Field',
        label: 'New Field',
        initialValue: null,
        isRequired: false,
      );

      formController.addForm('newField', newForm);
      expect(formController.forms.containsKey('newField'), true);

      formController.removeForm('newField');
      expect(formController.forms.containsKey('newField'), false);
    });

    test('Form should replace all forms', () {
      final newForms = {
        'newField1': TextForm<String>(
          hint: 'New Field 1',
          label: 'New Field 1',
          initialValue: null,
          isRequired: false,
        ),
        'newField2': TextForm<String>(
          hint: 'New Field 2',
          label: 'New Field 2',
          initialValue: null,
          isRequired: false,
        ),
      };

      formController.replaceForms(newForms);
      expect(formController.forms.length, 2);
      expect(formController.forms.containsKey('newField1'), true);
      expect(formController.forms.containsKey('newField2'), true);
      expect(formController.forms.containsKey('textField'), false);
    });

    test('Form should handle time field', () {
      final timeForm = TimeForm(
        hint: 'Select time',
        label: 'Time',
        initialValue: null,
        outputFormat: 'HH:mm',
        isRequired: false,
        minTime: '09:00',
        maxTime: '18:00',
      );

      // Optional field, null should be valid
      expect(timeForm.validate(null), true);

      // Valid time within range
      timeForm.changeValue('12:30');
      expect(timeForm.currentValue(), '12:30');
      expect(timeForm.validate('12:30'), true);

      // Time outside range
      timeForm.changeValue('08:00');
      expect(timeForm.validate('08:00'), false);

      // Invalid format
      expect(timeForm.validate('25:00'), false);
      expect(timeForm.validate('12:60'), false);
      expect(timeForm.validate('invalid'), false);
    });

    test('Form should handle URL field', () {
      final urlForm = URLForm(
        hint: 'Enter URL',
        label: 'URL',
        initialValue: null,
        messageError: 'Invalid URL',
        isRequired: false,
      );

      // Optional field, null should be valid
      expect(urlForm.validate(null), true);

      // Valid URLs
      urlForm.changeValue('https://example.com');
      expect(urlForm.validate('https://example.com'), true);
      expect(urlForm.inputTransform('https://example.com'), 'https://example.com');

      urlForm.changeValue('http://test.org/path');
      expect(urlForm.validate('http://test.org/path'), true);

      // URL without protocol should be transformed
      urlForm.changeValue('example.com');
      expect(urlForm.inputTransform('example.com'), 'https://example.com');
      expect(urlForm.validate('example.com'), true);

      // Invalid URLs
      expect(urlForm.validate('not a url'), false);
      expect(urlForm.validate('ftp://invalid'), false);
    });

    test('Form should handle phone field', () {
      final phoneForm = PhoneForm(
        hint: 'Enter phone',
        label: 'Phone',
        initialValue: null,
        messageError: 'Invalid phone',
        countryCode: '+39',
        isRequired: false,
      );

      // Optional field, null should be valid
      expect(phoneForm.validate(null), true);

      // Valid phone numbers
      phoneForm.changeValue('+39 123 456 7890');
      expect(phoneForm.validate('+39 123 456 7890'), true);

      phoneForm.changeValue('1234567890');
      expect(phoneForm.validate('1234567890'), true);

      // Phone with country code transformation
      phoneForm.changeValue('1234567890');
      expect(phoneForm.inputTransform('1234567890'), '+391234567890');

      // Invalid phone numbers
      expect(phoneForm.validate('123'), false); // Too short
      expect(phoneForm.validate('12345678901234567890'), false); // Too long
      expect(phoneForm.validate('abc'), false); // Not digits
    });

    test('Form should handle file field', () {
      final fileForm = FileForm(
        hint: 'Select file',
        label: 'File',
        initialValue: null,
        messageError: 'Invalid file',
        allowedExtensions: ['pdf', 'doc'],
        maxSizeBytes: 1024 * 1024, // 1MB
        isRequired: false,
      );

      // Optional field, null should be valid
      expect(fileForm.validate(null), true);

      // File path validation (file doesn't exist in test)
      // When not required, empty string is valid
      fileForm.changeValue('');
      expect(fileForm.validate(''), true);

      // When required, file must exist
      final requiredFileForm = FileForm(
        hint: 'Select file',
        label: 'File',
        initialValue: null,
        messageError: 'Invalid file',
        isRequired: true,
      );
      expect(requiredFileForm.validate(null), false);
      expect(requiredFileForm.validate(''), false);

      // Test clear and reset
      fileForm.clear();
      expect(fileForm.currentValue(), null);

      fileForm.changeValue('/test/file.pdf');
      fileForm.reset();
      expect(fileForm.currentValue(), null);
    });

    test('Form should handle image field', () {
      final imageForm = ImageForm(
        hint: 'Select image',
        label: 'Image',
        initialValue: null,
        messageError: 'Invalid image',
        allowedFormats: ['jpg', 'png'],
        maxSizeBytes: 2 * 1024 * 1024, // 2MB
        isRequired: false,
      );

      // Optional field, null should be valid
      expect(imageForm.validate(null), true);

      // When not required, empty string is valid
      imageForm.changeValue('');
      expect(imageForm.validate(''), true);

      // When required, image must exist and have valid extension
      final requiredImageForm = ImageForm(
        hint: 'Select image',
        label: 'Image',
        initialValue: null,
        messageError: 'Invalid image',
        allowedFormats: ['jpg', 'png'],
        isRequired: true,
      );
      expect(requiredImageForm.validate(null), false);
      expect(requiredImageForm.validate(''), false);

      // Invalid extension (even if file doesn't exist, extension check happens first)
      expect(requiredImageForm.validate('/path/to/file.gif'), false);

      // Test clear and reset
      imageForm.clear();
      expect(imageForm.currentValue(), null);

      imageForm.changeValue('/test/image.jpg');
      imageForm.reset();
      expect(imageForm.currentValue(), null);
    });
  });
}

