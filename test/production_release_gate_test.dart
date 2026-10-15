import 'package:flutter_test/flutter_test.dart';
import 'package:nolatefees/domain/reminder_engine.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import 'helpers.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('production release gates', () {
    test(
      '[P0] reminder edits replace alerts and deletion cancels them',
      () async {
        final gateway = FakeGateway();
        final services = buildServices(gateway: gateway);
        addTearDown(services.db.close);

        final today = dateOnly(DateTime.now());
        final oldDue = today.add(const Duration(days: 120));
        final newDue = today.add(const Duration(days: 165));
        final id = await services.repo.saveItem(
          title: 'Release gate insurance',
          categoryKey: 'vehicle.insurance',
          dueDate: oldDue,
          reminderOffsets: const [30, 7, 0],
        );

        expect(gateway.booked, hasLength(3));
        expect(
          gateway.booked.values.every((alert) => alert.payload == id),
          isTrue,
        );

        await services.repo.saveItem(
          id: id,
          title: 'Release gate insurance',
          categoryKey: 'vehicle.insurance',
          dueDate: newDue,
          reminderOffsets: const [30, 7, 0],
        );

        expect(gateway.booked, hasLength(3));
        expect(
          gateway.booked.values.map((alert) => dateOnly(alert.at)),
          isNot(contains(oldDue)),
        );
        expect(
          gateway.booked.values.map((alert) => dateOnly(alert.at)),
          contains(newDue),
        );

        await services.repo.deleteItem(id);

        expect(gateway.booked, isEmpty);
        expect(await services.repo.activeItems(), isEmpty);
        expect((await services.repo.getItem(id))!.deletedAt, isNotNull);
      },
    );

    test(
      '[P0] renewal history and relationships survive JSON backup restore',
      () async {
        final services = buildServices();
        addTearDown(services.db.close);
        final familyId = await services.repo.saveFamilyMember(
          name: 'Release test member',
          relation: 'parent',
        );
        final id = await services.repo.saveItem(
          title: 'Month-end renewal',
          categoryKey: 'insurance.health',
          dueDate: DateTime.utc(2027, 1, 31),
          recurrenceUnit: RecurrenceUnit.month,
          reminderOffsets: const [30, 1],
          familyMemberId: familyId,
        );

        final item = (await services.repo.getItem(id))!;
        final nextDue = nextDueDate(
          item.dueDate!,
          item.recurrenceUnit,
          item.recurrenceEvery,
        );
        await services.repo.renew(id, newDue: nextDue, amountMinor: 125000);

        final restoredDb = memoryDb();
        addTearDown(restoredDb.close);
        final restoredServices = buildServices(db: restoredDb);
        final restoredCount = await restoredServices.export.importJson(
          await services.export.toJson(),
        );
        final restored = (await restoredServices.repo.getItem(id))!;
        final history = await restoredServices.repo.watchRenewals(id).first;

        expect(restoredCount, 1);
        expect(nextDue, DateTime.utc(2027, 2, 28));
        expect(restored.dueDate, nextDue);
        expect(restored.recurrenceUnit, RecurrenceUnit.month);
        expect(restored.reminderOffsets, [30, 1]);
        expect(restored.familyMemberId, familyId);
        expect(history, hasLength(1));
        expect(history.single.previousDue, DateTime.utc(2027, 1, 31));
        expect(history.single.newDue, nextDue);
        expect(history.single.amountMinor, 125000);
      },
    );
  });
}
