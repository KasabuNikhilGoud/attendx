'use client'

import { useState } from 'react'
import { MOCK_SUBJECTS, getStudentForSubject, getSubjectAttendance } from '../../lib/mock/data'
import { ClipboardCheck, BarChart3, BookOpen, Users, LogOut, CheckCircle2, ArrowLeft } from 'lucide-react'

export default function FacultyPage() {
  const [view, setView] = useState<'dashboard' | 'mark' | 'reports'>('dashboard')
  const [selectedSubject, setSelectedSubject] = useState<string | null>(null)
  const [attendanceMap, setAttendanceMap] = useState<Record<string, 'present' | 'absent' | 'late'>>({})
  const [submitted, setSubmitted] = useState(false)

  const mySubjects = MOCK_SUBJECTS.filter(s => s.facultyId === 'fac-1')

  const startMarkAttendance = (subjectId: string) => {
    const students = getStudentForSubject(subjectId)
    const initial: Record<string, 'present' | 'absent' | 'late'> = {}
    students.forEach(s => { initial[s.id] = 'present' })
    setAttendanceMap(initial)
    setSelectedSubject(subjectId)
    setSubmitted(false)
    setView('mark')
  }

  const handleSubmit = () => {
    setSubmitted(true)
  }

  const goBack = () => {
    setSubmitted(false)
    setSelectedSubject(null)
    setView('dashboard')
  }

  const currentSub = selectedSubject ? mySubjects.find(s => s.id === selectedSubject) : null

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
            onClick={() => { if (typeof window !== 'undefined') window.location.href = '/login' }}
            className="text-white/55 hover:text-white text-sm transition-colors flex items-center gap-1.5"
          >
            <LogOut className="w-3.5 h-3.5" />
            Sign Out
          </button>
        </div>
      </header>

      <main className="max-w-6xl mx-auto px-6 py-8">
        {(view === 'mark' || view === 'reports') && (
          <button
            onClick={goBack}
            className="flex items-center gap-1.5 text-muted hover:text-white text-sm transition-colors mb-6"
          >
            <ArrowLeft className="w-4 h-4" />
            Back to Dashboard
          </button>
        )}

        <div className="mb-8">
          <h1 className="text-2xl font-bold text-white tracking-tight">Hello, Dr. Priya Patel</h1>
          <p className="text-muted mt-1 text-sm">Computer Science Department</p>
        </div>

        {view === 'dashboard' && (
          <>
            <div className="grid grid-cols-2 gap-4 mb-8">
              <button
                onClick={() => setView('mark')}
                className="card-gradient-hover rounded-2xl p-6 text-left"
              >
                <div className="w-10 h-10 rounded-xl bg-white/[0.03] border border-white/[0.06] flex items-center justify-center mb-3">
                  <ClipboardCheck className="w-5 h-5 text-white/70" />
                </div>
                <p className="text-white font-semibold text-sm">Mark Attendance</p>
                <p className="text-muted text-xs mt-1">Submit today&apos;s attendance</p>
              </button>
              <button
                onClick={() => { setSelectedSubject(null); setView('reports') }}
                className="card-gradient-hover rounded-2xl p-6 text-left"
              >
                <div className="w-10 h-10 rounded-xl bg-white/[0.03] border border-white/[0.06] flex items-center justify-center mb-3">
                  <BarChart3 className="w-5 h-5 text-white/70" />
                </div>
                <p className="text-white font-semibold text-sm">View Reports</p>
                <p className="text-muted text-xs mt-1">Class attendance reports</p>
              </button>
            </div>

            <h2 className="text-lg font-bold text-white tracking-tight mb-4">My Subjects</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
              {mySubjects.map((sub) => {
                const studentCount = sub.students.length
                return (
                  <div key={sub.id} className="card-gradient-hover rounded-2xl p-5">
                    <div className="flex items-center gap-3 mb-3">
                      <div className="w-9 h-9 rounded-xl bg-white/[0.03] border border-white/[0.06] flex items-center justify-center">
                        <BookOpen className="w-4 h-4 text-white/55" />
                      </div>
                      <div>
                        <p className="text-white font-semibold text-sm">{sub.name}</p>
                        <p className="text-subtle text-xs">{sub.code}</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2 text-muted text-xs mb-3">
                      <Users className="w-3.5 h-3.5" />
                      <span>{studentCount} students</span>
                    </div>
                    <div className="flex gap-2">
                      <button
                        onClick={() => startMarkAttendance(sub.id)}
                        className="flex-1 bg-red-600/10 hover:bg-red-600/20 text-red-400 text-xs font-medium py-2 rounded-xl transition-colors"
                      >
                        Mark Attendance
                      </button>
                      <button
                        onClick={() => { setSelectedSubject(sub.id); setView('reports') }}
                        className="flex-1 bg-white/[0.04] hover:bg-white/[0.08] text-white/70 text-xs font-medium py-2 rounded-xl transition-colors"
                      >
                        Reports
                      </button>
                    </div>
                  </div>
                )
              })}
            </div>
          </>
        )}

        {view === 'mark' && (
          <>
            {!selectedSubject ? (
              <>
                <h2 className="text-lg font-bold text-white tracking-tight mb-4">Select a Subject</h2>
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                  {mySubjects.map((sub) => (
                    <button
                      key={sub.id}
                      onClick={() => startMarkAttendance(sub.id)}
                      className="card-gradient-hover rounded-2xl p-5 text-left"
                    >
                      <div className="flex items-center gap-3 mb-3">
                        <div className="w-9 h-9 rounded-xl bg-white/[0.03] border border-white/[0.06] flex items-center justify-center">
                          <BookOpen className="w-4 h-4 text-white/55" />
                        </div>
                        <div>
                          <p className="text-white font-semibold text-sm">{sub.name}</p>
                          <p className="text-subtle text-xs">{sub.code}</p>
                        </div>
                      </div>
                      <p className="text-muted text-xs">{sub.students.length} students</p>
                    </button>
                  ))}
                </div>
              </>
            ) : submitted ? (
              <div className="card-gradient rounded-2xl p-12 text-center">
                <div className="w-16 h-16 bg-green-500/10 rounded-full flex items-center justify-center mx-auto mb-4">
                  <CheckCircle2 className="w-8 h-8 text-green-400" />
                </div>
                <h2 className="text-xl font-bold text-white mb-2">Attendance Submitted</h2>
                <p className="text-muted text-sm mb-6">
                  Attendance for {currentSub?.name} has been recorded successfully.
                </p>
                <div className="flex gap-3 justify-center">
                  <button
                    onClick={() => startMarkAttendance(selectedSubject)}
                    className="bg-red-600/10 hover:bg-red-600/20 text-red-400 text-sm font-medium px-5 py-2.5 rounded-xl transition-colors"
                  >
                    Mark Again
                  </button>
                  <button
                    onClick={goBack}
                    className="bg-white/[0.04] hover:bg-white/[0.08] text-white/70 text-sm font-medium px-5 py-2.5 rounded-xl transition-colors"
                  >
                    Back to Dashboard
                  </button>
                </div>
              </div>
            ) : (
              <>
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <h2 className="text-lg font-bold text-white tracking-tight">{currentSub?.name}</h2>
                    <p className="text-muted text-xs mt-0.5">{currentSub?.code} &middot; Mark Attendance</p>
                  </div>
                  <button
                    onClick={() => setSelectedSubject(null)}
                    className="text-xs text-muted hover:text-white transition-colors"
                  >
                    Change Subject
                  </button>
                </div>

                <div className="card-gradient rounded-2xl overflow-hidden mb-6">
                  <div className="divide-y divide-white/[0.06]">
                    {getStudentForSubject(selectedSubject).map((student) => {
                      const status = attendanceMap[student.id] || 'present'
                      return (
                        <div key={student.id} className="flex items-center justify-between px-5 py-3.5 hover:bg-white/[0.02] transition-colors">
                          <div className="flex items-center gap-3">
                            <div className="w-8 h-8 rounded-full bg-white/[0.03] border border-white/[0.06] flex items-center justify-center">
                              <span className="text-white text-xs font-medium">
                                {student.name.split(' ').map((n: string) => n[0]).join('')}
                              </span>
                            </div>
                            <div>
                              <p className="text-white text-sm font-medium">{student.name}</p>
                              <p className="text-subtle text-xs">{student.rollNo}</p>
                            </div>
                          </div>
                          <div className="flex gap-1.5">
                            {(['present', 'absent', 'late'] as const).map((s) => (
                              <button
                                key={s}
                                onClick={() => setAttendanceMap(prev => ({ ...prev, [student.id]: s }))}
                                className={`px-3 py-1.5 text-xs font-medium rounded-lg transition-all ${
                                  status === s
                                    ? s === 'present'
                                      ? 'bg-green-500/10 text-green-400 ring-1 ring-green-500/30'
                                      : s === 'absent'
                                      ? 'bg-red-500/10 text-red-400 ring-1 ring-red-500/30'
                                      : 'bg-yellow-500/10 text-yellow-400 ring-1 ring-yellow-500/30'
                                    : 'bg-white/[0.03] text-muted hover:text-white'
                                }`}
                              >
                                {s === 'present' ? 'P' : s === 'absent' ? 'A' : 'L'}
                              </button>
                            ))}
                          </div>
                        </div>
                      )
                    })}
                  </div>
                </div>

                <button
                  onClick={handleSubmit}
                  className="w-full bg-red-600 hover:bg-red-700 text-white text-sm font-semibold py-3 rounded-xl transition-colors"
                >
                  Submit Attendance
                </button>
              </>
            )}
          </>
        )}

        {view === 'reports' && (
          <>
            <h2 className="text-lg font-bold text-white tracking-tight mb-4">Attendance Reports</h2>
            <div className="grid grid-cols-1 gap-3">
              {mySubjects.map((sub) => {
                const records = getSubjectAttendance(sub.id)
                const present = records.filter(r => r.status === 'present').length
                const absent = records.filter(r => r.status === 'absent').length
                const late = records.filter(r => r.status === 'late').length
                const total = records.length
                const percentage = total > 0 ? Math.round((present / total) * 100) : 0
                const color = percentage >= 75 ? 'from-green-500 to-green-400' : percentage >= 60 ? 'from-yellow-500 to-yellow-400' : 'from-red-500 to-red-400'

                return (
                  <div key={sub.id} className="card-gradient rounded-2xl p-5">
                    <div className="flex items-center gap-3 mb-4">
                      <div className="w-9 h-9 rounded-xl bg-white/[0.03] border border-white/[0.06] flex items-center justify-center">
                        <BookOpen className="w-4 h-4 text-white/55" />
                      </div>
                      <div>
                        <p className="text-white font-semibold text-sm">{sub.name}</p>
                        <p className="text-subtle text-xs">{sub.code}</p>
                      </div>
                    </div>

                    <div className="grid grid-cols-3 gap-3 mb-4">
                      <div className="bg-green-500/5 rounded-xl p-3 text-center border border-green-500/10">
                        <p className="text-green-400 text-lg font-bold">{present}</p>
                        <p className="text-muted text-xs">Present</p>
                      </div>
                      <div className="bg-red-500/5 rounded-xl p-3 text-center border border-red-500/10">
                        <p className="text-red-400 text-lg font-bold">{absent}</p>
                        <p className="text-muted text-xs">Absent</p>
                      </div>
                      <div className="bg-yellow-500/5 rounded-xl p-3 text-center border border-yellow-500/10">
                        <p className="text-yellow-400 text-lg font-bold">{late}</p>
                        <p className="text-muted text-xs">Late</p>
                      </div>
                    </div>

                    <div className="flex items-center gap-3">
                      <div className="flex-1 h-2.5 bg-white/[0.06] rounded-full overflow-hidden">
                        <div
                          className={`h-full rounded-full bg-gradient-to-r ${color} transition-all duration-500`}
                          style={{ width: `${percentage}%` }}
                        />
                      </div>
                      <span className={`text-sm font-bold shrink-0 ${
                        percentage >= 75 ? 'text-green-400' : percentage >= 60 ? 'text-yellow-400' : 'text-red-400'
                      }`}>
                        {percentage}%
                      </span>
                    </div>

                    <p className="text-subtle text-xs mt-2">{total} total records</p>
                  </div>
                )
              })}
            </div>
          </>
        )}
      </main>
    </div>
  )
}
