import { useState, useEffect } from "react";
import { pb } from "@/lib/pocketbase";

export interface OverviewData {
  today: { ipa: number; ipd: number };
  yesterday: { ipa: number; ipd: number };
  change: { ipa: number; ipd: number };
  today_pct: number;
  yes_pct: number;
  change_pct: number;
  zero_ipa: number;
  checked_in: number;
  above_avg_ipd: number;
  below_avg_ipa: number;
}

export function useOverview() {
  const [data, setData] = useState<OverviewData | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    pb.send("/api/portal/overview", { $autoCancel: false })
      .then((res) => { if (!cancelled) setData(res as OverviewData); })
      .catch(() => {})
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, []);

  return { data, loading };
}
