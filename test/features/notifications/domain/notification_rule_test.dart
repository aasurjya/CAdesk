import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/notifications/domain/models/notification_rule.dart';

void main() {
  group('NotificationTrigger enum', () {
    test('has deadlineApproaching', () {
      expect(
        NotificationTrigger.values,
        contains(NotificationTrigger.deadlineApproaching),
      );
    });

    test('has paymentDue', () {
      expect(
        NotificationTrigger.values,
        contains(NotificationTrigger.paymentDue),
      );
    });

    test('has documentShared', () {
      expect(
        NotificationTrigger.values,
        contains(NotificationTrigger.documentShared),
      );
    });

    test('has filingComplete', () {
      expect(
        NotificationTrigger.values,
        contains(NotificationTrigger.filingComplete),
      );
    });

    test('has queryReceived', () {
      expect(
        NotificationTrigger.values,
        contains(NotificationTrigger.queryReceived),
      );
    });
  });

  group('NotificationChannel enum', () {
    test('has push', () {
      expect(NotificationChannel.values, contains(NotificationChannel.push));
    });

    test('has email', () {
      expect(NotificationChannel.values, contains(NotificationChannel.email));
    });

    test('has whatsApp', () {
      expect(
        NotificationChannel.values,
        contains(NotificationChannel.whatsApp),
      );
    });

    test('has sms', () {
      expect(NotificationChannel.values, contains(NotificationChannel.sms));
    });
  });

  group('NotificationRule', () {
    const baseRule = NotificationRule(
      id: 'rule-001',
      trigger: NotificationTrigger.deadlineApproaching,
      channels: [NotificationChannel.whatsApp, NotificationChannel.email],
      isActive: true,
      parameters: {'daysBeforeDeadline': '3'},
    );

    // -------------------------------------------------------------------------
    // Constructor
    // -------------------------------------------------------------------------

    group('constructor', () {
      test('assigns all required fields', () {
        expect(baseRule.id, equals('rule-001'));
        expect(
          baseRule.trigger,
          equals(NotificationTrigger.deadlineApproaching),
        );
        expect(
          baseRule.channels,
          containsAll([
            NotificationChannel.whatsApp,
            NotificationChannel.email,
          ]),
        );
        expect(baseRule.isActive, isTrue);
      });

      test('parameters default to empty map when omitted', () {
        const rule = NotificationRule(
          id: 'rule-no-params',
          trigger: NotificationTrigger.paymentDue,
          channels: [NotificationChannel.push],
          isActive: true,
        );

        expect(rule.parameters, isEmpty);
      });

      test('accepts all NotificationTrigger values', () {
        for (final trigger in NotificationTrigger.values) {
          final rule = NotificationRule(
            id: 'rule-${trigger.name}',
            trigger: trigger,
            channels: const [NotificationChannel.push],
            isActive: true,
          );
          expect(rule.trigger, equals(trigger));
        }
      });

      test('accepts multiple channels', () {
        const rule = NotificationRule(
          id: 'rule-multi-channel',
          trigger: NotificationTrigger.documentShared,
          channels: [
            NotificationChannel.whatsApp,
            NotificationChannel.email,
            NotificationChannel.sms,
          ],
          isActive: true,
        );

        expect(rule.channels, hasLength(3));
      });

      test('isActive can be false', () {
        const rule = NotificationRule(
          id: 'rule-inactive',
          trigger: NotificationTrigger.paymentDue,
          channels: [NotificationChannel.email],
          isActive: false,
        );

        expect(rule.isActive, isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // parameter helper
    // -------------------------------------------------------------------------

    group('parameter helper', () {
      test('returns value for a known key', () {
        expect(baseRule.parameter('daysBeforeDeadline'), equals('3'));
      });

      test('returns defaultValue for an unknown key', () {
        expect(
          baseRule.parameter('unknownKey', defaultValue: 'default'),
          equals('default'),
        );
      });

      test('returns empty string by default for unknown key', () {
        expect(baseRule.parameter('missing'), equals(''));
      });
    });

    // -------------------------------------------------------------------------
    // copyWith
    // -------------------------------------------------------------------------

    group('copyWith', () {
      test('returns a new instance (not same reference)', () {
        final copy = baseRule.copyWith(isActive: false);
        expect(identical(copy, baseRule), isFalse);
      });

      test('changing isActive preserves other fields', () {
        final copy = baseRule.copyWith(isActive: false);

        expect(copy.id, equals(baseRule.id));
        expect(copy.trigger, equals(baseRule.trigger));
        expect(copy.channels, equals(baseRule.channels));
        expect(copy.isActive, isFalse);
      });

      test('changing trigger preserves other fields', () {
        final copy = baseRule.copyWith(trigger: NotificationTrigger.paymentDue);

        expect(copy.id, equals(baseRule.id));
        expect(copy.trigger, equals(NotificationTrigger.paymentDue));
        expect(copy.channels, equals(baseRule.channels));
        expect(copy.isActive, equals(baseRule.isActive));
      });

      test('changing id returns new rule with updated id', () {
        final copy = baseRule.copyWith(id: 'rule-copy');

        expect(copy.id, equals('rule-copy'));
        expect(copy.trigger, equals(baseRule.trigger));
      });

      test('changing channels returns rule with new channels', () {
        final copy = baseRule.copyWith(channels: [NotificationChannel.sms]);

        expect(copy.channels, equals([NotificationChannel.sms]));
      });

      test('changing parameters returns rule with new params', () {
        final copy = baseRule.copyWith(
          parameters: {'templateName': 'deadline_v2'},
        );

        expect(copy.parameters['templateName'], equals('deadline_v2'));
      });

      test('copyWith with no changes preserves all fields', () {
        final copy = baseRule.copyWith();

        expect(copy.id, equals(baseRule.id));
        expect(copy.trigger, equals(baseRule.trigger));
        expect(copy.channels, equals(baseRule.channels));
        expect(copy.isActive, equals(baseRule.isActive));
        expect(copy.parameters, equals(baseRule.parameters));
      });
    });

    // -------------------------------------------------------------------------
    // Equality
    // -------------------------------------------------------------------------

    group('equality', () {
      test('equality is based on id, trigger, and isActive', () {
        const a = NotificationRule(
          id: 'rule-eq',
          trigger: NotificationTrigger.deadlineApproaching,
          channels: [NotificationChannel.whatsApp],
          isActive: true,
          parameters: {'key': 'value-a'},
        );
        const b = NotificationRule(
          id: 'rule-eq',
          trigger: NotificationTrigger.deadlineApproaching,
          channels: [NotificationChannel.email],
          isActive: true,
          parameters: {'key': 'value-b'},
        );

        expect(a, equals(b));
      });

      test('rules with different ids are not equal', () {
        const a = NotificationRule(
          id: 'rule-id-a',
          trigger: NotificationTrigger.deadlineApproaching,
          channels: [NotificationChannel.push],
          isActive: true,
        );
        const b = NotificationRule(
          id: 'rule-id-b',
          trigger: NotificationTrigger.deadlineApproaching,
          channels: [NotificationChannel.push],
          isActive: true,
        );

        expect(a, isNot(equals(b)));
      });

      test('rules with same id but different isActive are not equal', () {
        const a = NotificationRule(
          id: 'rule-active',
          trigger: NotificationTrigger.paymentDue,
          channels: [NotificationChannel.email],
          isActive: true,
        );
        const b = NotificationRule(
          id: 'rule-active',
          trigger: NotificationTrigger.paymentDue,
          channels: [NotificationChannel.email],
          isActive: false,
        );

        expect(a, isNot(equals(b)));
      });

      test('rules with same id but different trigger are not equal', () {
        const a = NotificationRule(
          id: 'rule-trig',
          trigger: NotificationTrigger.deadlineApproaching,
          channels: [NotificationChannel.email],
          isActive: true,
        );
        const b = NotificationRule(
          id: 'rule-trig',
          trigger: NotificationTrigger.paymentDue,
          channels: [NotificationChannel.email],
          isActive: true,
        );

        expect(a, isNot(equals(b)));
      });
    });

    // -------------------------------------------------------------------------
    // toString
    // -------------------------------------------------------------------------

    group('toString', () {
      test('contains the rule id', () {
        expect(baseRule.toString(), contains('rule-001'));
      });

      test('contains the trigger name', () {
        expect(baseRule.toString(), contains('deadlineApproaching'));
      });

      test('contains at least one channel name', () {
        expect(
          baseRule.toString(),
          anyOf(contains('whatsApp'), contains('email')),
        );
      });

      test('contains the isActive flag', () {
        expect(baseRule.toString(), contains('true'));
      });
    });

    // -------------------------------------------------------------------------
    // hashCode consistency
    // -------------------------------------------------------------------------

    group('hashCode', () {
      test('equal rules have the same hashCode', () {
        const a = NotificationRule(
          id: 'rule-hash',
          trigger: NotificationTrigger.filingComplete,
          channels: [NotificationChannel.push],
          isActive: false,
        );
        const b = NotificationRule(
          id: 'rule-hash',
          trigger: NotificationTrigger.filingComplete,
          channels: [NotificationChannel.email],
          isActive: false,
        );

        expect(a.hashCode, equals(b.hashCode));
      });
    });
  });
}
