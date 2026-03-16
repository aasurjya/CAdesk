import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/otp/otp_channel.dart';
import 'package:ca_app/core/otp/otp_intercept_service.dart';

void main() {
  group('OtpChannel', () {
    test('has expected values', () {
      expect(
        OtpChannel.values,
        containsAll([
          OtpChannel.sms,
          OtpChannel.aadhaarOtp,
          OtpChannel.totp,
          OtpChannel.email,
        ]),
      );
    });

    test('sms has correct label', () {
      expect(OtpChannel.sms.label, equals('SMS'));
    });

    test('aadhaarOtp has correct label', () {
      expect(OtpChannel.aadhaarOtp.label, equals('Aadhaar OTP'));
    });

    test('totp has correct label', () {
      expect(OtpChannel.totp.label, equals('Authenticator App'));
    });

    test('email has correct label', () {
      expect(OtpChannel.email.label, equals('Email'));
    });
  });

  group('OtpInterceptService', () {
    late OtpInterceptService service;

    setUp(() {
      service = OtpInterceptService();
    });

    tearDown(() {
      service.dispose();
    });

    group('waitForOtp', () {
      test('returns otp when resolveOtp called', () async {
        final future = service.waitForOtp(
          channel: OtpChannel.sms,
          portalName: 'ITD Portal',
          maskedContact: '+91-98xxx',
        );
        service.resolveOtp('123456');
        final result = await future;
        expect(result, equals('123456'));
      });

      test('throws OtpTimeoutException on timeout', () async {
        expect(
          () => service.waitForOtp(
            channel: OtpChannel.sms,
            portalName: 'GST Portal',
            maskedContact: '••@email.com',
            timeout: const Duration(milliseconds: 50),
          ),
          throwsA(isA<OtpTimeoutException>()),
        );
      });

      test('throws OtpCancelledException when cancelled', () async {
        final future = service.waitForOtp(
          channel: OtpChannel.email,
          portalName: 'TRACES',
          maskedContact: '••@example.com',
        );
        service.cancelOtp();
        expect(future, throwsA(isA<OtpCancelledException>()));
      });

      test('exposes pending request info', () async {
        unawaited(
          service
              .waitForOtp(
                channel: OtpChannel.aadhaarOtp,
                portalName: 'ITD Portal',
                maskedContact: 'XXXX9999',
              )
              .catchError((dynamic _) => ''),
        );
        // Give microtask a tick to register
        await Future<void>.delayed(Duration.zero);
        expect(service.pendingRequest, isNotNull);
        expect(service.pendingRequest!.channel, equals(OtpChannel.aadhaarOtp));
        expect(service.pendingRequest!.portalName, equals('ITD Portal'));
        service.cancelOtp();
      });

      test('pendingRequest is null when no wait active', () {
        expect(service.pendingRequest, isNull);
      });

      test('pendingRequest is null after resolution', () async {
        final future = service.waitForOtp(
          channel: OtpChannel.sms,
          portalName: 'EPFO',
          maskedContact: '+91-99xxx',
        );
        await Future<void>.delayed(Duration.zero);
        service.resolveOtp('654321');
        await future;
        expect(service.pendingRequest, isNull);
      });

      test('throws if called while already waiting', () async {
        unawaited(
          service
              .waitForOtp(
                channel: OtpChannel.sms,
                portalName: 'MCA',
                maskedContact: '+91-88xxx',
              )
              .catchError((dynamic _) => ''),
        );
        await Future<void>.delayed(Duration.zero);
        expect(
          () => service.waitForOtp(
            channel: OtpChannel.sms,
            portalName: 'MCA',
            maskedContact: '+91-88xxx',
          ),
          throwsA(isA<OtpAlreadyPendingException>()),
        );
        service.cancelOtp();
      });
    });

    group('resolveOtp', () {
      test('does nothing if no pending otp', () {
        // Should not throw
        expect(() => service.resolveOtp('123456'), returnsNormally);
      });
    });

    group('cancelOtp', () {
      test('does nothing if no pending otp', () {
        expect(() => service.cancelOtp(), returnsNormally);
      });
    });

    group('OtpPendingRequest', () {
      test('is immutable', () {
        const req = OtpPendingRequest(
          channel: OtpChannel.totp,
          portalName: 'ITD',
          maskedContact: 'N/A',
        );
        expect(req.channel, equals(OtpChannel.totp));
        expect(req.portalName, equals('ITD'));
        expect(req.maskedContact, equals('N/A'));
      });
    });
  });
}
