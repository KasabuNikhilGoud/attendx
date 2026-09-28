'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { LogIn, Mail, Lock, ChevronRight, Sparkles } from 'lucide-react'

const DEMO_ACCOUNTS = [
  { label: 'Admin', email: 'admin@attendx.com', pass: 'admin123', role: 'admin' },
  { label: 'HOD', email: 'hod@attendx.com', pass: 'hod123', role: 'hod' },
  { label: 'Faculty', email: 'faculty@attendx.com', pass: 'faculty123', role: 'faculty' },
  { label: 'Student', email: 'student@attendx.com', pass: 'student123', role: 'student' },
]

export default function LoginPage() {
  const router = useRouter()
  const [email, setEmail] = useState('admin@attendx.com')
  const [password, setPassword] = useState('admin123')
  const [selectedRole, setSelectedRole] = useState('admin')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  function handleSelectDemo(acc: typeof DEMO_ACCOUNTS[0]) {
    setSelectedRole(acc.role)
    setEmail(acc.email)
    setPassword(acc.pass)
    setError(null)
  }

  async function handleLogin(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError(null)

    const routes: Record<string, string> = {
      student: '/student',
      faculty: '/faculty',
      hod: '/hod',
      admin: '/admin',
    }

    const found = DEMO_ACCOUNTS.find(a => a.email === email && a.pass === password)
    if (found) {
      router.push(routes[found.role] ?? '/login')
      return
    }

    setError('Invalid credentials. Use one of the demo accounts below.')
    setLoading(false)
  }

  return (
    <div className="min-h-screen flex items-center justify-center p-4 sm:p-6 bg-[#0B0C0E] bg-dot-pattern">
      <div className="fixed inset-0 pointer-events-none overflow-hidden">
        <div className="absolute -top-40 -right-40 w-96 h-96 bg-gradient-to-br from-red-500/10 via-red-600/5 to-transparent rounded-full blur-3xl" />
        <div className="absolute -bottom-40 -left-40 w-96 h-96 bg-gradient-to-tr from-red-500/10 via-red-600/5 to-transparent rounded-full blur-3xl" />
      </div>

      <div className="w-full max-w-sm relative">
        <div className="glass rounded-2xl p-8">
          <div className="mb-8 text-center">
            <div className="w-14 h-14 mx-auto bg-gradient-to-br from-red-500 to-red-700 rounded-2xl flex items-center justify-center mb-4 shadow-lg shadow-red-500/20">
              <span className="text-white text-2xl font-black tracking-tight">A</span>
            </div>
            <h1 className="text-2xl font-bold text-white tracking-tight">AttendX</h1>
            <p className="text-muted mt-1 text-sm">Sign in to your dashboard</p>
          </div>

          <form onSubmit={handleLogin} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-white/70 mb-1.5">Email</label>
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full px-4 py-2.5 bg-white/[0.03] border border-white/[0.08] rounded-xl text-white placeholder:text-white/25 focus:outline-none focus:border-red-500/50 focus:ring-1 focus:ring-red-500/20 transition-all text-sm"
                placeholder="you@example.com"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-white/70 mb-1.5">Password</label>
              <input
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full px-4 py-2.5 bg-white/[0.03] border border-white/[0.08] rounded-xl text-white placeholder:text-white/25 focus:outline-none focus:border-red-500/50 focus:ring-1 focus:ring-red-500/20 transition-all text-sm"
                placeholder="••••••••"
              />
            </div>

            {error && (
              <div className="bg-red-500/10 border border-red-500/20 text-red-400 text-xs px-4 py-3 rounded-xl">
                {error}
              </div>
            )}

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-red-600 hover:bg-red-500 disabled:opacity-50 text-white font-semibold py-3 rounded-xl transition-all text-sm flex items-center justify-center gap-2"
            >
              {loading ? (
                <span className="inline-block w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              ) : (
                <>
                  <LogIn className="w-4 h-4" />
                  Sign In
                </>
              )}
            </button>
          </form>

          <div className="mt-8">
            <div className="flex items-center gap-3 mb-4">
              <div className="flex-1 h-px bg-white/[0.06]" />
              <span className="text-xs text-white/35 font-medium">Demo Accounts</span>
              <div className="flex-1 h-px bg-white/[0.06]" />
            </div>
            <div className="flex flex-wrap gap-2 justify-center">
              {DEMO_ACCOUNTS.map((acc) => (
                <button
                  key={acc.role}
                  type="button"
                  onClick={() => handleSelectDemo(acc)}
                  className={`px-4 py-1.5 rounded-full text-xs font-medium transition-all ${
                    selectedRole === acc.role
                      ? 'bg-red-600 text-white shadow-lg shadow-red-600/20'
                      : 'bg-white/[0.04] text-white/55 hover:bg-white/[0.08] hover:text-white/80 border border-white/[0.06]'
                  }`}
                >
                  {acc.label}
                </button>
              ))}
            </div>
            <p className="text-center text-white/35 text-xs mt-3">
              Tap a role to auto-fill credentials
            </p>
          </div>
        </div>

        <p className="text-center text-white/25 text-xs mt-6">
          AttendX &mdash; ERP Attendance System
        </p>
      </div>
    </div>
  )
}
