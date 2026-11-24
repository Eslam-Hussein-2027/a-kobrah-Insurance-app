@php
    /**
     * Shared A4 layout for printable policies — Arabic (RTL), black & white, single page.
     * mPDF notes: no CSS `size` in @page (format comes from config/pdf.php, `size` breaks pagination);
     * Latin text / dates next to Arabic are wrapped in <bdo dir="ltr"> so mPDF's BiDi doesn't reorder
     * them (e.g. "Co." → ".Co", "2026-11-05" → "05-11-2026").
     *
     * Sections: title_ar, title_en, footer_hint, content, terms (<li> items).
     *
     * @var \App\Models\Policy $policy
     */
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
        .company-en { font-size: 11pt; font-weight: bold; }
        .muted { font-size: 9pt; line-height: 1.35; }

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
        .qr-cell { text-align: center; vertical-align: middle; }
        .qr-caption { font-size: 8.5pt; font-weight: bold; margin-top: 1mm; }
        .stamp-line { border-top: 0.6pt solid #000; padding-top: 1mm; font-weight: bold; }

        .footer { font-size: 8pt; border-top: 0.6pt solid #000; }
    </style>
</head>
<body>

<htmlpagefooter name="policyFooter">
    <table class="footer">
        <tr>
            <td style="text-align: right; padding-top: 1.5mm;">
                @yield('footer_hint')
            </td>
            <td style="text-align: left; padding-top: 1.5mm;"><bdo dir="ltr">{{ $company['verification_url'] }}</bdo></td>
        </tr>
    </table>
</htmlpagefooter>

{{-- ================= Header ================= --}}
{{-- The logo already carries the Arabic name; the English name and contact details sit opposite it. --}}
<table>
    <tr>
        <td style="width: 50%; text-align: right; vertical-align: middle;">
            @if ($logo)
                <img src="{{ $logo }}" style="width: 64mm;" alt="">
            @else
                <div class="company-ar">{{ $company['name_ar'] }}</div>
            @endif
        </td>
        <td style="width: 50%; text-align: left; vertical-align: middle;" class="muted">
            <div class="company-en"><bdo dir="ltr">{{ $company['name_en'] }}</bdo></div>
            <div>{{ $company['address'] }} - هاتف: {{ $company['phone'] }}</div>
            <div>تاريخ الإصدار: <bdo dir="ltr">{{ ($policy->issued_at ?? now())->format('Y-m-d') }}</bdo></div>
        </td>
    </tr>
</table>

<div class="title-box">
    <div class="title-ar">@yield('title_ar')</div>
    <div class="title-en">@yield('title_en')</div>
</div>

<div class="policy-no">رقم الوثيقة: {{ $policy->policy_no }}</div>

@yield('content')

{{-- ================= Terms + signature (side by side to keep a single page) ================= --}}
<div class="section-title">ملاحظات هامة</div>
<table>
    <tr>
        <td class="terms" style="width: 50%;">
            <ol>
                @yield('terms')
            </ol>
        </td>
        {{-- Signed verification link: scanning opens the company's official page with the live status. --}}
        <td class="qr-cell" style="width: 22%;">
            <barcode code="{{ $verificationUrl }}" type="QR" size="1.25" error="M" disableborder="1" />
            <div class="qr-caption">امسح للتحقق</div>
        </td>
        <td class="stamp-cell" style="width: 28%;">
            @if ($stamp)
                <img src="{{ $stamp }}" style="height: 26mm;" alt=""><br>
            @endif
            <div class="stamp-line">توقيع وختم الشركة</div>
        </td>
    </tr>
</table>

</body>
</html>
