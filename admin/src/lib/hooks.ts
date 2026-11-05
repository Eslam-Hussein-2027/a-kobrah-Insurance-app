import { useEffect, useState } from 'react';
import { useSearchParams } from 'react-router';

export function useDebounced<T>(value: T, delay = 350): T {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const id = window.setTimeout(() => setDebounced(value), delay);
    return () => window.clearTimeout(id);
  }, [value, delay]);
  return debounced;
}

/**
 * Filters kept in the URL (?status=…&search=…&page=…) so pages can be linked and refreshed.
 * Changing any filter resets the page to 1.
 */
export function useUrlFilters<K extends string>(keys: readonly K[]) {
  const [params, setParams] = useSearchParams();

  const values = Object.fromEntries(keys.map((k) => [k, params.get(k) ?? ''])) as Record<K, string>;
  const page = Math.max(1, Number(params.get('page') ?? 1) || 1);

  const set = (key: K | 'page', value: string | number) => {
    setParams(
      (current) => {
        const next = new URLSearchParams(current);
        if (value === '' || value === 0) next.delete(key);
        else next.set(key, String(value));
        if (key !== 'page') next.delete('page');
        return next;
      },
      { replace: true },
    );
  };

  return { values, page, set };
}
