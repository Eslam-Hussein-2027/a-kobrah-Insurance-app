import type { ReactNode } from 'react';
import { NavLink, Navigate, Outlet } from 'react-router';
import { useAuth } from '../auth/AuthContext';
import { Loading } from './ui';

const NAV = [
  { to: '/', label: 'الرئيسية', icon: '▦', end: true },
  { to: '/policies', label: 'الوثائق', icon: '▤' },
  { to: '/payments', label: 'المدفوعات', icon: '◈' },
  { to: '/customers', label: 'العملاء', icon: '◉' },
  { to: '/pricing', label: 'التسعير', icon: '◧' },
];

export function RequireAuth({ children }: { children: ReactNode }) {
  const { user, ready } = useAuth();
  if (!ready) return <Loading />;
  if (!user) return <Navigate to="/login" replace />;
  return children;
}

export function Layout() {
  const { user, logout } = useAuth();

  return (
    <div className="min-h-screen md:flex">
      <aside className="border-line bg-white md:sticky md:top-0 md:flex md:h-screen md:w-64 md:shrink-0 md:flex-col md:border-e">
        <div className="flex items-center justify-between gap-3 border-b border-line px-5 py-4">
          <img src="/logo.png" alt="العربية الكبرى للتأمين" className="h-10" />
        </div>
        <nav className="flex gap-1 overflow-x-auto p-3 md:flex-1 md:flex-col md:overflow-visible">
          {NAV.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.end}
              className={({ isActive }) =>
                `flex items-center gap-3 rounded-xl px-4 py-2.5 text-sm font-bold whitespace-nowrap transition-colors ${
                  isActive ? 'bg-navy text-white' : 'text-slate-600 hover:bg-page'
                }`
              }
            >
              <span aria-hidden className="text-base">
                {item.icon}
              </span>
              {item.label}
            </NavLink>
          ))}
        </nav>
        <div className="hidden border-t border-line p-4 md:block">
          <p className="text-sm font-bold">{user?.name}</p>
          <p className="ltr text-xs text-muted">{user?.phone}</p>
          <button onClick={logout} className="mt-3 text-sm font-bold text-bad hover:underline">
            تسجيل الخروج
          </button>
        </div>
      </aside>

      <main className="min-w-0 flex-1 p-4 md:p-8">
        <Outlet />
      </main>
    </div>
  );
}
