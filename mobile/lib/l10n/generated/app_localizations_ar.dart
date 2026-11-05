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
  String get loginSubtitle => 'سجّل الدخول برقم هاتفك لإدارة تأمين سيارتك';

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
      'يمكنك رفع المستندات الآن أو لاحقًا من صفحة «حسابي»، وهي مطلوبة قبل إصدار الوثيقة.';

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
  String get tabVehicles => 'مركباتي';

  @override
  String get tabPolicies => 'وثائقي';

  @override
  String get tabProfile => 'حسابي';

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
  String get insureVehicle => 'تأمين المركبة';

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
  String get vehicleNotFound => 'المركبة غير موجودة';

  @override
  String get noPolicies => 'لا توجد وثائق تأمين بعد';

  @override
  String get noPoliciesHint => 'اذهب إلى «مركباتي» واضغط «تأمين المركبة»';

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
  String get cancelRequest => 'إلغاء الطلب';

  @override
  String get cancelRequestConfirm => 'هل تريد إلغاء طلب هذه الوثيقة؟';

  @override
  String get policyCancelled => 'تم إلغاء الطلب';

  @override
  String get policyCreated => 'تم إنشاء الوثيقة، يرجى إتمام الدفع لتفعيلها';

  @override
  String get quoteTitle => 'سعر التأمين';

  @override
  String get basePrice => 'السعر الأساسي';

  @override
  String get priceDetails => 'تفاصيل السعر';

  @override
  String get totalPremium => 'القسط الإجمالي';

  @override
  String get coverageStart => 'تاريخ بداية التأمين';

  @override
  String get issuePolicy => 'إصدار الوثيقة';

  @override
  String get kycMissingTitle => 'المستندات مطلوبة';

  @override
  String get kycMissingBody => 'يجب رفع صورة إثبات الهوية وصورة رخصة القيادة قبل إصدار الوثيقة.';

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
  String get currency => 'دينار ليبي';

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
}
