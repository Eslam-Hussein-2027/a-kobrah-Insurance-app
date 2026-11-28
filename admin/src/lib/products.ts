import { useQuery } from '@tanstack/react-query';
import { api } from './api';
import type { ProductCode } from './types';

export interface OfferedProduct {
  code: ProductCode;
  name: string;
  issuance: 'instant' | 'request';
}

/**
 * Products the company currently offers in the app (GET /products), in display order.
 * Screens use it to hide filters and sections of switched-off products (e.g. travel).
 */
export function useOfferedProducts() {
  const query = useQuery({
    queryKey: ['products'],
    queryFn: () => api<OfferedProduct[]>('/products').then((r) => r.data),
    staleTime: Infinity,
  });
  const all = query.data ?? [];
  return {
    all,
    instant: all.filter((p) => p.issuance === 'instant'),
    onRequest: all.filter((p) => p.issuance === 'request'),
  };
}
