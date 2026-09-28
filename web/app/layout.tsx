import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'AttendX — ERP Attendance System',
  description: 'Manage attendance for students, faculty, HOD and admin',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@100..900&family=JetBrains+Mono:wght@100..800&display=swap"
          rel="stylesheet"
        />
        <style>{`
          :root {
            --font-geist-sans: 'Inter', system-ui, sans-serif;
            --font-geist-mono: 'JetBrains Mono', monospace;
          }
        `}</style>
      </head>
      <body>{children}</body>
    </html>
  )
}
