import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar'), Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'العربية الكبرى للتأمين'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحبًا بك'**
  String get welcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول برقم هاتفك لإدارة تأمين سيارتك'**
  String get loginSubtitle;

  /// No description provided for @phoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneLabel;

  /// No description provided for @sendCode.
  ///
  /// In ar, this message translates to:
  /// **'إرسال رمز التحقق'**
  String get sendCode;

  /// No description provided for @verifyPolicyLink.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من وثيقة تأمين'**
  String get verifyPolicyLink;

  /// No description provided for @otpTitle.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز المكوّن من 6 أرقام المرسل إلى الرقم {phone}'**
  String otpSubtitle(String phone);

  /// No description provided for @otpLength.
  ///
  /// In ar, this message translates to:
  /// **'الرمز يجب أن يتكون من 6 أرقام'**
  String get otpLength;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @resendCode.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال بعد {seconds} ثانية'**
  String resendIn(int seconds);

  /// No description provided for @codeResent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رمز جديد'**
  String get codeResent;

  /// No description provided for @registerTitle.
  ///
  /// In ar, this message translates to:
  /// **'إكمال التسجيل'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تم التحقق من رقم هاتفك. أكمل بياناتك لإنشاء الحساب.'**
  String get registerSubtitle;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @nationalNumber.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الوطني'**
  String get nationalNumber;

  /// No description provided for @idImage.
  ///
  /// In ar, this message translates to:
  /// **'صورة إثبات الهوية'**
  String get idImage;

  /// No description provided for @licenseImage.
  ///
  /// In ar, this message translates to:
  /// **'صورة رخصة القيادة'**
  String get licenseImage;

  /// No description provided for @documentsOptionalHint.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك رفع المستندات الآن أو لاحقًا من صفحة «حسابي»، وهي مطلوبة قبل إصدار الوثيقة.'**
  String get documentsOptionalHint;

  /// No description provided for @chooseImage.
  ///
  /// In ar, this message translates to:
  /// **'اختيار صورة'**
  String get chooseImage;

  /// No description provided for @imageSelected.
  ///
  /// In ar, this message translates to:
  /// **'تم اختيار الصورة'**
  String get imageSelected;

  /// No description provided for @createAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحساب'**
  String get createAccount;

  /// No description provided for @registrationExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت صلاحية جلسة التسجيل، يرجى طلب رمز تحقق جديد.'**
  String get registrationExpired;

  /// No description provided for @camera.
  ///
  /// In ar, this message translates to:
  /// **'الكاميرا'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In ar, this message translates to:
  /// **'معرض الصور'**
  String get gallery;

  /// No description provided for @tabVehicles.
  ///
  /// In ar, this message translates to:
  /// **'مركباتي'**
  String get tabVehicles;

  /// No description provided for @tabPolicies.
  ///
  /// In ar, this message translates to:
  /// **'وثائقي'**
  String get tabPolicies;

  /// No description provided for @tabProfile.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get tabProfile;

  /// No description provided for @addVehicle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مركبة'**
  String get addVehicle;

  /// No description provided for @editVehicle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المركبة'**
  String get editVehicle;

  /// No description provided for @noVehicles.
  ///
  /// In ar, this message translates to:
  /// **'لم تضف أي مركبة بعد'**
  String get noVehicles;

  /// No description provided for @noVehiclesHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف مركبتك لتتمكن من تأمينها'**
  String get noVehiclesHint;

  /// No description provided for @plateNo.
  ///
  /// In ar, this message translates to:
  /// **'رقم اللوحة'**
  String get plateNo;

  /// No description provided for @plateHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 5-123456'**
  String get plateHint;

  /// No description provided for @vin.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهيكل (الشاسيه)'**
  String get vin;

  /// No description provided for @vinHint.
  ///
  /// In ar, this message translates to:
  /// **'17 حرفًا ورقمًا'**
  String get vinHint;

  /// No description provided for @make.
  ///
  /// In ar, this message translates to:
  /// **'الماركة'**
  String get make;

  /// No description provided for @model.
  ///
  /// In ar, this message translates to:
  /// **'الموديل'**
  String get model;

  /// No description provided for @year.
  ///
  /// In ar, this message translates to:
  /// **'سنة الصنع'**
  String get year;

  /// No description provided for @engineCc.
  ///
  /// In ar, this message translates to:
  /// **'سعة المحرك'**
  String get engineCc;

  /// No description provided for @ccUnit.
  ///
  /// In ar, this message translates to:
  /// **'سي سي'**
  String get ccUnit;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @insureVehicle.
  ///
  /// In ar, this message translates to:
  /// **'تأمين المركبة'**
  String get insureVehicle;

  /// No description provided for @deleteVehicleTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المركبة'**
  String get deleteVehicleTitle;

  /// No description provided for @deleteVehicleConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف المركبة {plate}؟'**
  String deleteVehicleConfirm(String plate);

  /// No description provided for @vehicleAdded.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة المركبة'**
  String get vehicleAdded;

  /// No description provided for @vehicleUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث بيانات المركبة'**
  String get vehicleUpdated;

  /// No description provided for @vehicleDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المركبة'**
  String get vehicleDeleted;

  /// No description provided for @vehicleNotFound.
  ///
  /// In ar, this message translates to:
  /// **'المركبة غير موجودة'**
  String get vehicleNotFound;

  /// No description provided for @noPolicies.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد وثائق تأمين بعد'**
  String get noPolicies;

  /// No description provided for @noPoliciesHint.
  ///
  /// In ar, this message translates to:
  /// **'اذهب إلى «مركباتي» واضغط «تأمين المركبة»'**
  String get noPoliciesHint;

  /// No description provided for @policyNo.
  ///
  /// In ar, this message translates to:
  /// **'رقم الوثيقة'**
  String get policyNo;

  /// No description provided for @coverage.
  ///
  /// In ar, this message translates to:
  /// **'نوع التأمين'**
  String get coverage;

  /// No description provided for @startDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ البداية'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ النهاية'**
  String get endDate;

  /// No description provided for @issuedAt.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإصدار'**
  String get issuedAt;

  /// No description provided for @premium.
  ///
  /// In ar, this message translates to:
  /// **'القسط'**
  String get premium;

  /// No description provided for @vehicle.
  ///
  /// In ar, this message translates to:
  /// **'المركبة'**
  String get vehicle;

  /// No description provided for @policyDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الوثيقة'**
  String get policyDetails;

  /// No description provided for @downloadPdf.
  ///
  /// In ar, this message translates to:
  /// **'تحميل الوثيقة للطباعة (PDF)'**
  String get downloadPdf;

  /// No description provided for @pdfMobileOnly.
  ///
  /// In ar, this message translates to:
  /// **'تحميل الوثيقة متاح من تطبيق الهاتف'**
  String get pdfMobileOnly;

  /// No description provided for @pendingPaymentTitle.
  ///
  /// In ar, this message translates to:
  /// **'الوثيقة بانتظار الدفع'**
  String get pendingPaymentTitle;

  /// No description provided for @pendingPaymentBody.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك دفع القسط الآن إلكترونيًا، وبعد تأكيد الدفع ستتمكن من تحميل الوثيقة وطباعتها مباشرة.'**
  String get pendingPaymentBody;

  /// No description provided for @customerService.
  ///
  /// In ar, this message translates to:
  /// **'خدمة العملاء'**
  String get customerService;

  /// No description provided for @cancelRequest.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الطلب'**
  String get cancelRequest;

  /// No description provided for @cancelRequestConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إلغاء طلب هذه الوثيقة؟'**
  String get cancelRequestConfirm;

  /// No description provided for @policyCancelled.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الطلب'**
  String get policyCancelled;

  /// No description provided for @policyCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الوثيقة، يرجى إتمام الدفع لتفعيلها'**
  String get policyCreated;

  /// No description provided for @quoteTitle.
  ///
  /// In ar, this message translates to:
  /// **'سعر التأمين'**
  String get quoteTitle;

  /// No description provided for @basePrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر الأساسي'**
  String get basePrice;

  /// No description provided for @priceDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل السعر'**
  String get priceDetails;

  /// No description provided for @totalPremium.
  ///
  /// In ar, this message translates to:
  /// **'القسط الإجمالي'**
  String get totalPremium;

  /// No description provided for @coverageStart.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ بداية التأمين'**
  String get coverageStart;

  /// No description provided for @issuePolicy.
  ///
  /// In ar, this message translates to:
  /// **'إصدار الوثيقة'**
  String get issuePolicy;

  /// No description provided for @kycMissingTitle.
  ///
  /// In ar, this message translates to:
  /// **'المستندات مطلوبة'**
  String get kycMissingTitle;

  /// No description provided for @kycMissingBody.
  ///
  /// In ar, this message translates to:
  /// **'يجب رفع صورة إثبات الهوية وصورة رخصة القيادة قبل إصدار الوثيقة.'**
  String get kycMissingBody;

  /// No description provided for @goToProfile.
  ///
  /// In ar, this message translates to:
  /// **'رفع المستندات'**
  String get goToProfile;

  /// No description provided for @documents.
  ///
  /// In ar, this message translates to:
  /// **'المستندات'**
  String get documents;

  /// No description provided for @uploaded.
  ///
  /// In ar, this message translates to:
  /// **'تم الرفع'**
  String get uploaded;

  /// No description provided for @notUploaded.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم الرفع'**
  String get notUploaded;

  /// No description provided for @upload.
  ///
  /// In ar, this message translates to:
  /// **'رفع'**
  String get upload;

  /// No description provided for @replace.
  ///
  /// In ar, this message translates to:
  /// **'تغيير'**
  String get replace;

  /// No description provided for @documentUploaded.
  ///
  /// In ar, this message translates to:
  /// **'تم رفع المستند'**
  String get documentUploaded;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل الخروج؟'**
  String get logoutConfirm;

  /// No description provided for @verifyTitle.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من وثيقة'**
  String get verifyTitle;

  /// No description provided for @verifySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم الوثيقة ورقم اللوحة للتحقق من صلاحية الوثيقة'**
  String get verifySubtitle;

  /// No description provided for @check.
  ///
  /// In ar, this message translates to:
  /// **'تحقق'**
  String get check;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @requiredField.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get requiredField;

  /// No description provided for @networkError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.'**
  String get networkError;

  /// No description provided for @unexpectedError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع، حاول مرة أخرى.'**
  String get unexpectedError;

  /// No description provided for @currency.
  ///
  /// In ar, this message translates to:
  /// **'دينار ليبي'**
  String get currency;

  /// No description provided for @payOnline.
  ///
  /// In ar, this message translates to:
  /// **'ادفع الآن إلكترونيًا'**
  String get payOnline;

  /// No description provided for @checkPaymentStatus.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من حالة الدفع'**
  String get checkPaymentStatus;

  /// No description provided for @orPayAtOffice.
  ///
  /// In ar, this message translates to:
  /// **'أو ادفع في أحد مكاتب الشركة مع ذكر رقم الوثيقة.'**
  String get orPayAtOffice;

  /// No description provided for @paymentSucceeded.
  ///
  /// In ar, this message translates to:
  /// **'تم الدفع بنجاح وتفعيل الوثيقة'**
  String get paymentSucceeded;

  /// No description provided for @paymentFailed.
  ///
  /// In ar, this message translates to:
  /// **'لم تتم عملية الدفع، يمكنك المحاولة مرة أخرى'**
  String get paymentFailed;

  /// No description provided for @paymentNotConfirmedYet.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تأكيد الدفع بعد، حاول بعد لحظات'**
  String get paymentNotConfirmedYet;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
