<?php

return [

    'user_role' => [
        'customer' => 'عميل',
        'surveyor' => 'معاين',
        'admin' => 'مدير النظام',
        'workshop' => 'ورشة صيانة',
    ],

    'policy_status' => [
        'PENDING_PAYMENT' => 'بانتظار الدفع',
        'ACTIVE' => 'سارية',
        'EXPIRED' => 'منتهية',
        'CANCELLED' => 'ملغاة',
    ],

    'payment_method' => [
        'ONLINE' => 'دفع إلكتروني',
        'OFFICE' => 'الدفع في المكتب',
    ],

    'payment_status' => [
        'PENDING' => 'قيد الانتظار',
        'PAID' => 'مدفوع',
        'FAILED' => 'فشل الدفع',
        'REFUNDED' => 'مسترد',
    ],

    'pricing_factor_type' => [
        'vehicle_age' => 'عمر المركبة',
        'engine_cc' => 'سعة المحرك',
        'claims_history' => 'سجل المطالبات',
    ],

    'claim_status' => [
        'SUBMITTED' => 'تم التقديم',
        'UNDER_REVIEW' => 'قيد المراجعة',
        'SURVEYOR_ASSIGNED' => 'تم تعيين معاين',
        'INSPECTED' => 'تمت المعاينة',
        'APPROVED' => 'تمت الموافقة',
        'IN_REPAIR' => 'قيد الإصلاح',
        'SETTLED' => 'تمت التسوية',
        'CLOSED' => 'مغلقة',
        'REJECTED' => 'مرفوضة',
    ],

    'claim_media_type' => [
        'DAMAGE' => 'صورة الضرر',
        'POLICE_REPORT' => 'محضر الشرطة',
    ],

    'user_document_type' => [
        'id_image' => 'صورة إثبات الهوية (البطاقة الشخصية أو جواز السفر)',
        'license_image' => 'صورة رخصة القيادة',
    ],

    'policy_verification' => [
        'VALID' => 'الوثيقة سارية',
        'EXPIRED' => 'الوثيقة منتهية',
        'NOT_FOUND' => 'لا توجد وثيقة سارية بهذه البيانات',
    ],

    'insurance_product' => [
        'motor' => 'التأمين الإجباري',
        'travel' => 'تأمين السفر',
        'orange_card' => 'البطاقة البرتقالية',
        'foreign_workers' => 'العمالة الوافدة',
        'medical_liability' => 'المسؤولية الطبية',
        'marine_cargo' => 'التأمين البحري',
    ],

    'person_relationship' => [
        'self' => 'أنا',
        'spouse' => 'الزوج / الزوجة',
        'child' => 'ابن / ابنة',
        'parent' => 'أب / أم',
        'sibling' => 'أخ / أخت',
        'other' => 'آخر',
    ],

    'insurance_request_kind' => [
        'issue' => 'طلب إصدار',
        'quote' => 'طلب عرض سعر',
    ],

    'insurance_request_status' => [
        'SUBMITTED' => 'تم الإرسال',
        'IN_REVIEW' => 'قيد المراجعة',
        'QUOTED' => 'وصل عرض السعر',
        'COMPLETED' => 'مكتمل',
        'REJECTED' => 'مرفوض',
        'CANCELLED' => 'ملغى',
    ],

    'travel_zone' => [
        'arab' => 'الدول العربية',
        'schengen' => 'أوروبا (شنغن)',
        'worldwide' => 'جميع دول العالم',
    ],

    'vehicle_color' => [
        'white' => 'أبيض',
        'black' => 'أسود',
        'silver' => 'فضي',
        'grey' => 'رمادي',
        'red' => 'أحمر',
        'blue' => 'أزرق',
        'green' => 'أخضر',
        'beige' => 'بيج',
        'brown' => 'بني',
        'gold' => 'ذهبي',
        'yellow' => 'أصفر',
        'orange' => 'برتقالي',
        'other' => 'لون آخر',
    ],

    'manufacture_country' => [
        'japan' => 'اليابان',
        'south_korea' => 'كوريا الجنوبية',
        'germany' => 'ألمانيا',
        'united_states' => 'الولايات المتحدة',
        'china' => 'الصين',
        'france' => 'فرنسا',
        'italy' => 'إيطاليا',
        'united_kingdom' => 'المملكة المتحدة',
        'sweden' => 'السويد',
        'czech_republic' => 'التشيك',
        'spain' => 'إسبانيا',
        'turkey' => 'تركيا',
        'india' => 'الهند',
        'iran' => 'إيران',
        'malaysia' => 'ماليزيا',
        'other' => 'بلد آخر',
    ],

    'license_purpose' => [
        'private' => 'خاصة',
        'taxi' => 'أجرة (تاكسي)',
        'private_transport' => 'نقل خاص',
        'public_transport' => 'نقل عام',
        'passenger_transport' => 'نقل ركاب (حافلة)',
        'driving_school' => 'تعليم قيادة',
        'government' => 'حكومية',
    ],

    'licensing_authority' => [
        'tripoli' => 'مرور طرابلس',
        'benghazi' => 'مرور بنغازي',
        'misrata' => 'مرور مصراتة',
        'zawiya' => 'مرور الزاوية',
        'sabha' => 'مرور سبها',
        'bayda' => 'مرور البيضاء',
        'tobruk' => 'مرور طبرق',
        'derna' => 'مرور درنة',
        'sirte' => 'مرور سرت',
        'khoms' => 'مرور الخمس',
        'zliten' => 'مرور زليتن',
        'gharyan' => 'مرور غريان',
        'ajdabiya' => 'مرور أجدابيا',
        'marj' => 'مرور المرج',
        'sabratha' => 'مرور صبراتة',
        'zuwara' => 'مرور زوارة',
        'tarhuna' => 'مرور ترهونة',
        'bani_walid' => 'مرور بني وليد',
        'kufra' => 'مرور الكفرة',
        'ubari' => 'مرور أوباري',
        'ghat' => 'مرور غات',
        'murzuq' => 'مرور مرزق',
        'jufra' => 'مرور الجفرة',
        'nalut' => 'مرور نالوت',
        'yafran' => 'مرور يفرن',
        'other' => 'جهة أخرى',
    ],

];
