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
        'id_image' => 'صورة بطاقة الرقم القومي',
        'license_image' => 'صورة رخصة القيادة',
    ],

    'policy_verification' => [
        'VALID' => 'الوثيقة سارية',
        'EXPIRED' => 'الوثيقة منتهية',
        'NOT_FOUND' => 'لا توجد وثيقة سارية بهذه البيانات',
    ],

];
