 String? customValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }

    // Regular expression to allow only letters and numbers
    final regex = RegExp(r'^[a-zA-Z0-9]+$');

    if (!regex.hasMatch(value)) {
      return 'Only letters and numbers are allowed.';
    }

    return null;
  }