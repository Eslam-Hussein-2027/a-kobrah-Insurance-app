import { useQueryClient } from '@tanstack/react-query';
import type { ReactNode } from 'react';
import { createContext, useCallback, useContext, useEffect, useMemo, useState } from 'react';
import { ApiError, api, onUnauthorized, tokenStore } from '../lib/api';
import type { User } from '../lib/types';

export const NOT_ADMIN_MESSAGE = 'هذا الحساب لا يملك صلاحية الدخول إلى لوحة التحكم.';

interface AuthState {
  user: User | null;
  ready: boolean;
  login: (phone: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthState | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const queryClient = useQueryClient();
  const [user, setUser] = useState<User | null>(null);
  const [ready, setReady] = useState(false);

  const signOutLocally = useCallback(() => {
    tokenStore.clear();
    setUser(null);
    queryClient.clear();
  }, [queryClient]);

  useEffect(() => {
    onUnauthorized(signOutLocally);

    if (!tokenStore.get()) {
      setReady(true);
      return;
    }

    api<User>('/auth/me')
      .then(({ data }) => (data.role.value === 'admin' ? setUser(data) : signOutLocally()))
      .catch(signOutLocally)
      .finally(() => setReady(true));
  }, [signOutLocally]);

  const login = useCallback(async (phone: string, password: string) => {
    const { data } = await api<{ token: string; user: User }>('/auth/staff/login', {
      method: 'POST',
      body: { phone, password, device_name: 'admin-dashboard' },
    });

    if (data.user.role.value !== 'admin') {
      tokenStore.set(data.token);
      await api('/auth/logout', { method: 'POST' }).catch(() => undefined);
      tokenStore.clear();
      throw new ApiError(NOT_ADMIN_MESSAGE, 403);
    }

    tokenStore.set(data.token);
    setUser(data.user);
  }, []);

  const logout = useCallback(async () => {
    await api('/auth/logout', { method: 'POST' }).catch(() => undefined);
    signOutLocally();
  }, [signOutLocally]);

  const value = useMemo(() => ({ user, ready, login, logout }), [user, ready, login, logout]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthState {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used inside <AuthProvider>');
  return ctx;
}
