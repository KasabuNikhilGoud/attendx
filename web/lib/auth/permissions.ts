import type { Role } from '../constants/roles';

/** Minimal role hierarchy for ERP guards. Higher index = less privilege. */
const HIERARCHY: Role[] = ['admin', 'hod', 'faculty', 'student'];

export function canAccess(userRole: Role | null | undefined, allowed: Role[]): boolean {
  if (!userRole) return false;
  return allowed.includes(userRole);
}

/** Admin can access everything; HOD can access hod+faculty+student scopes, etc. */
export function hasMinRole(userRole: Role | null | undefined, minRole: Role): boolean {
  if (!userRole) return false;
  return HIERARCHY.indexOf(userRole) <= HIERARCHY.indexOf(minRole);
}

/** Tenant/institution scope check placeholder (multi-tenant ready). */
export function inSameInstitution(
  userInstitutionId: string | null | undefined,
  resourceInstitutionId: string | null | undefined,
): boolean {
  // Single-institution demo: allow when either side is unset.
  if (!userInstitutionId || !resourceInstitutionId) return true;
  return userInstitutionId === resourceInstitutionId;
}
