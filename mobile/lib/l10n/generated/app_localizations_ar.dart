// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'العربية الكبرى للتأمين';

  @override
  String get welcome => 'مرحبًا بك';

  @override
  String get loginSubtitle => 'سجّل الدخول برقم هاتفك لإدارة وثائق التأمين';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get sendCode => 'إرسال رمز التحقق';

  @override
  String get verifyPolicyLink => 'التحقق من وثيقة تأمين';

  @override
  String get otpTitle => 'رمز التحقق';

  @override
  String otpSubtitle(String phone) {
    return 'أدخل الرمز المكوّن من 6 أرقام المرسل إلى الرقم $phone';
  }

  @override
  String get otpLength => 'الرمز يجب أن يتكون من 6 أرقام';

  @override
  String get confirm => 'تأكيد';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String resendIn(int seconds) {
    return 'إعادة الإرسال بعد $seconds ثانية';
  }

  @override
  String get codeResent => 'تم إرسال رمز جديد';

  @override
  String get registerTitle => 'إكمال التسجيل';

  @override
  String get registerSubtitle => 'تم التحقق من رقم هاتفك. أكمل بياناتك لإنشاء الحساب.';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get nationalNumber => 'الرقم الوطني';

  @override
  String get idImage => 'صورة إثبات الهوية';

  @override
  String get licenseImage => 'صورة رخصة القيادة';

  @override
  String get documentsOptionalHint =>
      'يمكنك رفع المستندات الآن أو لاحقًا من «المزيد ← المعلومات الشخصية»، وهي مطلوبة قبل إصدار وثيقة التأمين الإجباري.';

  @override
  String get chooseImage => 'اختيار صورة';

  @override
  String get imageSelected => 'تم اختيار الصورة';

  @override
  String get createAccount => 'إنشاء الحساب';

  @override
  String get registrationExpired => 'انتهت صلاحية جلسة التسجيل، يرجى طلب رمز تحقق جديد.';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'معرض الصور';

  @override
  String get tabVehicles => 'المركبات';

  @override
  String get addVehicle => 'إضافة مركبة';

  @override
  String get editVehicle => 'تعديل المركبة';

  @override
  String get noVehicles => 'لم تضف أي مركبة بعد';

  @override
  String get noVehiclesHint => 'أضف مركبتك لتتمكن من تأمينها';

  @override
  String get plateNo => 'رقم اللوحة';

  @override
  String get plateHint => 'مثال: 5-123456';

  @override
  String get vin => 'رقم الهيكل (الشاسيه)';

  @override
  String get vinHint => '17 حرفًا ورقمًا';

  @override
  String get make => 'الماركة';

  @override
  String get model => 'الموديل';

  @override
  String get year => 'سنة الصنع';

  @override
  String get engineCc => 'سعة المحرك';

  @override
  String get ccUnit => 'سي سي';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get cancel => 'إلغاء';

  @override
  String get deleteVehicleTitle => 'حذف المركبة';

  @override
  String deleteVehicleConfirm(String plate) {
    return 'هل تريد حذف المركبة $plate؟';
  }

  @override
  String get vehicleAdded => 'تمت إضافة المركبة';

  @override
  String get vehicleUpdated => 'تم تحديث بيانات المركبة';

  @override
  String get vehicleDeleted => 'تم حذف المركبة';

  @override
  String get noPolicies => 'لا توجد وثائق تأمين بعد';

  @override
  String get noPoliciesHint => 'اختر منتجًا من الرئيسية لإصدار أول وثيقة.';

  @override
  String get policyNo => 'رقم الوثيقة';

  @override
  String get coverage => 'نوع التأمين';

  @override
  String get startDate => 'تاريخ البداية';

  @override
  String get endDate => 'تاريخ النهاية';

  @override
  String get issuedAt => 'تاريخ الإصدار';

  @override
  String get premium => 'القسط';

  @override
  String get vehicle => 'المركبة';

  @override
  String get policyDetails => 'تفاصيل الوثيقة';

  @override
  String get downloadPdf => 'تحميل الوثيقة للطباعة (PDF)';

  @override
  String get pdfMobileOnly => 'تحميل الوثيقة متاح من تطبيق الهاتف';

  @override
  String get pendingPaymentTitle => 'الوثيقة بانتظار الدفع';

  @override
  String get pendingPaymentBody =>
      'يمكنك دفع القسط الآن إلكترونيًا، وبعد تأكيد الدفع ستتمكن من تحميل الوثيقة وطباعتها مباشرة.';

  @override
  String get customerService => 'خدمة العملاء';

  @override
  String get cancelRequestConfirm => 'هل تريد إلغاء طلب هذه الوثيقة؟';

  @override
  String get policyCancelled => 'تم إلغاء الطلب';

  @override
  String get policyCreated => 'تم إنشاء الوثيقة، يرجى إتمام الدفع لتفعيلها';

  @override
  String get basePrice => 'السعر الأساسي';

  @override
  String get priceDetails => 'تفاصيل السعر';

  @override
  String get coverageStart => 'تاريخ بداية التأمين';

  @override
  String get issuePolicy => 'إصدار الوثيقة';

  @override
  String get kycMissingTitle => 'المستندات مطلوبة';

  @override
  String get kycMissingBody => 'يجب رفع صورة إثبات الهوية وصورة رخصة القيادة قبل إصدار وثيقة التأمين الإجباري.';

  @override
  String get goToProfile => 'رفع المستندات';

  @override
  String get documents => 'المستندات';

  @override
  String get uploaded => 'تم الرفع';

  @override
  String get notUploaded => 'لم يتم الرفع';

  @override
  String get upload => 'رفع';

  @override
  String get replace => 'تغيير';

  @override
  String get documentUploaded => 'تم رفع المستند';

  @override
  String get language => 'اللغة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل تريد تسجيل الخروج؟';

  @override
  String get verifyTitle => 'التحقق من وثيقة';

  @override
  String get verifySubtitle => 'أدخل رقم الوثيقة ورقم اللوحة للتحقق من صلاحية الوثيقة';

  @override
  String get check => 'تحقق';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get requiredField => 'هذا الحقل مطلوب';

  @override
  String get networkError => 'تعذّر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.';

  @override
  String get unexpectedError => 'حدث خطأ غير متوقع، حاول مرة أخرى.';

  @override
  String get currency => 'د.ل';

  @override
  String get payOnline => 'ادفع الآن إلكترونيًا';

  @override
  String get checkPaymentStatus => 'تحقق من حالة الدفع';

  @override
  String get orPayAtOffice => 'أو ادفع في أحد مكاتب الشركة مع ذكر رقم الوثيقة.';

  @override
  String get paymentSucceeded => 'تم الدفع بنجاح وتفعيل الوثيقة';

  @override
  String get paymentFailed => 'لم تتم عملية الدفع، يمكنك المحاولة مرة أخرى';

  @override
  String get paymentNotConfirmedYet => 'لم يتم تأكيد الدفع بعد، حاول بعد لحظات';

  @override
  String get verificationQrTitle => 'رمز التحقق من الوثيقة';

  @override
  String get verificationQrHint =>
      'يمكن لرجال المرور والجهات الحكومية والشركات مسح هذا الرمز بكاميرا الهاتف للتأكد من صحة الوثيقة.';

  @override
  String get tabHome => 'الرئيسية';

  @override
  String get tabMyInsurance => 'تأميناتي';

  @override
  String get tabAccount => 'حسابي';

  @override
  String get hello => 'مرحبًا،';

  @override
  String get contactUs => 'تواصل معنا';

  @override
  String get insuranceProducts => 'منتجات التأمين';

  @override
  String myPoliciesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'وثائقي ($count)', zero: 'وثائقي');
    return '$_temp0';
  }

  @override
  String get instantIssue => 'إصدار فوري';

  @override
  String get onRequest => 'بطلب عرض سعر';

  @override
  String get calculatePrice => 'احسب السعر';

  @override
  String get verifyPolicyShort => 'تحقق من وثيقة';

  @override
  String get branches => 'فروعنا';

  @override
  String get uninsuredVehicle => 'مركبة بدون تأمين';

  @override
  String get insureItNow => 'أمّنها الآن';

  @override
  String get noActivePolicy => 'لا توجد وثيقة سارية';

  @override
  String get noActivePolicyHint => 'أصدر وثيقة التأمين الإجباري لمركبتك في دقائق.';

  @override
  String get verificationCode => 'رمز التحقق';

  @override
  String endsOn(String date) {
    return 'تنتهي في $date';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'متبقٍ $count يوم',
      many: 'متبقٍ $count يومًا',
      few: 'متبقٍ $count أيام',
      two: 'متبقٍ يومان',
      one: 'متبقٍ يوم واحد',
      zero: 'تنتهي اليوم',
    );
    return '$_temp0';
  }

  @override
  String otherActivePolicies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ولديك $count وثيقة سارية أخرى في «تأميناتي»',
      few: 'ولديك $count وثائق سارية أخرى في «تأميناتي»',
      two: 'ولديك وثيقتان ساريتان أخريان في «تأميناتي»',
      one: 'ولديك وثيقة سارية أخرى في «تأميناتي»',
    );
    return '$_temp0';
  }

  @override
  String get issuedInstantly => 'تصدر فورًا عبر التطبيق';

  @override
  String get issuedAfterReview => 'تصدر بعد مراجعة الطلب';

  @override
  String get issuePolicyHint => 'ادفع إلكترونيًا واستلم الوثيقة في الحال';

  @override
  String get requestPolicy => 'طلب إصدار وثيقة';

  @override
  String get requestPolicyHint => 'أرسل بياناتك وسيتواصل معك موظف';

  @override
  String get knowThePrice => 'اعرف السعر';

  @override
  String get knowThePriceHint => 'احسب القيمة قبل إصدار الوثيقة';

  @override
  String get requestQuote => 'طلب عرض سعر';

  @override
  String get requestQuoteHint => 'يصلك السعر خلال يوم عمل';

  @override
  String get whatIsCovered => 'ماذا تغطي الوثيقة';

  @override
  String get requiredDocuments => 'المستندات المطلوبة';

  @override
  String get haveAQuestion => 'لديك سؤال؟ اتصل بنا على';

  @override
  String get add => 'إضافة';

  @override
  String get more => 'المزيد';

  @override
  String get choose => 'اختر';

  @override
  String get optional => 'اختياري';

  @override
  String get notes => 'ملاحظات';

  @override
  String get notice => 'تنبيه';

  @override
  String get total => 'الإجمالي';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get stepReview => 'الخطوة 2 من 3 · المراجعة';

  @override
  String get payAfterIssueHint => 'بعد الإصدار تنتقل إلى صفحة الوثيقة لإتمام الدفع إلكترونيًا أو في المقر الرئيسي.';

  @override
  String get issueNow => 'أصدر الوثيقة الآن';

  @override
  String get estimateDisclaimer => 'السعر تقديري، ويظهر السعر النهائي عند الإصدار حسب البيانات المسجّلة.';

  @override
  String get estimatedPrice => 'السعر التقديري';

  @override
  String get estimatedPriceOneYear => 'السعر التقديري لسنة واحدة';

  @override
  String get increase => 'زيادة';

  @override
  String get decrease => 'إنقاص';

  @override
  String get call => 'اتصال';

  @override
  String get motorIssueTitle => 'إصدار تأمين إجباري';

  @override
  String get motorStepVehicle => 'الخطوة 1 من 3 · المركبة';

  @override
  String get checkDataNotice => 'يرجى التأكد من صحة بيانات المركبة قبل الإصدار، فهي تُطبع على الوثيقة.';

  @override
  String get chooseVehicle => 'اختر المركبة';

  @override
  String get addNewVehicle => 'إضافة مركبة جديدة';

  @override
  String get policyData => 'بيانات الوثيقة';

  @override
  String get policyDuration => 'مدة التأمين';

  @override
  String get oneYear => 'سنة واحدة';

  @override
  String get insuredPerson => 'المؤمَّن له';

  @override
  String insuredUntil(String date) {
    return 'مؤمّنة حتى $date';
  }

  @override
  String get hasPendingPolicy => 'لها وثيقة بانتظار الدفع';

  @override
  String get notInsured => 'غير مؤمّنة';

  @override
  String get viewPolicy => 'عرض الوثيقة';

  @override
  String get motorPriceTitle => 'اعرف سعر التأمين الإجباري';

  @override
  String get engineCcInvalid => 'أدخل سعة محرك صحيحة (50 - 10000)';

  @override
  String get travelIssueTitle => 'إصدار تأمين سفر';

  @override
  String get travelStepTrip => 'الخطوة 1 من 3 · الرحلة والمسافرون';

  @override
  String get travelPriceTitle => 'اعرف سعر تأمين السفر';

  @override
  String get travelUnavailable => 'تأمين السفر غير متاح حاليًا، تواصل مع خدمة العملاء.';

  @override
  String get destination => 'الوجهة';

  @override
  String get tripLength => 'مدة الرحلة';

  @override
  String get tripDetails => 'بيانات الرحلة';

  @override
  String get travelDate => 'تاريخ السفر';

  @override
  String coverageEndsOn(String date) {
    return 'تنتهي التغطية في $date';
  }

  @override
  String get travellers => 'المسافرون';

  @override
  String get travellersNumber => 'عدد المسافرين';

  @override
  String travellersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مسافر',
      many: '$count مسافرًا',
      few: '$count مسافرين',
      two: 'مسافران',
      one: 'مسافر واحد',
      zero: 'لم تختر أي مسافر',
    );
    return '$_temp0';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم',
      many: '$count يومًا',
      few: '$count أيام',
      two: 'يومان',
      one: 'يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String fromPrice(String price) {
    return 'من $price';
  }

  @override
  String get pricePerTraveller => 'سعر الفرد';

  @override
  String get addTravellersHint => 'أضف الأشخاص المسافرين أولًا (الاسم وتاريخ الميلاد ورقم الجواز).';

  @override
  String get passportMissing => 'بدون رقم جواز';

  @override
  String passportRequiredFor(String names) {
    return 'يرجى إضافة رقم جواز السفر لـ: $names';
  }

  @override
  String get addPassport => 'إضافة رقم الجواز';

  @override
  String get addPerson => 'إضافة شخص';

  @override
  String get editPerson => 'تعديل بيانات الشخص';

  @override
  String get deletePerson => 'حذف الشخص';

  @override
  String deletePersonConfirm(String name) {
    return 'هل تريد حذف $name من قائمة الأشخاص؟ الوثائق الصادرة له لا تتأثر.';
  }

  @override
  String get personAdded => 'تمت إضافة الشخص';

  @override
  String get personUpdated => 'تم تحديث البيانات';

  @override
  String get personDeleted => 'تم حذف الشخص';

  @override
  String get relationship => 'صلة القرابة';

  @override
  String get relationshipSelf => 'أنا';

  @override
  String get relationshipSpouse => 'الزوج / الزوجة';

  @override
  String get relationshipChild => 'ابن / ابنة';

  @override
  String get relationshipParent => 'أب / أم';

  @override
  String get relationshipSibling => 'أخ / أخت';

  @override
  String get relationshipOther => 'آخر';

  @override
  String get birthDate => 'تاريخ الميلاد';

  @override
  String bornOn(String date) {
    return 'مواليد $date';
  }

  @override
  String get passportNo => 'رقم جواز السفر';

  @override
  String passportShort(String number) {
    return 'جواز $number';
  }

  @override
  String get passportNeededForTravel => 'مطلوب لتأمين السفر';

  @override
  String get sendRequest => 'إرسال الطلب';

  @override
  String get requestSent => 'تم إرسال طلبك، وسيتواصل معك أحد موظفي الشركة.';

  @override
  String get attach => 'إرفاق';

  @override
  String get documentsLaterHint => 'يمكنك إرسال الطلب الآن وإرفاق المستندات لاحقًا عند تواصل الموظف معك.';

  @override
  String get addVehicleFirst => 'أضف مركبتك أولًا من «المركبات».';

  @override
  String requestContactHint(String phone) {
    return 'سيتواصل معك موظف من الشركة على الرقم $phone خلال يوم عمل.';
  }

  @override
  String get requestDetails => 'تفاصيل الطلب';

  @override
  String sentOn(String date) {
    return 'أُرسل في $date';
  }

  @override
  String get requestWaitingHint => 'طلبك قيد المتابعة، وسيصلك رد الشركة هنا.';

  @override
  String get requestData => 'بيانات الطلب';

  @override
  String get companyReply => 'رد الشركة';

  @override
  String get offeredPrice => 'السعر المعروض';

  @override
  String get acceptOfferHint => 'لقبول العرض تواصل مع خدمة العملاء أو انتظر اتصال الموظف.';

  @override
  String get withdrawRequest => 'سحب الطلب';

  @override
  String get withdrawRequestConfirm => 'هل تريد سحب هذا الطلب؟';

  @override
  String get requestWithdrawn => 'تم سحب الطلب';

  @override
  String get noRequests => 'لا توجد طلبات';

  @override
  String get noRequestsHint => 'الطلبات التي ترسلها للمنتجات الأخرى تظهر هنا.';

  @override
  String get requestsNotificationHint => 'يصلك إشعار عند رد الشركة على أي طلب.';

  @override
  String get filterAllPolicies => 'كل الوثائق';

  @override
  String get filterActive => 'السارية';

  @override
  String get filterRequests => 'الطلبات';

  @override
  String validUntil(String date) {
    return 'سارية حتى $date';
  }

  @override
  String endedOn(String date) {
    return 'انتهت في $date';
  }

  @override
  String get awaitingPayment => 'بانتظار الدفع';

  @override
  String get cancelPolicyRequest => 'إلغاء الوثيقة';

  @override
  String get account => 'الحساب';

  @override
  String get settings => 'الإعدادات';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get documentsMissing => 'المستندات غير مكتملة';

  @override
  String get branchesAndAgents => 'الفروع والوكلاء';

  @override
  String get headOffice => 'المقر الرئيسي';

  @override
  String get agentsComingSoon => 'تُضاف الفروع والوكلاء الجدد هنا فور اعتمادهم.';

  @override
  String get website => 'الموقع الإلكتروني';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get aboutCompany => 'عن الشركة';

  @override
  String get appVersion => 'الإصدار';

  @override
  String get aboutApp => 'عن التطبيق';

  @override
  String get aboutAppBody =>
      'تطبيق العربية الكبرى للتأمين يتيح لك إصدار وثيقة التأمين من هاتفك ودفع قيمتها إلكترونيًا، وتبقى وثائقك معك في أي وقت مع رمز تحقق يثبت صحتها.';

  @override
  String get aboutAppFeatureIssue => 'إصدار الوثيقة خلال دقائق بدون زيارة المكتب';

  @override
  String get aboutAppFeaturePay => 'الدفع الإلكتروني عبر المحافظ وتطبيقات المصارف الليبية';

  @override
  String get aboutAppFeatureVerify => 'رمز QR على كل وثيقة يتحقق منه رجال المرور والجهات الرسمية';

  @override
  String get aboutAppFeatureSupport => 'متابعة طلباتك والتواصل مع خدمة العملاء من التطبيق';

  @override
  String aboutAppCopyright(int year) {
    return '© $year العربية الكبرى للتأمين المساهمة';
  }

  @override
  String get payWith => 'طريقة الدفع';

  @override
  String get paymentService => 'خدمة الدفع';

  @override
  String walletPhone(String method) {
    return 'رقم هاتفك المسجّل في $method';
  }

  @override
  String get walletPhoneHint => 'سيصلك رمز تحقق على هذا الرقم';

  @override
  String get sendPaymentCode => 'إرسال رمز التحقق';

  @override
  String enterPaymentCode(String phone) {
    return 'أدخل الرمز الذي وصلك على الرقم $phone لإتمام الدفع.';
  }

  @override
  String get confirmPayment => 'تأكيد الدفع';

  @override
  String get changeNumberOrResend => 'تغيير الرقم أو إعادة إرسال الرمز';
}
