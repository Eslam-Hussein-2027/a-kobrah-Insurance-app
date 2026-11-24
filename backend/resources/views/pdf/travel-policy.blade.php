@extends('pdf.layouts.policy')

{{--
    A4 printable travel policy.
    @var \App\Models\Policy $policy
    @var \Illuminate\Support\Collection<int, \App\Models\PolicyTraveller> $travellers
--}}
@php($money = number_format((float) $policy->premium, 2))

@section('title_ar', 'وثيقة تأمين سفر')
@section('title_en', 'TRAVEL INSURANCE POLICY')
@section('footer_hint', 'للتحقق من صحة الوثيقة امسح رمز QR بكاميرا الهاتف، أو افتح:')

@section('content')
{{-- ================= Policy ================= --}}
<div class="section-title">بيانات الوثيقة</div>
<table class="grid">
    <tr>
        <td class="label">الوجهة<br><span class="en">Destination</span></td>
        <td class="value">{{ $policy->travel_zone->label() }}</td>
        <td class="label">مدة الرحلة<br><span class="en">Trip Length</span></td>
        <td class="value">{{ $policy->travel_days }} يومًا</td>
    </tr>
    <tr>
        <td class="label">تاريخ البداية<br><span class="en">Start Date</span></td>
        <td class="value">{{ $policy->start_date->format('Y-m-d') }}</td>
        <td class="label">تاريخ النهاية<br><span class="en">End Date</span></td>
        <td class="value">{{ $policy->end_date->format('Y-m-d') }}</td>
    </tr>
    <tr>
        <td class="label">القسط المدفوع<br><span class="en">Premium Paid</span></td>
        <td class="value">{{ $money }} {{ $currency_label }}</td>
        <td class="label">عدد المسافرين<br><span class="en">Travellers</span></td>
        <td class="value">{{ $travellers->count() }}</td>
    </tr>
</table>

{{-- ================= Policyholder ================= --}}
<div class="section-title">بيانات حامل الوثيقة</div>
<table class="grid">
    <tr>
        <td class="label">الاسم<br><span class="en">Name</span></td>
        <td class="value">{{ $customer->name }}</td>
        <td class="label">رقم الهاتف<br><span class="en">Phone</span></td>
        <td class="value">{{ $customer->phone }}</td>
    </tr>
</table>

{{-- ================= Travellers ================= --}}
<div class="section-title">المسافرون المؤمَّن عليهم</div>
<table class="grid">
    <tr>
        <td class="label" style="width: 6%; text-align: center;">#</td>
        <td class="label" style="width: 44%;">الاسم<br><span class="en">Name</span></td>
        <td class="label" style="width: 25%;">تاريخ الميلاد<br><span class="en">Date of Birth</span></td>
        <td class="label" style="width: 25%;">رقم الجواز<br><span class="en">Passport No.</span></td>
    </tr>
    @foreach ($travellers as $traveller)
        <tr>
            <td class="value" style="text-align: center;">{{ $loop->iteration }}</td>
            <td class="value">{{ $traveller->full_name }}</td>
            <td class="value">{{ $traveller->birth_date->format('Y-m-d') }}</td>
            <td class="value"><bdo dir="ltr">{{ $traveller->passport_no }}</bdo></td>
        </tr>
    @endforeach
</table>
@endsection

@section('terms')
    <li>تغطي هذه الوثيقة المسافرين المذكورين أعلاه فقط، في الوجهة والفترة المذكورتين، وتخضع للشروط العامة لتأمين السفر لدى الشركة.</li>
    <li>في الحالات الطارئة أثناء السفر يرجى التواصل مع الشركة على الرقم {{ $company['phone'] }}.</li>
    <li>أي كشط أو تعديل في بيانات هذه الوثيقة يلغيها، ويمكن التحقق من صحتها في أي وقت بمسح رمز QR.</li>
@endsection
