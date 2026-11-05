/**
 * Minimal client for the Laravel API envelope:
 *   { success, message, data, meta?: { pagination } }  /  { success: false, message, errors? }
 * Messages come back already in Arabic (Accept-Language: ar).
 */

const BASE_URL = (import.meta.env.VITE_API_BASE_URL as string | undefined) ?? 'http://127.0.0.1:8000/api/v1';
const TOKEN_KEY = 'akobrah_admin_token';

export const NETWORK_ERROR = 'تعذّر الاتصال بالخادم. تحقق من الاتصال وحاول مرة أخرى.';
export const UNEXPECTED_ERROR = 'حدث خطأ غير متوقع، حاول مرة أخرى.';

export interface Pagination {
  current_page: number;
  per_page: number;
  total: number;
  last_page: number;
}

export interface Envelope<T> {
  success: boolean;
  message: string | null;
  data: T;
  meta?: { pagination?: Pagination };
}

export class ApiError extends Error {
  readonly status: number;
  readonly fieldErrors: Record<string, string[]>;

  constructor(message: string, status: number, fieldErrors: Record<string, string[]> = {}) {
    super(message);
    this.status = status;
    this.fieldErrors = fieldErrors;
  }

  field(name: string): string | undefined {
    return this.fieldErrors[name]?.[0];
  }
}

export function toApiError(status: number, body: unknown): ApiError {
  if (body && typeof body === 'object') {
    const { message, errors } = body as { message?: unknown; errors?: unknown };
    const fields: Record<string, string[]> = {};
    if (errors && typeof errors === 'object') {
      for (const [key, value] of Object.entries(errors)) {
        if (Array.isArray(value)) fields[key] = value.map(String);
      }
    }
    return new ApiError(typeof message === 'string' && message ? message : UNEXPECTED_ERROR, status, fields);
  }
  return new ApiError(UNEXPECTED_ERROR, status);
}

/** Token persistence; storage can be unavailable (private mode), so every access is guarded. */
export const tokenStore = {
  get(): string | null {
    try {
      return localStorage.getItem(TOKEN_KEY);
    } catch {
      return null;
    }
  },
  set(token: string) {
    try {
      localStorage.setItem(TOKEN_KEY, token);
    } catch {
      /* session-only */
    }
  },
  clear() {
    try {
      localStorage.removeItem(TOKEN_KEY);
    } catch {
      /* ignore */
    }
  },
};

let unauthorizedHandler: (() => void) | undefined;

export function onUnauthorized(handler: () => void) {
  unauthorizedHandler = handler;
}

type QueryValue = string | number | boolean | null | undefined;

export function buildUrl(path: string, query: Record<string, QueryValue> = {}): string {
  const url = new URL(BASE_URL.replace(/\/$/, '') + path);
  for (const [key, value] of Object.entries(query)) {
    if (value !== undefined && value !== null && value !== '' && value !== false) {
      url.searchParams.set(key, String(value === true ? 1 : value));
    }
  }
  return url.toString();
}

async function send(path: string, init: RequestInit & { query?: Record<string, QueryValue> }): Promise<Response> {
  const headers = new Headers(init.headers);
  if (!headers.has('Accept')) headers.set('Accept', 'application/json');
  headers.set('Accept-Language', 'ar');
  const token = tokenStore.get();
  if (token) headers.set('Authorization', `Bearer ${token}`);

  let response: Response;
  try {
    response = await fetch(buildUrl(path, init.query), { ...init, headers });
  } catch {
    throw new ApiError(NETWORK_ERROR, 0);
  }

  if (!response.ok) {
    const body: unknown = await response.json().catch(() => null);
    if (response.status === 401 && token) unauthorizedHandler?.();
    throw toApiError(response.status, body);
  }
  return response;
}

export async function api<T>(
  path: string,
  options: { method?: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE'; body?: unknown; query?: Record<string, QueryValue> } = {},
): Promise<Envelope<T>> {
  const response = await send(path, {
    method: options.method ?? 'GET',
    query: options.query,
    headers: options.body === undefined ? undefined : { 'Content-Type': 'application/json' },
    body: options.body === undefined ? undefined : JSON.stringify(options.body),
  });
  return (await response.json()) as Envelope<T>;
}

/** Downloads a protected file (e.g. policy PDF) and opens it in a new tab for printing. */
export async function openProtectedFile(path: string): Promise<void> {
  const popup = window.open('', '_blank');
  try {
    const response = await send(path, { method: 'GET', headers: { Accept: 'application/pdf' } });
    const blobUrl = URL.createObjectURL(await response.blob());
    if (popup) popup.location.href = blobUrl;
    else window.location.href = blobUrl;
  } catch (error) {
    popup?.close();
    throw error;
  }
}
