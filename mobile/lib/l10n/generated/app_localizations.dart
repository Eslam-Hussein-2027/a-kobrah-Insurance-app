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
  /// **'سجّل الدخول برقم هاتفك لإدارة وثائق التأمين'**
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
  /// **'يمكنك رفع المستندات الآن أو لاحقًا من «المزيد ← المعلومات الشخصية»، وهي مطلوبة قبل إصدار وثيقة التأمين الإجباري.'**
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

  /// No description provided for @noPolicies.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد وثائق تأمين بعد'**
  String get noPolicies;

  /// No description provided for @noPoliciesHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر منتجًا من الرئيسية لإصدار أول وثيقة.'**
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
  /// **'يجب رفع صورة إثبات الهوية وصورة رخصة القيادة قبل إصدار وثيقة التأمين الإجباري.'**
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
  /// **'د.ل'**
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

  /// No description provided for @verificationQrTitle.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق من الوثيقة'**
  String get verificationQrTitle;

  /// No description provided for @verificationQrHint.
  ///
  /// In ar, this message translates to:
  /// **'يمكن لرجال المرور والجهات الحكومية والشركات مسح هذا الرمز بكاميرا الهاتف للتأكد من صحة الوثيقة.'**
  String get verificationQrHint;

  /// No description provided for @tabHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get tabHome;

  /// No description provided for @tabMyInsurance.
  ///
  /// In ar, this message translates to:
  /// **'تأميناتي'**
  String get tabMyInsurance;

  /// No description provided for @tabPersons.
  ///
  /// In ar, this message translates to:
  /// **'الأشخاص'**
  String get tabPersons;

  /// No description provided for @tabMore.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get tabMore;

  /// No description provided for @hello.
  ///
  /// In ar, this message translates to:
  /// **'مرحبًا،'**
  String get hello;

  /// No description provided for @contactUs.
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا'**
  String get contactUs;

  /// No description provided for @insuranceProducts.
  ///
  /// In ar, this message translates to:
  /// **'منتجات التأمين'**
  String get insuranceProducts;

  /// No description provided for @myPoliciesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{وثائقي} other{وثائقي ({count})}}'**
  String myPoliciesCount(int count);

  /// No description provided for @instantIssue.
  ///
  /// In ar, this message translates to:
  /// **'إصدار فوري'**
  String get instantIssue;

  /// No description provided for @onRequest.
  ///
  /// In ar, this message translates to:
  /// **'بطلب عرض سعر'**
  String get onRequest;

  /// No description provided for @calculatePrice.
  ///
  /// In ar, this message translates to:
  /// **'احسب السعر'**
  String get calculatePrice;

  /// No description provided for @verifyPolicyShort.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من وثيقة'**
  String get verifyPolicyShort;

  /// No description provided for @branches.
  ///
  /// In ar, this message translates to:
  /// **'فروعنا'**
  String get branches;

  /// No description provided for @uninsuredVehicle.
  ///
  /// In ar, this message translates to:
  /// **'مركبة بدون تأمين'**
  String get uninsuredVehicle;

  /// No description provided for @insureItNow.
  ///
  /// In ar, this message translates to:
  /// **'أمّنها الآن'**
  String get insureItNow;

  /// No description provided for @noActivePolicy.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد وثيقة سارية'**
  String get noActivePolicy;

  /// No description provided for @noActivePolicyHint.
  ///
  /// In ar, this message translates to:
  /// **'أصدر وثيقة التأمين الإجباري لمركبتك في دقائق.'**
  String get noActivePolicyHint;

  /// No description provided for @verificationCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق'**
  String get verificationCode;

  /// No description provided for @endsOn.
  ///
  /// In ar, this message translates to:
  /// **'تنتهي في {date}'**
  String endsOn(String date);

  /// No description provided for @daysLeft.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{تنتهي اليوم} =1{متبقٍ يوم واحد} =2{متبقٍ يومان} few{متبقٍ {count} أيام} many{متبقٍ {count} يومًا} other{متبقٍ {count} يوم}}'**
  String daysLeft(int count);

  /// No description provided for @otherActivePolicies.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{ولديك وثيقة سارية أخرى في «تأميناتي»} =2{ولديك وثيقتان ساريتان أخريان في «تأميناتي»} few{ولديك {count} وثائق سارية أخرى في «تأميناتي»} other{ولديك {count} وثيقة سارية أخرى في «تأميناتي»}}'**
  String otherActivePolicies(int count);

  /// No description provided for @issuedInstantly.
  ///
  /// In ar, this message translates to:
  /// **'تصدر فورًا عبر التطبيق'**
  String get issuedInstantly;

  /// No description provided for @issuedAfterReview.
  ///
  /// In ar, this message translates to:
  /// **'تصدر بعد مراجعة الطلب'**
  String get issuedAfterReview;

  /// No description provided for @issuePolicyHint.
  ///
  /// In ar, this message translates to:
  /// **'ادفع إلكترونيًا واستلم الوثيقة في الحال'**
  String get issuePolicyHint;

  /// No description provided for @requestPolicy.
  ///
  /// In ar, this message translates to:
  /// **'طلب إصدار وثيقة'**
  String get requestPolicy;

  /// No description provided for @requestPolicyHint.
  ///
  /// In ar, this message translates to:
  /// **'أرسل بياناتك وسيتواصل معك موظف'**
  String get requestPolicyHint;

  /// No description provided for @knowThePrice.
  ///
  /// In ar, this message translates to:
  /// **'اعرف السعر'**
  String get knowThePrice;

  /// No description provided for @knowThePriceHint.
  ///
  /// In ar, this message translates to:
  /// **'احسب القيمة قبل إصدار الوثيقة'**
  String get knowThePriceHint;

  /// No description provided for @requestQuote.
  ///
  /// In ar, this message translates to:
  /// **'طلب عرض سعر'**
  String get requestQuote;

  /// No description provided for @requestQuoteHint.
  ///
  /// In ar, this message translates to:
  /// **'يصلك السعر خلال يوم عمل'**
  String get requestQuoteHint;

  /// No description provided for @whatIsCovered.
  ///
  /// In ar, this message translates to:
  /// **'ماذا تغطي الوثيقة'**
  String get whatIsCovered;

  /// No description provided for @requiredDocuments.
  ///
  /// In ar, this message translates to:
  /// **'المستندات المطلوبة'**
  String get requiredDocuments;

  /// No description provided for @haveAQuestion.
  ///
  /// In ar, this message translates to:
  /// **'لديك سؤال؟ اتصل بنا على'**
  String get haveAQuestion;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @more.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get more;

  /// No description provided for @choose.
  ///
  /// In ar, this message translates to:
  /// **'اختر'**
  String get choose;

  /// No description provided for @optional.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get optional;

  /// No description provided for @notes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get notes;

  /// No description provided for @notice.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه'**
  String get notice;

  /// No description provided for @total.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get total;

  /// No description provided for @continueLabel.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continueLabel;

  /// No description provided for @stepReview.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة 2 من 3 · المراجعة'**
  String get stepReview;

  /// No description provided for @payAfterIssueHint.
  ///
  /// In ar, this message translates to:
  /// **'بعد الإصدار تنتقل إلى صفحة الوثيقة لإتمام الدفع إلكترونيًا أو في المقر الرئيسي.'**
  String get payAfterIssueHint;

  /// No description provided for @issueNow.
  ///
  /// In ar, this message translates to:
  /// **'أصدر الوثيقة الآن'**
  String get issueNow;

  /// No description provided for @estimateDisclaimer.
  ///
  /// In ar, this message translates to:
  /// **'السعر تقديري، ويظهر السعر النهائي عند الإصدار حسب البيانات المسجّلة.'**
  String get estimateDisclaimer;

  /// No description provided for @estimatedPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر التقديري'**
  String get estimatedPrice;

  /// No description provided for @estimatedPriceOneYear.
  ///
  /// In ar, this message translates to:
  /// **'السعر التقديري لسنة واحدة'**
  String get estimatedPriceOneYear;

  /// No description provided for @increase.
  ///
  /// In ar, this message translates to:
  /// **'زيادة'**
  String get increase;

  /// No description provided for @decrease.
  ///
  /// In ar, this message translates to:
  /// **'إنقاص'**
  String get decrease;

  /// No description provided for @call.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get call;

  /// No description provided for @motorIssueTitle.
  ///
  /// In ar, this message translates to:
  /// **'إصدار تأمين إجباري'**
  String get motorIssueTitle;

  /// No description provided for @motorStepVehicle.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة 1 من 3 · المركبة'**
  String get motorStepVehicle;

  /// No description provided for @checkDataNotice.
  ///
  /// In ar, this message translates to:
  /// **'يرجى التأكد من صحة بيانات المركبة قبل الإصدار، فهي تُطبع على الوثيقة.'**
  String get checkDataNotice;

  /// No description provided for @chooseVehicle.
  ///
  /// In ar, this message translates to:
  /// **'اختر المركبة'**
  String get chooseVehicle;

  /// No description provided for @addNewVehicle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مركبة جديدة'**
  String get addNewVehicle;

  /// No description provided for @policyData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الوثيقة'**
  String get policyData;

  /// No description provided for @policyDuration.
  ///
  /// In ar, this message translates to:
  /// **'مدة التأمين'**
  String get policyDuration;

  /// No description provided for @oneYear.
  ///
  /// In ar, this message translates to:
  /// **'سنة واحدة'**
  String get oneYear;

  /// No description provided for @insuredPerson.
  ///
  /// In ar, this message translates to:
  /// **'المؤمَّن له'**
  String get insuredPerson;

  /// No description provided for @insuredUntil.
  ///
  /// In ar, this message translates to:
  /// **'مؤمّنة حتى {date}'**
  String insuredUntil(String date);

  /// No description provided for @hasPendingPolicy.
  ///
  /// In ar, this message translates to:
  /// **'لها وثيقة بانتظار الدفع'**
  String get hasPendingPolicy;

  /// No description provided for @notInsured.
  ///
  /// In ar, this message translates to:
  /// **'غير مؤمّنة'**
  String get notInsured;

  /// No description provided for @viewPolicy.
  ///
  /// In ar, this message translates to:
  /// **'عرض الوثيقة'**
  String get viewPolicy;

  /// No description provided for @motorPriceTitle.
  ///
  /// In ar, this message translates to:
  /// **'اعرف سعر التأمين الإجباري'**
  String get motorPriceTitle;

  /// No description provided for @engineCcInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل سعة محرك صحيحة (50 - 10000)'**
  String get engineCcInvalid;

  /// No description provided for @travelIssueTitle.
  ///
  /// In ar, this message translates to:
  /// **'إصدار تأمين سفر'**
  String get travelIssueTitle;

  /// No description provided for @travelStepTrip.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة 1 من 3 · الرحلة والمسافرون'**
  String get travelStepTrip;

  /// No description provided for @travelPriceTitle.
  ///
  /// In ar, this message translates to:
  /// **'اعرف سعر تأمين السفر'**
  String get travelPriceTitle;

  /// No description provided for @travelUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'تأمين السفر غير متاح حاليًا، تواصل مع خدمة العملاء.'**
  String get travelUnavailable;

  /// No description provided for @destination.
  ///
  /// In ar, this message translates to:
  /// **'الوجهة'**
  String get destination;

  /// No description provided for @tripLength.
  ///
  /// In ar, this message translates to:
  /// **'مدة الرحلة'**
  String get tripLength;

  /// No description provided for @tripDetails.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الرحلة'**
  String get tripDetails;

  /// No description provided for @travelDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ السفر'**
  String get travelDate;

  /// No description provided for @coverageEndsOn.
  ///
  /// In ar, this message translates to:
  /// **'تنتهي التغطية في {date}'**
  String coverageEndsOn(String date);

  /// No description provided for @travellers.
  ///
  /// In ar, this message translates to:
  /// **'المسافرون'**
  String get travellers;

  /// No description provided for @travellersNumber.
  ///
  /// In ar, this message translates to:
  /// **'عدد المسافرين'**
  String get travellersNumber;

  /// No description provided for @travellersCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لم تختر أي مسافر} =1{مسافر واحد} =2{مسافران} few{{count} مسافرين} many{{count} مسافرًا} other{{count} مسافر}}'**
  String travellersCount(int count);

  /// No description provided for @daysCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{يوم واحد} =2{يومان} few{{count} أيام} many{{count} يومًا} other{{count} يوم}}'**
  String daysCount(int count);

  /// No description provided for @fromPrice.
  ///
  /// In ar, this message translates to:
  /// **'من {price}'**
  String fromPrice(String price);

  /// No description provided for @pricePerTraveller.
  ///
  /// In ar, this message translates to:
  /// **'سعر الفرد'**
  String get pricePerTraveller;

  /// No description provided for @addTravellersHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف الأشخاص المسافرين أولًا (الاسم وتاريخ الميلاد ورقم الجواز).'**
  String get addTravellersHint;

  /// No description provided for @passportMissing.
  ///
  /// In ar, this message translates to:
  /// **'بدون رقم جواز'**
  String get passportMissing;

  /// No description provided for @passportRequiredFor.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إضافة رقم جواز السفر لـ: {names}'**
  String passportRequiredFor(String names);

  /// No description provided for @addPassport.
  ///
  /// In ar, this message translates to:
  /// **'إضافة رقم الجواز'**
  String get addPassport;

  /// No description provided for @personsHint.
  ///
  /// In ar, this message translates to:
  /// **'تختارهم مباشرة عند إصدار تأمين السفر بدون إعادة إدخال البيانات.'**
  String get personsHint;

  /// No description provided for @noPersons.
  ///
  /// In ar, this message translates to:
  /// **'لم تضف أي شخص بعد'**
  String get noPersons;

  /// No description provided for @noPersonsHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف نفسك وأفراد عائلتك لتأمين سفرهم.'**
  String get noPersonsHint;

  /// No description provided for @addPerson.
  ///
  /// In ar, this message translates to:
  /// **'إضافة شخص'**
  String get addPerson;

  /// No description provided for @editPerson.
  ///
  /// In ar, this message translates to:
  /// **'تعديل بيانات الشخص'**
  String get editPerson;

  /// No description provided for @deletePerson.
  ///
  /// In ar, this message translates to:
  /// **'حذف الشخص'**
  String get deletePerson;

  /// No description provided for @deletePersonConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف {name} من قائمة الأشخاص؟ الوثائق الصادرة له لا تتأثر.'**
  String deletePersonConfirm(String name);

  /// No description provided for @personAdded.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة الشخص'**
  String get personAdded;

  /// No description provided for @personUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث البيانات'**
  String get personUpdated;

  /// No description provided for @personDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الشخص'**
  String get personDeleted;

  /// No description provided for @relationship.
  ///
  /// In ar, this message translates to:
  /// **'صلة القرابة'**
  String get relationship;

  /// No description provided for @relationshipSelf.
  ///
  /// In ar, this message translates to:
  /// **'أنا'**
  String get relationshipSelf;

  /// No description provided for @relationshipSpouse.
  ///
  /// In ar, this message translates to:
  /// **'الزوج / الزوجة'**
  String get relationshipSpouse;

  /// No description provided for @relationshipChild.
  ///
  /// In ar, this message translates to:
  /// **'ابن / ابنة'**
  String get relationshipChild;

  /// No description provided for @relationshipParent.
  ///
  /// In ar, this message translates to:
  /// **'أب / أم'**
  String get relationshipParent;

  /// No description provided for @relationshipSibling.
  ///
  /// In ar, this message translates to:
  /// **'أخ / أخت'**
  String get relationshipSibling;

  /// No description provided for @relationshipOther.
  ///
  /// In ar, this message translates to:
  /// **'آخر'**
  String get relationshipOther;

  /// No description provided for @birthDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الميلاد'**
  String get birthDate;

  /// No description provided for @bornOn.
  ///
  /// In ar, this message translates to:
  /// **'مواليد {date}'**
  String bornOn(String date);

  /// No description provided for @passportNo.
  ///
  /// In ar, this message translates to:
  /// **'رقم جواز السفر'**
  String get passportNo;

  /// No description provided for @passportShort.
  ///
  /// In ar, this message translates to:
  /// **'جواز {number}'**
  String passportShort(String number);

  /// No description provided for @passportNeededForTravel.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب لتأمين السفر'**
  String get passportNeededForTravel;

  /// No description provided for @sendRequest.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب'**
  String get sendRequest;

  /// No description provided for @requestSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلبك، وسيتواصل معك أحد موظفي الشركة.'**
  String get requestSent;

  /// No description provided for @attach.
  ///
  /// In ar, this message translates to:
  /// **'إرفاق'**
  String get attach;

  /// No description provided for @documentsLaterHint.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك إرسال الطلب الآن وإرفاق المستندات لاحقًا عند تواصل الموظف معك.'**
  String get documentsLaterHint;

  /// No description provided for @addVehicleFirst.
  ///
  /// In ar, this message translates to:
  /// **'أضف مركبتك أولًا من «مركباتي».'**
  String get addVehicleFirst;

  /// No description provided for @requestContactHint.
  ///
  /// In ar, this message translates to:
  /// **'سيتواصل معك موظف من الشركة على الرقم {phone} خلال يوم عمل.'**
  String requestContactHint(String phone);

  /// No description provided for @requestDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطلب'**
  String get requestDetails;

  /// No description provided for @sentOn.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل في {date}'**
  String sentOn(String date);

  /// No description provided for @requestWaitingHint.
  ///
  /// In ar, this message translates to:
  /// **'طلبك قيد المتابعة، وسيصلك رد الشركة هنا.'**
  String get requestWaitingHint;

  /// No description provided for @requestData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الطلب'**
  String get requestData;

  /// No description provided for @companyReply.
  ///
  /// In ar, this message translates to:
  /// **'رد الشركة'**
  String get companyReply;

  /// No description provided for @offeredPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر المعروض'**
  String get offeredPrice;

  /// No description provided for @acceptOfferHint.
  ///
  /// In ar, this message translates to:
  /// **'لقبول العرض تواصل مع خدمة العملاء أو انتظر اتصال الموظف.'**
  String get acceptOfferHint;

  /// No description provided for @withdrawRequest.
  ///
  /// In ar, this message translates to:
  /// **'سحب الطلب'**
  String get withdrawRequest;

  /// No description provided for @withdrawRequestConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد سحب هذا الطلب؟'**
  String get withdrawRequestConfirm;

  /// No description provided for @requestWithdrawn.
  ///
  /// In ar, this message translates to:
  /// **'تم سحب الطلب'**
  String get requestWithdrawn;

  /// No description provided for @noRequests.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات'**
  String get noRequests;

  /// No description provided for @noRequestsHint.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات التي ترسلها للمنتجات الأخرى تظهر هنا.'**
  String get noRequestsHint;

  /// No description provided for @requestsNotificationHint.
  ///
  /// In ar, this message translates to:
  /// **'يصلك إشعار عند رد الشركة على أي طلب.'**
  String get requestsNotificationHint;

  /// No description provided for @filterAllPolicies.
  ///
  /// In ar, this message translates to:
  /// **'كل الوثائق'**
  String get filterAllPolicies;

  /// No description provided for @filterActive.
  ///
  /// In ar, this message translates to:
  /// **'السارية'**
  String get filterActive;

  /// No description provided for @filterRequests.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات'**
  String get filterRequests;

  /// No description provided for @validUntil.
  ///
  /// In ar, this message translates to:
  /// **'سارية حتى {date}'**
  String validUntil(String date);

  /// No description provided for @endedOn.
  ///
  /// In ar, this message translates to:
  /// **'انتهت في {date}'**
  String endedOn(String date);

  /// No description provided for @awaitingPayment.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الدفع'**
  String get awaitingPayment;

  /// No description provided for @cancelPolicyRequest.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الوثيقة'**
  String get cancelPolicyRequest;

  /// No description provided for @account.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get account;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @personalInfo.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية'**
  String get personalInfo;

  /// No description provided for @documentsMissing.
  ///
  /// In ar, this message translates to:
  /// **'المستندات غير مكتملة'**
  String get documentsMissing;

  /// No description provided for @branchesAndAgents.
  ///
  /// In ar, this message translates to:
  /// **'الفروع والوكلاء'**
  String get branchesAndAgents;

  /// No description provided for @headOffice.
  ///
  /// In ar, this message translates to:
  /// **'المقر الرئيسي'**
  String get headOffice;

  /// No description provided for @agentsComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'تُضاف الفروع والوكلاء الجدد هنا فور اعتمادهم.'**
  String get agentsComingSoon;

  /// No description provided for @website.
  ///
  /// In ar, this message translates to:
  /// **'الموقع الإلكتروني'**
  String get website;

  /// No description provided for @privacy.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية'**
  String get privacy;

  /// No description provided for @aboutCompany.
  ///
  /// In ar, this message translates to:
  /// **'عن الشركة'**
  String get aboutCompany;

  /// No description provided for @appVersion.
  ///
  /// In ar, this message translates to:
  /// **'إصدار التطبيق'**
  String get appVersion;
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
