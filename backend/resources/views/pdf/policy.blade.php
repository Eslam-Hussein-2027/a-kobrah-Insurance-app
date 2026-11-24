@extends('pdf.layouts.policy')

{{-- A4 printable motor policy. @var \App\Models\Policy $policy --}}
@php($money = number_format((float) $policy->premium, 2))

@section('title_ar', 'وثيقة تأمين سيارة')
@section('title_en', 'MOTOR INSURANCE POLICY')
@section('footer_hint', 'للتحقق من صحة الوثيقة امسح رمز QR بكاميرا الهاتف، أو أدخل رقم الوثيقة ورقم اللوحة في:')

@section('content')
{{-- ================= Policy ================= --}}
<div class="section-title">بيانات الوثيقة</div>
<table class="grid">
    <tr>
        <td class="label">نوع التغطية<br><span class="en">Coverage</span></td>
        <td class="value">{{ $coverage->name }}</td>
        <td class="label">القسط المدفوع<br><span class="en">Premium Paid</span></td>
        <td class="value">{{ $money }} {{ $currency_label }}</td>
    </tr>
    <tr>
        <td class="label">تاريخ البداية<br><span class="en">Start Date</span></td>
        <td class="value">{{ $policy->start_date->format('Y-m-d') }}</td>
        <td class="label">تاريخ النهاية<br><span class="en">End Date</span></td>
        <td class="value">{{ $policy->end_date->format('Y-m-d') }}</td>
    </tr>
</table>

{{-- ================= Insured person ================= --}}
<div class="section-title">بيانات المؤمَّن له</div>
<table class="grid">
    <tr>
        <td class="label">الاسم<br><span class="en">Name</span></td>
        <td class="value" colspan="3">{{ $customer->name }}</td>
    </tr>
    <tr>
        <td class="label">الرقم الوطني<br><span class="en">National Number</span></td>
        <td class="value">{{ $customer->national_id }}</td>
        <td class="label">رقم الهاتف<br><span class="en">Phone</span></td>
        <td class="value">{{ $customer->phone }}</td>
    </tr>
</table>

{{-- ================= Vehicle ================= --}}
<div class="section-title">بيانات المركبة</div>
<table class="grid">
    <tr>
        <td class="label">رقم اللوحة<br><span class="en">Plate Number</span></td>
        <td class="value">{{ $vehicle->plate_no }}</td>
        <td class="label">رقم الشاسيه<br><span class="en">VIN</span></td>
        <td class="value">{{ $vehicle->vin }}</td>
    </tr>
    <tr>
        <td class="label">الماركة<br><span class="en">Make</span></td>
        <td class="value">{{ $vehicle->make }}</td>
        <td class="label">الموديل<br><span class="en">Model</span></td>
        <td class="value">{{ $vehicle->model }}</td>
    </tr>
    <tr>
        <td class="label">سنة الصنع<br><span class="en">Year</span></td>
        <td class="value">{{ $vehicle->year }}</td>
        <td class="label">سعة المحرك<br><span class="en">Engine</span></td>
        <td class="value">{{ $vehicle->engine_cc }} سي سي</td>
    </tr>
</table>
@endsection

@section('terms')
    <li>تسري هذه الوثيقة خلال الفترة المذكورة أعلاه فقط، وتخضع للشروط والأحكام العامة لوثائق تأمين السيارات لدى الشركة.</li>
    <li>يجب الإبلاغ عن أي حادث خلال المدة المحددة في الشروط العامة عبر تطبيق الشركة أو أحد فروعها.</li>
    <li>أي كشط أو تعديل في بيانات هذه الوثيقة يلغيها، ويمكن التحقق من صحتها في أي وقت بمسح رمز QR.</li>
@endsection
