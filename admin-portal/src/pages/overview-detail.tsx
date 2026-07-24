import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, TrendingUp, TrendingDown } from "lucide-react";
import { pb } from "@/lib/pocketbase";
import { useOverview } from "@/hooks/use-overview";

interface EmployeeDetail {
  employee_code: string;
  employee_name: string;
  today_ipa: number;
  today_ipd: number;
  yes_ipa: number;
  yes_ipd: number;
}

interface EmployeesData {
  employees: EmployeeDetail[];
  checked_in: number;
  avg_ipa: number;
  avg_ipd: number;
  zero_ipa: number;
  below_avg_ipa: number;
  above_avg_ipd: number;
}

const GRID = "48px 1fr 64px 64px 72px 96px 64px 64px 72px 72px 72px 72px";

export default function OverviewDetailPage() {
  const navigate = useNavigate();
  const { data: overview } = useOverview();
  const [empData, setEmpData] = useState<EmployeesData | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    pb.send("/api/portal/overview/employees", { $autoCancel: false })
      .then((res) => {
        if (cancelled) return;
        const d = res as EmployeesData;
        d.employees.sort((a, b) => {
          if (a.today_ipa > 0 && b.today_ipa > 0) return b.today_ipa - a.today_ipa;
          if (a.today_ipa === 0 && b.today_ipa === 0) return b.today_ipd - a.today_ipd;
          if (a.today_ipa === 0) return 1;
          if (b.today_ipa === 0) return -1;
          return b.today_ipa - a.today_ipa;
        });
        setEmpData(d);
      })
      .catch(() => {})
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, []);

  const headerRow1 = (
    <div className="grid" style={{ gridTemplateColumns: GRID }}>
      <div className="flex items-center justify-center py-3 text-xs font-medium text-gray-400 uppercase tracking-wide">SN</div>
      <div className="flex items-center py-3 text-xs font-medium text-gray-400 uppercase tracking-wide">Employee Name</div>
      <div className="flex items-center justify-center col-span-3 text-xs font-medium text-gray-400 uppercase tracking-wide">Today</div>
      <div />
      <div className="flex items-center justify-center col-span-3 text-xs font-medium text-gray-400 uppercase tracking-wide">Yesterday</div>
      <div />
      <div className="flex items-center justify-center py-3 text-xs font-medium text-gray-400 uppercase tracking-wide">IPA %</div>
      <div />
    </div>
  );

  const headerRow2 = (
    <div className="grid border-t border-blue-100/60" style={{ gridTemplateColumns: GRID }}>
      <div className="flex items-center justify-center py-2 text-xs font-medium text-gray-500">SN</div>
      <div className="flex items-center py-2 text-xs font-medium text-gray-500">Employee Name</div>
      <div className="flex items-center justify-center py-2 text-xs font-medium text-gray-500">IPA</div>
      <div className="flex items-center justify-center py-2 text-xs font-medium text-gray-500">IPD</div>
      <div className="flex items-center justify-center py-2 text-xs font-medium text-gray-500">Total</div>
      <div />
      <div className="flex items-center justify-center py-2 text-xs font-medium text-gray-500">IPA</div>
      <div className="flex items-center justify-center py-2 text-xs font-medium text-gray-500">IPD</div>
      <div className="flex items-center justify-center py-2 text-xs font-medium text-gray-500">Total</div>
      <div />
      <div className="flex items-center justify-center py-2 text-xs font-medium text-gray-500">IPA %</div>
      <div />
    </div>
  );

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <button onClick={() => navigate(-1)} className="p-1.5 rounded-lg hover:bg-gray-100 transition-colors cursor-pointer">
          <ArrowLeft className="w-4 h-4 text-gray-600" />
        </button>
        <h1 className="text-sm font-semibold text-gray-900">Employee Overview</h1>
        {empData && empData.checked_in > 0 && (
          <span className="text-xs text-gray-400">{empData.checked_in} active</span>
        )}
      </div>

      <div className="bg-white rounded-xl border border-blue-100/60 shadow-sm">
        {loading ? (
          <div className="p-8 space-y-4">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="h-4 bg-gray-100 rounded animate-pulse" />
            ))}
          </div>
        ) : empData ? (
          <div className="overflow-x-auto">
            {headerRow1}
            {headerRow2}

            {empData.employees.map((emp, i) => {
              const ttl = emp.today_ipa + emp.today_ipd;
              const ltd = emp.yes_ipa + emp.yes_ipd;
              const pct = ttl > 0 ? Math.round(emp.today_ipa / ttl * 100) : 0;
              return (
                <div
                  key={emp.employee_code}
                  className="grid border-t border-gray-100 hover:bg-gray-50/50 transition-colors"
                  style={{ gridTemplateColumns: GRID }}
                >
                  <div className="flex items-center justify-center py-3 text-xs text-gray-400">{i + 1}</div>
                  <div className="flex items-center gap-2 py-3 text-sm font-medium text-gray-900">
                    {emp.employee_name}
                    {(() => {
                      const d = (emp.today_ipa + emp.today_ipd) - (emp.yes_ipa + emp.yes_ipd);
                      if (d === 0) return null;
                      return d > 0 ? <TrendingUp className="w-3.5 h-3.5 text-emerald-600 shrink-0" /> : <TrendingDown className="w-3.5 h-3.5 text-red-600 shrink-0" />;
                    })()}
                  </div>
                  <div className="flex items-center justify-center py-3 text-sm font-medium text-emerald-600">{emp.today_ipa || "-"}</div>
                  <div className="flex items-center justify-center py-3 text-sm font-medium text-red-600">{emp.today_ipd || "-"}</div>
                  <div className="flex items-center justify-center py-3 text-sm font-medium text-blue-600">{ttl || "-"}</div>
                  <div />
                  <div className="flex items-center justify-center py-3 text-xs text-gray-400">{emp.yes_ipa || "-"}</div>
                  <div className="flex items-center justify-center py-3 text-xs text-gray-400">{emp.yes_ipd || "-"}</div>
                  <div className="flex items-center justify-center py-3 text-xs text-gray-400">{ltd || "-"}</div>
                  <div />
                  <div className="flex items-center justify-center py-3 text-sm font-medium text-violet-600">{pct > 0 ? pct + "%" : "-"}</div>
                  <div />
                </div>
              );
            })}

            {overview && (
              <div
                className="grid border-t border-gray-200 bg-gray-50"
                style={{ gridTemplateColumns: GRID }}
              >
                <div />
                <div className="flex items-center py-3 text-sm font-semibold text-gray-900">Total</div>
                <div className="flex items-center justify-center py-3 text-sm font-semibold text-emerald-600">{overview.today.ipa || "-"}</div>
                <div className="flex items-center justify-center py-3 text-sm font-semibold text-red-600">{overview.today.ipd || "-"}</div>
                <div className="flex items-center justify-center py-3 text-sm font-semibold text-blue-600">{overview.today.ipa + overview.today.ipd || "-"}</div>
                <div />
                <div className="flex items-center justify-center py-3 text-xs font-semibold text-gray-400">{overview.yesterday.ipa || "-"}</div>
                <div className="flex items-center justify-center py-3 text-xs font-semibold text-gray-400">{overview.yesterday.ipd || "-"}</div>
                <div className="flex items-center justify-center py-3 text-xs font-semibold text-gray-400">{overview.yesterday.ipa + overview.yesterday.ipd || "-"}</div>
                <div />
                <div className="flex items-center justify-center py-3 text-sm font-semibold text-violet-600">{Math.round(overview.today_pct) > 0 ? Math.round(overview.today_pct) + "%" : "-"}</div>
                <div />
              </div>
            )}
          </div>
        ) : (
          <p className="p-8 text-sm text-gray-400 text-center">Failed to load data</p>
        )}
      </div>
    </div>
  );
}
