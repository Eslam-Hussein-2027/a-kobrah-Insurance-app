<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="noindex">
    <title>@yield('title') - {{ config('insurance.company.name_ar') }}</title>
    <style>
        @font-face { font-family: Tajawal; src: url('{{ asset('fonts/Tajawal-Regular.ttf') }}'); font-weight: 400; }
        @font-face { font-family: Tajawal; src: url('{{ asset('fonts/Tajawal-Bold.ttf') }}'); font-weight: 700; }
        :root { --navy: #14178F; --blue: #0A7FD4; --bg: #F4F6FB; --border: #E1E5EF; --muted: #667085; --ok: #12805C; --bad: #C0352B; --warn: #B54708; }
        * { box-sizing: border-box; }
        body { margin: 0; min-height: 100vh; background: var(--bg); font-family: Tajawal, system-ui, sans-serif; color: #101828; display: flex; align-items: center; justify-content: center; padding: 16px; }
        .card { width: 100%; max-width: 420px; background: #fff; border: 1px solid var(--border); border-radius: 20px; padding: 28px 24px; text-align: center; }
        .logo { height: 48px; margin-bottom: 20px; }
        h1 { font-size: 22px; color: var(--navy); margin: 8px 0 4px; }
        p { color: var(--muted); line-height: 1.7; margin: 6px 0; }
        .amount { font-size: 32px; font-weight: 700; color: var(--navy); margin: 18px 0 4px; }
        .row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid var(--border); font-size: 15px; }
        .row span:first-child { color: var(--muted); }
        .ltr { direction: ltr; unicode-bidi: isolate; font-weight: 700; }
        .btn { display: block; width: 100%; border: 0; border-radius: 14px; padding: 15px; font: inherit; font-size: 17px; font-weight: 700; cursor: pointer; margin-top: 12px; }
        .btn-pay { background: var(--navy); color: #fff; }
        .btn-decline { background: #fff; color: var(--bad); border: 1px solid var(--bad); }
        .badge { display: inline-block; background: #FEF0C7; color: var(--warn); border-radius: 999px; padding: 4px 12px; font-size: 13px; font-weight: 700; }
        .icon { width: 72px; height: 72px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 8px; font-size: 38px; color: #fff; }
        .icon.ok { background: var(--ok); } .icon.bad { background: var(--bad); } .icon.wait { background: var(--warn); }
    </style>
</head>
<body>
    <main class="card">
        <img class="logo" src="{{ asset('images/logo.png') }}" alt="{{ config('insurance.company.name_ar') }}">
        @yield('content')
    </main>
</body>
</html>
