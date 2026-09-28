'use client'

import { useState } from 'react'
import { MOCK_SUBJECTS, MOCK_ATTENDANCE, getOverallAttendance, getAttendancePercentage } from '../../lib/mock/data'
import { BookOpen, TrendingUp, Calendar, LogOut } from 'lucide-react'

export default function StudentPage() {
  const [selectedSubject, setSelectedSubject] = useState<string | null>(null)
  const overall = getOverallAttendance()
  const subjects = MOCK_SUBJECTS.map(s => ({ ...s, percentage: getAttendancePercentage(s.id) }))
  const records = selectedSubject ? MOCK_ATTENDANCE.filter(a => a.subjectId === selectedSubject) : MOCK_ATTENDANCE
  const selectedSub = MOCK_SUBJECTS.find(s => s.id === selectedSubject)

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
          <button onClick={() => { if (typeof window !== 'undefined') window.location.href = '/login' }} className="text-white/55 hover:text-white text-sm transition-colors flex items-center gap-1.5">
            <LogOut className="w-3.5 h-3.5" />
            Sign Out
          </button>
        </div>
      </header>

      <main className="max-w-6xl mx-auto px-6 py-8">
        <div className="mb-8">
          <h1 className="text-2xl font-bold text-white tracking-tight">Hello, Rahul Sharma</h1>
          <p className="text-muted mt-1 text-sm">CS2022-001 &middot; 3rd Year &middot; 6th Sem</p>
        </div>

        <div className="card-gradient rounded-2xl p-6 mb-8 flex items-center justify-between">
          <div>
            <p className="text-muted text-sm">Overall Attendance</p>
            <p className={`text-5xl font-black mt-1 tracking-tight ${overall >= 75 ? 'text-green-400' : overall >= 60 ? 'text-yellow-400' : 'text-red-400'}`}>{overall}%</p>
            <p className="text-subtle text-xs mt-2">{overall >= 75 ? 'Good standing' : overall >= 60 ? 'Needs improvement' : 'At risk'}</p>
          </div>
          <div className="w-16 h-16 bg-white/[0.03] rounded-2xl flex items-center justify-center border border-white/[0.06]">
            <TrendingUp className="w-7 h-7 text-white/55" />
          </div>
        </div>

        <h2 className="text-lg font-bold text-white tracking-tight mb-4">Subject-wise Attendance</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 mb-8">
          {subjects.map((sub) => (
            <button
              key={sub.id}
              onClick={() => setSelectedSubject(selectedSubject === sub.id ? null : sub.id)}
              className={`card-gradient-hover rounded-2xl p-5 text-left transition-all ${selectedSubject === sub.id ? 'ring-1 ring-red-500/40 border-red-500/30' : ''}`}
            >
              <div className="flex items-start justify-between mb-3">
                <div>
                  <p className="text-white font-semibold text-sm">{sub.name}</p>
                  <p className="text-subtle text-xs mt-0.5">{sub.code} &middot; {sub.faculty}</p>
                </div>
                <div className="w-9 h-9 rounded-xl bg-white/[0.03] border border-white/[0.06] flex items-center justify-center">
                  <BookOpen className="w-4 h-4 text-white/55" />
                </div>
              </div>
              <div className="flex items-end justify-between mb-2">
                <div className="flex-1 mr-4">
                  <div className="h-2 bg-white/[0.06] rounded-full overflow-hidden">
                    <div className={`h-full rounded-full transition-all duration-500 ${sub.percentage >= 75 ? 'bg-gradient-to-r from-green-500 to-green-400' : sub.percentage >= 60 ? 'bg-gradient-to-r from-yellow-500 to-yellow-400' : 'bg-gradient-to-r from-red-500 to-red-400'}`} style={{ width: `${sub.percentage}%` }} />
                  </div>
                </div>
                <span className={`text-sm font-bold ${sub.percentage >= 75 ? 'text-green-400' : sub.percentage >= 60 ? 'text-yellow-400' : 'text-red-400'}`}>{sub.percentage}%</span>
              </div>
            </button>
          ))}
        </div>

        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-bold text-white tracking-tight">{selectedSubject ? `${selectedSub?.name} Attendance` : 'Recent Attendance'}</h2>
          {selectedSubject && (
            <button onClick={() => setSelectedSubject(null)} className="text-xs text-white/55 hover:text-white transition-colors">View All</button>
          )}
        </div>

        <div className="card-gradient rounded-2xl overflow-hidden">
          <div className="divide-y divide-white/[0.06]">
            {records.length === 0 ? (
              <div className="p-8 text-center">
                <Calendar className="w-8 h-8 text-white/25 mx-auto mb-2" />
                <p className="text-muted text-sm">No attendance records yet</p>
              </div>
            ) : (
              records.slice().reverse().map((record) => (
                <div key={record.id} className="flex items-center gap-4 px-5 py-3.5 hover:bg-white/[0.02] transition-colors">
                  <div className={`w-2 h-2 rounded-full shrink-0 ${record.status === 'present' ? 'bg-green-400' : record.status === 'absent' ? 'bg-red-400' : 'bg-yellow-400'}`} />
                  <div className="flex-1 min-w-0">
                    <p className="text-white text-sm font-medium">{record.subjectName}</p>
                    <p className="text-subtle text-xs">{record.date}</p>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-subtle text-xs">{record.time}</span>
                    <span className={`text-xs font-medium px-2 py-0.5 rounded-full ${record.status === 'present' ? 'bg-green-500/10 text-green-400' : record.status === 'absent' ? 'bg-red-500/10 text-red-400' : 'bg-yellow-500/10 text-yellow-400'}`}>{record.status === 'present' ? 'Present' : record.status === 'absent' ? 'Absent' : 'Late'}</span>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </main>
    </div>
  )
}
