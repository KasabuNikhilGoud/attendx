'use client'

import { useRouter } from 'next/navigation'
import { LogOut, User } from 'lucide-react'

interface DashboardLayoutProps {
  children: React.ReactNode
  title: string
  subtitle: string
  userName?: string
}

export default function DashboardLayout({ children, title, subtitle, userName }: DashboardLayoutProps) {
  const router = useRouter()

  return (
    <div className="min-h-screen bg-[#0B0C0E]">
      <header className="border-b border-white/[0.06] bg-[#0B0C0E]/80 backdrop-blur-xl sticky top-0 z-50">
        <div className="max-w-6xl mx-auto px-6 h-14 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 bg-gradient-to-br from-red-500 to-red-700 rounded-lg flex items-center justify-center shadow-lg shadow-red-500/20">
              <span className="text-white text-xs font-black">A</span>
            </div>
            <span className="text-white font-semibold text-sm">AttendX</span>
          </div>
          <button
            onClick={() => router.push('/login')}
            className="text-white/55 hover:text-white text-sm transition-colors flex items-center gap-1.5"
          >
            <LogOut className="w-3.5 h-3.5" />
            Sign Out
          </button>
        </div>
      </header>

      <main className="max-w-6xl mx-auto px-6 py-8">
        <div className="mb-8">
          <h1 className="text-2xl font-bold text-white tracking-tight">{title}</h1>
          <p className="text-muted mt-1 text-sm">{subtitle}</p>
        </div>
        {children}
      </main>
    </div>
  )
}
