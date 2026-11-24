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

];
