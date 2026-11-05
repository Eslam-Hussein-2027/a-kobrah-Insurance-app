@extends('payments.layout')

@section('title', 'بوابة الدفع التجريبية')

@section('content')
    <span class="badge">بوابة دفع تجريبية - لا يتم خصم أي مبلغ</span>
    <h1>إتمام الدفع</h1>
    <p>هذه الصفحة تحاكي صفحة مزوّد الدفع الإلكتروني لأغراض التجربة فقط.</p>

    <div class="amount">{{ number_format((float) $payment->amount, 2) }} {{ config('insurance.currency_label') }}</div>

    <div class="row"><span>رقم الوثيقة</span><span class="ltr">{{ $payment->policy->policy_no }}</span></div>
    <div class="row"><span>مرجع العملية</span><span class="ltr">{{ $payment->gateway_ref }}</span></div>

    <form method="POST" action="{{ $action }}">
        @csrf
        <button class="btn btn-pay" type="submit" name="outcome" value="paid">دفع ناجح</button>
        <button class="btn btn-decline" type="submit" name="outcome" value="failed">رفض الدفع</button>
    </form>
@endsection
