@extends('layouts.public')

@section('title', 'التحقق من وثيقة تأمين')

@section('content')
    <h1>التحقق من وثيقة تأمين</h1>
    <p>امسح رمز QR الموجود على الوثيقة بكاميرا الهاتف، أو أدخل رقم الوثيقة ورقم اللوحة.</p>

    <form method="GET" action="{{ route('verify.form') }}" novalidate>
        <label for="policy_no">رقم الوثيقة</label>
        <input id="policy_no" name="policy_no" dir="ltr" autocomplete="off" placeholder="POL-2026-000001"
               value="{{ $input['policy_no'] ?? '' }}" required>
        @if (isset($formErrors) && $formErrors->has('policy_no'))
            <div class="error">رقم الوثيقة يجب أن يكون بالصيغة POL-2026-000001</div>
        @endif

        <label for="plate_no">رقم اللوحة</label>
        <input id="plate_no" name="plate_no" dir="ltr" autocomplete="off" placeholder="5-123456"
               value="{{ $input['plate_no'] ?? '' }}" required>
        @if (isset($formErrors) && $formErrors->has('plate_no'))
            <div class="error">يرجى إدخال رقم اللوحة</div>
        @endif

        <button class="btn btn-pay" type="submit" style="margin-top: 20px">تحقق</button>
    </form>

    <div class="footer-links">خدمة العملاء: <span class="ltr">{{ config('insurance.company.phone') }}</span></div>
@endsection
