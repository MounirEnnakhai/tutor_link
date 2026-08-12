class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(r'^\+?[0-9]{8,15}$');
    if (!regex.hasMatch(value)) return 'Enter a valid phone number';
    return null;
  }

  static String? positiveNumber(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    final n = double.tryParse(value);
    if (n == null) return 'Enter a valid number';
    if (n <= 0) return 'Must be greater than 0';
    return null;
  }

  // ✅ FIXED TYPES BELOW

  static String? Function(String?) minLength(int min) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'This field is required';
      }
      if (value.length < min) {
        return 'Minimum $min characters required';
      }
      return null;
    };
  }

  static String? Function(String?) maxLength(int max) {
    return (String? value) {
      if (value != null && value.length > max) {
        return 'Maximum $max characters allowed';
      }
      return null;
    };
  }

  static String? Function(String?) combined(
      List<String? Function(String?)> validators) {
    return (String? value) {
      for (final v in validators) {
        final result = v(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}