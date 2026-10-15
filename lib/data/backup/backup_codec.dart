// Local rows <-> the JSON backup file. Keys are snake_case; dates are
// 'yyyy-mm-dd'; times are 'HH:MM:SS'; enums are their names. Backups made by
// older versions (with sync fields such as rev, user_id, photo_url) still
// read, because unknown keys are ignored.
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/reminder_engine.dart';
import '../local/database.dart';

String? _date(DateTime? d) => d == null ? null : formatDate(d);
DateTime? _parseDate(Object? s) => s == null ? null : DateTime.parse('${s as String}T00:00:00Z');
String? _ts(DateTime? d) => d?.toUtc().toIso8601String();
DateTime? _parseTs(Object? s) => s == null ? null : DateTime.parse(s as String);

String? minutesToTime(int? m) => m == null
    ? null
    : '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}:00';
int? timeToMinutes(Object? s) {
  if (s == null) return null;
  final parts = (s as String).split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

List<int>? _intList(Object? v) => v == null ? null : (v as List).map((e) => (e as num).toInt()).toList();

Map<String, dynamic> profileToJson(Profile p) => {
      'display_name': p.displayName,
      'email': p.email,
      'phone': p.phone,
      'timezone': p.timezone,
      'default_notify_at': minutesToTime(p.defaultNotifyMinutes),
      'default_offsets': p.defaultOffsets,
      'currency': p.currency,
    };

ProfilesCompanion profileFromJson(Map<String, dynamic> j) => ProfilesCompanion(
      displayName: Value(j['display_name'] as String?),
      email: Value(j['email'] as String?),
      phone: Value(j['phone'] as String?),
      timezone: Value(j['timezone'] as String),
      defaultNotifyMinutes: Value(timeToMinutes(j['default_notify_at'])!),
      defaultOffsets: Value(_intList(j['default_offsets'])!),
      currency: Value((j['currency'] as String).trim()),
    );

Map<String, dynamic> familyToJson(FamilyMember f) => {
      'id': f.id,
      'name': f.name,
      'relation': f.relation,
      'emoji': f.emoji,
      'sort_order': f.sortOrder,
      'created_at': _ts(f.createdAt),
      'deleted_at': _ts(f.deletedAt),
    };

FamilyMembersCompanion familyFromJson(Map<String, dynamic> j) => FamilyMembersCompanion(
      id: Value(j['id'] as String),
      name: Value(j['name'] as String),
      relation: Value(j['relation'] as String?),
      emoji: Value(j['emoji'] as String?),
      sortOrder: Value((j['sort_order'] as num?)?.toInt() ?? 0),
      createdAt: Value(_parseTs(j['created_at'])!),
      updatedAt: Value(_parseTs(j['updated_at'])!),
      deletedAt: Value(_parseTs(j['deleted_at'])),
    );

Map<String, dynamic> categoryToJson(CustomCategory c) => {
      'id': c.id,
      'parent_key': c.parentKey,
      'name': c.name,
      'icon': c.icon,
      'created_at': _ts(c.createdAt),
      'deleted_at': _ts(c.deletedAt),
    };

CustomCategoriesCompanion categoryFromJson(Map<String, dynamic> j) => CustomCategoriesCompanion(
      id: Value(j['id'] as String),
      parentKey: Value(j['parent_key'] as String?),
      name: Value(j['name'] as String),
      icon: Value(j['icon'] as String?),
      createdAt: Value(_parseTs(j['created_at'])!),
      updatedAt: Value(_parseTs(j['updated_at'])!),
      deletedAt: Value(_parseTs(j['deleted_at'])),
    );

Map<String, dynamic> itemToJson(Item i) => {
      'id': i.id,
      'family_member_id': i.familyMemberId,
      'category_key': i.categoryKey,
      'title': i.title,
      'provider': i.provider,
      'reference_no': i.referenceNo,
      'amount_minor': i.amountMinor,
      'currency': i.currency,
      'start_date': _date(i.startDate),
      'due_date': _date(i.dueDate),
      'recurrence_unit': i.recurrenceUnit.name,
      'recurrence_every': i.recurrenceEvery,
      'reminder_offsets': i.reminderOffsets,
      'notify_at': minutesToTime(i.notifyMinutes),
      'snoozed_until': _ts(i.snoozedUntil),
      'status': i.archived ? 'archived' : 'active',
      'notes': i.notes,
      'extra': jsonDecode(i.extra),
      'created_at': _ts(i.createdAt),
      'deleted_at': _ts(i.deletedAt),
    };

ItemsCompanion itemFromJson(Map<String, dynamic> j) => ItemsCompanion(
      id: Value(j['id'] as String),
      familyMemberId: Value(j['family_member_id'] as String?),
      categoryKey: Value(j['category_key'] as String),
      title: Value(j['title'] as String),
      provider: Value(j['provider'] as String?),
      referenceNo: Value(j['reference_no'] as String?),
      amountMinor: Value((j['amount_minor'] as num?)?.toInt()),
      currency: Value(((j['currency'] as String?) ?? 'INR').trim()),
      startDate: Value(_parseDate(j['start_date'])),
      dueDate: Value(_parseDate(j['due_date'])),
      recurrenceUnit: Value(RecurrenceUnit.values.byName(j['recurrence_unit'] as String)),
      recurrenceEvery: Value((j['recurrence_every'] as num).toInt()),
      reminderOffsets: Value(_intList(j['reminder_offsets'])),
      notifyMinutes: Value(timeToMinutes(j['notify_at'])),
      snoozedUntil: Value(_parseTs(j['snoozed_until'])),
      archived: Value(j['status'] == 'archived'),
      notes: Value(j['notes'] as String?),
      extra: Value(jsonEncode(j['extra'] ?? {})),
      createdAt: Value(_parseTs(j['created_at'])!),
      updatedAt: Value(_parseTs(j['updated_at'])!),
      deletedAt: Value(_parseTs(j['deleted_at'])),
    );

Map<String, dynamic> renewalToJson(Renewal r) => {
      'id': r.id,
      'item_id': r.itemId,
      'previous_due': _date(r.previousDue),
      'new_due': _date(r.newDue),
      'amount_minor': r.amountMinor,
      'provider': r.provider,
      'notes': r.notes,
      'renewed_at': _ts(r.renewedAt),
      'created_at': _ts(r.createdAt),
      'deleted_at': _ts(r.deletedAt),
    };

RenewalsCompanion renewalFromJson(Map<String, dynamic> j) => RenewalsCompanion(
      id: Value(j['id'] as String),
      itemId: Value(j['item_id'] as String),
      previousDue: Value(_parseDate(j['previous_due'])!),
      newDue: Value(_parseDate(j['new_due'])!),
      amountMinor: Value((j['amount_minor'] as num?)?.toInt()),
      provider: Value(j['provider'] as String?),
      notes: Value(j['notes'] as String?),
      renewedAt: Value(_parseTs(j['renewed_at'])!),
      createdAt: Value(_parseTs(j['created_at'])!),
      updatedAt: Value(_parseTs(j['updated_at'])!),
      deletedAt: Value(_parseTs(j['deleted_at'])),
    );
