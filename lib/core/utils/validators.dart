/// Collection of common validators for form fields.
class Validators {
  Validators._();

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required.';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
      return 'Password must contain a lowercase letter.';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Password must contain an uppercase letter.';
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'Password must contain a number.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? original) {
    final passwordError = password(value);
    if (passwordError != null) return passwordError;
    if (value != original) return 'Passwords do not match.';
    return null;
  }

  static String? minLength(String? value, int min, [String fieldName = 'Field']) {
    if (value == null || value.length < min) {
      return '$fieldName must be at least $min characters.';
    }
    return null;
  }

  static String? maxLength(String? value, int max, [String fieldName = 'Field']) {
    if (value != null && value.length > max) {
      return '$fieldName must not exceed $max characters.';
    }
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) return 'OTP is required.';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Please enter a valid 6-digit OTP.';
    }
    return null;
  }
}
