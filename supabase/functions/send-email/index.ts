// Supabase Edge Function: send-email
// Triggered after attendance session is submitted
// Uses Resend API to send absence notifications

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')!

interface EmailPayload {
  studentEmail: string
  studentName: string
  subjectName: string
  date: string
  facultyName: string
}

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 })
  }

  try {
    const { absentStudents, subjectName, date, facultyName }: {
      absentStudents: EmailPayload[]
      subjectName: string
      date: string
      facultyName: string
    } = await req.json()

    const results = await Promise.allSettled(
      absentStudents.map((student) =>
        fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${RESEND_API_KEY}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            from: 'AttendX <noreply@yourdomain.com>',
            to: student.studentEmail,
            subject: `Absence Notification — ${subjectName} on ${date}`,
            html: `
              <div style="font-family: Inter, sans-serif; max-width: 480px; margin: 0 auto; padding: 32px;">
                <h2 style="color: #1A73E8; margin-bottom: 8px;">AttendX</h2>
                <p style="color: #5F6368; font-size: 14px; margin-bottom: 24px;">Attendance Notification</p>
                <p>Dear <strong>${student.studentName}</strong>,</p>
                <p>You were marked <strong style="color: #EA4335;">absent</strong> for:</p>
                <div style="background: #F8F9FA; border-radius: 8px; padding: 16px; margin: 16px 0;">
                  <p style="margin: 4px 0;"><strong>Subject:</strong> ${subjectName}</p>
                  <p style="margin: 4px 0;"><strong>Date:</strong> ${date}</p>
                  <p style="margin: 4px 0;"><strong>Faculty:</strong> ${facultyName}</p>
                </div>
                <p style="color: #5F6368; font-size: 13px;">
                  If you believe this is an error, please contact your faculty.
                </p>
                <hr style="border: none; border-top: 1px solid #E8EAED; margin: 24px 0;" />
                <p style="color: #9AA0A6; font-size: 12px;">AttendX — ERP Attendance System</p>
              </div>
            `,
          }),
        })
      )
    )

    const sent = results.filter((r) => r.status === 'fulfilled').length
    const failed = results.filter((r) => r.status === 'rejected').length

    return new Response(
      JSON.stringify({ success: true, sent, failed }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
