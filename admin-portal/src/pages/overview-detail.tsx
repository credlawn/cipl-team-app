import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, TrendingUp, TrendingDown, Building2, Home, GraduationCap } from "lucide-react";
import { pb } from "@/lib/pocketbase";
import { useOverview } from "@/hooks/use-overview";

interface EmployeeDetail {
  employee_code: string;
  employee_name: string;
  wfh?: boolean;
  designation?: string;
  is_checked_in?: boolean;
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
          if (a.is_checked_in && !b.is_checked_in) return -1;
          if (!a.is_checked_in && b.is_checked_in) return 1;
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

  // Split employees into 3 groups:
  // 1. Trainee (designation == "Trainee") - Priority 1
  // 2. WFH (wfh == true && designation != "Trainee")
  // 3. Office (wfh == false && designation != "Trainee")
  const trainees = empData?.employees.filter(
    (e) => e.designation?.toLowerCase() === "trainee"
  ) || [];

  const wfhEmployees = empData?.employees.filter(
    (e) => e.wfh && e.designation?.toLowerCase() !== "trainee"
  ) || [];

  const officeEmployees = empData?.employees.filter(
    (e) => !e.wfh && e.designation?.toLowerCase() !== "trainee"
  ) || [];

  const headerRow1 = (
    <div className="grid bg-gray-50/50" style={{ gridTemplateColumns: GRID }}>
      <div />
      <div />
      <div className="flex items-center justify-center col-span-3 text-xs font-medium text-gray-400 uppercase tracking-wide">Today</div>
      <div />
      <div className="flex items-center justify-center col-span-3 text-xs font-medium text-gray-400 uppercase tracking-wide">Yesterday</div>
      <div />
      <div className="flex items-center justify-center py-3 text-xs font-medium text-gray-400 uppercase tracking-wide">IPA %</div>
      <div />
    </div>
  );

  const headerRow2 = (
    <div className="grid border-t border-blue-100/60 bg-gray-50/50" style={{ gridTemplateColumns: GRID }}>
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

  const renderGroup = (
    title: string,
    icon: React.ReactNode,
    list: EmployeeDetail[],
    bgColor: string,
    badgeBg: string,
    badgeText: string
  ) => {
    if (list.length === 0) return null;

    const groupTodayIPA = list.reduce((acc, e) => acc + e.today_ipa, 0);
    const groupTodayIPD = list.reduce((acc, e) => acc + e.today_ipd, 0);
    const groupTodayTotal = groupTodayIPA + groupTodayIPD;

    const groupYesIPA = list.reduce((acc, e) => acc + e.yes_ipa, 0);
    const groupYesIPD = list.reduce((acc, e) => acc + e.yes_ipd, 0);
    const groupYesTotal = groupYesIPA + groupYesIPD;

    const groupPct = groupTodayTotal > 0 ? Math.round((groupTodayIPA / groupTodayTotal) * 100) : 0;

    return (
      <div className="border-t border-gray-200">
        {/* Category Section Header */}
        <div className={`px-4 py-2.5 flex items-center justify-between ${bgColor} border-b border-gray-200/80`}>
          <div className="flex items-center gap-2">
            {icon}
            <span className="font-bold text-sm text-gray-800 tracking-tight">{title}</span>
            <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${badgeBg} ${badgeText}`}>
              {list.length}
            </span>
          </div>
        </div>

        {/* Group Rows */}
        {list.map((emp, i) => {
          const ttl = emp.today_ipa + emp.today_ipd;
          const ltd = emp.yes_ipa + emp.yes_ipd;
          const pct = ttl > 0 ? Math.round((emp.today_ipa / ttl) * 100) : 0;
          return (
            <div
              key={emp.employee_code}
              className="grid border-t border-gray-100 hover:bg-gray-50/60 transition-colors"
              style={{ gridTemplateColumns: GRID }}
            >
              <div className="flex items-center justify-center py-3 text-xs text-gray-400">{i + 1}</div>
              <div className="flex items-center gap-2 py-3 text-sm font-medium text-gray-900">
                <span>{emp.employee_name}</span>
                {!emp.is_checked_in && (
                  <span className="px-1.5 py-0.5 text-[10px] font-bold bg-red-100 text-red-600 rounded border border-red-200/80 leading-none shrink-0" title="Absent Today">
                    A
                  </span>
                )}
                {(() => {
                  const d = (emp.today_ipa + emp.today_ipd) - (emp.yes_ipa + emp.yes_ipd);
                  if (d === 0) return null;
                  return d > 0 ? (
                    <TrendingUp className="w-3.5 h-3.5 text-emerald-600 shrink-0" />
                  ) : (
                    <TrendingDown className="w-3.5 h-3.5 text-red-600 shrink-0" />
                  );
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

        {/* Group Subtotal Row */}
        <div
          className="grid border-t border-gray-200 bg-gray-50/70 font-semibold text-xs text-gray-700"
          style={{ gridTemplateColumns: GRID }}
        >
          <div />
          <div className="flex items-center py-2.5 font-bold text-gray-800">{title} Subtotal</div>
          <div className="flex items-center justify-center py-2.5 font-bold text-emerald-700">{groupTodayIPA || "-"}</div>
          <div className="flex items-center justify-center py-2.5 font-bold text-red-700">{groupTodayIPD || "-"}</div>
          <div className="flex items-center justify-center py-2.5 font-bold text-blue-700">{groupTodayTotal || "-"}</div>
          <div />
          <div className="flex items-center justify-center py-2.5 text-gray-500">{groupYesIPA || "-"}</div>
          <div className="flex items-center justify-center py-2.5 text-gray-500">{groupYesIPD || "-"}</div>
          <div className="flex items-center justify-center py-2.5 text-gray-500">{groupYesTotal || "-"}</div>
          <div />
          <div className="flex items-center justify-center py-2.5 font-bold text-violet-700">{groupPct > 0 ? groupPct + "%" : "-"}</div>
          <div />
        </div>
      </div>
    );
  };

  return (
    <div className="bg-white rounded-xl border border-blue-100/60 shadow-sm overflow-hidden">
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

          {/* Group 1: Office Employees */}
          {renderGroup(
            "Office Employees",
            <Building2 className="w-4 h-4 text-blue-600" />,
            officeEmployees,
            "bg-blue-50/60",
            "bg-blue-100",
            "text-blue-700"
          )}

          {/* Group 2: WFH Employees */}
          {renderGroup(
            "WFH Employees",
            <Home className="w-4 h-4 text-emerald-600" />,
            wfhEmployees,
            "bg-emerald-50/60",
            "bg-emerald-100",
            "text-emerald-700"
          )}

          {/* Group 3: Trainees */}
          {renderGroup(
            "Trainee Employees",
            <GraduationCap className="w-4 h-4 text-amber-600" />,
            trainees,
            "bg-amber-50/60",
            "bg-amber-100",
            "text-amber-700"
          )}

          {/* Overall Grand Total Row */}
          {overview && (
            <div
              className="grid border-t-2 border-gray-300 bg-gray-100/90"
              style={{ gridTemplateColumns: GRID }}
            >
              <div />
              <div className="flex items-center gap-2 py-3 text-sm font-bold text-gray-900">
                <span>Grand Total</span>
                <span className="text-xs px-2 py-0.5 rounded-full font-medium bg-gray-200 text-gray-800">
                  {empData?.employees.length || 0}
                </span>
              </div>
              <div className="flex items-center justify-center py-3 text-sm font-bold text-emerald-700">{overview.today.ipa || "-"}</div>
              <div className="flex items-center justify-center py-3 text-sm font-bold text-red-700">{overview.today.ipd || "-"}</div>
              <div className="flex items-center justify-center py-3 text-sm font-bold text-blue-700">{overview.today.ipa + overview.today.ipd || "-"}</div>
              <div />
              <div className="flex items-center justify-center py-3 text-xs font-bold text-gray-600">{overview.yesterday.ipa || "-"}</div>
              <div className="flex items-center justify-center py-3 text-xs font-bold text-gray-600">{overview.yesterday.ipd || "-"}</div>
              <div className="flex items-center justify-center py-3 text-xs font-bold text-gray-600">{overview.yesterday.ipa + overview.yesterday.ipd || "-"}</div>
              <div />
              <div className="flex items-center justify-center py-3 text-sm font-bold text-violet-700">{Math.round(overview.today_pct) > 0 ? Math.round(overview.today_pct) + "%" : "-"}</div>
              <div />
            </div>
          )}
        </div>
      ) : (
        <p className="p-8 text-sm text-gray-400 text-center">Failed to load data</p>
      )}
    </div>
  );
}
