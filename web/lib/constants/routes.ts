export const ROUTES = {
  home: '/',
  login: '/login',
  admin: '/admin',
  hod: '/hod',
  faculty: '/faculty',
  student: '/student',
} as const;

export type AppRoute = (typeof ROUTES)[keyof typeof ROUTES];
