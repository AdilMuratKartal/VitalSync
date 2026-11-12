/// Form ve şifre doğrulama kurallarını içeren ortak yardımcı sınıf.
class AppValidators {
  AppValidators._();

  /// Şifre kuralları için anlık kontrol sonuçları
  static bool hasMinLength(String value, [int min = 8]) => value.length >= min;
  static bool hasUppercase(String value) => RegExp(r'[A-ZÇĞİÖŞÜ]').hasMatch(value);
  static bool hasLowercase(String value) => RegExp(r'[a-zçğıöşü]').hasMatch(value);
  static bool hasDigit(String value) => RegExp(r'[0-9]').hasMatch(value);
  static bool hasSpecialChar(String value) =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=/\\[\]~`]').hasMatch(value);

  /// Tüm şifre kriterlerinin sağlanıp sağlanmadığını kontrol eder
  static bool isPasswordStrong(String value) {
    return hasMinLength(value) &&
        hasUppercase(value) &&
        hasLowercase(value) &&
        hasDigit(value) &&
        hasSpecialChar(value);
  }

  /// 11 haneli TC Kimlik / Sicil No kontrolü
  static bool isValidTc(String value) {
    final clean = value.trim();
    return RegExp(r'^\d{11}$').hasMatch(clean);
  }

  /// Geçerli E-posta format kontrolü
  static bool isValidEmail(String value) {
    final clean = value.trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(clean);
  }

  /// Geçerli Telefon numarası kontrolü (en az 10 rakam)
  static bool isValidPhone(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    return digitsOnly.length >= 10;
  }

  /// Ad Soyad kontrolü (en az 2 kelime ve toplam 5 karakter)
  static bool isValidFullName(String value) {
    final clean = value.trim();
    final parts = clean.split(RegExp(r'\s+'));
    return parts.length >= 2 && clean.length >= 5;
  }

  /// TextFormField için TC Kimlik validatörü
  static String? validateTc(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'TC Kimlik / Sicil numarası zorunludur.';
    }
    if (!isValidTc(value)) {
      return 'Lütfen 11 haneli geçerli bir numara giriniz.';
    }
    return null;
  }

  /// TextFormField için E-posta validatörü
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi zorunludur.';
    }
    if (!isValidEmail(value)) {
      return 'Geçerli bir e-posta adresi giriniz (örn: ad@alan.com).';
    }
    return null;
  }

  /// TextFormField için Şifre validatörü
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre alanı boş bırakılamaz.';
    }
    if (!isPasswordStrong(value)) {
      return 'Lütfen aşağıdaki tüm şifre güvenlik kurallarını tamamlayınız.';
    }
    return null;
  }

  /// TextFormField için Ad Soyad validatörü
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ad Soyad zorunludur.';
    }
    if (!isValidFullName(value)) {
      return 'Lütfen adınızı ve soyadınızı giriniz.';
    }
    return null;
  }

  /// TextFormField için Telefon validatörü
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefon numarası zorunludur.';
    }
    if (!isValidPhone(value)) {
      return 'Geçerli bir telefon numarası giriniz.';
    }
    return null;
  }

  /// TC Kimlik veya E-posta girişinin geçerli olup olmadığını kontrol eder
  static bool isValidTcOrEmail(String value) {
    final clean = value.trim();
    return isValidTc(clean) || isValidEmail(clean);
  }

  /// TextFormField için TC veya E-posta validatörü
  static String? validateTcOrEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'TC Kimlik veya E-posta adresi zorunludur.';
    }
    if (!isValidTcOrEmail(value)) {
      return 'Geçerli bir TC Kimlik (11 hane) veya E-posta adresi giriniz.';
    }
    return null;
  }
}

