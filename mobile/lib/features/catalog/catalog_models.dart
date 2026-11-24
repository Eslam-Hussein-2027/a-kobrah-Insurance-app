/// Product catalog and company information served by the API (already localized).
library;

enum Issuance {
  /// Issued and paid in the app.
  instant,

  /// Sent as a request; staff reply with a price or issue it.
  request,
}

class ProductField {
  const ProductField({
    required this.key,
    required this.label,
    required this.type,
    required this.required,
    this.min,
    this.max,
  });

  factory ProductField.fromJson(Map<String, dynamic> json) => ProductField(
    key: json['key'] as String,
    label: json['label'] as String,
    type: ProductFieldType.fromValue(json['type'] as String),
    required: json['required'] == true,
    min: json['min'] as num?,
    max: json['max'] as num?,
  );

  final String key;
  final String label;
  final ProductFieldType type;
  final bool required;
  final num? min;
  final num? max;
}

enum ProductFieldType {
  text,
  integer,
  number,
  date,

  /// One of the customer's vehicles (sent as its id).
  vehicle;

  static ProductFieldType fromValue(String value) =>
      ProductFieldType.values.firstWhere((t) => t.name == value, orElse: () => ProductFieldType.text);
}

class ProductDocument {
  const ProductDocument({required this.key, required this.label});

  factory ProductDocument.fromJson(Map<String, dynamic> json) =>
      ProductDocument(key: json['key'] as String, label: json['label'] as String);

  final String key;
  final String label;
}

class Product {
  const Product({
    required this.code,
    required this.name,
    required this.title,
    required this.description,
    required this.issuance,
    required this.icon,
    required this.covers,
    required this.documents,
    required this.fields,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    code: json['code'] as String,
    name: json['name'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    issuance: json['issuance'] == 'instant' ? Issuance.instant : Issuance.request,
    icon: json['icon'] as String,
    covers: (json['covers'] as List).cast<String>(),
    documents: (json['documents'] as List).cast<Map<String, dynamic>>().map(ProductDocument.fromJson).toList(),
    fields: (json['fields'] as List).cast<Map<String, dynamic>>().map(ProductField.fromJson).toList(),
  );

  static const motor = 'motor';
  static const travel = 'travel';

  final String code;

  /// Short name ("التأمين الإجباري").
  final String name;

  /// Full name ("التأمين الإجباري للمركبات").
  final String title;
  final String description;
  final Issuance issuance;

  /// Icon key mapped by [productIcon].
  final String icon;
  final List<String> covers;
  final List<ProductDocument> documents;
  final List<ProductField> fields;

  bool get isInstant => issuance == Issuance.instant;
}

class Branch {
  const Branch({required this.name, required this.city, required this.phone, required this.isHeadOffice});

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
    name: json['name'] as String,
    city: json['city'] as String,
    phone: json['phone'] as String,
    isHeadOffice: json['is_head_office'] == true,
  );

  final String name;
  final String city;
  final String phone;
  final bool isHeadOffice;
}

class CompanyInfo {
  const CompanyInfo({
    required this.name,
    required this.phone,
    required this.website,
    required this.address,
    required this.branches,
    required this.about,
    required this.privacy,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) => CompanyInfo(
    name: json['name'] as String,
    phone: json['phone'] as String,
    website: json['website'] as String,
    address: json['address'] as String,
    branches: (json['branches'] as List).cast<Map<String, dynamic>>().map(Branch.fromJson).toList(),
    about: (json['about'] as List).cast<String>(),
    privacy: (json['privacy'] as List).cast<String>(),
  );

  final String name;
  final String phone;
  final String website;
  final String address;
  final List<Branch> branches;
  final List<String> about;
  final List<String> privacy;
}
