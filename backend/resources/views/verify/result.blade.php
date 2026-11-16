@extends('layouts.public')

@section('title', 'نتيجة التحقق')

@php
    $view = match ($status ?? null) {
        \App\Services\Policy\PolicyVerificationService::VALID => ['tone' => 'ok', 'icon' => '&#10003;', 'title' => 'الوثيقة سارية'],
        \App\Services\Policy\PolicyVerificationService::EXPIRED => ['tone' => 'wait', 'icon' => '!', 'title' => 'الوثيقة منتهية'],
        \App\Services\Policy\PolicyVerificationService::CANCELLED => ['tone' => 'bad', 'icon' => '&#10005;', 'title' => 'الوثيقة ملغاة'],
        \App\Services\Policy\PolicyVerificationService::NOT_ACTIVE => ['tone' => 'muted', 'icon' => '&#8230;', 'title' => 'الوثيقة غير مفعّلة'],
        default => null,
    };
@endphp

@section('content')
    @if ($policy === null)
        <div class="icon bad">&#10005;</div>
        <div class="status bad">لا توجد وثيقة بهذه البيانات</div>
        @if ($detailed)
            <p>رمز التحقق غير صحيح. قد تكون الوثيقة غير صادرة عن الشركة؛ يرجى التواصل معنا للتأكد.</p>
        @else
            <p>تأكد من رقم الوثيقة ورقم اللوحة وحاول مرة أخرى.</p>
        @endif
    @else
        <div class="icon {{ $view['tone'] }}">{!! $view['icon'] !!}</div>
        <div class="status {{ $view['tone'] }}">{{ $view['title'] }}</div>
        <p class="checked-at">تم التحقق بتاريخ <span class="ltr">{{ now()->format('Y-m-d H:i') }}</span></p>

        <div class="rows">
            <div class="row"><span>رقم الوثيقة</span><span class="ltr">{{ $policy->policy_no }}</span></div>
            <div class="row"><span>نوع التأمين</span><span>{{ $policy->coverageType->name }}</span></div>
            <div class="row"><span>تاريخ البداية</span><span class="ltr">{{ $policy->start_date->format('Y-m-d') }}</span></div>
            <div class="row"><span>تاريخ النهاية</span><span class="ltr">{{ $policy->end_date->format('Y-m-d') }}</span></div>
            <div class="row"><span>رقم اللوحة</span><span class="ltr">{{ $policy->vehicle->plate_no }}</span></div>
            <div class="row"><span>المركبة</span><span class="ltr">{{ $policy->vehicle->make }} {{ $policy->vehicle->model }} {{ $policy->vehicle->year }}</span></div>
            @if ($detailed)
                <div class="row"><span>رقم الهيكل</span><span class="ltr">•••••••••••{{ substr($policy->vehicle->vin, -6) }}</span></div>
                <div class="row"><span>المؤمَّن له</span><span>{{ \App\Support\PersonName::mask($policy->vehicle->user->name) }}</span></div>
            @endif
        </div>

        <div class="note">
            تأكد من مطابقة رقم اللوحة ونوع المركبة مع المركبة الفعلية.
            هذه الصفحة صادرة من نظام {{ config('insurance.company.name_ar') }} مباشرة، ولا يُعتدّ بصورها الملتقطة.
        </div>
    @endif

    <div class="footer-links">
        <a href="{{ route('verify.form') }}">تحقق من وثيقة أخرى</a>
        · خدمة العملاء: <span class="ltr">{{ config('insurance.company.phone') }}</span>
    </div>
@endsection
