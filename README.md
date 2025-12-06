# CDX Reactive Forms

A powerful, type-safe, and highly customizable reactive forms library for Flutter. Built with performance and developer experience in mind, CDX Reactive Forms provides a comprehensive set of form controls with built-in validation, error handling, and JSON serialization support.

## Features

✨ **Comprehensive Form Controls** - 19+ form types including text, email, password, numbers, dates, files, images, and more  
🔒 **Type-Safe** - Full type safety with generics and compile-time checks  
⚡ **Reactive** - Built on `ValueNotifier` for efficient, reactive updates  
🎨 **Customizable** - Extensive theming and customization options  
✅ **Built-in Validation** - Comprehensive validation with custom validators  
📦 **JSON Ready** - Direct JSON serialization/deserialization support  
🔄 **Nested Forms** - Support for nested and array forms for complex data structures  
📱 **Cross-Platform** - Works on mobile, web, and desktop  
🖱️ **Drag & Drop** - Native drag & drop support for files and images (web & desktop)  
🧪 **Well Tested** - Comprehensive test coverage  

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  cdx_reactiveforms:
    path: ../cdx_reactiveforms  # or use git/version if published
  cdx_core:
    path: ../cdx_core  # Required dependency
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:cdx_reactiveforms/controllers/form_controller.dart';
import 'package:cdx_reactiveforms/forms/text.dart';
import 'package:cdx_reactiveforms/forms/email.dart';

// Create a form controller
final formController = FormController({
  'name': TextForm<String>(
    hint: 'Enter your name',
    label: 'Full Name',
    initialValue: null,
    isRequired: true,
  ),
  'email': EmailForm(
    hint: 'Enter your email',
    label: 'Email',
    initialValue: null,
    messageError: 'Please enter a valid email',
    isRequired: true,
  ),
});

// Validate all forms
final isValid = formController.validateAll(showErrors: true);

// Get form values as JSON
final values = formController.getValues();
```

## Form Types

### Text Input Forms

#### TextForm
Basic text input field with customizable validation.

```dart
TextForm<String>(
  hint: 'Enter text',
  label: 'Text Field',
  initialValue: null,
  isRequired: true,
)
```

#### EmailForm
Email input with automatic email validation.

```dart
EmailForm(
  hint: 'Enter your email',
  label: 'Email',
  initialValue: null,
  messageError: 'Invalid email address',
  isRequired: true,
)
```

#### PasswordForm
Password input with visibility toggle.

```dart
PasswordForm(
  hint: 'Enter password',
  label: 'Password',
  initialValue: null,
  messageError: 'Password must be at least 8 characters',
  isRequired: true,
)
```

#### MultilineForm
Multi-line text input for longer content.

```dart
MultilineForm<String>(
  hint: 'Enter description',
  label: 'Description',
  initialValue: null,
  minLines: 3,
  maxLines: 6,
  isRequired: false,
)
```

#### URLForm
URL input with automatic protocol handling and validation.

```dart
URLForm(
  hint: 'Enter website URL',
  label: 'Website',
  initialValue: null,
  messageError: 'Please enter a valid URL',
  isRequired: false,
)
```

#### PhoneForm
Phone number input with international format support.

```dart
PhoneForm(
  hint: 'Enter phone number',
  label: 'Phone',
  initialValue: null,
  messageError: 'Invalid phone number',
  countryCode: '+39',  // Optional: auto-adds country code
  isRequired: false,
)
```

### Numeric Forms

#### IntNumberForm
Integer input with increment/decrement buttons and range validation.

```dart
IntNumberForm(
  hint: 'Enter age',
  label: 'Age',
  initialValue: null,
  minValue: 0,
  maxValue: 120,
  isRequired: true,
)
```

#### DoubleNumberForm
Decimal number input with range validation.

```dart
DoubleNumberForm(
  hint: 'Enter weight (kg)',
  label: 'Weight',
  initialValue: null,
  minValue: 0.0,
  maxValue: 300.0,
  isRequired: false,
)
```

### Date & Time Forms

#### DateForm
Date picker with customizable format and date range.

```dart
DateForm(
  hint: 'Select date',
  label: 'Birth Date',
  initialValue: null,
  outputFormat: 'dd/MM/yyyy',
  minDate: DateTime(1900),
  maxDate: DateTime.now(),
  isRequired: true,
)
```

#### TimeForm
Time picker with customizable format and time range.

```dart
TimeForm(
  hint: 'Select time',
  label: 'Preferred Time',
  initialValue: null,
  outputFormat: 'HH:mm',
  minTime: '09:00',
  maxTime: '18:00',
  isRequired: false,
)
```

### Selection Forms

#### DropdownForm
Single selection dropdown with reactive options.

```dart
final optionsStream = StreamController<List<DropdownItem<String>>>.broadcast();

DropdownForm<String>(
  hint: 'Select country',
  label: 'Country',
  initialValue: null,
  optionsStream: optionsStream.stream,
  isRequired: true,
)

// Update options
optionsStream.add([
  DropdownItem(title: 'Italy', value: 'IT'),
  DropdownItem(title: 'France', value: 'FR'),
]);
```

#### RadioForm
Radio button group for single selection.

```dart
RadioForm<String>(
  hint: 'Select gender',
  label: 'Gender',
  initialValue: null,
  optionsStream: genderStream.stream,
  isRequired: true,
)
```

#### SelectableForm (Multiselect)
Multi-selection form with min/max constraints.

```dart
SelectableForm<String>(
  hint: 'Select hobbies',
  label: 'Hobbies',
  initialValue: [],
  optionsStream: hobbiesStream.stream,
  minSize: 1,
  maxSize: 5,
  isRequired: true,
)
```

### Boolean Forms

#### BooleanForm
Switch/toggle for boolean values.

```dart
BooleanForm(
  hint: 'I agree to terms',
  label: 'Terms & Conditions',
  initialValue: false,
  isRequired: true,
)
```

#### CheckboxForm
Checkbox for boolean values.

```dart
CheckboxForm(
  hint: 'Subscribe to newsletter',
  label: 'Newsletter',
  initialValue: false,
  isRequired: false,
)
```

### File & Image Forms

#### FileForm
File upload with extension and size validation.

```dart
FileForm(
  hint: 'Select document',
  label: 'Document',
  initialValue: null,
  messageError: 'Please select a valid file',
  allowedExtensions: ['pdf', 'doc', 'docx'],
  maxSizeBytes: 5 * 1024 * 1024,  // 5MB
  filePicker: () async {
    // Use file_picker package or custom implementation
    return await pickFile();
  },
  enableDragDrop: true,  // Enable drag & drop (see below)
  isRequired: false,
)
```

#### ImageForm
Image upload with format validation and preview.

```dart
ImageForm(
  hint: 'Select image',
  label: 'Profile Image',
  initialValue: null,
  messageError: 'Please select a valid image',
  allowedFormats: ['jpg', 'jpeg', 'png'],
  maxSizeBytes: 2 * 1024 * 1024,  // 2MB
  imagePreviewHeight: 200.0,
  imagePicker: () async {
    // Use image_picker package or custom implementation
    return await pickImage();
  },
  enableDragDrop: true,  // Enable drag & drop (see below)
  isRequired: false,
)
```

### Complex Forms

#### NestedForm
Form containing other forms for nested data structures.

```dart
NestedForm(
  hint: 'Address Information',
  label: 'Address',
  innerForms: {
    'street': TextForm<String>(
      hint: 'Street',
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
  },
)
```

#### ArrayForm
Dynamic array of forms for lists of objects.

```dart
ArrayForm(
  hint: 'Phone Numbers',
  label: 'Phone Numbers',
  itemFormFactory: () => {
    'type': TextForm<String>(
      hint: 'Type',
      label: 'Type',
      initialValue: null,
      isRequired: true,
    ),
    'number': TextForm<String>(
      hint: 'Number',
      label: 'Number',
      initialValue: null,
      isRequired: true,
    ),
  },
  minItems: 0,
  maxItems: 5,
  initialValue: null,
)
```

## Drag & Drop Support

CDX Reactive Forms includes built-in support for drag & drop functionality on `FileForm` and `ImageForm`. The drag & drop feature is enabled by default and works on both web and desktop platforms.

### Enabling Drag & Drop

Drag & drop is enabled by default. You can disable it by setting `enableDragDrop: false`:

```dart
FileForm(
  // ... other parameters
  enableDragDrop: false,  // Disable drag & drop
)
```

### Web Implementation

For web applications, you need to set up HTML5 drag & drop events using `dart:html`. Here's a complete example:

```dart
import 'dart:html' as html;
import 'dart:io';
import 'package:cdx_reactiveforms/forms/file.dart';
import 'package:flutter/material.dart';

class FileUploadWidget extends StatefulWidget {
  @override
  _FileUploadWidgetState createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  late FileForm fileForm;
  GlobalKey key = GlobalKey();

  @override
  void initState() {
    super.initState();
    
    fileForm = FileForm(
      hint: 'Drag & drop or click to select',
      label: 'Document',
      initialValue: null,
      messageError: 'Invalid file',
      enableDragDrop: true,
      filePicker: () async => null,  // Optional: for click-to-select
    );
    
    // Set up drag & drop after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupDragAndDrop();
    });
  }

  void _setupDragAndDrop() {
    final element = html.document.querySelector('#file-drop-zone');
    if (element == null) return;

    // Prevent default drag behaviors
    element.onDragOver.listen((e) {
      e.preventDefault();
      e.stopPropagation();
    });

    element.onDragEnter.listen((e) {
      e.preventDefault();
      e.stopPropagation();
    });

    element.onDragLeave.listen((e) {
      e.preventDefault();
      e.stopPropagation();
    });

    // Handle file drop
    element.onDrop.listen((e) {
      e.preventDefault();
      e.stopPropagation();
      
      final files = e.dataTransfer?.files;
      if (files != null && files.isNotEmpty) {
        final htmlFile = files[0];
        final reader = html.FileReader();
        
        reader.onLoadEnd.listen((_) {
          // For web, you'll need to handle the file differently
          // as File.fromUri() doesn't work the same way
          // You might want to upload directly or use a different approach
          print('File dropped: ${htmlFile.name}');
        });
        
        reader.readAsDataUrl(htmlFile);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      child: fileForm.build(context, () => ValueListenableBuilder(
        valueListenable: fileForm.errorNotifier,
        builder: (context, error, _) => Text(error),
      )),
    );
  }
}
```

**Note for Web**: On web, file handling is different because `dart:io` File doesn't work the same way. You may need to:
- Upload files directly to a server
- Use `html.FileReader` to read file contents
- Store file data as `Uint8List` or base64 strings

### Desktop Implementation

For desktop applications (Windows, macOS, Linux), you can use the `desktop_drop` package for native drag & drop support:

#### 1. Add the dependency:

```yaml
dependencies:
  desktop_drop: ^0.4.0
```

#### 2. Implement drag & drop:

```dart
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cdx_reactiveforms/forms/file.dart';
import 'dart:io';

class FileUploadWidget extends StatefulWidget {
  @override
  _FileUploadWidgetState createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  bool _dragging = false;
  late FileForm fileForm;

  @override
  void initState() {
    super.initState();
    fileForm = FileForm(
      hint: 'Drag & drop or click to select',
      label: 'Document',
      initialValue: null,
      messageError: 'Invalid file',
      enableDragDrop: true,
      filePicker: () async {
        // Use file_picker for click-to-select
        final result = await FilePicker.platform.pickFiles();
        if (result != null && result.files.single.path != null) {
          return File(result.files.single.path!);
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) {
        setState(() => _dragging = false);
        if (detail.files.isNotEmpty) {
          final file = File(detail.files.first.path);
          // Trigger the form's drop handler
          // You'll need to access the internal _DragDropWrapper state
          // or handle it directly:
          fileForm.changeValue(file.path);
        }
      },
      onDragEntered: (detail) {
        setState(() => _dragging = true);
      },
      onDragExited: (detail) {
        setState(() => _dragging = false);
      },
      child: Container(
        decoration: BoxDecoration(
          border: _dragging
              ? Border.all(color: Colors.blue, width: 2)
              : null,
        ),
        child: fileForm.build(context, () => ValueListenableBuilder(
          valueListenable: fileForm.errorNotifier,
          builder: (context, error, _) => Text(error),
        )),
      ),
    );
  }
}
```

### Alternative: Using `super_drag_and_drop`

For a more comprehensive cross-platform solution, you can use `super_drag_and_drop`:

```yaml
dependencies:
  super_drag_and_drop: ^2.0.0
```

```dart
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

DropTarget(
  onDropOver: (event) {
    // Handle drag over
  },
  onDrop: (event) async {
    final items = await event.session.items;
    for (final item in items) {
      if (item.kind == DataKind.file) {
        final file = await item.getFile();
        if (file != null) {
          fileForm.changeValue(file.path);
        }
      }
    }
  },
  child: fileForm.build(context, errorBuilder),
)
```

### Mobile Platforms

On mobile platforms (iOS/Android), drag & drop from the file system is not typically used. Instead, use the `filePicker` or `imagePicker` callbacks with packages like:
- `file_picker` for file selection
- `image_picker` for image selection

## Form Controller

The `FormController` manages multiple forms and provides centralized validation and value access.

### Basic Usage

```dart
final controller = FormController({
  'name': TextForm<String>(...),
  'email': EmailForm(...),
});

// Validate all forms
final isValid = controller.validateAll(showErrors: true);

// Get all values as JSON
final values = controller.getValues();

// Clear all forms
controller.clearAll();

// Reset all forms to initial values
controller.resetAll();

// Show errors on all invalid forms
controller.showErrors();

// Check overall validation status
ValueListenableBuilder<bool>(
  valueListenable: controller.isValid,
  builder: (context, isValid, _) {
    return Text(isValid ? 'Valid' : 'Invalid');
  },
)
```

### Dynamic Form Management

```dart
// Add a form dynamically
controller.addForm('newField', TextForm<String>(...));

// Remove a form
controller.removeForm('newField');

// Replace all forms
controller.replaceForms({
  'field1': TextForm<String>(...),
  'field2': EmailForm(...),
});

// Dispose when done
controller.dispose();
```

## Validation

### Built-in Validation

All forms include built-in validation based on their type:
- **Required fields**: Check if value is present
- **Email**: Validates email format
- **URL**: Validates URL format
- **Phone**: Validates phone number format
- **Numbers**: Validates range (min/max)
- **Dates/Times**: Validates date/time ranges
- **Files/Images**: Validates extensions and file size

### Custom Validation

You can add custom validation using the `isValid` parameter:

```dart
TextForm<String>(
  hint: 'Username',
  label: 'Username',
  initialValue: null,
  isRequired: true,
  isValid: (value) {
    // Custom validation logic
    return value != null && value.length >= 3 && !value.contains(' ');
  },
)
```

### Error Messages

Customize error messages:

```dart
EmailForm(
  hint: 'Email',
  label: 'Email',
  initialValue: null,
  messageError: 'Please enter a valid email address',
  isRequired: true,
)
```

## JSON Serialization

Forms output values directly as JSON-ready data. Use with `json_serializable` or any JSON library:

```dart
// Get form values
final values = formController.getValues();

// Use with json_serializable
final user = UserModel.fromJson(values);

// Or with any JSON library
final jsonString = jsonEncode(values);
```

The `getValues()` method returns a `Map<String, dynamic>` where:
- Simple forms return primitive values (String, int, double, bool)
- Nested forms return `Map<String, dynamic>`
- Array forms return `List<Map<String, dynamic>>`
- All values are JSON-compatible (no custom objects)

## Theming

Forms use the theme from `cdx_core`. Customize the theme:

```dart
TextForm<String>(
  // ... other parameters
  themeData: CdxInputThemeData(
    // Custom theme properties
  ),
)
```

## Best Practices

1. **Always dispose controllers**: Call `controller.dispose()` when done
2. **Use streams for dynamic options**: Use `StreamController` for dropdown/radio options that change
3. **Validate before submission**: Always call `validateAll()` before processing form data
4. **Handle errors gracefully**: Show user-friendly error messages
5. **Use nested forms for complex data**: Break down complex forms into nested structures
6. **Leverage type safety**: Use proper generic types for compile-time safety

## Example

See the `/example` directory for a complete working example with all form types.

Run the example:

```bash
cd example
flutter pub get
flutter run
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[Add your license here]

## Support

For issues, questions, or contributions, please [open an issue](link-to-issues) or contact the maintainers.

---

**Made with ❤️ by Codedix**
