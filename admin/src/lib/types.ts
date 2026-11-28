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
  /** Registration details: null for vehicles added before they were asked. */
  owner_name: string | null;
  owner_address: string | null;
  color: EnumValue | null;
  country_of_origin: EnumValue | null;
  license_purpose: EnumValue | null;
  seats: number | null;
  licensing_authority: EnumValue | null;
  details_complete: boolean;
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

/** Motor: base × factors. Travel: price per traveller × travellers. */
export interface PricingSnapshot {
  product?: 'travel';
  base_price?: string;
  factors?: { type: string; input: number; multiplier: string }[];
  price_per_traveller?: string;
  travellers?: number;
  premium: string;
}

export type ProductCode = 'motor' | 'travel' | 'orange_card' | 'foreign_workers' | 'medical_liability' | 'marine_cargo';

export interface Traveller {
  full_name: string;
  birth_date: string;
  passport_no: string;
}

export interface TravelInfo {
  zone: EnumValue | null;
  days: number | null;
  travellers: Traveller[];
}

export interface AdminPolicy {
  id: number;
  policy_no: string;
  product: EnumValue<ProductCode>;
  /** "التأمين الإجباري (ضد الغير)" / "تأمين السفر - أوروبا (شنغن)" */
  title: string;
  status: EnumValue<PolicyStatus>;
  start_date: string;
  end_date: string;
  premium: string;
  currency: string;
  issued_at: string | null;
  customer: { id: number; name: string; phone: string; national_id: string | null } | null;
  /** Motor only. */
  vehicle?: Vehicle | null;
  coverage_type?: CoverageType | null;
  /** Travel only. */
  travel?: TravelInfo | null;
  payments?: Payment[];
  pricing_snapshot?: PricingSnapshot | null;
  /** Same signed link as the QR printed on the policy (issued policies only). */
  verification_url?: string;
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
  address: string | null;
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
  active_by_product: Partial<Record<ProductCode, number>>;
  open_requests: number;
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

export interface TravelRate {
  id: number;
  zone: EnumValue;
  days: number;
  price: string;
  is_active: boolean;
}

export interface Pricing {
  coverage_types: CoverageType[];
  factors: PricingFactor[];
  factor_types: EnumValue<FactorType>[];
  gaps: Record<FactorType, string[]>;
  /** Present only while travel insurance is offered. */
  travel_rates?: TravelRate[];
  travel_zones?: EnumValue[];
}

export type RequestStatus = 'SUBMITTED' | 'IN_REVIEW' | 'QUOTED' | 'COMPLETED' | 'REJECTED' | 'CANCELLED';

/** A customer's request for a staff-handled product (orange card, workers, medical, marine). */
export interface InsuranceRequest {
  id: number;
  request_no: string;
  product: EnumValue<ProductCode>;
  kind: EnumValue<'issue' | 'quote'>;
  status: EnumValue<RequestStatus>;
  details: { key: string; label: string; value: string }[];
  notes: string | null;
  staff_reply: string | null;
  quoted_amount: string | null;
  currency: string;
  replied_at: string | null;
  can_cancel: boolean;
  /** Present on the details endpoint; `url` is a short-lived signed link. */
  documents?: { id: number; key: string; label: string; name: string; url?: string }[];
  customer?: { id: number; name: string; phone: string };
  created_at: string;
}
