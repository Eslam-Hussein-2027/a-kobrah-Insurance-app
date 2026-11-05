/** Shapes of the Laravel API responses (backend/app/Http/Resources). */

export interface EnumValue<T extends string = string> {
  value: T;
  label: string;
}

export type PolicyStatus = 'PENDING_PAYMENT' | 'ACTIVE' | 'EXPIRED' | 'CANCELLED';
export type PaymentStatus = 'PENDING' | 'PAID' | 'FAILED' | 'REFUNDED';
export type PaymentMethod = 'ONLINE' | 'OFFICE';

export interface User {
  id: number;
  name: string;
  phone: string;
  national_id: string | null;
  role: EnumValue;
}

export interface Vehicle {
  id: number;
  plate_no: string;
  vin: string;
  make: string;
  model: string;
  year: number;
  engine_cc: number;
}

export interface CoverageType {
  id: number;
  code: string;
  name: string;
  name_en?: string | null;
  description: string | null;
  base_price: string;
  is_mandatory: boolean;
  is_active?: boolean;
}

export interface Payment {
  id: number;
  policy_id: number;
  amount: string;
  currency: string;
  method: EnumValue<PaymentMethod>;
  gateway: string | null;
  reference: string | null;
  status: EnumValue<PaymentStatus>;
  failure_reason: string | null;
  requires_refund: boolean;
  paid_at: string | null;
  confirmed_by?: string | null;
  policy?: { id: number; policy_no: string; vehicle?: Vehicle };
  created_at: string;
}

export interface PricingSnapshot {
  base_price: string;
  premium: string;
  factors: { type: string; input: number; multiplier: string }[];
}

export interface AdminPolicy {
  id: number;
  policy_no: string;
  status: EnumValue<PolicyStatus>;
  start_date: string;
  end_date: string;
  premium: string;
  currency: string;
  issued_at: string | null;
  customer: { id: number; name: string; phone: string; national_id: string | null } | null;
  vehicle?: Vehicle;
  coverage_type?: CoverageType;
  payments?: Payment[];
  pricing_snapshot?: PricingSnapshot | null;
  created_at: string;
}

export interface CustomerDocument {
  label: string;
  uploaded: boolean;
  url: string | null;
}

export interface Customer {
  id: number;
  name: string;
  phone: string;
  national_id: string | null;
  is_active: boolean;
  kyc_completed: boolean;
  vehicles_count?: number;
  policies_count?: number;
  documents: Record<'id_image' | 'license_image', CustomerDocument>;
  vehicles?: Vehicle[];
  policies?: AdminPolicy[];
  created_at: string;
}

export interface Stats {
  policies: { active: number; pending_payment: number; expired: number; cancelled: number; issued_this_month: number };
  revenue: { currency: string; total: string; this_month: string; online: string; office: string };
  customers: number;
  vehicles: number;
  refunds_required: number;
  monthly: { month: string; policies: number; revenue: string }[];
}

export type FactorType = 'vehicle_age' | 'engine_cc' | 'claims_history';

export interface PricingFactor {
  id: number;
  factor_type: EnumValue<FactorType>;
  min_value: number;
  max_value: number | null;
  multiplier: string;
}

export interface Pricing {
  coverage_types: CoverageType[];
  factors: PricingFactor[];
  factor_types: EnumValue<FactorType>[];
  gaps: Record<FactorType, string[]>;
}
