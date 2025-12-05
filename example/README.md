# CDX Reactive Forms Example

This example demonstrates all available form types in the `cdx_reactiveforms` package.

## Form Types Included

1. **TextForm** - Basic text input field
2. **EmailForm** - Email validation
3. **PasswordForm** - Password input with visibility toggle
4. **IntNumberForm** - Integer number input with increment/decrement buttons
5. **DoubleNumberForm** - Decimal number input
6. **DateForm** - Date picker
7. **BooleanForm** - Switch/checkbox
8. **DropdownForm** - Single selection dropdown
9. **SelectableForm** - Multi-selection form
10. **NestedForm** - Nested form containing other forms (recursive)

## Features Demonstrated

- Form validation
- Error display
- Form state management
- Nested forms (form within form)
- Real-time validation status
- Clear and reset functionality
- JSON output of form values

## Running the Example

1. Navigate to the example directory:
   ```bash
   cd example
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Usage

The example shows:
- How to create each form type
- How to use FormController to manage multiple forms
- How to validate all forms at once
- How to clear and reset forms
- How to access form values as JSON
- How to create nested forms for complex data structures

## Example Structure

The example includes:
- A main form with all form types
- A nested address form (NestedForm) containing street, city, and zip code fields
- Real-time validation status indicator
- Action buttons for validation, clear, and reset
- JSON viewer showing current form values

