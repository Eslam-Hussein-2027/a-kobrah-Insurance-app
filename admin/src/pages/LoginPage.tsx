import type { FormEvent } from 'react';
import { useState } from 'react';
import { Navigate, useNavigate } from 'react-router';
import { useAuth } from '../auth/AuthContext';
import { Button, Input } from '../components/ui';
import { ApiError, UNEXPECTED_ERROR } from '../lib/api';

export function LoginPage() {
  const { user, login } = useAuth();
  const navigate = useNavigate();
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<ApiError | null>(null);

  if (user) return <Navigate to="/" replace />;

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      await login(phone.trim(), password);
      navigate('/', { replace: true });
    } catch (err) {
      setError(err instanceof ApiError ? err : new ApiError(UNEXPECTED_ERROR, 0));
    } finally {
      setLoading(false);
    }
  };

  const fieldError = error?.field('phone') ?? error?.field('password');

  return (
    <div className="flex min-h-screen items-center justify-center p-4">
      <form onSubmit={submit} className="w-full max-w-sm rounded-2xl border border-line bg-white p-8">
        <img src="/logo.png" alt="العربية الكبرى للتأمين" className="mx-auto mb-6 h-14" />
        <h1 className="text-center text-xl font-bold text-navy">لوحة تحكم الموظفين</h1>
        <p className="mb-6 mt-1 text-center text-sm text-muted">سجّل الدخول برقم الهاتف وكلمة المرور</p>

        <div className="space-y-4">
          <Input label="رقم الهاتف" ltr inputMode="tel" autoComplete="username" placeholder="09XXXXXXXX" value={phone} onChange={(e) => setPhone(e.target.value)} required />
          <Input label="كلمة المرور" ltr type="password" autoComplete="current-password" value={password} onChange={(e) => setPassword(e.target.value)} required />
        </div>

        {error && <p className="mt-4 rounded-xl bg-bad/10 px-3 py-2 text-sm text-bad">{fieldError ?? error.message}</p>}

        <Button type="submit" loading={loading} className="mt-6 w-full py-3">
          دخول
        </Button>
      </form>
    </div>
  );
}
