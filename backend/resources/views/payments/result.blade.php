@extends('payments.layout')

@section('title', 'نتيجة الدفع')

@php($status = $payment->status)

@section('content')
    @if ($status === \App\Enums\PaymentStatus::Paid)
        <div class="icon ok">&#10003;</div>
        <h1>تم الدفع بنجاح</h1>
        @if ($payment->requires_refund)
            <p>تم استلام المبلغ لكن الوثيقة لم تعد بانتظار الدفع. سيتواصل معك فريقنا لاسترداد المبلغ.</p>
        @else
            <p>تم تفعيل وثيقتك. يمكنك العودة إلى التطبيق لتحميل الوثيقة وطباعتها.</p>
        @endif
    @elseif ($status === \App\Enums\PaymentStatus::Failed)
        <div class="icon bad">&#10005;</div>
        <h1>لم تتم عملية الدفع</h1>
        <p>لم يتم خصم أي مبلغ. يمكنك العودة إلى التطبيق والمحاولة مرة أخرى أو الدفع في أحد مكاتبنا.</p>
    @else
        <div class="icon wait">&#8230;</div>
        <h1>جارٍ تأكيد الدفع</h1>
        <p>نحن بانتظار تأكيد مزوّد الدفع. ستظهر النتيجة في التطبيق خلال لحظات.</p>
    @endif

    <div class="amount">{{ number_format((float) $payment->amount, 2) }} {{ config('insurance.currency_label') }}</div>
    <div class="row"><span>رقم الوثيقة</span><span class="ltr">{{ $payment->policy->policy_no }}</span></div>
    <p style="margin-top: 18px">يمكنك إغلاق هذه الصفحة والعودة إلى التطبيق.</p>
@endsection
