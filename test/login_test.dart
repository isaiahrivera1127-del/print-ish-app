import 'package:flutter_test/flutter_test.dart';

String? validatePassword(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter your password';
  }
  if (value.trim().length < 6) {
    return 'Password must be at least 6 characters long';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter your email';
  }
  final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value.trim())) {
    return 'Please enter a valid email address';
  }
  return null;
}

String? validateZipCode(String? value) {
  if (value == null || value.isEmpty) {
    return 'ZIP Code is required';
  }
  if (!RegExp(r'^\d{5}$').hasMatch(value)) {
    return 'Enter a valid 5-digit ZIP Code';
  }
  return null;
}

void main() {
  group('Automated Tests for login', () {

    group('Password Length Boundary Tests', () {
      test('Empty string (Below min boundary) -> Returns error', () {
        final result = validatePassword('');
        expect(result, equals('Please enter your password'));
      });

      test('5 characters (1 below boundary min) -> Returns error', () {
        final result = validatePassword('12345');
        expect(result, equals('Password must be at least 6 characters long'));
      });

      test('6 characters (Exact boundary min) -> Valid (Returns null)', () {
        final result = validatePassword('123456');
        expect(result, isNull);
      });

      test('7 characters (Above boundary min) -> Valid (Returns null)', () {
        final result = validatePassword('1234567');
        expect(result, isNull);
      });
    });

    group('Email Format Acceptance Tests', () {
      test('Empty email -> Returns error', () {
        final result = validateEmail('');
        expect(result, equals('Please enter your email'));
      });

      test('Missing domain ("user@com") -> Returns invalid format error', () {
        final result = validateEmail('user@com');
        expect(result, equals('Please enter a valid email address'));
      });

      test('Valid email ("user@example.com") -> Valid (Returns null)', () {
        final result = validateEmail('user@example.com');
        expect(result, isNull);
      });
    });


    group('ZIP Code 5-Digit Boundary Tests', () {
      test('4 digits (Below boundary length of 5) -> Returns error', () {
        final result = validateZipCode('1234');
        expect(result, equals('Enter a valid 5-digit ZIP Code'));
      });

      test('5 digits (Exact boundary length of 5) -> Valid (Returns null)', () {
        final result = validateZipCode('12345');
        expect(result, isNull);
      });

      test('6 digits (Above boundary length of 5) -> Returns error', () {
        final result = validateZipCode('123456');
        expect(result, equals('Enter a valid 5-digit ZIP Code'));
      });
    });

  });
}
