// Re-export for backward compatibility.
// New code should import from '@/lib/supabase/client' or relative '../supabase/client'.
export { supabase, getUserRole } from './supabase/client';
export type { UserRole } from './supabase/client';
