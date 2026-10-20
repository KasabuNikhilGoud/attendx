"use client";

import { useEffect, useState } from "react";
import { fetchProfile } from "@/lib/data";

/** Root /dashboard — redirects to the per-role dashboard. */
export default function DashboardIndex() {
  const [note, setNote] = useState("Redirecting…");

  useEffect(() => {
    fetchProfile()
      .then((p) => {
        if (!p) {
          window.location.replace("/login");
          return;
        }
        switch (p.role) {
          case "student":
            window.location.replace("/dashboard/student");
            break;
          case "faculty":
            window.location.replace("/dashboard/faculty");
            break;
          case "hod":
            window.location.replace("/dashboard/hod");
            break;
          case "admin":
            window.location.replace("/dashboard/admin");
            break;
          default:
            setNote(`Unknown role: ${p.role}`);
        }
      })
      .catch((e) => setNote(`Something went wrong: ${String(e)}`));
  }, []);

  return (
    <div className="flex min-h-[60vh] items-center justify-center text-sm text-zinc-500">
      {note}
    </div>
  );
}
