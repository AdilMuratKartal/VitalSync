import 'package:flutter_test/flutter_test.dart';
import 'package:vitalsync/presentation/cubits/cubit_status.dart';

void main() {
  group('DataStatus', () {
    test('tüm beklenen durum değerlerini içerir', () {
      expect(
        DataStatus.values,
        equals([
          DataStatus.initial,
          DataStatus.loading,
          DataStatus.empty,
          DataStatus.success,
          DataStatus.error,
        ]),
      );
    });

    test('isInitial yalnızca initial durumunda true döner', () {
      expect(DataStatus.initial.isInitial, isTrue);
      expect(DataStatus.loading.isInitial, isFalse);
      expect(DataStatus.empty.isInitial, isFalse);
      expect(DataStatus.success.isInitial, isFalse);
      expect(DataStatus.error.isInitial, isFalse);
    });

    test('isLoading yalnızca loading durumunda true döner', () {
      expect(DataStatus.loading.isLoading, isTrue);
      expect(DataStatus.initial.isLoading, isFalse);
      expect(DataStatus.empty.isLoading, isFalse);
      expect(DataStatus.success.isLoading, isFalse);
      expect(DataStatus.error.isLoading, isFalse);
    });

    test('isEmpty yalnızca empty durumunda true döner', () {
      expect(DataStatus.empty.isEmpty, isTrue);
      expect(DataStatus.initial.isEmpty, isFalse);
      expect(DataStatus.loading.isEmpty, isFalse);
      expect(DataStatus.success.isEmpty, isFalse);
      expect(DataStatus.error.isEmpty, isFalse);
    });

    test('isSuccess yalnızca success durumunda true döner', () {
      expect(DataStatus.success.isSuccess, isTrue);
      expect(DataStatus.initial.isSuccess, isFalse);
      expect(DataStatus.loading.isSuccess, isFalse);
      expect(DataStatus.empty.isSuccess, isFalse);
      expect(DataStatus.error.isSuccess, isFalse);
    });

    test('isError yalnızca error durumunda true döner', () {
      expect(DataStatus.error.isError, isTrue);
      expect(DataStatus.initial.isError, isFalse);
      expect(DataStatus.loading.isError, isFalse);
      expect(DataStatus.empty.isError, isFalse);
      expect(DataStatus.success.isError, isFalse);
    });
  });

  group('ActionStatus', () {
    test('tüm beklenen işlem durum değerlerini içerir', () {
      expect(
        ActionStatus.values,
        equals([
          ActionStatus.idle,
          ActionStatus.submitting,
          ActionStatus.succeeded,
          ActionStatus.failed,
        ]),
      );
    });

    test('isIdle yalnızca idle durumunda true döner', () {
      expect(ActionStatus.idle.isIdle, isTrue);
      expect(ActionStatus.submitting.isIdle, isFalse);
      expect(ActionStatus.succeeded.isIdle, isFalse);
      expect(ActionStatus.failed.isIdle, isFalse);
    });

    test('isSubmitting yalnızca submitting durumunda true döner', () {
      expect(ActionStatus.submitting.isSubmitting, isTrue);
      expect(ActionStatus.idle.isSubmitting, isFalse);
      expect(ActionStatus.succeeded.isSubmitting, isFalse);
      expect(ActionStatus.failed.isSubmitting, isFalse);
    });

    test('isSucceeded yalnızca succeeded durumunda true döner', () {
      expect(ActionStatus.succeeded.isSucceeded, isTrue);
      expect(ActionStatus.idle.isSucceeded, isFalse);
      expect(ActionStatus.submitting.isSucceeded, isFalse);
      expect(ActionStatus.failed.isSucceeded, isFalse);
    });

    test('isFailed yalnızca failed durumunda true döner', () {
      expect(ActionStatus.failed.isFailed, isTrue);
      expect(ActionStatus.idle.isFailed, isFalse);
      expect(ActionStatus.submitting.isFailed, isFalse);
      expect(ActionStatus.succeeded.isFailed, isFalse);
    });
  });
}

