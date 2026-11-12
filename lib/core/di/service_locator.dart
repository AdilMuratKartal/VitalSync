/// Ekstra paket bağımlılığı gerektirmeyen sade Dependency Injection (Servis Kayıt) yapısı.
/// Geliştirici 3 ve Geliştirici 5 kendi servis/repository sınıflarını buraya kaydedebilir.
class ServiceLocator {
  ServiceLocator._();

  static final Map<Type, dynamic> _services = {};
  static final Map<Type, dynamic Function()> _factories = {};

  /// Tekil (Singleton) servis kaydı yapar.
  static void registerSingleton<T>(T instance) {
    _services[T] = instance;
  }

  /// İhtiyaç anında üretilecek (Factory) sınıf kaydı yapar.
  static void registerFactory<T>(T Function() factoryFunc) {
    _factories[T] = factoryFunc;
  }

  /// Kayıtlı servisi veya sınıfı döndürür.
  static T get<T>() {
    if (_services.containsKey(T)) {
      return _services[T] as T;
    }
    if (_factories.containsKey(T)) {
      return _factories[T]!() as T;
    }
    throw StateError('ServiceLocator içinde $T tipi henüz kayıt edilmedi.');
  }

  /// Servisin kayıtlı olup olmadığını kontrol eder.
  static bool isRegistered<T>() {
    return _services.containsKey(T) || _factories.containsKey(T);
  }

  /// Temel uygulama servislerini başlatır.
  static void setup() {
    // Geliştirici 3 Firebase servislerini hazırladığında buraya ekleyebilir.
  }
}

