@php
    /**
     * A4 printable motor policy — Arabic (RTL), black & white, single page.
     * mPDF notes: no CSS `size` in @page (format comes from config/pdf.php, `size` breaks pagination);
     * Latin text / dates next to Arabic are wrapped in <bdo dir="ltr"> so mPDF's BiDi doesn't reorder
     * them (e.g. "Co." → ".Co", "2026-11-05" → "05-11-2026").
     *
     * @var \App\Models\Policy $policy
     */
    $money = number_format((float) $policy->premium, 2);
@endphp
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>{{ $policy->policy_no }}</title>
    <style>
        @page {
            margin: 12mm 13mm 20mm 13mm;
            footer: html_policyFooter;
        }

        body { font-family: amiri; font-size: 11pt; color: #000; }
        table { width: 100%; border-collapse: collapse; }

        .company-ar { font-size: 16pt; font-weight: bold; }
        .company-en { font-size: 9.5pt; }
        .muted { font-size: 8.5pt; }

        .title-box { border: 1.5pt solid #000; text-align: center; padding: 2.5mm 0; margin: 4mm 0 3mm 0; }
        .title-ar { font-size: 17pt; font-weight: bold; }
        .title-en { font-size: 9pt; letter-spacing: 1pt; }

        .policy-no { font-size: 13pt; font-weight: bold; text-align: center; border: 0.8pt dashed #000; padding: 1.5mm; margin-bottom: 3mm; }

        .section-title { font-size: 12pt; font-weight: bold; border-bottom: 1.2pt solid #000; padding-bottom: 0.5mm; margin: 3mm 0 1.5mm 0; }

        .grid td { border: 0.6pt solid #000; padding: 1.4mm 2.2mm; vertical-align: middle; }
        .grid td.label { width: 21%; font-weight: bold; background-color: #eeeeee; line-height: 1.15; }
        .grid td.value { width: 29%; }
        .en { font-weight: normal; font-size: 7.5pt; }

        .terms { font-size: 9pt; line-height: 1.45; vertical-align: top; }
        .terms ol { margin: 0; padding-right: 5mm; }

        .stamp-cell { text-align: center; vertical-align: bottom; }
        .stamp-line { border-top: 0.6pt solid #000; padding-top: 1mm; font-weight: bold; }

        .footer { font-size: 8pt; border-top: 0.6pt solid #000; }
    </style>
</head>
<body>

<htmlpagefooter name="policyFooter">
    <table class="footer">
        <tr>
            <td style="text-align: right; padding-top: 1.5mm;">
                للتحقق من صحة الوثيقة يرجى زيارة الرابط التالي وإدخال رقم الوثيقة ورقم اللوحة:
            </td>
            <td style="text-align: left; padding-top: 1.5mm;"><bdo dir="ltr">{{ $company['verification_url'] }}</bdo></td>
        </tr>
    </table>
</htmlpagefooter>

{{-- ================= Header ================= --}}
<table>
    <tr>
        <td style="width: 22%; text-align: right; vertical-align: middle;">
            @if ($logo)
                <img src="{{ $logo }}" style="height: 20mm;" alt="">
            @endif
        </td>
        <td style="text-align: center; vertical-align: middle;">
            <div class="company-ar">{{ $company['name_ar'] }}</div>
            <div class="company-en"><bdo dir="ltr">{{ $company['name_en'] }}</bdo></div>
            <div class="muted">{{ $company['address'] }} - هاتف: {{ $company['phone'] }}</div>
        </td>
        <td style="width: 22%; text-align: left; vertical-align: middle;" class="muted">
            <div>تاريخ الإصدار</div>
            <div><bdo dir="ltr">{{ ($policy->issued_at ?? now())->format('Y-m-d') }}</bdo></div>
        </td>
    </tr>
</table>

<div class="title-box">
    <div class="title-ar">وثيقة تأمين سيارة</div>
    <div class="title-en">MOTOR INSURANCE POLICY</div>
</div>

<div class="policy-no">رقم الوثيقة: {{ $policy->policy_no }}</div>

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
        <td class="label">الرقم القومي<br><span class="en">National ID</span></td>
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

{{-- ================= Terms + signature (side by side to keep a single page) ================= --}}
<div class="section-title">ملاحظات هامة</div>
<table>
    <tr>
        <td class="terms" style="width: 64%;">
            <ol>
                <li>تسري هذه الوثيقة خلال الفترة المذكورة أعلاه فقط، وتخضع للشروط والأحكام العامة لوثائق تأمين السيارات لدى الشركة.</li>
                <li>يجب الإبلاغ عن أي حادث خلال المدة المحددة في الشروط العامة عبر تطبيق الشركة أو أحد فروعها.</li>
                <li>أي كشط أو تعديل في بيانات هذه الوثيقة يلغيها، ويمكن التحقق من صحتها عبر رابط التحقق أسفل الصفحة.</li>
            </ol>
        </td>
        <td class="stamp-cell" style="width: 36%;">
            @if ($stamp)
                <img src="{{ $stamp }}" style="height: 26mm;" alt=""><br>
            @endif
            <div class="stamp-line">توقيع وختم الشركة</div>
        </td>
    </tr>
</table>

</body>
</html>
