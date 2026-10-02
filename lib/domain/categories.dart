// Built-in categories ship with the app and are never stored in the database.
// Items reference them by stable key ("vehicle.insurance"). User-created
// categories are stored and referenced as "custom:<uuid>".
import 'reminder_engine.dart';

class Category {
  const Category(this.key, this.name, this.emoji, this.children,
      {this.defaultRecurrence = RecurrenceUnit.year});

  final String key;
  final String name;
  final String emoji;
  final List<SubCategory> children;
  final RecurrenceUnit defaultRecurrence;
}

class SubCategory {
  const SubCategory(this.key, this.name, {this.recurrence});
  final String key;
  final String name;
  final RecurrenceUnit? recurrence; // null = parent's default
}

const builtInCategories = <Category>[
  Category('vehicle', 'Vehicle', '🚗', [
    SubCategory('vehicle.insurance', 'Vehicle Insurance'),
    SubCategory('vehicle.puc', 'PUC', recurrence: RecurrenceUnit.none),
    SubCategory('vehicle.rc', 'RC', recurrence: RecurrenceUnit.none),
    SubCategory('vehicle.service', 'Vehicle Service'),
    SubCategory('vehicle.fastag', 'FASTag', recurrence: RecurrenceUnit.none),
    SubCategory('vehicle.road_tax', 'Road Tax'),
  ]),
  Category('insurance', 'Insurance', '🛡️', [
    SubCategory('insurance.health', 'Health Insurance'),
    SubCategory('insurance.life', 'Life Insurance'),
    SubCategory('insurance.term', 'Term Insurance'),
    SubCategory('insurance.home', 'Home Insurance'),
    SubCategory('insurance.travel', 'Travel Insurance', recurrence: RecurrenceUnit.none),
    SubCategory('insurance.other', 'Other Insurance'),
  ]),
  Category('mobile', 'Mobile & Internet', '📱', defaultRecurrence: RecurrenceUnit.month, [
    SubCategory('mobile.recharge', 'Mobile Recharge'),
    SubCategory('mobile.postpaid', 'Postpaid Bill'),
    SubCategory('mobile.broadband', 'Broadband'),
    SubCategory('mobile.sim', 'SIM Validity', recurrence: RecurrenceUnit.year),
  ]),
  Category('finance', 'Finance', '💰', defaultRecurrence: RecurrenceUnit.month, [
    SubCategory('finance.emi', 'EMI'),
    SubCategory('finance.loan', 'Loan Payment'),
    SubCategory('finance.credit_card', 'Credit Card Payment'),
    SubCategory('finance.rent', 'Rent'),
    SubCategory('finance.other', 'Other Payment'),
  ]),
  Category('documents', 'Documents', '📄', defaultRecurrence: RecurrenceUnit.none, [
    SubCategory('documents.passport', 'Passport'),
    SubCategory('documents.visa', 'Visa'),
    SubCategory('documents.driving_licence', 'Driving Licence'),
    SubCategory('documents.id', 'ID'),
    SubCategory('documents.certificate', 'Certificate'),
    SubCategory('documents.permit', 'Permit'),
    SubCategory('documents.other', 'Other Document'),
  ]),
  Category('subscriptions', 'Subscriptions', '📺', defaultRecurrence: RecurrenceUnit.month, [
    SubCategory('subscriptions.netflix', 'Netflix'),
    SubCategory('subscriptions.spotify', 'Spotify'),
    SubCategory('subscriptions.youtube', 'YouTube'),
    SubCategory('subscriptions.prime', 'Amazon Prime', recurrence: RecurrenceUnit.year),
    SubCategory('subscriptions.gym', 'Gym'),
    SubCategory('subscriptions.software', 'Software'),
    SubCategory('subscriptions.cloud', 'Cloud Storage'),
    SubCategory('subscriptions.other', 'Other Subscription'),
  ]),
  Category('home', 'Home', '🏠', [
    SubCategory('home.warranty', 'Appliance Warranty', recurrence: RecurrenceUnit.none),
    SubCategory('home.ac_service', 'AC Service'),
    SubCategory('home.pest_control', 'Pest Control'),
    SubCategory('home.maintenance', 'Maintenance', recurrence: RecurrenceUnit.month),
    SubCategory('home.rental_agreement', 'Rental Agreement', recurrence: RecurrenceUnit.year),
  ]),
  Category('custom', 'Custom', '✏️', defaultRecurrence: RecurrenceUnit.none, [
    SubCategory('custom.other', 'Anything else'),
  ]),
];

Category? parentOf(String key) {
  final parent = key.split('.').first;
  for (final c in builtInCategories) {
    if (c.key == parent) return c;
  }
  return null;
}

SubCategory? subCategoryOf(String key) {
  for (final c in builtInCategories) {
    for (final s in c.children) {
      if (s.key == key) return s;
    }
  }
  return null;
}

String categoryEmoji(String key) =>
    key.startsWith('custom:') ? '✏️' : (parentOf(key)?.emoji ?? '📌');

/// Display name for a key. Custom categories need [customNames] to resolve.
String categoryName(String key, [Map<String, String> customNames = const {}]) {
  if (key.startsWith('custom:')) return customNames[key.substring(7)] ?? 'Custom';
  return subCategoryOf(key)?.name ?? parentOf(key)?.name ?? key;
}

RecurrenceUnit suggestedRecurrence(String key) {
  final sub = subCategoryOf(key);
  return sub?.recurrence ?? parentOf(key)?.defaultRecurrence ?? RecurrenceUnit.none;
}
