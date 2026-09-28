'use client'

import { useState } from 'react'
import {
  MOCK_STUDENTS,
  MOCK_FACULTY,
  MOCK_SUBJECTS,
  MOCK_ATTENDANCE,
  MOCK_CLASSES,
  MOCK_DEPARTMENTS,
  getOverallAttendance,
  getAttendancePercentage,
} from '../../lib/mock/data'
import {
  Users,
  GraduationCap,
  TrendingUp,
  Building2,
  LogOut,
  BookOpen,
  Mail,
  Calendar,
  ChevronRight,
  BarChart3,
  UserCheck,
} from 'lucide-react'

function getFacultyAttendancePercentage(facultyId: string) {
  const subjects = MOCK_SUBJECTS.filter(s => s.facultyId === facultyId)
  if (subjects.length === 0) return 0
  const pcts = subjects.map(s => getAttendancePercentage(s.id))
  return Math.round(pcts.reduce((a, b) => a + b, 0) / pcts.length)
}

function getFacultyAttendanceRecords(facultyId: string) {
  const subjectIds = MOCK_SUBJECTS.filter(s => s.facultyId === facultyId).map(s => s.id)
  return MOCK_ATTENDANCE.filter(a => subjectIds.includes(a.subjectId))
}

export default function HODPage() {
  const [tab, setTab] = useState<'dashboard' | 'faculty' | 'reports'>('dashboard')

  const totalStudents = MOCK_STUDENTS.length
  const totalFaculty = MOCK_FACULTY.length
  const avgAttendance = getOverallAttendance()
  const totalClasses = MOCK_CLASSES.length

  const tabs = [
    { key: 'dashboard' as const, label: 'Dashboard', icon: Building2 },
    { key: 'faculty' as const, label: 'Faculty', icon: GraduationCap },
    { key: 'reports' as const, label: 'Reports', icon: BarChart3 },
  ]

  const recentRecords = [...MOCK_ATTENDANCE].reverse().slice(0, 6)

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
        <div className="mb-8">
          <h1 className="text-2xl font-bold text-white tracking-tight">
            HOD Dashboard
          </h1>
          <p className="text-muted mt-1 text-sm">
            {MOCK_DEPARTMENTS[0]?.name ?? 'Computer Science'} Department
          </p>
        </div>

        <div className="flex gap-1 p-1 card-gradient rounded-2xl w-fit mb-8">
          {tabs.map(t => {
            const Icon = t.icon
            return (
              <button
                key={t.key}
                onClick={() => setTab(t.key)}
                className={`flex items-center gap-2 px-4 py-2 text-sm font-medium rounded-xl transition-all ${
                  tab === t.key
                    ? 'bg-white/[0.08] text-white shadow-sm'
                    : 'text-muted hover:text-white'
                }`}
              >
                <Icon className="w-4 h-4" />
                {t.label}
              </button>
            )
          })}
        </div>

        {tab === 'dashboard' && (
          <>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 mb-8">
              <div className="card-gradient rounded-2xl p-5">
                <div className="flex items-center justify-between mb-3">
                  <p className="text-muted text-xs font-medium">Total Students</p>
                  <div className="w-9 h-9 rounded-xl bg-blue-500/10 border border-blue-500/15 flex items-center justify-center">
                    <Users className="w-4 h-4 text-blue-400" />
                  </div>
                </div>
                <p className="text-3xl font-black text-blue-400 tracking-tight">{totalStudents}</p>
              </div>
              <div className="card-gradient rounded-2xl p-5">
                <div className="flex items-center justify-between mb-3">
                  <p className="text-muted text-xs font-medium">Faculty</p>
                  <div className="w-9 h-9 rounded-xl bg-purple-500/10 border border-purple-500/15 flex items-center justify-center">
                    <GraduationCap className="w-4 h-4 text-purple-400" />
                  </div>
                </div>
                <p className="text-3xl font-black text-purple-400 tracking-tight">{totalFaculty}</p>
              </div>
              <div className="card-gradient rounded-2xl p-5">
                <div className="flex items-center justify-between mb-3">
                  <p className="text-muted text-xs font-medium">Avg Attendance</p>
                  <div className={`w-9 h-9 rounded-xl border flex items-center justify-center ${
                    avgAttendance >= 75 ? 'bg-green-500/10 border-green-500/15' : avgAttendance >= 60 ? 'bg-yellow-500/10 border-yellow-500/15' : 'bg-red-500/10 border-red-500/15'
                  }`}>
                    <TrendingUp className={`w-4 h-4 ${
                      avgAttendance >= 75 ? 'text-green-400' : avgAttendance >= 60 ? 'text-yellow-400' : 'text-red-400'
                    }`} />
                  </div>
                </div>
                <p className={`text-3xl font-black tracking-tight ${
                  avgAttendance >= 75 ? 'text-green-400' : avgAttendance >= 60 ? 'text-yellow-400' : 'text-red-400'
                }`}>
                  {avgAttendance}%
                </p>
              </div>
              <div className="card-gradient rounded-2xl p-5">
                <div className="flex items-center justify-between mb-3">
                  <p className="text-muted text-xs font-medium">Classes</p>
                  <div className="w-9 h-9 rounded-xl bg-orange-500/10 border border-orange-500/15 flex items-center justify-center">
                    <Building2 className="w-4 h-4 text-orange-400" />
                  </div>
                </div>
                <p className="text-3xl font-black text-orange-400 tracking-tight">{totalClasses}</p>
              </div>
            </div>

            <h2 className="text-lg font-bold text-white tracking-tight mb-4">Faculty Overview</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-8">
              {MOCK_FACULTY.map(faculty => {
                const subjects = MOCK_SUBJECTS.filter(s => s.facultyId === faculty.id)
                const pct = getFacultyAttendancePercentage(faculty.id)
                return (
                  <div key={faculty.id} className="card-gradient rounded-2xl p-5">
                    <div className="flex items-center gap-3 mb-3">
                      <div className="w-9 h-9 rounded-full bg-white/[0.03] border border-white/[0.06] flex items-center justify-center">
                        <span className="text-white text-xs font-medium">
                          {faculty.name.split(' ').map(n => n[0]).join('')}
                        </span>
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="text-white font-semibold text-sm truncate">{faculty.name}</p>
                        <p className="text-subtle text-xs truncate">{faculty.email}</p>
                      </div>
                    </div>
                    <div className="flex flex-wrap gap-1.5 mb-3">
                      {subjects.map(sub => (
                        <span key={sub.id} className="text-xs px-2 py-0.5 rounded-lg bg-white/[0.04] text-muted border border-white/[0.06]">
                          {sub.name}
                        </span>
                      ))}
                    </div>
                    <div className="flex items-center gap-3">
                      <div className="flex-1 h-2 bg-white/[0.06] rounded-full overflow-hidden">
                        <div
                          className={`h-full rounded-full transition-all duration-500 ${
                            pct >= 75 ? 'bg-gradient-to-r from-green-500 to-green-400' :
                            pct >= 60 ? 'bg-gradient-to-r from-yellow-500 to-yellow-400' :
                            'bg-gradient-to-r from-red-500 to-red-400'
                          }`}
                          style={{ width: `${pct}%` }}
                        />
                      </div>
                      <span className={`text-xs font-bold shrink-0 ${
                        pct >= 75 ? 'text-green-400' : pct >= 60 ? 'text-yellow-400' : 'text-red-400'
                      }`}>
                        {pct}%
                      </span>
                    </div>
                  </div>
                )
              })}
            </div>

            <h2 className="text-lg font-bold text-white tracking-tight mb-4">Recent Activity</h2>
            <div className="card-gradient rounded-2xl overflow-hidden">
              <div className="divide-y divide-white/[0.06]">
                {recentRecords.length === 0 ? (
                  <div className="p-8 text-center">
                    <Calendar className="w-8 h-8 text-white/25 mx-auto mb-2" />
                    <p className="text-muted text-sm">No recent activity</p>
                  </div>
                ) : (
                  recentRecords.map(record => (
                    <div key={record.id} className="flex items-center gap-4 px-5 py-3.5 hover:bg-white/[0.02] transition-colors">
                      <div className={`w-2 h-2 rounded-full shrink-0 ${
                        record.status === 'present' ? 'bg-green-400' :
                        record.status === 'absent' ? 'bg-red-400' : 'bg-yellow-400'
                      }`} />
                      <div className="flex-1 min-w-0">
                        <p className="text-white text-sm font-medium">{record.subjectName}</p>
                        <p className="text-subtle text-xs">{record.date}</p>
                      </div>
                      <div className="flex items-center gap-2">
                        <span className="text-subtle text-xs">{record.time}</span>
                        <span className={`text-xs font-medium px-2 py-0.5 rounded-full ${
                          record.status === 'present' ? 'bg-green-500/10 text-green-400' :
                          record.status === 'absent' ? 'bg-red-500/10 text-red-400' : 'bg-yellow-500/10 text-yellow-400'
                        }`}>
                          {record.status === 'present' ? 'Present' : record.status === 'absent' ? 'Absent' : 'Late'}
                        </span>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>
          </>
        )}

        {tab === 'faculty' && (
          <>
            <h2 className="text-lg font-bold text-white tracking-tight mb-4">Faculty Members</h2>
            <div className="grid grid-cols-1 gap-3">
              {MOCK_FACULTY.map(faculty => {
                const subjects = MOCK_SUBJECTS.filter(s => s.facultyId === faculty.id)
                const pct = getFacultyAttendancePercentage(faculty.id)
                return (
                  <div key={faculty.id} className="card-gradient rounded-2xl p-5">
                    <div className="flex items-center gap-4">
                      <div className="w-11 h-11 rounded-full bg-white/[0.03] border border-white/[0.06] flex items-center justify-center shrink-0">
                        <span className="text-white text-sm font-medium">
                          {faculty.name.split(' ').map(n => n[0]).join('')}
                        </span>
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-0.5">
                          <p className="text-white font-semibold text-sm">{faculty.name}</p>
                          <span className={`text-xs font-medium px-2 py-0.5 rounded-full ${
                            pct >= 75 ? 'bg-green-500/10 text-green-400' : pct >= 60 ? 'bg-yellow-500/10 text-yellow-400' : 'bg-red-500/10 text-red-400'
                          }`}>
                            {pct}% attendance
                          </span>
                        </div>
                        <p className="text-subtle text-xs">{faculty.email} &middot; {faculty.department}</p>
                        <div className="flex flex-wrap gap-1.5 mt-2">
                          {subjects.map(sub => (
                            <span key={sub.id} className="text-xs px-2 py-0.5 rounded-lg bg-white/[0.04] text-muted border border-white/[0.06] flex items-center gap-1">
                              <BookOpen className="w-3 h-3" />
                              {sub.name}
                            </span>
                          ))}
                        </div>
                      </div>
                      <div className="hidden sm:flex items-center gap-4 shrink-0">
                        <div className="text-right">
                          <p className="text-muted text-xs">{subjects.length} subjects</p>
                          <p className="text-subtle text-xs">{getFacultyAttendanceRecords(faculty.id).length} records</p>
                        </div>
                        <ChevronRight className="w-4 h-4 text-white/25" />
                      </div>
                    </div>
                  </div>
                )
              })}
            </div>
          </>
        )}

        {tab === 'reports' && (
          <>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 mb-8">
              <div className="card-gradient rounded-2xl p-5">
                <div className="flex items-center justify-between mb-2">
                  <p className="text-muted text-xs font-medium">Total Students</p>
                  <Users className="w-4 h-4 text-muted" />
                </div>
                <p className="text-2xl font-black text-white tracking-tight">{totalStudents}</p>
              </div>
              <div className="card-gradient rounded-2xl p-5">
                <div className="flex items-center justify-between mb-2">
                  <p className="text-muted text-xs font-medium">Total Faculty</p>
                  <GraduationCap className="w-4 h-4 text-muted" />
                </div>
                <p className="text-2xl font-black text-white tracking-tight">{totalFaculty}</p>
              </div>
              <div className="card-gradient rounded-2xl p-5">
                <div className="flex items-center justify-between mb-2">
                  <p className="text-muted text-xs font-medium">Total Classes</p>
                  <Building2 className="w-4 h-4 text-muted" />
                </div>
                <p className="text-2xl font-black text-white tracking-tight">{totalClasses}</p>
              </div>
              <div className="card-gradient rounded-2xl p-5">
                <div className="flex items-center justify-between mb-2">
                  <p className="text-muted text-xs font-medium">Overall Attendance</p>
                  <TrendingUp className="w-4 h-4 text-muted" />
                </div>
                <p className={`text-2xl font-black tracking-tight ${
                  avgAttendance >= 75 ? 'text-green-400' : avgAttendance >= 60 ? 'text-yellow-400' : 'text-red-400'
                }`}>
                  {avgAttendance}%
                </p>
              </div>
            </div>

            <h2 className="text-lg font-bold text-white tracking-tight mb-4">Subject-wise Attendance</h2>
            <div className="grid grid-cols-1 gap-3">
              {MOCK_SUBJECTS.map(sub => {
                const pct = getAttendancePercentage(sub.id)
                return (
                  <div key={sub.id} className="card-gradient rounded-2xl p-5">
                    <div className="flex items-center gap-3 mb-4">
                      <div className="w-9 h-9 rounded-xl bg-white/[0.03] border border-white/[0.06] flex items-center justify-center">
                        <BookOpen className="w-4 h-4 text-white/55" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="text-white font-semibold text-sm">{sub.name}</p>
                        <p className="text-subtle text-xs">{sub.code} &middot; {sub.faculty}</p>
                      </div>
                    </div>
                    <div className="grid grid-cols-3 gap-3 mb-4">
                      <div className="bg-green-500/5 rounded-xl p-3 text-center border border-green-500/10">
                        <p className="text-green-400 text-lg font-bold">{MOCK_ATTENDANCE.filter(a => a.subjectId === sub.id && a.status === 'present').length}</p>
                        <p className="text-muted text-xs">Present</p>
                      </div>
                      <div className="bg-red-500/5 rounded-xl p-3 text-center border border-red-500/10">
                        <p className="text-red-400 text-lg font-bold">{MOCK_ATTENDANCE.filter(a => a.subjectId === sub.id && a.status === 'absent').length}</p>
                        <p className="text-muted text-xs">Absent</p>
                      </div>
                      <div className="bg-yellow-500/5 rounded-xl p-3 text-center border border-yellow-500/10">
                        <p className="text-yellow-400 text-lg font-bold">{MOCK_ATTENDANCE.filter(a => a.subjectId === sub.id && a.status === 'late').length}</p>
                        <p className="text-muted text-xs">Late</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-3">
                      <div className="flex-1 h-2.5 bg-white/[0.06] rounded-full overflow-hidden">
                        <div
                          className={`h-full rounded-full bg-gradient-to-r transition-all duration-500 ${
                            pct >= 75 ? 'from-green-500 to-green-400' :
                            pct >= 60 ? 'from-yellow-500 to-yellow-400' :
                            'from-red-500 to-red-400'
                          }`}
                          style={{ width: `${pct}%` }}
                        />
                      </div>
                      <span className={`text-sm font-bold shrink-0 ${
                        pct >= 75 ? 'text-green-400' : pct >= 60 ? 'text-yellow-400' : 'text-red-400'
                      }`}>
                        {pct}%
                      </span>
                    </div>
                    <div className="flex items-center gap-3 mt-3 text-xs text-muted">
                      <span className="flex items-center gap-1">
                        <UserCheck className="w-3.5 h-3.5" />
                        {sub.students.length} students
                      </span>
                      <span className="text-white/20">&middot;</span>
                      <span>{MOCK_ATTENDANCE.filter(a => a.subjectId === sub.id).length} total records</span>
                    </div>
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
