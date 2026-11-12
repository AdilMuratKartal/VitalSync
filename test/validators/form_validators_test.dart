import 'package:flutter_test/flutter_test.dart';
import 'package:vitalsync/core/utils/validators.dart';

void main() {
  group('AppValidators - Şifre Kuralları Testleri', () {
    test('hasMinLength: 8 karakter ve üzeri doğru kontrol edilir', () {
      expect(AppValidators.hasMinLength('1234567'), isFalse);
      expect(AppValidators.hasMinLength('12345678'), isTrue);
      expect(AppValidators.hasMinLength('UzunSifre123!'), isTrue);
    });

    test('hasUppercase: En az bir büyük harf olmalıdır', () {
      expect(AppValidators.hasUppercase('sifre123!'), isFalse);
      expect(AppValidators.hasUppercase('Sifre123!'), isTrue);
      expect(AppValidators.hasUppercase('Şifre123!'), isTrue); // Türkçe karakter desteği
    });

    test('hasLowercase: En az bir küçük harf olmalıdır', () {
      expect(AppValidators.hasLowercase('SIFRE123!'), isFalse);
      expect(AppValidators.hasLowercase('Sifre123!'), isTrue);
      expect(AppValidators.hasLowercase('ŞİFREı123!'), isTrue);
    });

    test('hasDigit: En az bir rakam içermelidir', () {
      expect(AppValidators.hasDigit('Sifre!abc'), isFalse);
      expect(AppValidators.hasDigit('Sifre1!abc'), isTrue);
    });

    test('hasSpecialChar: Özel karakter doğrulaması', () {
      expect(AppValidators.hasSpecialChar('Sifre123'), isFalse);
      expect(AppValidators.hasSpecialChar('Sifre123!'), isTrue);
      expect(AppValidators.hasSpecialChar('Sifre123@'), isTrue);
      expect(AppValidators.hasSpecialChar('Sifre123#'), isTrue);
    });

    test('isPasswordStrong: Tüm kriterler sağlandığında geçerli olmalıdır', () {
      expect(AppValidators.isPasswordStrong('zayif'), isFalse);
      expect(AppValidators.isPasswordStrong('Dentora2026!'), isTrue);
      expect(AppValidators.isPasswordStrong('Selin123*'), isTrue);
    });

    test('validatePassword: Boş ve zayıf şifre durumlarında hata mesajı döner', () {
      expect(AppValidators.validatePassword(null), 'Şifre alanı boş bırakılamaz.');
      expect(AppValidators.validatePassword(''), 'Şifre alanı boş bırakılamaz.');
      expect(
        AppValidators.validatePassword('123'),
        'Lütfen aşağıdaki tüm şifre güvenlik kurallarını tamamlayınız.',
      );
      expect(AppValidators.validatePassword('Dentora2026!'), isNull);
    });
  });

  group('AppValidators - Kimlik & E-posta Testleri', () {
    test('isValidTc: Tam 11 haneli rakamlardan oluşmalıdır', () {
      expect(AppValidators.isValidTc('1234567890'), isFalse); // 10 hane
      expect(AppValidators.isValidTc('123456789012'), isFalse); // 12 hane
      expect(AppValidators.isValidTc('1234567890a'), isFalse); // harf içeriyor
      expect(AppValidators.isValidTc('34891204829'), isTrue);
      expect(AppValidators.isValidTc('10948271650'), isTrue);
    });

    test('validateTc: Zorunlu alan ve format kontrolü', () {
      expect(AppValidators.validateTc(''), 'TC Kimlik / Sicil numarası zorunludur.');
      expect(AppValidators.validateTc('123'), 'Lütfen 11 haneli geçerli bir numara giriniz.');
      expect(AppValidators.validateTc('34891204829'), isNull);
    });

    test('isValidEmail: E-posta formatı doğru kontrol edilir', () {
      expect(AppValidators.isValidEmail('gecersiz'), isFalse);
      expect(AppValidators.isValidEmail('test@'), isFalse);
      expect(AppValidators.isValidEmail('test@alan'), isFalse);
      expect(AppValidators.isValidEmail('zeynep.demir@eposta.com'), isTrue);
      expect(AppValidators.isValidEmail('selin.yilmaz@dentora.com'), isTrue);
    });

    test('validateEmail: Zorunlu alan ve e-posta kontrolü', () {
      expect(AppValidators.validateEmail(null), 'E-posta adresi zorunludur.');
      expect(AppValidators.validateEmail('hatali-posta'), 'Geçerli bir e-posta adresi giriniz (örn: ad@alan.com).');
      expect(AppValidators.validateEmail('doktor@dentora.com'), isNull);
    });

    test('isValidTcOrEmail & validateTcOrEmail: Hem TC hem E-posta desteklenir', () {
      expect(AppValidators.isValidTcOrEmail('34891204829'), isTrue);
      expect(AppValidators.isValidTcOrEmail('selin.yilmaz@dentora.com'), isTrue);
      expect(AppValidators.isValidTcOrEmail('gecersiz'), isFalse);

      expect(AppValidators.validateTcOrEmail(''), 'TC Kimlik veya E-posta adresi zorunludur.');
      expect(AppValidators.validateTcOrEmail('34891204829'), isNull);
      expect(AppValidators.validateTcOrEmail('selin.yilmaz@dentora.com'), isNull);
      expect(
        AppValidators.validateTcOrEmail('12345'),
        'Geçerli bir TC Kimlik (11 hane) veya E-posta adresi giriniz.',
      );
    });
  });

  group('AppValidators - Ad Soyad & Telefon Testleri', () {
    test('isValidFullName: En az 2 kelime ve 5 karakter olmalıdır', () {
      expect(AppValidators.isValidFullName('Ali'), isFalse);
      expect(AppValidators.isValidFullName('Ali Veli'), isTrue);
      expect(AppValidators.isValidFullName('Zeynep Demir Kaya'), isTrue);
    });

    test('isValidPhone: En az 10 rakam içermelidir', () {
      expect(AppValidators.isValidPhone('123'), isFalse);
      expect(AppValidators.isValidPhone('0532 410 20 30'), isTrue);
      expect(AppValidators.isValidPhone('+90 532 410 2030'), isTrue);
    });
  });
}
