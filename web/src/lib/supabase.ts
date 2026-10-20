import { createClient, type SupabaseClient } from "@supabase/supabase-js";

export type Role = "student" | "faculty" | "hod" | "admin";

export interface Profile {
  id: string;
  email: string;
  full_name: string;
  role: Role;
  department_id: string | null;
  roll_no: string | null;
  designation: string | null;
}

const rawUrl = (process.env.NEXT_PUBLIC_SUPABASE_URL ?? "").trim();
const rawKey = (process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? "").trim();

/** True when a real Supabase project is configured via .env.local. */
const looksConfigured =
  rawUrl.startsWith("https://") &&
  rawKey.length > 20 &&
  !rawUrl.includes("YOUR-PROJECT-REF") &&
  !rawKey.startsWith("YOUR_");

export const isLiveConfigured = looksConfigured;

/** When no backend is configured the web boots with built-in fake data. */
export const isDemoMode = !looksConfigured;

export const supabase: SupabaseClient | null = looksConfigured
  ? createClient(rawUrl, rawKey)
  : null;
