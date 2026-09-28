'use client'

import { useState } from 'react'
import {
  MOCK_STUDENTS,
  MOCK_FACULTY,
  MOCK_SUBJECTS,
  MOCK_ATTENDANCE,
  MOCK_DEPARTMENTS,
  MOCK_CLASSES,
} from '../../lib/mock/data'
import {
  Users,
  Building2,
  GraduationCap,
  BookOpen,
  ClipboardCheck,
  Mail,
  LogOut,
  ChevronRight,
  LayoutDashboard,
  School,
} from 'lucide-react'

const tabs = [
  { key: 'dashboard' as const, label: 'Dashboard', icon: LayoutDashboard },
  { key: 'users' as const, label: 'Manage Users', icon: Users },
  { key: 'departments' as const, label: 'Departments', icon: Building2 },
  { key: 'subjects' as const, label: 'Subjects', icon: BookOpen },
]

const managementCards = [
  { key: 'users', icon: Users, label: 'Manage Users', desc: 'Add, edit, remove students & faculty' },
  { key: 'departments', icon: Building2, label: 'Departments', desc: 'Create and manage departments' },
  { key: 'classes', icon: GraduationCap, label: 'Classes', desc: 'Manage classes and batches' },
  { key: 'subjects', icon: BookOpen, label: 'Subjects', desc: 'Assign subjects to faculty' },
  { key: 'enrollments', icon: ClipboardCheck, label: 'Enrollments', desc: 'Enroll students into classes' },
  { key: 'email', icon: Mail, label: 'Email Settings', desc: 'Configure notification emails' },
]

const totalUsers = MOCK_STUDENTS.length + MOCK_FACULTY.length
const totalDepartments = MOCK_DEPARTMENTS.length
const totalSubjects = MOCK_SUBJECTS.length
const totalClasses = MOCK_CLASSES.length

export default function AdminPage() {
  const [view, setView] = useState<'dashboard' | 'users' | 'departments' | 'subjects'>('dashboard')
  const [userTab, setUserTab] = useState<'students' | 'faculty'>('students')

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
          <h1 className="text-2xl font-bold text-white tracking-tight">Admin Dashboard</h1>
          <p className="text-muted mt-1 text-sm">Manage the entire system from here</p>
        </div>

        <div className="flex gap-1 p-1 card-gradient rounded-2xl w-fit mb-8 overflow-x-auto">
          {tabs.map(t => {
            const Icon = t.icon
            return (
              <button
                key={t.key}
                onClick={() => setView(t.key)}
                className={`flex items-center gap-2 px-4 py-2 text-sm font-medium rounded-xl transition-all whitespace-nowrap ${
                  view === t.key
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

        {view === 'dashboard' && (
          <>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 mb-8">
              <div className="card-gradient rounded-2xl p-5">
                <div className="flex items-center justify-between mb-3">
                  <p className="text-muted text-xs font-medium">Total Users</p>
                  <div className="w-9 h-9 rounded-xl bg-blue-500/10 border border-blue-500/15 flex items-center justify-center">
                    <Users className="w-4 h-4 text-blue-400" />
                  </div>
                </div>
                <p className="text-3xl font-black text-blue-400 tracking-tight">{totalUsers}</p>
              </div>
              <div className="card-gradient rounded-2xl p-5">
                <div className="flex items-center justify-between mb-3">
                  <p className="text-muted text-xs font-medium">Departments</p>
                  <div className="w-9 h-9 rounded-xl bg-purple-500/10 border border-purple-500/15 flex items-center justify-center">
                    <Building2 className="w-4 h-4 text-purple-400" />
                  </div>
                </div>
                <p className="text-3xl font-black text-purple-400 tracking-tight">{totalDepartments}</p>
              </div>
              <div className="card-gradient rounded-2xl p-5">
                <div className="flex items-center justify-between mb-3">
                  <p className="text-muted text-xs font-medium">Subjects</p>
                  <div className="w-9 h-9 rounded-xl bg-orange-500/10 border border-orange-500/15 flex items-center justify-center">
                    <BookOpen className="w-4 h-4 text-orange-400" />
                  </div>
                </div>
                <p className="text-3xl font-black text-orange-400 tracking-tight">{totalSubjects}</p>
              </div>
              <div className="card-gradient rounded-2xl p-5">
                <div className="flex items-center justify-between mb-3">
                  <p className="text-muted text-xs font-medium">Classes</p>
                  <div className="w-9 h-9 rounded-xl bg-green-500/10 border border-green-500/15 flex items-center justify-center">
                    <GraduationCap className="w-4 h-4 text-green-400" />
                  </div>
                </div>
                <p className="text-3xl font-black text-green-400 tracking-tight">{totalClasses}</p>
              </div>
            </div>

            <h2 className="text-lg font-bold text-white tracking-tight mb-4">Management</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {managementCards.map((item) => {
                const Icon = item.icon
                return (
                  <button
                    key={item.key}
                    onClick={() => {
                      if (item.key === 'users') setView('users')
                      else if (item.key === 'departments') setView('departments')
                      else if (item.key === 'subjects') setView('subjects')
                    }}
                    className="card-gradient-hover rounded-2xl p-5 text-left flex items-center gap-4"
                  >
                    <div className="w-11 h-11 rounded-xl bg-white/[0.03] border border-white/[0.06] flex items-center justify-center shrink-0">
                      <Icon className="w-5 h-5 text-white/70" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-white font-semibold text-sm">{item.label}</p>
                      <p className="text-muted text-xs mt-0.5 truncate">{item.desc}</p>
                    </div>
                    <ChevronRight className="w-4 h-4 text-white/25 shrink-0" />
                  </button>
                )
              })}
            </div>
          </>
        )}

        {view === 'users' && (
          <>
            <div className="flex gap-1 p-1 card-gradient rounded-2xl w-fit mb-6">
              {(['students', 'faculty'] as const).map(t => (
                <button
                  key={t}
                  onClick={() => setUserTab(t)}
                  className={`px-4 py-2 text-sm font-medium rounded-xl transition-all capitalize ${
                    userTab === t
                      ? 'bg-white/[0.08] text-white shadow-sm'
                      : 'text-muted hover:text-white'
                  }`}
                >
                  {t}
                </button>
              ))}
            </div>

            {userTab === 'students' && (
              <div className="card-gradient rounded-2xl overflow-hidden">
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead>
                      <tr className="border-b border-white/[0.06]">
                        <th className="text-left text-muted text-xs font-medium px-5 py-3">Name</th>
                        <th className="text-left text-muted text-xs font-medium px-5 py-3">Roll No</th>
                        <th className="text-left text-muted text-xs font-medium px-5 py-3">Email</th>
                        <th className="text-left text-muted text-xs font-medium px-5 py-3">Department</th>
                        <th className="text-left text-muted text-xs font-medium px-5 py-3">Year</th>
                        <th className="text-left text-muted text-xs font-medium px-5 py-3">Semester</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-white/[0.06]">
                      {MOCK_STUDENTS.map(student => (
                        <tr key={student.id} className="hover:bg-white/[0.02] transition-colors">
                          <td className="px-5 py-3.5">
                            <div className="flex items-center gap-3">
                              <div className="w-8 h-8 rounded-full bg-white/[0.03] border border-white/[0.06] flex items-center justify-center shrink-0">
                                <span className="text-white text-xs font-medium">
                                  {student.name.split(' ').map(n => n[0]).join('')}
                                </span>
                              </div>
                              <span className="text-white text-sm font-medium">{student.name}</span>
                            </div>
                          </td>
                          <td className="px-5 py-3.5 text-muted text-sm">{student.rollNo}</td>
                          <td className="px-5 py-3.5 text-subtle text-sm">{student.email}</td>
                          <td className="px-5 py-3.5 text-muted text-sm">{student.department}</td>
                          <td className="px-5 py-3.5">
                            <span className="text-xs px-2 py-0.5 rounded-lg bg-white/[0.04] text-muted border border-white/[0.06]">
                              {student.year}
                            </span>
                          </td>
                          <td className="px-5 py-3.5 text-muted text-sm">{student.semester}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}

            {userTab === 'faculty' && (
              <div className="card-gradient rounded-2xl overflow-hidden">
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead>
                      <tr className="border-b border-white/[0.06]">
                        <th className="text-left text-muted text-xs font-medium px-5 py-3">Name</th>
                        <th className="text-left text-muted text-xs font-medium px-5 py-3">Email</th>
                        <th className="text-left text-muted text-xs font-medium px-5 py-3">Department</th>
                        <th className="text-left text-muted text-xs font-medium px-5 py-3">Subjects</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-white/[0.06]">
                      {MOCK_FACULTY.map(faculty => (
                        <tr key={faculty.id} className="hover:bg-white/[0.02] transition-colors">
                          <td className="px-5 py-3.5">
                            <div className="flex items-center gap-3">
                              <div className="w-8 h-8 rounded-full bg-white/[0.03] border border-white/[0.06] flex items-center justify-center shrink-0">
                                <span className="text-white text-xs font-medium">
                                  {faculty.name.split(' ').map(n => n[0]).join('')}
                                </span>
                              </div>
                              <span className="text-white text-sm font-medium">{faculty.name}</span>
                            </div>
                          </td>
                          <td className="px-5 py-3.5 text-subtle text-sm">{faculty.email}</td>
                          <td className="px-5 py-3.5 text-muted text-sm">{faculty.department}</td>
                          <td className="px-5 py-3.5">
                            <div className="flex flex-wrap gap-1.5">
                              {faculty.subjects.map(sub => (
                                <span
                                  key={sub}
                                  className="text-xs px-2 py-0.5 rounded-lg bg-white/[0.04] text-muted border border-white/[0.06]"
                                >
                                  {sub}
                                </span>
                              ))}
                            </div>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}
          </>
        )}

        {view === 'departments' && (
          <div className="grid grid-cols-1 gap-3">
            {MOCK_DEPARTMENTS.map(dept => (
              <div key={dept.id} className="card-gradient rounded-2xl p-5">
                <div className="flex items-center gap-4">
                  <div className="w-11 h-11 rounded-xl bg-white/[0.03] border border-white/[0.06] flex items-center justify-center shrink-0">
                    <School className="w-5 h-5 text-white/55" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-0.5">
                      <p className="text-white font-semibold text-sm">{dept.name}</p>
                      <span className="text-xs px-2 py-0.5 rounded-lg bg-white/[0.04] text-muted border border-white/[0.06]">
                        {dept.code}
                      </span>
                    </div>
                    <p className="text-subtle text-xs">HOD: {dept.hod}</p>
                  </div>
                  <div className="flex items-center gap-4 shrink-0">
                    <div className="text-center">
                      <p className="text-white font-bold text-lg">{dept.facultyCount}</p>
                      <p className="text-muted text-xs">Faculty</p>
                    </div>
                    <div className="text-center">
                      <p className="text-white font-bold text-lg">{dept.studentCount}</p>
                      <p className="text-muted text-xs">Students</p>
                    </div>
                    <ChevronRight className="w-4 h-4 text-white/25" />
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {view === 'subjects' && (
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            {MOCK_SUBJECTS.map(sub => (
              <div key={sub.id} className="card-gradient rounded-2xl p-5">
                <div className="flex items-center gap-3 mb-3">
                  <div className="w-9 h-9 rounded-xl bg-white/[0.03] border border-white/[0.06] flex items-center justify-center">
                    <BookOpen className="w-4 h-4 text-white/55" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-white font-semibold text-sm">{sub.name}</p>
                    <p className="text-subtle text-xs">{sub.code}</p>
                  </div>
                  <span className="text-xs px-2 py-0.5 rounded-lg bg-white/[0.04] text-muted border border-white/[0.06] shrink-0">
                    {sub.credits} credits
                  </span>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div className="bg-white/[0.03] rounded-xl p-3 border border-white/[0.06]">
                    <p className="text-subtle text-xs mb-0.5">Faculty</p>
                    <p className="text-white text-sm font-medium truncate">{sub.faculty}</p>
                  </div>
                  <div className="bg-white/[0.03] rounded-xl p-3 border border-white/[0.06]">
                    <p className="text-subtle text-xs mb-0.5">Students</p>
                    <p className="text-white text-sm font-medium">{sub.students.length} enrolled</p>
                  </div>
                </div>
                <div className="mt-3 flex items-center gap-2 text-muted text-xs">
                  <Building2 className="w-3.5 h-3.5" />
                  <span>{sub.department} &middot; Sem {sub.semester}</span>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  )
}
